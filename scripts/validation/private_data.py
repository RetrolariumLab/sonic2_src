"""Reject private payloads and unapproved binaries in the tree and all refs."""

import hashlib
import io
import re
import subprocess
from pathlib import PurePosixPath
from scripts.build.project import ROOT, load

FORBIDDEN_EXTENSIONS = {
    ".bin",
    ".gen",
    ".rom",
    ".smd",
    ".wav",
    ".pcx",
    ".png",
    ".jpg",
    ".zip",
    ".unc",
    ".kos",
    ".nem",
    ".eni",
    ".dpcm",
    ".pcm",
    ".sax",
    ".p",
    ".lst",
}
FORBIDDEN_PREFIXES = (
    "data/",
    "build/",
    "SonLVL INI Files/",
    "Utility Project Files/",
    "sound/music/",
    "sound/sfx/",
    "sound/_smps2asm_inc.asm",
)


def contracts(root=ROOT):
    manifest = load("assets/manifest.json", root)
    hashes = {item["sha1"] for item in manifest["assets"] + manifest["images"] if item["size"] > 0}
    audio = root / "config/audio.json"
    if audio.is_file():
        hashes.update(item["sha1"] for item in load("config/audio.json", root).get("psg_envelopes", []))
    allowed = {item["path"]: item for item in load("config/binary_allowlist.json", root)["files"]}
    if allowed:
        raise ValueError("Compiler exceptions are not permitted in this text-only repository")
    return hashes, allowed


def payload_problem(data, name, private_hashes, allowed):
    if hashlib.sha1(data).hexdigest() in private_hashes:
        return "matches a private manifest payload"
    record = allowed.get(name)
    if record is not None:
        if len(data) == record["size"] and hashlib.sha256(data).hexdigest() == record["sha256"]:
            return None
        return "does not match its explicit binary allowlist identity"
    if name.startswith(FORBIDDEN_PREFIXES) or PurePosixPath(name).suffix.lower() in FORBIDDEN_EXTENSIONS:
        return "uses a forbidden private/generated path or extension"
    if PurePosixPath(name).suffix.lower() == ".asm" and re.search(rb"(?m)^zPSG_Env[0-9]+:\s*\n[ \t]+db\b", data):
        return "contains inline PSG envelope content"
    if PurePosixPath(name).suffix.lower() == ".asm":
        code = b"\n".join(line.split(b";", 1)[0] for line in data.splitlines())
        if re.search(
            rb"\b(?:smpsHeaderStartSong|smpsHeaderVoice|smpsHeaderTempo|smpsHeaderSFXChannel|smpsVcAlgorithm)\b",
            code,
            re.I,
        ):
            return "contains SMPS content source outside private inputs"
    if b"\x00" in data:
        return "contains binary NUL bytes outside the allowlist"
    try:
        data.decode("utf-8")
    except UnicodeDecodeError:
        return "is a non-UTF-8 binary outside the allowlist"
    return None


def current_problems(root=ROOT, private_hashes=None, allowed=None):
    if private_hashes is None:
        private_hashes, allowed = contracts(root)
    raw = subprocess.check_output(["git", "ls-files", "--cached", "--others", "--exclude-standard", "-z"], cwd=root)
    problems = []
    for name in dict.fromkeys(raw.decode("utf-8").split("\x00")):
        if not name:
            continue
        path = root / name
        if not path.is_file():
            continue
        issue = payload_problem(path.read_bytes(), name, private_hashes, allowed)
        if issue:
            problems.append(name + ": " + issue)
    return problems


def history_problems(root=ROOT, private_hashes=None, allowed=None):
    if private_hashes is None:
        private_hashes, allowed = contracts(root)
    raw = subprocess.check_output(["git", "rev-list", "--objects", "--all"], cwd=root)
    names = {}
    for line in raw.decode("utf-8").splitlines():
        oid, _, name = line.partition(" ")
        names[oid] = name
    if not names:
        return []
    output = subprocess.check_output(["git", "cat-file", "--batch"], cwd=root, input=("\n".join(names) + "\n").encode())
    stream = io.BytesIO(output)
    problems = []
    while line := stream.readline():
        oid, kind, size = line.decode().split()
        data = stream.read(int(size))
        if stream.read(1) != b"\n":
            raise ValueError("Malformed git cat-file stream")
        if kind != "blob":
            continue
        name = names[oid]
        issue = payload_problem(data, name, private_hashes, allowed)
        if issue:
            problems.append(oid[:12] + " " + name + ": " + issue)
    return problems


def main():
    problems = current_problems() + history_problems()
    if problems:
        raise SystemExit("Private-data audit failed:\n" + "\n".join(problems))
    print("[OK] No manifest payloads or unapproved binaries in the tree or reachable history")
