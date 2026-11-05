"""Prove bounded palette edits in actual ROMs rebuilt from a private workspace."""

from dataclasses import replace
import argparse
import json
from scripts.build.project import ROOT, atomic_write, load, profiles, project_path, reference, toolchain
from scripts.build.build_rom import assemble_image, prepare_audio
from scripts.build.listing import symbols
from scripts.authoring.asset_document import Document
from scripts.authoring.catalog import codec
from scripts.authoring.contexts import target_for
from scripts.authoring.roundtrip import digest, prepare_view, public_sources, registry
from scripts.authoring.source_data import canonical_context, private_placements


def expected_image(original, edits):
    result = bytearray(original)
    occupied = set()
    for start, before, after in edits:
        if not before or len(before) != len(after) or not 0x200 <= start < start + len(before) <= len(result):
            raise ValueError("Palette probe leaves its fixed original allocation")
        positions = set(range(start, start + len(before)))
        if positions & occupied or bytes(result[start : start + len(before)]) != before:
            raise ValueError("Palette consumers overlap or differ from the verified original")
        occupied.update(positions)
        result[start : start + len(after)] = after
    checksum = sum(int.from_bytes(result[at : at + 2], "big") for at in range(0x200, len(result), 2)) & 0xFFFF
    result[0x18E:0x190] = checksum.to_bytes(2, "big")
    return bytes(result)


def compare(actual, original, edits):
    expected = expected_image(original, edits)
    if actual != expected or actual == original:
        raise ValueError("Rebuilt edit differs outside its typed palette changes and checksum")
    return [index for index, (a, b) in enumerate(zip(original, actual)) if a != b]


def run(root=ROOT):
    destination = root / "build/authoring/content-edits.json"
    destination.unlink(missing_ok=True)
    before = public_sources(root)
    baseline = load("build/authoring/content-zero-edit.json", root)
    if baseline.get("passed") is not True or baseline.get("source_hashes") != before:
        raise ValueError("Edit proof requires a current complete zero-edit baseline")
    config, manifest, audio, artifacts = registry(root)
    probes = load("config/authoring/edit_probes.json", root)["probes"]
    if len(probes) < 2 or len({row["asset"] for row in probes}) != len(probes):
        raise ValueError("Edit proof requires distinct palette owners")
    owners = {row["path"]: row for row in artifacts}
    view = prepare_view(root, "edit-probes")
    source = root / "build/authoring/zero-edit/project"
    for row in artifacts:
        name = manifest["output"] + "/" + row["path"]
        atomic_write(view / name, project_path(name, source).read_bytes())
    for row in manifest["images"]:
        atomic_write(view / row["file"], reference(row["id"], root))
    results = []
    for selected in profiles(root)["profiles"]:
        revision = selected["id"]
        context = canonical_context(revision, root)
        placements = private_placements(context, root)["placements"]
        changes, evidence = [], []
        for probe in probes:
            name = probe["asset"]
            owner = owners[name]
            if owner["codec"] != "palette-md" or owner["compression"] != "none":
                raise ValueError("Edit probe must own an uncompressed Mega Drive palette")
            original = project_path(manifest["output"] + "/" + name, root).read_bytes()
            sites = placements[name]
            if not sites or any(site["address_space"] != "m68000-rom" for site in sites):
                raise ValueError("Palette has no checked ROM consumers")
            target = target_for(owner, sites[0], original, original, context, root)
            document, model = Document.open(original, target, handler=codec(name))
            index, channel = probe["index"], probe["channel"]
            if type(index) is not int or not 0 <= index < len(model) or channel not in {"red", "green", "blue"}:
                raise ValueError("Invalid typed palette edit")
            model[index][channel] = (model[index][channel] + 1) % 8
            encoded = document.encode(model, target)
            if encoded == original or len(encoded) != len(original) or codec(name).decode(encoded) != model:
                raise ValueError("Palette edit did not retain its model and allocation")
            try:
                document.encode(model, replace(target, start=target.start + 2))
            except ValueError:
                pass
            else:
                raise ValueError("Edited palette accepted a moved allocation")
            atomic_write(view / manifest["output"] / name, encoded)
            for site in sites:
                changes.append((site["start"], original, encoded))
            evidence.append(
                {
                    "asset": name,
                    "index": index,
                    "channel": channel,
                    "original_sha256": digest(original),
                    "edited_sha256": digest(encoded),
                    "consumers": [site["start"] for site in sites],
                }
            )
        assembler, p2bin = toolchain(view)
        prepare_audio(assembler, p2bin, view)
        output = project_path(selected["output"], view)
        entry = output.parent / "main.asm"
        wrapper = "".join(f"{name} = {value}\n" for name, value in selected["defines"].items())
        wrapper += '\tinclude "' + profiles(view)["entry"] + '"\n'
        atomic_write(entry, wrapper.encode())
        assemble_image(entry, output, assembler, p2bin, view)
        actual = output.read_bytes()
        changed = compare(actual, reference(revision, root), changes)
        current = symbols(entry.with_suffix(".lst"))
        if current != context["symbols"]:
            raise ValueError("A fixed palette edit changed assembler symbols")
        results.append(
            {
                "revision": revision,
                "sha256": digest(actual),
                "changed_offsets": changed,
                "symbols_unchanged": len(current),
                "allocation_move_rejected": True,
                "probes": evidence,
            }
        )
        print("[OK] " + revision + ": two typed palette edits rebuilt with exact ROM differences", flush=True)
    if public_sources(root) != before:
        raise ValueError("Edit proof changed public inputs")
    from scripts.validation.evidence import output_hashes, public_hash

    report = {
        "gate": "check-content-edits",
        "passed": True,
        "public_sha256": public_hash(root),
        "profiles": results,
        "evidence": output_hashes(
            [
                "build/authoring/content-zero-edit.json",
                *["build/authoring/edit-probes/project/" + row["output"] for row in profiles(root)["profiles"]],
                *[
                    "build/authoring/edit-probes/project/" + row["output"].replace("sonic2.bin", "main.lst")
                    for row in profiles(root)["profiles"]
                ],
            ],
            root,
        ),
    }
    atomic_write(destination, (json.dumps(report, indent=2) + "\n").encode())
    return report


def main():
    argparse.ArgumentParser(description=__doc__).parse_args()
    try:
        run()
    except (OSError, ValueError, KeyError) as exc:
        raise SystemExit(str(exc)) from exc
