"""Check controller-driven routes against original-ROM RAM observations."""

import argparse
import hashlib
import json
import re
from scripts.build.listing import symbols
from scripts.build.project import ROOT, atomic_write, image, load, profiles, project_path, reference
from scripts.runtime.movies import invoke, relocated_input, resolve, runtime_lock, stage_emulator


def movie_runs(text, frames):
    lines = text.splitlines()
    if not lines or lines[0] != "# retrolarium movie 1" or lines.count("---") != 1:
        raise ValueError("Invalid extended controller movie")
    split = lines.index("---")
    header = {}
    for line in lines[1:split]:
        key, space, value = line.partition(" ")
        if not space or key in header:
            raise ValueError("Invalid or duplicate extended movie header")
        header[key] = value
    if header != {"platform": "megadrive", "source": "mame", "frames": str(frames), "offset": "0"}:
        raise ValueError("Extended movie must start from unmodified power-on state")
    runs = []
    for line in lines[split + 1 :]:
        match = re.fullmatch(r"([1-9][0-9]*) ([0-9A-F]{2}) ([0-9A-F]{2})", line)
        if not match:
            raise ValueError("Extended movie has an unsupported controller record")
        runs.append((int(match[1]), int(match[2], 16), int(match[3], 16)))
    if sum(row[0] for row in runs) != frames or not any(row[1] for row in runs):
        raise ValueError("Extended route lacks complete controller input")
    return runs


def reached(expected, case):
    observations = sorted((int(frame), row) for frame, row in expected.items())
    previous = -1
    for state in case["required_states"]:
        matches = [
            frame
            for frame, row in observations
            if frame > previous
            and frame >= state["after"]
            and all(row.get(name) == value for name, value in state["values"].items())
        ]
        if not matches:
            raise ValueError("Extended movie did not reach its declared state: " + case["id"])
        previous = min(matches)
    for field in case["motion_cells"]:
        if len({row[field] for frame, row in observations if frame >= case["motion_after"]}) < 2:
            raise ValueError("Extended movie did not exercise movement: " + field)


def check_spec(spec, case, config, table, path, revision, root=ROOT, complete=True):
    if spec.get("schema") != "retrolarium.movie-check" or spec.get("schema_version") != 1:
        raise ValueError("Unsupported extended golden schema")
    if spec.get("source_profile") != revision or spec.get("machine") != config["machine"] or spec.get("offset", 0) != 0:
        raise ValueError("Extended golden belongs to another profile or execution mode")
    frames = case["checkpoints"]
    if (
        not frames
        or frames != sorted(set(frames))
        or any(type(value) is not int or not 0 < value <= case["frames"] for value in frames)
    ):
        raise ValueError("Invalid extended checkpoint set")
    if spec.get("frames") != frames or set(spec.get("cells", {})) != set(config["watches"]):
        raise ValueError("Extended golden omits checkpoints or RAM watches")
    movie = project_path(path.parent / spec["movie"], root)
    text = movie.read_text()
    movie_runs(text, case["frames"])
    if hashlib.sha256(movie.read_bytes()).hexdigest() != case["movie_sha256"]:
        raise ValueError("Extended controller route changed after review")
    for name, watch in config["watches"].items():
        cell = spec["cells"][name]
        if (
            cell.get("symbol") != watch["symbol"]
            or cell.get("length") != watch["length"]
            or int(cell["address"], 0) != resolve(watch["symbol"], table)
            or cell.get("tolerance", 0) != 0
            or cell.get("space", "program") != "program"
            or cell.get("endian", "big") != "big"
        ):
            raise ValueError("Extended RAM watch differs from its source contract")
    if not complete:
        return
    expected = spec.get("expected", {})
    if set(expected) != {str(frame) for frame in frames}:
        raise ValueError("Extended golden has incomplete checkpoint coverage")
    for values in expected.values():
        if set(values) != set(config["watches"]):
            raise ValueError("Extended golden has incomplete RAM-cell coverage")
        for name, value in values.items():
            if not isinstance(value, str) or not re.fullmatch(
                r"[0-9a-f]{" + str(config["watches"][name]["length"] * 2) + "}", value
            ):
                raise ValueError("Extended golden has an invalid RAM value")
    reached(expected, case)


def execute(action="check", root=ROOT):
    if action not in {"golden", "check"}:
        raise ValueError("Unknown extended runtime action")
    config = load("config/runtime_extended.json", root)
    base = load("config/runtime.json", root)
    destination = root / "build/runtime/extended-report.json"
    if action == "check":
        destination.unlink(missing_ok=True)
    results, outputs = [], []
    with runtime_lock(root, base["limits"]):
        emulator = stage_emulator(base, root)
        for selected in profiles(root)["profiles"]:
            revision = selected["id"]
            reference(revision, root)
            table = symbols((root / selected["output"]).parent / "main.lst")
            for case in config["cases"]:
                path = project_path(case["checks"][revision], root)
                spec = json.loads(path.read_text())
                check_spec(
                    spec,
                    case,
                    base | {"watches": config["watches"]},
                    table,
                    path,
                    revision,
                    root,
                    complete=action != "golden",
                )
                provenance = {
                    "original_sha256": image(revision, root)["sha256"],
                    "emulator_sha256": base["emulator"]["sha256"],
                    "movie_sha256": case["movie_sha256"],
                }
                if action == "check" and spec.get("provenance") != provenance:
                    raise ValueError("Extended golden lacks its verified original-ROM provenance")
                variants = ["original"] if action == "golden" else ["canonical", "relocated"]
                for variant in variants:
                    rom = (
                        root / image(revision, root)["file"]
                        if action == "golden"
                        else (root / selected["output"] if variant == "canonical" else relocated_input(revision, root))
                    )
                    log = root / "build/runtime/extended" / (revision + "-" + case["id"] + "-" + variant + ".log")
                    output = invoke(action, path, rom, emulator, base, log, root)
                    if action == "golden":
                        spec = json.loads(path.read_text())
                        check_spec(spec, case, base | {"watches": config["watches"]}, table, path, revision, root)
                        spec["provenance"] = provenance
                        atomic_write(path, (json.dumps(spec, indent=2) + "\n").encode())
                    elif not re.search(
                        r"\b"
                        + str(len(case["checkpoints"]) * len(config["watches"]))
                        + r" cell\(s\) match the original after "
                        + str(len(case["checkpoints"]))
                        + r" frame\(s\)",
                        output,
                    ):
                        raise ValueError("Extended movie runner omitted required comparisons")
                    outputs.extend([log.relative_to(root).as_posix()])
                    results.append(
                        {
                            "profile": revision,
                            "case": case["id"],
                            "variant": variant,
                            "rom_sha256": hashlib.sha256(rom.read_bytes()).hexdigest(),
                            "golden_sha256": hashlib.sha256(path.read_bytes()).hexdigest(),
                        }
                    )
    if action == "check":
        from scripts.validation.evidence import output_hashes, public_hash

        report = {
            "gate": "runtime-extended-check",
            "passed": True,
            "public_sha256": public_hash(root),
            "runs": results,
            "evidence": output_hashes(outputs, root),
        }
        atomic_write(destination, (json.dumps(report, indent=2) + "\n").encode())
        return report


def audit(root=ROOT):
    from scripts.validation.evidence import validate

    report = load("build/runtime/extended-report.json", root)
    validate(report, root)
    cases = load("config/runtime_extended.json", root)["cases"]
    expected = {
        (profile["id"], case["id"], variant)
        for profile in profiles(root)["profiles"]
        for case in cases
        for variant in ("canonical", "relocated")
    }
    rows = report.get("runs", [])
    if len(rows) != len(expected) or {(row["profile"], row["case"], row["variant"]) for row in rows} != expected:
        raise ValueError("Extended runtime evidence omits a scenario or ROM variant")
    for row in rows:
        selected = next(profile for profile in profiles(root)["profiles"] if profile["id"] == row["profile"])
        rom = root / selected["output"] if row["variant"] == "canonical" else relocated_input(row["profile"], root)
        case = next(case for case in cases if case["id"] == row["case"])
        golden = project_path(case["checks"][row["profile"]], root)
        if (
            row["rom_sha256"] != hashlib.sha256(rom.read_bytes()).hexdigest()
            or row["golden_sha256"] != hashlib.sha256(golden.read_bytes()).hexdigest()
        ):
            raise ValueError("Extended runtime ROM or golden changed after its run")
    return report


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("action", choices=["golden", "check"], default="check", nargs="?")
    args = parser.parse_args()
    try:
        execute(args.action)
    except (OSError, ValueError, KeyError) as exc:
        raise SystemExit(str(exc)) from exc
