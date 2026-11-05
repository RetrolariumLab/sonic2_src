"""Run the preservation guarantee set shared by later reconstruction gates."""

import json
import hashlib
import re
from pathlib import Path
import shutil
import subprocess
import sys
from scripts.build.assets import split
from scripts.build.build_rom import verify
from scripts.build.project import ROOT, atomic_write, load, profiles, reference, toolchain, project_path
from scripts.build.relocate import build as build_relocated
from scripts.runtime.movies import execute
from scripts.validation.pointers import audit as pointer_audit
from scripts.validation.release_audit import audit as release_audit


def command(args, root=ROOT):
    print("[GATE] " + " ".join(str(value) for value in args), flush=True)
    subprocess.run([str(value) for value in args], cwd=root, check=True)


def clean_profile_outputs(root=ROOT):
    build_root = (root / "build").resolve()
    if not build_root.is_relative_to(root.resolve()):
        raise ValueError("Build root leaves the project")
    for selected in profiles(root)["profiles"]:
        if (
            not re.fullmatch(r"[a-z0-9][a-z0-9_-]*", selected["id"])
            or selected["output"] != "build/" + selected["id"] + "/sonic2.bin"
        ):
            raise ValueError("Canonical clean output is not an owned profile directory")
        for target in [(root / selected["output"]).parent, root / "build/relocated" / selected["id"]]:
            resolved = target.resolve()
            if (
                resolved == build_root
                or not resolved.is_relative_to(build_root)
                or resolved != root.resolve() / target.relative_to(root)
            ):
                raise ValueError("Refusing to clean output outside its build directory")
            if target.exists():
                shutil.rmtree(target)


def prepare_inputs(root=ROOT):
    """Reproduce preservation assets without overwriting changed private inputs."""
    selected = profiles(root)["profiles"]
    for item in selected:
        reference(item["id"], root)
    manifest = load("assets/manifest.json", root)
    output = manifest["output"].rstrip("/")
    owned = list(manifest["assets"]) + list(load("config/audio.json", root)["psg_envelopes"])
    for item in owned:
        path = project_path(output + "/" + item["path"], root)
        if path.exists():
            data = path.read_bytes()
            if len(data) != item["size"] or hashlib.sha1(data).hexdigest() != item["sha1"]:
                raise ValueError("Refusing to replace changed preservation input: " + item["path"])
    split(root=root)
    return {
        "profiles": [item["id"] for item in selected],
        "direct_assets": len(manifest["assets"]),
        "derived_assets": len(owned) - len(manifest["assets"]),
        "extraction": "fresh from verified ROMs",
        "changed_existing_assets_rejected": True,
    }


def run(root=ROOT):
    project_path("build/source-1-check.json", root).unlink(missing_ok=True)
    command(["make", "lint"], root)
    command([sys.executable, "-m", "unittest", "discover", "-s", "tests"], root)
    for selected in profiles(root)["profiles"]:
        reference(selected["id"], root)
    toolchain(root)
    from scripts.validation.evidence import public_hash, output_hashes

    public = public_hash(root)
    inputs = prepare_inputs(root)
    clean_profile_outputs(root)
    identities = [verify(item["id"], root) for item in profiles(root)["profiles"]]
    from scripts.validation.semantics import audit as semantic_audit

    semantic = semantic_audit(root, compiled=True)
    pointer_audit(root)
    for selected in profiles(root)["profiles"]:
        build_relocated(selected["id"], root)
    runtime = execute("check", root=root)
    release_audit(root, clean=True, ready=True)
    result = subprocess.run(
        [sys.executable, "-m", "retrolarium_core.stop_words", "history", str(root), "--all"],
        cwd=root,
        text=True,
        stdout=subprocess.PIPE,
        stderr=subprocess.STDOUT,
    )
    print(result.stdout, end="", flush=True)
    if result.returncode or "0 stop words in the history" not in result.stdout:
        raise ValueError("The all-ref stop-word history audit did not run successfully")
    if public_hash(root) != public:
        raise ValueError("Public inputs changed during preservation acceptance")
    evidence_paths = ["build/semantic-symbols.json", "build/pointer-audit.json", "build/runtime/check-report.json"]
    for item in profiles(root)["profiles"]:
        revision = item["id"]
        listing = project_path(item["output"], root).parent / "main.lst"
        atomic_write(root / "build/acceptance/source1" / (revision + ".lst"), listing.read_bytes())
        evidence_paths.extend(
            [
                item["output"],
                "build/acceptance/source1/" + revision + ".lst",
                item["output"].replace("sonic2.bin", "identity.json"),
                "build/relocated/" + revision + "/sonic2.bin",
                "build/relocated/" + revision + "/report.json",
                "build/relocated/" + revision + "/main.lst",
                "build/runtime/" + revision + "-check.log",
            ]
        )
    report = {
        "public_sha256": public,
        "evidence": output_hashes(evidence_paths, root),
        "gate": "source-1-check",
        "passed": True,
        "inputs": inputs,
        "identities": identities,
        "runtime": runtime,
        "semantic_symbols": semantic,
    }
    atomic_write(root / "build/source-1-check.json", (json.dumps(report, indent=2) + "\n").encode())
    print("[OK] Source Reconstruction 1.0 preservation guarantee set")
    return report


def main():
    try:
        run()
    except (OSError, ValueError, subprocess.SubprocessError) as exc:
        raise SystemExit(str(exc)) from exc
