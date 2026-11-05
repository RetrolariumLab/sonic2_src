"""Check every registered format and rebuild both revisions after zero edits."""

import argparse
from collections import Counter
import hashlib
import json
import os
from pathlib import Path
import shutil
import subprocess
import time
from scripts.build.project import ROOT, atomic_write, load, profiles, project_path, reference
from scripts.build.assets import check
from scripts.build.audio_data import derive
from scripts.build.build_rom import verify
from scripts.build.core_tool import prepare
from scripts.authoring import compression
from scripts.authoring.asset_document import Document
from scripts.authoring.catalog import codec, format_id
from scripts.authoring.contexts import audio_contexts, bumper_order_context, shared_context, target_for
from scripts.authoring.source_data import canonical_context, private_placements, source_roundtrips

VIEW_ROOTS = ("src", "scripts", "config", "assets", "tests", "tools", "mk", "docs")
VIEW_FILES = ("Makefile", "README.md", "CONTRIBUTING.md", ".gitignore", ".gitattributes", ".git-blame-ignore-revs")


def digest(data):
    return hashlib.sha256(data).hexdigest()


def public_sources(root=ROOT):
    result = {}
    if (root / ".git").exists():
        names = (
            subprocess.check_output(["git", "ls-files", "-z", "--cached", "--others", "--exclude-standard"], cwd=root)
            .decode()
            .split("\0")
        )
        for name in sorted(set(names) - {""}):
            path = project_path(name, root)
            if not path.is_file():
                raise ValueError("Public input is missing: " + name)
            result[name] = digest(path.read_bytes())
        return result
    for name in VIEW_ROOTS:
        parent = project_path(name, root)
        if parent.is_dir():
            for path in sorted(parent.rglob("*")):
                if path.is_file() and "__pycache__" not in path.parts and path.suffix not in {".pyc", ".pyo"}:
                    if not path.resolve().is_relative_to(root.resolve()):
                        raise ValueError("Build source leaves its project root")
                    result[path.relative_to(root).as_posix()] = digest(path.read_bytes())
    for name in VIEW_FILES:
        path = project_path(name, root)
        if path.is_file():
            result[name] = digest(path.read_bytes())
    return result


def prepare_view(root=ROOT, kind="zero-edit"):
    if kind not in {"zero-edit", "edit-probes"}:
        raise ValueError("Unknown private authoring workspace")
    view = root / "build/authoring" / kind / "project"
    resolved = view.resolve()
    build = (root / "build").resolve()
    if resolved == build or not resolved.is_relative_to(build):
        raise ValueError("Zero-edit build view leaves build/")
    if view.exists():
        shutil.rmtree(view)
    view.mkdir(parents=True)
    for name in public_sources(root):
        destination = view / name
        destination.parent.mkdir(parents=True, exist_ok=True)
        shutil.copy2(root / name, destination)
    return view


def registry(root=ROOT):
    config = load("config/authoring/data_formats.json", root)
    manifest = load("assets/manifest.json", root)
    audio = load("config/audio.json", root)
    direct = {item["path"] for item in manifest["assets"]}
    derived = {item["path"] for item in audio["psg_envelopes"]}
    artifacts = [item for item in config["artifacts"] if item["storage"] != "assembly"]
    names = [item["path"] for item in artifacts]
    if len(names) != len(set(names)) or set(names) != direct | derived:
        raise ValueError("Content registry does not cover each private input exactly once")
    for item in artifacts:
        if item["codec"] != format_id(item["path"]):
            raise ValueError("Content format differs from its structural owner: " + item["path"])
        if item["storage"] != ("private_asset" if item["path"] in direct else "derived_driver_data"):
            raise ValueError("Content storage owner differs from its input declaration")
    exceptions = config.get("retail_bumper_order_exceptions", [])
    names = [item["asset"] for item in exceptions]
    if len(names) != len(set(names)):
        raise ValueError("Duplicate retail bumper order exception")
    for item in exceptions:
        if (
            item["asset"] not in direct
            or format_id(item["asset"]) != "cnz-bumper-placement"
            or item["policy"] != "unchanged_stream_only"
            or len(item.get("reason", "")) < 40
            or len(item["sha256"]) != 64
            or any(c not in "0123456789abcdef" for c in item["sha256"])
        ):
            raise ValueError("Invalid retail bumper order exception contract")
    source_keys = [
        (item["source"], item["root_symbol"]) for item in config["artifacts"] if item["storage"] == "assembly"
    ]
    if len(source_keys) != len(set(source_keys)):
        raise ValueError("Source ledgers have duplicate registry owners")
    return config, manifest, audio, artifacts


def run(action="formats", root=ROOT):
    if action not in {"formats", "zero-edit"}:
        raise ValueError("Unknown content validation action")
    destination = root / (
        "build/authoring/roundtrip-formats.json" if action == "formats" else "build/authoring/content-zero-edit.json"
    )
    destination.unlink(missing_ok=True)
    started = time.monotonic()
    config, manifest, audio, artifacts = registry(root)
    prepare(os.environ.get("CORE_SOURCE"), os.environ.get("CMAKE_GENERATOR"), root)
    check(root)
    snapshots = public_sources(root)
    identities = [verify(item["id"], root) for item in profiles(root)["profiles"]]
    contexts = [canonical_context(item["id"], root) for item in profiles(root)["profiles"]]
    consumers = [private_placements(context, root) for context in contexts]
    covered = set().union(*(item["placements"] for item in consumers))
    if covered != {item["path"] for item in artifacts}:
        raise ValueError("Private input registry and active consumers differ")
    sources = {
        item["path"]: project_path(manifest["output"] + "/" + item["path"], root).read_bytes() for item in artifacts
    }
    plain = {}
    recompression = []
    for item in artifacts:
        name = item["path"]
        kind = item["compression"]
        stream = sources[name]
        plain[name] = compression.decode(
            kind, stream, driver_trailer=audio["driver_data"]["discard_trailing_bytes"], root=root
        )
        if kind != "none":
            count = audio["driver_data"]["discard_trailing_bytes"] if kind == "saxman-driver-trailer" else 0
            packed = compression.encode(
                kind, plain[name], reference=stream, driver_trailer=stream[-count:] if count else b"", root=root
            )
            if compression.decode(kind, packed, driver_trailer=count or 1, root=root) != plain[name]:
                raise ValueError("Compression semantic round trip differs: " + name)
            if kind.startswith("saxman") and packed != stream:
                raise ValueError("Authentic Saxman reconstruction differs: " + name)
            recompression.append(
                {
                    "asset": name,
                    "compression": kind,
                    "recompression_exact": packed == stream,
                    "plain_sha256": digest(plain[name]),
                    "encoded_sha256": digest(packed),
                    "encoded_size": len(packed),
                    "semantic": True,
                }
            )
    view = prepare_view(root) if action == "zero-edit" else None
    records = []
    dependencies = []
    target_count = 0
    for context, consumed in zip(contexts, consumers):
        common = shared_context(context)
        sound, links = audio_contexts(plain, context, root)
        dependencies.extend(links)
        for item in artifacts:
            name = item["path"]
            placements = consumed["placements"].get(name, [])
            for placement in placements:
                target = target_for(item, placement, plain[name], sources[name], context, root)
                handler = codec(
                    name, {**common, **sound.get(name, {}), **bumper_order_context(name, plain[name], root)}
                )
                document, model = Document.open(
                    sources[name],
                    target,
                    item["compression"],
                    decoder=lambda unused, name=name: plain[name],
                    handler=handler,
                )
                serialized = handler.encode(model)
                if serialized != plain[name]:
                    raise ValueError("Structural round trip differs: " + name)
                returned = document.encode(model, target)
                if returned != sources[name]:
                    raise ValueError("Zero-edit representation differs: " + name)
                if view is not None:
                    atomic_write(view / manifest["output"] / name, returned)
                target_count += 1
            if placements:
                records.append(
                    {
                        "asset": name,
                        "revision": context["revision"],
                        "format": item["codec"],
                        "compression": item["compression"],
                        "consumers": len(placements),
                        "encoded_size": len(sources[name]),
                        "decoded_size": len(plain[name]),
                        "sha256": digest(sources[name]),
                        "zero_edit": True,
                    }
                )
        print("[OK] Content contracts: " + context["revision"], flush=True)
    source_tables = source_roundtrips(contexts, root)
    zero_edit = []
    if view is not None:
        for item in manifest["images"]:
            atomic_write(view / item["file"], reference(item["id"], root))
        derive(view)
        for item in audio["psg_envelopes"]:
            name = item["path"]
            if project_path(manifest["output"] + "/" + name, view).read_bytes() != sources[name]:
                raise ValueError("Rebuilt derived PSG input differs: " + name)
        zero_edit = [verify(item["id"], view) for item in profiles(root)["profiles"]]
    if public_sources(root) != snapshots:
        raise ValueError("Content validation changed public source files")
    if covered != {record["asset"] for record in records}:
        raise ValueError("Structural round trip has incomplete input coverage")
    report = {
        "gate": "roundtrip-formats" if action == "formats" else "check-content-zero-edit",
        "passed": True,
        "schema_version": 1,
        "direct_assets": len(manifest["assets"]),
        "derived_assets": len(audio["psg_envelopes"]),
        "private_assets": len(artifacts),
        "profile_asset_checks": len(records),
        "placement_checks": target_count,
        "formats": dict(Counter(item["codec"] for item in artifacts)),
        "records": records,
        "recompression": recompression,
        "consumers": consumers,
        "smps_external_dependencies": dependencies,
        "source_owned_content": source_tables,
        "canonical_revisions": identities,
        "zero_edit_revisions": zero_edit,
        "source_hashes": snapshots,
        "source_unchanged": True,
        "elapsed_seconds": round(time.monotonic() - started, 2),
    }
    atomic_write(destination, (json.dumps(report, indent=2) + "\n").encode())
    print(
        "[OK] "
        + report["gate"]
        + ": "
        + str(len(artifacts))
        + " private inputs, "
        + str(source_tables["summary"]["profile_checks"])
        + " source-ledger checks",
        flush=True,
    )
    return report


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("action", choices=["formats", "zero-edit"])
    args = parser.parse_args()
    try:
        run(args.action)
    except (OSError, ValueError, subprocess.SubprocessError) as exc:
        raise SystemExit(str(exc)) from exc


if __name__ == "__main__":
    main()
