"""Run the preservation guarantee set shared by later reconstruction gates."""

import json
from pathlib import Path
import shutil
import subprocess
import sys
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


def run(root=ROOT):
    project_path("build/source-1-check.json", root).unlink(missing_ok=True)
    command(["make", "lint"], root)
    command([sys.executable, "-m", "unittest", "discover", "-s", "tests"], root)
    for selected in profiles(root)["profiles"]:
        reference(selected["id"], root)
    toolchain(root)
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
    report = {"gate": "source-1-check", "passed": True, "identities": identities, "runtime": runtime}
    atomic_write(root / "build/source-1-check.json", (json.dumps(report, indent=2) + "\n").encode())
    print("[OK] Source Reconstruction 1.0 preservation guarantee set")
    return report


def main():
    try:
        run()
    except (OSError, ValueError, subprocess.SubprocessError) as exc:
        raise SystemExit(str(exc)) from exc
