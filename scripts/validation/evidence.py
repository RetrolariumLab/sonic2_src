"""Bind acceptance reports to the complete public tree and their actual outputs."""

import argparse
import hashlib
import json
import subprocess
from scripts.build.project import ROOT, load, project_path
from scripts.authoring.roundtrip import public_sources


def public_hash(root=ROOT):
    return hashlib.sha256(json.dumps(public_sources(root), sort_keys=True, separators=(",", ":")).encode()).hexdigest()


def output_hashes(names, root=ROOT):
    result = {}
    for name in sorted(set(names)):
        path = project_path(name, root)
        if not path.is_relative_to((root / "build").resolve()) or not path.is_file():
            raise ValueError("Acceptance evidence must be an existing build output: " + name)
        result[name] = hashlib.sha256(path.read_bytes()).hexdigest()
    if not result:
        raise ValueError("Acceptance report has no output evidence")
    return result


def validate(report, root=ROOT):
    if report.get("passed") is not True or report.get("public_sha256") != public_hash(root):
        raise ValueError("Acceptance report is incomplete or belongs to another public tree")
    expected = report.get("evidence")
    if not isinstance(expected, dict) or output_hashes(expected, root) != expected:
        raise ValueError("An accepted output changed or disappeared")
    return report


def check(root=ROOT):
    report = load("build/source-2-check.json", root)
    validate(report, root)
    head = subprocess.check_output(["git", "rev-parse", "HEAD"], cwd=root, text=True).strip()
    if report.get("commit") != head:
        raise ValueError("Acceptance report belongs to another commit")
    for name in (
        "build/source-1-check.json",
        "build/authoring/content-edits.json",
        "build/runtime/extended-report.json",
    ):
        validate(load(name, root), root)
    from scripts.runtime.extended import audit

    audit(root)
    print("[OK] Complete current Source 2.0 report and all bound artifacts")
    return report


def main():
    argparse.ArgumentParser(description=__doc__).parse_args()
    try:
        check()
    except (OSError, ValueError, subprocess.SubprocessError) as exc:
        raise SystemExit(str(exc)) from exc
