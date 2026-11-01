"""Check ROM-free repository contracts and the declared synthetic test surface."""

import argparse
import json
import re
import subprocess
import sys
from scripts.build.project import ROOT, atomic_write, load, project_path
from scripts.authoring.roundtrip import registry
from scripts.validation import structure, documentation
from scripts.validation.source2 import manifest_check

SYNTHETIC_MODULES = (
    "tests.validation.test_structure",
    "tests.validation.test_documentation",
    "tests.validation.test_release_command",
    "tests.validation.test_source2",
    "tests.validation.test_source1_inputs",
)


def make_contract(root=ROOT):
    root_make = project_path("Makefile", root).read_text()
    includes = re.findall(r"(?m)^include\s+(mk/[^\s]+\.mk)\s*$", root_make)
    files = {path.relative_to(root).as_posix() for path in (root / "mk").glob("*.mk")}
    if set(includes) != files or len(includes) != len(files):
        raise ValueError("Root Makefile must include each workflow exactly once")
    targets = set()
    for name in ["Makefile", *includes]:
        for line in project_path(name, root).read_text().splitlines():
            match = re.match(r"^([A-Za-z0-9][A-Za-z0-9_. -]*):(?!=)", line)
            if match:
                targets.update(match[1].split())
    declared = set(load("config/source_reconstruction_2_0.json", root)["release_commands"])
    if targets != declared:
        raise ValueError("Make targets and release command contract differ")
    help_result = subprocess.run(
        ["make", "--no-print-directory", "-s", "help"],
        cwd=root,
        stdout=subprocess.PIPE,
        stderr=subprocess.STDOUT,
        text=True,
        timeout=30,
    )
    if help_result.returncode:
        raise ValueError("Public make help failed: " + help_result.stdout)
    shown = {line.strip().split()[0] for line in help_result.stdout.splitlines() if line.startswith("  ")}
    if shown != targets:
        raise ValueError("Public help omits or invents a Make command")
    return {"public_targets": sorted(targets), "workflow_files": sorted(files)}


def run(root=ROOT):
    destination = project_path("build/scaffold-check.json", root)
    destination.unlink(missing_ok=True)
    manifest_check(root)
    registry(root)
    for parent in [root / "scripts", root / "tests"]:
        for child in parent.iterdir():
            if child.is_dir() and child.name != "__pycache__" and list(child.glob("*.py")):
                if not (child / "__init__.py").is_file():
                    raise ValueError("Python responsibility package lacks __init__.py: " + child.name)
    layout = structure.audit(root)
    corpus = documentation.audit(root)
    interface = make_contract(root)
    subprocess.run([sys.executable, "-m", "unittest", "discover", "-s", "tests/authoring"], cwd=root, check=True)
    subprocess.run([sys.executable, "-m", "unittest", *SYNTHETIC_MODULES], cwd=root, check=True)
    report = {
        "gate": "scaffold-check",
        "passed": True,
        "requires_rom": False,
        "release_acceptance": False,
        "layout": layout,
        "documentation": corpus,
        "make_interface": interface,
        "synthetic_modules": list(SYNTHETIC_MODULES),
    }
    atomic_write(destination, (json.dumps(report, indent=2) + "\n").encode())
    print("[OK] ROM-free scaffold and synthetic checks; complete release acceptance is separate")
    return report


def main():
    argparse.ArgumentParser(description=__doc__).parse_args()
    try:
        run()
    except (OSError, ValueError, subprocess.SubprocessError) as exc:
        raise SystemExit(str(exc)) from exc


if __name__ == "__main__":
    main()
