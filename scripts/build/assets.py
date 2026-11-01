"""Import verified user images and delegate extraction to Retrolarium Kit."""

import argparse
import hashlib
from pathlib import Path
import shutil
import subprocess
from scripts.build.project import ROOT, load, project_path, reference, profiles
from scripts.build.audio_data import derive, check_derived


def import_images(directory, root=ROOT):
    images = load("assets/manifest.json", root)["images"]
    by_size = {item["size"] for item in images}
    wanted = {item["sha1"]: item for item in images}
    found = set()
    for source in sorted(Path(directory).rglob("*")):
        if not source.is_file() or source.stat().st_size not in by_size:
            continue
        data = source.read_bytes()
        record = wanted.get(hashlib.sha1(data).hexdigest())
        if record is None:
            continue
        if hashlib.sha256(data).hexdigest() != record["sha256"]:
            raise ValueError("Input SHA-256 mismatch")
        target = project_path(record["file"], root)
        target.parent.mkdir(parents=True, exist_ok=True)
        if source.resolve() != target.resolve():
            shutil.copyfile(source, target)
        found.add(record["id"])
    return found


def split(directory=None, root=ROOT):
    if directory:
        found = import_images(directory, root)
        print("Imported verified inputs: " + ", ".join(sorted(found)))
    for item in profiles(root)["profiles"]:
        reference(item["id"], root)
    subprocess.run(
        ["rltool", "assets", "split", "--root", str(root), "--manifest", str(root / "assets/manifest.json")], check=True
    )
    derive(root)


def check(root=ROOT):
    subprocess.run(
        ["rltool", "assets", "check", "--root", str(root), "--manifest", str(root / "assets/manifest.json"), "--exact"],
        check=True,
    )
    check_derived(root)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("action", choices=["split", "check"])
    parser.add_argument("--rom-dir", type=Path)
    args = parser.parse_args()
    try:
        split(args.rom_dir) if args.action == "split" else check()
    except (OSError, ValueError, subprocess.CalledProcessError) as exc:
        raise SystemExit(str(exc)) from exc
