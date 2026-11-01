"""Check release documents, ownership, privacy and all reachable draft commits."""

import argparse
from datetime import datetime
import json
import re
import subprocess
from scripts.build.project import ROOT, atomic_write, load, profiles, project_path
from scripts.validation.private_data import current_problems, history_problems
from scripts.validation.asm_style import source_files

OWNER = ("Daniel Oranguthang", "75395800+oranguthang@users.noreply.github.com")


def git(*args, root=ROOT):
    return subprocess.check_output(["git", *args], cwd=root, text=True)


def audit_history(root=ROOT):
    problems = []
    dates = {}
    trees = {}
    rows = git("rev-list", "--all", "--parents", root=root).splitlines()

    def tree(oid):
        if oid not in trees:
            trees[oid] = git("rev-parse", oid + "^{tree}", root=root).strip()
        return trees[oid]

    for row in rows:
        oid, *parents = row.split()
        fields = git("show", "-s", "--format=%an%x00%ae%x00%cn%x00%ce%x00%aI%x00%cI%x00%B", oid, root=root).split(
            "\0", 6
        )
        author, email, committer, commit_email, authored, committed, message = fields
        dates[oid] = (datetime.fromisoformat(authored), datetime.fromisoformat(committed))
        if (author, email) != OWNER or (committer, commit_email) != OWNER:
            problems.append(oid[:12] + ": incorrect owner identity")
        standard_merge = (
            len(parents) > 1
            and re.fullmatch(
                r"Merge (?:branch(?:es)?|remote-tracking branch(?:es)?|tags?|commits?) .+", message.strip()
            )
            is not None
        )
        if re.search(r"[\u0400-\u04ff]", message) or (
            not standard_merge and (not message.strip() or "\n\n" not in message.strip())
        ):
            problems.append(oid[:12] + ": commit needs an English subject and explanatory body")
        if not standard_merge and "Co-Authored-By: Codex <noreply@openai.com>" not in message:
            problems.append(oid[:12] + ": missing truthful Codex co-author credit")
        if (parents and all(tree(oid) == tree(parent) for parent in parents)) or (
            not parents and not git("ls-tree", tree(oid), root=root).strip()
        ):
            problems.append(oid[:12] + ": empty commit")
    for row in rows:
        oid, *parents = row.split()
        for parent in parents:
            if parent in dates and any(before > after for before, after in zip(dates[parent], dates[oid])):
                problems.append(oid[:12] + ": parent/child timestamps are out of order")
    return problems


def audit(root=ROOT, clean=False, ready=False, post_tag=False, line="1.0"):
    destination = project_path("build/release-audit.json", root)
    destination.unlink(missing_ok=True)
    manifest = load("config/source_reconstruction_1_0.json", root)
    from scripts.validation.release_contract import validate, inspect_tag

    selected_manifest = validate(root, line, ready=ready)
    problems = current_problems(root) + history_problems(root) + audit_history(root)
    if manifest.get("release_line") != "1.0" or manifest.get("release_kind") != "preservation":
        problems.append("Incorrect preservation release boundary")
    expected = {item["id"] for item in profiles(root)["profiles"]}
    if {item["id"] for item in manifest["profiles"]} != expected:
        problems.append("Release profiles differ from their canonical owner")
    for name in manifest["required_documents"]:
        path = project_path(name, root)
        if not path.is_file() or not path.read_text().strip():
            problems.append("Missing required document: " + name)
    tracked = git("ls-files", root=root).splitlines()
    source_names = {path.relative_to(root).as_posix() for path in source_files(root)}
    for name in tracked:
        if name.endswith((".asm", ".s", ".inc")) and name not in source_names:
            problems.append("Assembly file is outside the checked source roots: " + name)
        path = root / name
        if not path.is_file():
            continue
        try:
            text = path.read_text()
        except UnicodeDecodeError:
            continue
        if re.search(r"[\u0400-\u04ff]", text):
            problems.append("Non-English tracked text: " + name)
    if clean and git("status", "--porcelain", root=root).strip():
        problems.append("Working tree is not clean")
    if post_tag:
        inspect_tag(root, line)
    elif git("tag", "--list", selected_manifest["tag"], root=root).strip():
        expected_commit = None
        if line == "1.0" and (root / "config/source_reconstruction_2_0.json").exists():
            expected_commit = load("config/source_reconstruction_2_0.json", root)["predecessor"]["commit"]
        inspect_tag(root, line, expected_commit=expected_commit)
    report = {
        "release_line": line,
        "status": selected_manifest["status"],
        "problems": problems,
        "reachable_commits": len(git("rev-list", "--all", root=root).splitlines()),
    }
    atomic_write(destination, (json.dumps(report, indent=2) + "\n").encode())
    if problems:
        raise ValueError(
            "Release audit failed:\n"
            + "\n".join(problems[:20])
            + ("\n... see build/release-audit.json" if len(problems) > 20 else "")
        )
    print("[OK] Release ownership, privacy, documents and history audit")
    return report


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--clean", action="store_true")
    parser.add_argument("--ready", action="store_true")
    parser.add_argument("--post-tag", action="store_true")
    parser.add_argument("--line", choices=("1.0", "2.0"), default="1.0")
    args = parser.parse_args()
    try:
        audit(clean=args.clean, ready=args.ready, post_tag=args.post_tag, line=args.line)
    except (OSError, ValueError, subprocess.SubprocessError) as exc:
        raise SystemExit(str(exc)) from exc
