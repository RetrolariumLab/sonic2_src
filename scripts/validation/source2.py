"""Run the complete preservation predecessor before the Source 2.0 acceptance delta."""

import argparse
import hashlib
import json
import re
import subprocess
import sys
from scripts.build.project import ROOT, atomic_write, load, profiles, project_path, image
from scripts.build.listing import symbols
from scripts.authoring.roundtrip import public_sources
from scripts.runtime.movies import relocated_input, validate_check
from scripts.validation import structure, documentation


def git(*arguments, root=ROOT):
    return subprocess.check_output(["git", *arguments], cwd=root, text=True).strip()


def manifest_check(root=ROOT, final=False):
    from scripts.validation.release_contract import validate

    validate(root, "2.0", ready=final)
    manifest = load("config/source_reconstruction_2_0.json", root)
    if (
        manifest.get("schema_version") != 1
        or manifest.get("release_line") != "2.0"
        or manifest.get("release_kind") != "baseline"
    ):
        raise ValueError("Incorrect Source 2.0 release boundary")
    if manifest.get("status") not in {"development", "tag-ready"}:
        raise ValueError("Unknown Source 2.0 release state")
    predecessor = manifest["predecessor"]
    if predecessor["manifest"] != "config/source_reconstruction_1_0.json" or predecessor["gate"] != "release-check":
        raise ValueError("Source 2.0 must retain the complete preservation predecessor")
    expected = {item["id"] for item in profiles(root)["profiles"]}
    if expected != {item["id"] for item in manifest["profiles"]}:
        raise ValueError("Source 2.0 profiles differ from their canonical owner")
    abi = [item.get("content_abi") for item in profiles(root)["profiles"]]
    if any(not isinstance(value, str) or not value for value in abi) or len(set(abi)) != len(abi):
        raise ValueError("Revision content ABIs must be explicit and distinct")
    for entry in manifest["delta"]:
        if entry["kind"] not in {"source", "tooling", "evidence", "documentation"} or not entry.get("summary"):
            raise ValueError("Invalid release delta classification")
        for name in entry["evidence"]:
            if "/" in name and not project_path(name, root).is_file():
                raise ValueError("Missing Source 2.0 evidence owner: " + name)
    for name in manifest["required_documents"]:
        if not project_path(name, root).is_file():
            raise ValueError("Missing required Source 2.0 document: " + name)
    if not final:
        return manifest
    commit = predecessor["commit"]
    if not isinstance(commit, str) or not re.fullmatch(r"[0-9a-f]{40}", commit):
        raise ValueError("The exact accepted preservation predecessor is still pending")
    if predecessor.get("status") != "accepted":
        raise ValueError("Preservation predecessor has not been accepted")
    subprocess.run(["git", "merge-base", "--is-ancestor", commit, "HEAD"], cwd=root, check=True)
    old = json.loads(git("show", commit + ":" + predecessor["manifest"], root=root))
    if old.get("release_line") != "1.0" or old.get("status") != "tag-ready":
        raise ValueError("Named predecessor is not a ready preservation boundary")
    layout = load("config/reconstruction/source_layout.json", root)
    if layout["baseline"]["commit"] != commit:
        raise ValueError("Source range baseline differs from the release predecessor")
    actual = git("rev-list", "--reverse", commit + "..HEAD", root=root).splitlines()
    declared = []
    for item in manifest["delta"]:
        for value in item["commits"]:
            declared.append(git("rev-parse", "HEAD", root=root) if value == "release-commit" else value)
    if not actual or len(declared) != len(set(declared)) or set(actual) != set(declared):
        raise ValueError("Release delta does not classify every substantive commit exactly once")
    if manifest["delta_history"]["base_commit"] != commit or manifest["delta_history"]["commit_count"] != len(actual):
        raise ValueError("Release delta history boundary or count is stale")
    formats = load("config/authoring/data_formats.json", root)
    inventory = formats.get("source_table_inventory", {})
    if inventory.get("pending_review") or inventory.get("inline_mapping_reviews"):
        raise ValueError("Source-owned data format reviews remain pending")
    if manifest["content"]["source_table_review_status"] != "complete" or manifest["open_milestones"]:
        raise ValueError("Source 2.0 implementation milestones remain open")
    if load("config/reconstruction/documentation_review.json", root)["status"] != "reviewed":
        raise ValueError("The complete documentation substance review is still pending")
    return manifest


def preservation_matrix(report, root=ROOT):
    if report.get("gate") != "source-1-check" or report.get("passed") is not True:
        raise ValueError("The mandatory preservation predecessor did not pass")
    selected = profiles(root)["profiles"]
    wanted = {item["id"] for item in selected}
    identities = report.get("identities", [])
    runtime = report.get("runtime", [])
    if len(identities) != len(wanted) or {item["profile"] for item in identities} != wanted:
        raise ValueError("Preservation identity matrix does not cover every accepted profile")
    if len(runtime) != len(wanted) or {item["profile"] for item in runtime} != wanted:
        raise ValueError("Preservation runtime matrix does not cover every accepted profile")
    for row in identities:
        if row.get("byte_identical") is not True:
            raise ValueError("Preservation identity matrix contains a failed byte comparison")
        contract = image(row["profile"], root)
        if any(row.get(key) != contract[key] for key in ["size", "sha1", "sha256"]):
            raise ValueError("Preservation identity report differs from its legal input contract")
        profile = next(item for item in selected if item["id"] == row["profile"])
        binary = project_path(profile["output"], root).read_bytes()
        if len(binary) != contract["size"] or hashlib.sha256(binary).hexdigest() != contract["sha256"]:
            raise ValueError("Preservation identity report differs from the current canonical output")
    config = load("config/runtime.json", root)
    for row in runtime:
        profile = next(item for item in selected if item["id"] == row["profile"])
        scenario = next(item for item in config["scenarios"] if item["profile"] == row["profile"])
        path = project_path(scenario["check"], root)
        coverage = validate_check(
            load(scenario["check"], root),
            config,
            symbols(project_path(profile["output"], root).parent / "main.lst"),
            path,
            root=root,
        )
        if row.get("action") != "check" or row["emulator_sha256"] != config["emulator"]["sha256"]:
            raise ValueError("Runtime evidence has the wrong action or emulator")
        if row["golden_sha256"] != hashlib.sha256(path.read_bytes()).hexdigest():
            raise ValueError("Runtime golden changed after the predecessor check")
        if any(row.get(key) != value for key, value in coverage.items()):
            raise ValueError("Runtime coverage differs from the full current scenario")
        if row["rom_sha256"] != hashlib.sha256(relocated_input(row["profile"], root).read_bytes()).hexdigest():
            raise ValueError("Runtime evidence differs from the current relocation image")
    return {
        "identity_profiles": sorted(wanted),
        "runtime_profiles": sorted(wanted),
        "runtime_execution_owner": "mandatory source-1-check",
    }


def run(root=ROOT):
    destination = project_path("build/source-2-check.json", root)
    destination.unlink(missing_ok=True)
    # The predecessor implementation is executed, never replaced by a cached report.
    try:
        from scripts.validation import source1
    except ImportError as error:
        raise ValueError("The required preservation gate implementation is unavailable") from error
    before = public_sources(root)
    predecessor = source1.run(root)
    matrix = preservation_matrix(predecessor, root)
    layout = structure.audit(root, baseline=True)
    from scripts.authoring.roundtrip import run as content_check

    content = content_check("zero-edit", root)
    corpus = documentation.audit(root)
    manifest = manifest_check(root, final=True)
    from scripts.validation.release_audit import audit as release_audit

    release_audit(root, clean=True, ready=True, line="2.0")
    completed = subprocess.run(
        [sys.executable, "-m", "retrolarium_core.stop_words", "history", str(root), "--all"],
        cwd=root,
        stdout=subprocess.PIPE,
        stderr=subprocess.STDOUT,
        text=True,
    )
    print(completed.stdout, end="", flush=True)
    if completed.returncode or "0 stop words in the history" not in completed.stdout:
        raise ValueError("The final all-ref stop-word audit did not run successfully")
    if public_sources(root) != before or git("status", "--porcelain", root=root):
        raise ValueError("The Source 2.0 gate changed source or left a dirty working tree")
    report = {
        "gate": "source-2-check",
        "passed": True,
        "release_line": manifest["release_line"],
        "commit": git("rev-parse", "HEAD", root=root),
        "predecessor_commit": manifest["predecessor"]["commit"],
        "predecessor_executed": True,
        "preservation": predecessor,
        "profile_matrix": matrix,
        "source_layout": layout,
        "content_report": "build/authoring/content-zero-edit.json",
        "content_report_sha256": hashlib.sha256(
            project_path("build/authoring/content-zero-edit.json", root).read_bytes()
        ).hexdigest(),
        "source_ledger_checks": content["source_owned_content"]["summary"]["profile_checks"],
        "corpus_review": corpus["substance_review_status"],
        "source_hashes": before,
    }
    atomic_write(destination, (json.dumps(report, indent=2) + "\n").encode())
    print("[OK] Source Reconstruction 2.0 complete predecessor and acceptance delta")
    return report


def main():
    argparse.ArgumentParser(description=__doc__).parse_args()
    try:
        run()
    except (OSError, ValueError, subprocess.SubprocessError) as exc:
        raise SystemExit(str(exc)) from exc


if __name__ == "__main__":
    main()
