"""Run the preservation guarantee set shared by later reconstruction gates."""

import json
import hashlib
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
        for target in [(root / selected["output"]).parent, root / "build/relocated" / selected["id"]]:
            resolved = target.resolve()
            if resolved == build_root or not resolved.is_relative_to(build_root):
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
    inputs = prepare_inputs(root)
    clean_profile_outputs(root)
    identities = [verify(item["id"], root) for item in profiles(root)["profiles"]]
    pointer_audit(root)
    for selected in profiles(root)["profiles"]:
        build_relocated(selected["id"], root)
    runtime = execute("check", root=root)
    release_audit(root, clean=True)
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
    report = {"gate": "source-1-check", "passed": True, "inputs": inputs, "identities": identities, "runtime": runtime}
    atomic_write(root / "build/source-1-check.json", (json.dumps(report, indent=2) + "\n").encode())
    print("[OK] Source Reconstruction 1.0 preservation guarantee set")
    return report


def main():
    try:
        run()
    except (OSError, ValueError, subprocess.SubprocessError) as exc:
        raise SystemExit(str(exc)) from exc
