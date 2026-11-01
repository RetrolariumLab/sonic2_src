"""Build and verify original Sonic 2 revisions from user-extracted data."""

import argparse
import hashlib
from pathlib import Path
import re
import subprocess
from scripts.build.assets import check
from scripts.build.project import ROOT, atomic_write, image, load, profile, profiles, project_path, reference, toolchain


def run(args, root=ROOT, log=None):
    result = subprocess.run(
        [str(arg) for arg in args], cwd=root, stdout=subprocess.PIPE, stderr=subprocess.STDOUT, timeout=180
    )
    if log is not None:
        atomic_write(log, result.stdout)
    return result


def assemble(entry, assembler, root=ROOT, header=False):
    object_file = entry.with_suffix(".p")
    object_file.unlink(missing_ok=True)
    log_file = entry.with_suffix(".log")
    log_file.unlink(missing_ok=True)
    args = [assembler, "-xx", "-n", "-q", "-A", "-L", "-U", "-E", "-i", "."]
    if header:
        args.append("-c")
    args.append(entry.relative_to(root).as_posix())
    result = run(args, root, entry.with_suffix(".stdout.log"))
    diagnostics = log_file.read_text(errors="replace") if log_file.exists() else ""
    if not object_file.exists() or re.search(r"error #[0-9]+", diagnostics):
        raise ValueError(
            "Assembly failed: "
            + entry.relative_to(root).as_posix()
            + "\n"
            + diagnostics
            + result.stdout.decode(errors="replace")
        )
    # Upstream's intentional odd-address crash instruction emits warning #180
    # in REV00. AS returns 1 for that warning even though it produced the object.
    if result.returncode and (result.returncode != 1 or "warning #180" not in diagnostics):
        raise ValueError("Unexpected assembler exit: " + str(result.returncode))
    return object_file


def prepare_audio(assembler=None, p2bin=None, root=ROOT):
    """Generate wrappers; preservation builds never reassemble music or effects."""
    from scripts.build.audio_data import prepare

    prepare(root)


def patch_image(data, header, logical_size=None):
    values = {name: int(value, 16) for name, value in re.findall(r"\b(\w+)\s+(0x[0-9a-fA-F]+)", header)}
    if not {"comp_z80_size", "movewZ80CompSize"} <= values.keys():
        raise ValueError("Missing p2bin sound-driver patch symbols")
    data = bytearray(data)
    at = values["movewZ80CompSize"] + 2
    if at < 0x200 or at + 2 > len(data) or not 0 < values["comp_z80_size"] < 65536:
        raise ValueError("Sound-driver patch lies outside the image or its capacity")
    if len(data) % 2:
        raise ValueError("The Mega Drive image must have an even size")
    data[at : at + 2] = values["comp_z80_size"].to_bytes(2, "big")
    extent = len(data) if logical_size is None else logical_size
    if extent < 0x200 or extent > len(data) or extent % 2:
        raise ValueError("Invalid logical checksum extent")
    data[0x1A4:0x1A8] = (extent - 1).to_bytes(4, "big")
    checksum = sum(int.from_bytes(data[i : i + 2], "big") for i in range(0x200, extent, 2)) & 65535
    data[0x18E:0x190] = checksum.to_bytes(2, "big")
    return bytes(data)


def assemble_image(entry, output, assembler, p2bin, root=ROOT, logical_size=None):
    """Own the shared AS, p2bin and post-patch pipeline for every image kind."""
    directory = output.parent
    obj = assemble(entry, assembler, root, header=True)
    output.unlink(missing_ok=True)
    header = entry.with_suffix(".h")
    result = run(
        [
            p2bin,
            "-p=0",
            "-z=0,saxman-bugged,Size_of_Snd_driver_guess,after",
            obj.relative_to(root),
            output.relative_to(root),
            header.relative_to(root),
        ],
        root,
        directory / "p2bin.log",
    )
    if result.returncode or not output.exists():
        raise ValueError("Main p2bin failed\n" + result.stdout.decode(errors="replace"))
    atomic_write(output, patch_image(output.read_bytes(), header.read_text(), logical_size))
    return output


def build(revision=None, root=ROOT):
    selected = profile(revision, root)
    check(root)
    assembler, p2bin = toolchain(root)
    prepare_audio(assembler, p2bin, root)
    directory = project_path(selected["output"], root).parent
    entry = directory / "main.asm"
    wrapper = "".join(f"{name} = {value}\n" for name, value in selected["defines"].items())
    wrapper += '\tinclude "' + profiles(root)["entry"] + '"\n'
    atomic_write(entry, wrapper.encode())
    output = project_path(selected["output"], root)
    assemble_image(entry, output, assembler, p2bin, root)
    print("[OK] Built " + selected["id"] + ": " + selected["output"])
    return output


def verify(revision=None, root=ROOT):
    selected = profile(revision, root)
    expected = reference(selected["id"], root)
    output = build(selected["id"], root)
    actual = output.read_bytes()
    if len(actual) != len(expected):
        raise ValueError(f"{selected['id']}: size differs, {len(actual)} != {len(expected)}")
    if actual != expected:
        mismatch = next(i for i, (a, b) in enumerate(zip(actual, expected)) if a != b)
        raise ValueError(
            f"{selected['id']}: first byte mismatch at {mismatch:#x}: {actual[mismatch]:02x} != {expected[mismatch]:02x}"
        )
    record = image(selected["id"], root)
    if hashlib.sha1(actual).hexdigest() != record["sha1"] or hashlib.sha256(actual).hexdigest() != record["sha256"]:
        raise ValueError("Output hash differs from its input contract")
    report = {
        "profile": selected["id"],
        "byte_identical": True,
        "size": len(actual),
        "sha1": record["sha1"],
        "sha256": record["sha256"],
    }
    import json

    atomic_write(output.parent / "identity.json", (json.dumps(report, indent=2) + "\n").encode())
    print("[OK] " + selected["id"] + ": every byte matches the user image")
    return report


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("action", choices=["build", "verify", "verify-all"])
    parser.add_argument("--revision")
    args = parser.parse_args()
    try:
        if args.action == "verify-all":
            for selected in profiles()["profiles"]:
                verify(selected["id"])
        else:
            (build if args.action == "build" else verify)(args.revision)
    except (OSError, ValueError, subprocess.SubprocessError) as exc:
        raise SystemExit(str(exc)) from exc
