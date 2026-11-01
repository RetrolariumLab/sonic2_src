"""Shared manifest loading, safe paths, and pinned build tools."""

from pathlib import Path
import hashlib
import json
import os
import platform
import subprocess

ROOT = Path(__file__).resolve().parents[2]


def load(name, root=ROOT):
    return json.loads((root / name).read_text(encoding="utf-8"))


def project_path(name, root=ROOT):
    path = root / name
    if not path.resolve().is_relative_to(root.resolve()):
        raise ValueError("Path leaves the project: " + str(name))
    return path


def atomic_write(path, data):
    path.parent.mkdir(parents=True, exist_ok=True)
    temporary = path.with_name(path.name + ".tmp")
    temporary.write_bytes(data)
    temporary.replace(path)


def profiles(root=ROOT):
    return load("config/revision_profiles.json", root)


def profile(revision=None, root=ROOT):
    config = profiles(root)
    revision = revision or config["default"]
    for item in config["profiles"]:
        if item["id"] == revision:
            return item
    raise ValueError("Unknown revision: " + revision)


def image(revision=None, root=ROOT):
    selected = profile(revision, root)
    return next(item for item in load("assets/manifest.json", root)["images"] if item["id"] == selected["image"])


def reference(revision=None, root=ROOT):
    item = image(revision, root)
    path = project_path(item["file"], root)
    if not path.is_file():
        raise ValueError(f"Missing legal input {item['id']}: {item['file']}; run make split with your own ROMs")
    data = path.read_bytes()
    if (
        len(data) != item["size"]
        or hashlib.sha1(data).hexdigest() != item["sha1"]
        or hashlib.sha256(data).hexdigest() != item["sha256"]
    ):
        raise ValueError("Legal input does not match its size and hashes: " + item["id"])
    return data


def host_id():
    if platform.machine().lower() not in {"amd64", "x86_64"}:
        raise ValueError("This host architecture has no pinned assembler")
    return ("windows" if os.name == "nt" else "linux") + "-x86_64"


def toolchain(root=ROOT):
    config = load("config/toolchain.json", root)
    host = host_id()
    from scripts.build.external_as import assembler as external_assembler

    assembler = external_assembler(config["assembler"], root)
    status = json.loads(subprocess.check_output(["rltool", "build-tools", "status"], text=True))
    if status["release"] != config["kit"]["release"]:
        raise ValueError("Kit build-tool release differs from config/toolchain.json")
    p2bin = Path(subprocess.check_output(["rltool", "build-tools", "path", "megadrive", "p2bin"], text=True).strip())
    if hashlib.sha256(p2bin.read_bytes()).hexdigest() != config["p2bin"]["hosts"][host]["sha256"]:
        raise ValueError("p2bin hash mismatch")
    return assembler, p2bin
