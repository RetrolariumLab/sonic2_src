"""Validate release values and canonical evidence owners, including tag inspection."""

import re
import subprocess
from scripts.build.project import ROOT, load, profiles, project_path

STATES = {"satisfied", "not_applicable", "partial", "unsupported", "planned"}
FIELDS = ("requirements", "runtime_coverage", "toolchain", "artifacts", "layout_deviations")


def targets(root):
    paths = [root / "Makefile", *sorted((root / "mk").glob("*.mk"))]
    return {
        name
        for path in paths
        for line in path.read_text().splitlines()
        if (match := re.match(r"^([A-Za-z0-9][A-Za-z0-9_. -]*):(?!=)", line))
        for name in match[1].split()
    }


def validate(root=ROOT, line="1.0", ready=False):
    manifest = load("config/source_reconstruction_" + line.replace(".", "_") + ".json", root)
    requirements = manifest.get("requirements", {})
    for identifier, requirement in requirements.items():
        if not re.fullmatch(r"[a-z][a-z0-9_]+", identifier) or requirement.get("status") not in STATES:
            raise ValueError("Invalid release requirement identifier or status: " + identifier)
        if requirement["status"] != "satisfied" and not requirement.get("reason"):
            raise ValueError("An unsatisfied or excluded requirement needs a reason: " + identifier)
        if ready and requirement["status"] not in {"satisfied", "not_applicable"}:
            raise ValueError("Release requirement remains open: " + identifier)
    if not ready and manifest.get("status") != "tag-ready":
        return manifest
    if manifest.get("status") != "tag-ready" or manifest.get("open_milestones"):
        raise ValueError("The release boundary is not ready")
    if manifest.get("release", {}).get("version") != line or manifest.get("tag") != "source-reconstruction-" + line:
        raise ValueError("Release version and proposed tag disagree")
    available = targets(root)
    if set(manifest["release_commands"]) != available:
        raise ValueError("Release command contract omits or invents a public target")
    inherited = manifest.get("preservation_contract")
    if line == "2.0":
        if inherited != {"manifest": "config/source_reconstruction_1_0.json", "fields": list(FIELDS)}:
            raise ValueError("Source 2.0 lacks explicit canonical preservation contract references")
        validate(root, "1.0", ready=True)
        common = load(inherited["manifest"], root)
    else:
        common = manifest
    if not requirements or any(field not in common for field in (*FIELDS, "aggregate_gates")):
        raise ValueError("Release contract lacks required value owners")
    for requirement in requirements.values():
        evidence = requirement.get("evidence", {})
        if requirement["status"] == "satisfied" and not any(evidence.values()):
            raise ValueError("Satisfied requirement has no evidence owner")
        for name in evidence.get("files", []):
            if not project_path(name, root).is_file():
                raise ValueError("Missing release evidence file: " + name)
        if not set(evidence.get("targets", [])) <= available:
            raise ValueError("Requirement names an unavailable public target")
    selected = {item["id"]: item for item in profiles(root)["profiles"]}
    if {item["id"] for item in manifest["profiles"]} != set(selected) or any(
        item["status"] != "accepted" for item in manifest["profiles"]
    ):
        raise ValueError("Release profiles are not accepted canonical profiles")
    runtime = load("config/runtime.json", root)
    scenarios = {load(item["check"], root)["id"]: item for item in runtime["scenarios"]}
    coverage = common["runtime_coverage"]
    if {row["profile_id"] for row in coverage} != set(selected):
        raise ValueError("Runtime contract omits an accepted profile")
    for row in coverage:
        if row["mode"] != "direct" or row["manifest"] != "config/runtime.json" or not row["scenarios"]:
            raise ValueError("Runtime coverage has no direct scenario owner")
        for identifier in row["scenarios"]:
            if identifier not in scenarios or scenarios[identifier]["profile"] != row["profile_id"]:
                raise ValueError("Runtime scenario belongs to a different profile")
    artifacts = common["artifacts"]
    if len({item["id"] for item in artifacts}) != len(artifacts) or {item["profile"] for item in artifacts} != set(
        selected
    ):
        raise ValueError("Artifact identities do not cover every accepted profile")
    for row in artifacts:
        if (
            row["build_target"] not in available
            or row["tracked"] is not False
            or row["identity_manifest"] != "assets/manifest.json"
            or row["identity_image"] != selected[row["profile"]]["image"]
        ):
            raise ValueError("Artifact identity differs from its canonical profile owner")
    if common["toolchain"]["manifest"] != "config/toolchain.json":
        raise ValueError("Toolchain has a competing owner")
    tools = load("config/toolchain.json", root)
    for key in ("kit", "core"):
        if not re.fullmatch(r"[0-9a-f]{40}", tools[key]["commit"]):
            raise ValueError("Toolchain source revision is not pinned")
    hosts = [row for row in tools["supported_hosts"] if row["status"] == "supported"]
    if not hosts or any(not all(row.get(key) for key in ("os", "architecture", "python", "shell")) for row in hosts):
        raise ValueError("Supported host environment is not explicit")
    for stage in ("pre_tag", "post_tag"):
        commands = manifest["aggregate_gates"].get(stage, [])
        if not commands or any(
            len(command.split()) < 2 or command.split()[0] != "make" or command.split()[1] not in available
            for command in commands
        ):
            raise ValueError("Missing real " + stage + " aggregate command")
    for row in common["layout_deviations"]:
        if (
            not all(row.get(key) for key in ("rule_id", "actual_path", "reason", "equivalent_control"))
            or not project_path(row["actual_path"], root).exists()
        ):
            raise ValueError("Layout deviation has no existing path or equivalent control")
    return manifest


def inspect_tag(root=ROOT, line="1.0", expected_commit=None):
    manifest = validate(root, line, ready=True)
    tag = manifest["tag"]

    def git(*args):
        return subprocess.check_output(["git", *args], cwd=root, text=True, stderr=subprocess.STDOUT).strip()

    if git("cat-file", "-t", "refs/tags/" + tag) != "tag":
        raise ValueError("Release tag must be annotated")
    target = git("rev-parse", "refs/tags/" + tag + "^{commit}")
    if target != (expected_commit or git("rev-parse", "HEAD")):
        raise ValueError("Release tag points to a different candidate")
    tagged = git("show", tag + ":config/source_reconstruction_" + line.replace(".", "_") + ".json")
    import json

    expected = (
        manifest
        if expected_commit is None
        else json.loads(
            git("show", expected_commit + ":config/source_reconstruction_" + line.replace(".", "_") + ".json")
        )
    )
    if json.loads(tagged) != expected:
        raise ValueError("Tagged release manifest differs from the checked tree")
    return {"tag": tag, "commit": target, "annotated": True}
