"""Run the project style contract through Retrolarium Kit."""

import argparse
import subprocess
from scripts.build.project import ROOT
from scripts.validation.asm_style import normalize


def check(fix=False):
    if not fix:
        labels = subprocess.run(["rltool", "lint", "--project", ".", "--only", "labels"], cwd=ROOT)
        if labels.returncode:
            raise ValueError("Assembly label check failed on the original sources")
    changed = normalize(fix=fix)
    command = ["rltool", "lint", "--project", str(ROOT), "--only", "text", "--only", "code"]
    if fix:
        command.append("--fix")
    result = subprocess.run(command, cwd=ROOT)
    return result.returncode == 0 and (fix or not changed)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("action", nargs="?", choices=["lint", "format"], default="lint")
    args = parser.parse_args()
    try:
        if args.action == "format":
            if not check(fix=True):
                raise SystemExit(1)
            if not check():
                raise SystemExit("Formatting did not reach a stable passing state")
        elif not check():
            raise SystemExit("Run make format to normalize the reported source and text files")
    except (OSError, ValueError, subprocess.SubprocessError) as exc:
        raise SystemExit(str(exc)) from exc
