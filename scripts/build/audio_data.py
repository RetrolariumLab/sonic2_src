"""Derive private driver data and emit source-only audio include wrappers."""

import hashlib
from scripts.authoring.saxman import decode
from scripts.build.project import ROOT, atomic_write, load, project_path


def derived_payloads(root=ROOT):
    config = load("config/audio.json", root)
    manifest = load("assets/manifest.json", root)
    driver = config["driver_data"]
    source = next(item for item in manifest["assets"] if item["path"] == driver["asset"])
    raw = project_path(manifest["output"] + "/" + source["path"], root).read_bytes()
    if len(raw) != source["size"] or hashlib.sha1(raw).hexdigest() != source["sha1"]:
        raise ValueError("Compressed driver input differs from its asset contract")
    discard = driver["discard_trailing_bytes"]
    if not 0 < discard < len(raw):
        raise ValueError("Invalid driver trailer size")
    data = decode(raw[:-discard], with_size=False, max_output=driver["decoded_size"])
    if len(data) != driver["decoded_size"] or hashlib.sha1(data).hexdigest() != driver["decoded_sha1"]:
        raise ValueError("Decoded driver differs from its contract")
    for item in config["psg_envelopes"]:
        start, size = item["offset"], item["size"]
        if start < 0 or size <= 0 or start + size > len(data):
            raise ValueError("PSG envelope lies outside the decoded driver")
        payload = data[start : start + size]
        if hashlib.sha1(payload).hexdigest() != item["sha1"]:
            raise ValueError("PSG envelope hash mismatch: " + item["label"])
        yield project_path(manifest["output"] + "/" + item["path"], root), payload


def derive(root=ROOT):
    for path, payload in derived_payloads(root):
        atomic_write(path, payload)


def check_derived(root=ROOT):
    for path, payload in derived_payloads(root):
        if not path.is_file() or path.read_bytes() != payload:
            raise ValueError("Missing or modified derived audio asset: " + path.relative_to(root).as_posix())


def prepare(root=ROOT):
    config = load("config/audio.json", root)
    manifest = load("assets/manifest.json", root)
    assets = {item["path"]: item for item in manifest["assets"]}
    for item in config["samples"]:
        asset = assets[item["asset"]]
        text = f'.sample_rate = {item["sample_rate"]}\n.size = {asset["size"]}\n\tbinclude "{manifest["output"]}/{item["asset"]}"\n'
        atomic_write(root / "build/samples" / item["kind"] / (item["name"] + ".inc"), text.encode())
    for kind, items, folder in [
        ("music", config["songs"], "build/music"),
        ("effects", config["effects"], "build/audio/sfx"),
    ]:
        for item in items:
            compressed = item.get("compressed", False)
            text = f".is_compressed = {'TRUE' if compressed else 'FALSE'}\n" if kind == "music" else ""
            if not compressed:
                text += f'\tif getZ80BankOffset(*)<>${item["bank_offset"]:X}\n\tfatal "Uncompressed SMPS data moved within its Z80 bank"\n\tendif\n'
            text += f'\tbinclude "{manifest["output"]}/{item["asset"]}"\n'
            atomic_write(root / folder / (item["name"] + ".inc"), text.encode())
