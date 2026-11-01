"""Validate complete original RAM goldens and run MAME jobs one at a time."""

import argparse
from contextlib import contextmanager
import hashlib
import json
import os
from pathlib import Path
import re
import shutil
import subprocess
import time
from scripts.build.listing import symbols
from scripts.build.project import ROOT, atomic_write, host_id, image, load, profile, project_path, reference


def resolve(expression, table):
    if not re.fullmatch(r"[A-Za-z_][\w.]*(?:\+[A-Za-z_][\w.]*)*", expression):
        raise ValueError("Unsupported RAM symbol expression: " + expression)
    return sum(table[part] for part in expression.split("+")) & 0xFFFFFF


def frame_numbers(config):
    item = config["frame_range"]
    if (
        not all(isinstance(item[k], int) and item[k] > 0 for k in ["first", "last", "step"])
        or item["last"] < item["first"]
    ):
        raise ValueError("Invalid runtime frame range")
    return list(range(item["first"], item["last"] + 1, item["step"]))


def validate_check(spec, config, table, path, complete=True, root=ROOT):
    frames = frame_numbers(config)
    if spec.get("schema") != "retrolarium.movie-check" or spec.get("schema_version") != 1:
        raise ValueError("Unsupported movie-check schema")
    if spec.get("offset", 0) != 0:
        raise ValueError("Checkpoint alignment offsets are forbidden")
    if spec.get("machine") != config["machine"] or spec.get("frames") != frames:
        raise ValueError("Runtime machine or checkpoint set differs from its contract")
    cells = spec.get("cells", {})
    if set(cells) != set(config["watches"]):
        raise ValueError("Missing or unexpected RAM cells")
    for name, watch in config["watches"].items():
        cell = cells[name]
        if cell.get("symbol") != watch["symbol"] or cell.get("length") != watch["length"]:
            raise ValueError("RAM watch differs from its source contract: " + name)
        if int(cell["address"], 0) != resolve(watch["symbol"], table):
            raise ValueError("RAM address differs from its AS symbol: " + name)
        if (
            cell.get("space", "program") != "program"
            or cell.get("tolerance", 0) != 0
            or cell.get("endian", "big") != "big"
        ):
            raise ValueError("Runtime comparisons must use exact big-endian program RAM")
    movie_path = project_path((path.parent / spec["movie"]).relative_to(root).as_posix(), root)
    lines = movie_path.read_text().splitlines()
    if not lines or lines[0] != "# retrolarium movie 1" or lines.count("---") != 1:
        raise ValueError("Invalid attract movie container")
    separator = lines.index("---")
    header = {}
    for line in lines[1:separator]:
        key, space, value = line.partition(" ")
        if not space or key in header:
            raise ValueError("Malformed or duplicate movie header")
        header[key] = value
    if not set(header).issubset(
        {"platform", "source", "frames", "offset", "title", "kind", "author", "description", "rom"}
    ):
        raise ValueError("Attract movie contains unsupported power-on or execution settings")
    required = {"platform": "megadrive", "source": "mame", "offset": "0", "frames": str(frames[-1])}
    if any(header.get(key) != value for key, value in required.items()):
        raise ValueError("Movie is not the complete unaligned power-on attract run")
    # This contract deliberately accepts only one zero-input run. Kit remains
    # the general movie parser and execution engine.
    if lines[separator + 1 :] != [str(frames[-1]) + " 00 00"]:
        raise ValueError("Attract movie must contain exactly one complete zero-input run")
    if not complete:
        return {}
    expected = spec.get("expected", {})
    if set(expected) != {str(frame) for frame in frames}:
        raise ValueError("Incomplete golden checkpoint coverage")
    for row in expected.values():
        if set(row) != set(cells):
            raise ValueError("Incomplete golden RAM-cell coverage")
        for name, value in row.items():
            if not isinstance(value, str) or not re.fullmatch(
                r"[0-9a-f]{" + str(cells[name]["length"] * 2) + "}", value
            ):
                raise ValueError("Golden RAM value has the wrong byte width: " + name)
    covered = {int(row["zone"], 16) for row in expected.values()}
    if not {table[name] for name in config["required_zone_symbols"]}.issubset(covered):
        raise ValueError("Golden omits a required attract zone")
    if config["require_two_player"] and not any(
        int(row["two_player"], 16) and row["game_mode"] in {"08", "88"} for row in expected.values()
    ):
        raise ValueError("Golden omits a running two-player checkpoint")
    return {
        "checkpoints": len(frames),
        "cells": len(cells),
        "comparisons": len(frames) * len(cells),
        "modes": sorted({row["game_mode"] for row in expected.values()}),
        "zone_two_player_pairs": sorted({(row["zone"], row["two_player"]) for row in expected.values()}),
    }


def active_emulators():
    if os.name != "nt":
        raise ValueError("The pinned runtime host is Windows x86-64")
    command = "@(Get-CimInstance Win32_Process -Filter \"Name='consoles.exe'\" | Select-Object ProcessId,ExecutablePath) | ConvertTo-Json -Compress"
    raw = subprocess.check_output(
        ["powershell.exe", "-NoProfile", "-NonInteractive", "-Command", command], text=True
    ).strip()
    values = json.loads(raw) if raw else []
    return values if isinstance(values, list) else [values]


def owned_emulators(executable):
    return [
        item
        for item in active_emulators()
        if item.get("ExecutablePath") and Path(item["ExecutablePath"]).resolve() == executable.resolve()
    ]


def stop_owned(executable):
    for item in owned_emulators(executable):
        subprocess.run(
            [
                "powershell.exe",
                "-NoProfile",
                "-NonInteractive",
                "-Command",
                "Stop-Process -Id " + str(int(item["ProcessId"])) + " -ErrorAction SilentlyContinue",
            ],
            check=True,
        )


@contextmanager
def runtime_lock(root, limits):
    folder = root / "build/runtime"
    folder.mkdir(parents=True, exist_ok=True)
    deadline = time.monotonic() + limits["queue_seconds"]
    with (folder / "runner.lock").open("a+b") as handle:
        if handle.seek(0, 2) == 0:
            handle.write(b"0")
            handle.flush()
        announced = False
        while True:
            try:
                import msvcrt

                handle.seek(0)
                msvcrt.locking(handle.fileno(), msvcrt.LK_NBLCK, 1)
                break
            except OSError:
                if time.monotonic() >= deadline:
                    raise ValueError("Timed out waiting for this project's runtime lock")
                if not announced:
                    print("[WAIT] A project runtime job is active", flush=True)
                    announced = True
                time.sleep(limits["poll_seconds"])
        try:
            yield
        finally:
            handle.seek(0)
            msvcrt.locking(handle.fileno(), msvcrt.LK_UNLCK, 1)


def wait_for_machine(limits):
    deadline = time.monotonic() + limits["queue_seconds"]
    announced = False
    while active_emulators():
        if time.monotonic() >= deadline:
            raise ValueError("Timed out waiting for the global MAME slot")
        if not announced:
            print("[WAIT] MAME is active; the next run remains queued", flush=True)
            announced = True
        time.sleep(limits["poll_seconds"])


def stage_emulator(config, root=ROOT):
    if host_id() != config["host"]:
        raise ValueError("This host has no accepted runtime pin")
    source = Path(subprocess.check_output(["rltool", "movie", "mame"], text=True).strip())
    expected = config["emulator"]
    if source.name.lower() != "consoles.exe" or hashlib.sha256(source.read_bytes()).hexdigest() != expected["sha256"]:
        raise ValueError("Registered MAME executable differs from its pinned identity")
    if expected["copied_dlls"] or list(source.parent.glob("*.dll")):
        raise ValueError("The current runtime pin expects a standalone executable without DLLs")
    folder = root / "build/runtime/mame"
    folder.mkdir(parents=True, exist_ok=True)
    target = folder / source.name
    if not target.is_file() or hashlib.sha256(target.read_bytes()).hexdigest() != expected["sha256"]:
        shutil.copyfile(source, target)
    return target


def terminate_invocation(process, executable):
    """Stop only this launcher tree and this project's staged emulator."""
    if os.name == "nt" and process.poll() is None:
        subprocess.run(
            ["taskkill.exe", "/PID", str(process.pid), "/T", "/F"],
            stdout=subprocess.PIPE,
            stderr=subprocess.STDOUT,
            timeout=15,
            check=False,
        )
    try:
        stop_owned(executable)
    finally:
        if process.poll() is None:
            process.kill()


def invoke(action, check, rom, executable, config, log, root=ROOT):
    wait_for_machine(config["limits"])
    temporary = root / "build/runtime/tmp"
    temporary.mkdir(parents=True, exist_ok=True)
    environment = dict(os.environ, TEMP=str(temporary), TMP=str(temporary))
    command = ["rltool", "movie", action, str(check), "--rom", str(rom), "--mame", str(executable)]
    print("[RUN] " + action + " " + check.name, flush=True)
    process = subprocess.Popen(command, cwd=root, env=environment, stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
    try:
        output, _ = process.communicate(timeout=config["limits"]["timeout_seconds"])
    except (subprocess.TimeoutExpired, KeyboardInterrupt):
        terminate_invocation(process, executable)
        try:
            output, _ = process.communicate(timeout=10)
        except subprocess.TimeoutExpired as exc:
            atomic_write(log, exc.output or b"")
            raise ValueError("Owned launcher pipes did not close after cleanup") from exc
        atomic_write(log, output)
        raise ValueError("Movie run interrupted or timed out; owned invocation processes were stopped")
    finally:
        leftovers = owned_emulators(executable)
        if leftovers:
            stop_owned(executable)
    atomic_write(log, output)
    if leftovers:
        raise ValueError("An owned emulator remained after the movie command")
    if process.returncode:
        raise ValueError(output.decode(errors="replace")[-6000:])
    print(output.decode(errors="replace").strip(), flush=True)
    return output.decode(errors="replace")


def relocated_input(revision, root=ROOT):
    folder = root / "build/relocated" / revision
    report = json.loads((folder / "report.json").read_text())
    path = folder / "sonic2.bin"
    if report["profile"] != revision or report["sha256"] != hashlib.sha256(path.read_bytes()).hexdigest():
        raise ValueError("Relocated image does not match its report")
    if report["logical_size"] != image(revision, root)["size"]:
        raise ValueError("Relocation checksum extent differs from the original")
    if (
        report.get("config_sha256")
        != hashlib.sha256((root / "config/reconstruction/relocation.json").read_bytes()).hexdigest()
    ):
        raise ValueError("Relocation configuration changed; rebuild the probe")
    for name, expected in report["source_hashes"].items():
        if hashlib.sha256(project_path(name, root).read_bytes()).hexdigest() != expected:
            raise ValueError("Source changed; rebuild the relocation probe: " + name)
    return path


def execute(action, revision=None, root=ROOT):
    config = load("config/runtime.json", root)
    if host_id() != config["host"]:
        raise ValueError("This host has no accepted runtime pin")
    chosen = config["scenarios"]
    if revision:
        profile(revision, root)
        chosen = [item for item in chosen if item["profile"] == revision]
    if not chosen:
        raise ValueError("No runtime scenario for the selected profile")
    reports = []
    with runtime_lock(root, config["limits"]):
        executable = stage_emulator(config, root)
        for item in chosen:
            revision = item["profile"]
            reference(revision, root)
            path = project_path(item["check"], root)
            selected = profile(revision, root)
            table = symbols((root / selected["output"]).parent / "main.lst")
            spec = json.loads(path.read_text())
            if spec.get("source_profile") != revision:
                raise ValueError("Golden belongs to another original profile")
            coverage = validate_check(spec, config, table, path, complete=action != "golden", root=root)
            rom = root / image(revision, root)["file"] if action == "golden" else relocated_input(revision, root)
            log = root / "build/runtime" / (revision + "-" + action + ".log")
            output = invoke(action, path, rom, executable, config, log, root)
            if action == "golden":
                coverage = validate_check(json.loads(path.read_text()), config, table, path, root=root)
            elif not re.search(
                r"\b"
                + str(coverage["comparisons"])
                + r" cell\(s\) match the original after "
                + str(coverage["checkpoints"])
                + r" frame\(s\)",
                output,
            ):
                raise ValueError("Movie runner did not report the full required comparison count")
            reports.append(
                {
                    "profile": revision,
                    "action": action,
                    "rom_sha256": hashlib.sha256(rom.read_bytes()).hexdigest(),
                    "emulator_sha256": config["emulator"]["sha256"],
                    "golden_sha256": hashlib.sha256(path.read_bytes()).hexdigest(),
                    **coverage,
                }
            )
        atomic_write(
            root / "build/runtime" / (action + "-report.json"), (json.dumps(reports, indent=2) + "\n").encode()
        )
    return reports


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("action", choices=["golden", "check"])
    parser.add_argument("--revision")
    args = parser.parse_args()
    try:
        execute(args.action, args.revision)
    except (OSError, ValueError, subprocess.SubprocessError) as exc:
        raise SystemExit(str(exc)) from exc


if __name__ == "__main__":
    main()
