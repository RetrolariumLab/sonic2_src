"""Validate the linked documentation corpus and its explicit substance-review ledger."""

import argparse
from collections import Counter, defaultdict
import hashlib
import json
import re
from urllib.parse import unquote, urlsplit
from scripts.build.project import ROOT, atomic_write, load, project_path

LINK = re.compile(r"!?\[[^\]\n]+\]\(([^)\n]+)\)")
HEADING = re.compile(r"^#{1,6}\s+(.+?)\s*#*\s*$", re.M)


def visible_markdown(text):
    result = []
    fence = None
    for line in text.splitlines():
        marker = re.match(r"^\s*(`{3,}|~{3,})", line)
        if marker:
            if fence is None:
                fence = marker[1][0]
            elif marker[1][0] == fence:
                fence = None
            result.append("")
        elif fence is None:
            result.append(re.sub(r"`[^`]*`", "", line))
    return "\n".join(result)


def heading_ids(text):
    counts = Counter()
    result = set()
    for heading in HEADING.findall(visible_markdown(text)):
        name = re.sub(r"[^\w\- ]", "", heading.lower()).replace(" ", "-")
        suffix = counts[name]
        counts[name] += 1
        result.add(name + ("-" + str(suffix) if suffix else ""))
    return result


def markdown_files(root=ROOT):
    return sorted({*root.glob("*.md"), *(root / "docs").rglob("*.md")})


def audit(root=ROOT):
    destination = project_path("build/documentation-check.json", root)
    destination.unlink(missing_ok=True)
    manifest = load("config/source_reconstruction_2_0.json", root)
    review = load("config/reconstruction/documentation_review.json", root)
    paths = markdown_files(root)
    texts = {}
    for path in paths:
        name = path.relative_to(root).as_posix()
        project_path(name, root)
        text = path.read_text()
        if not text.strip() or re.search(r"[\u0400-\u04ff]", text):
            raise ValueError("Empty or non-English document: " + name)
        texts[name] = text
    if set(manifest["required_documents"]) != set(texts):
        raise ValueError("Required document manifest and actual corpus differ")
    reviewed = {item["path"]: item for item in review["documents"]}
    if len(reviewed) != len(review["documents"]) or set(reviewed) != set(texts):
        raise ValueError("Substance-review ledger does not cover each document once")
    if review["status"] not in {"development", "reviewed"}:
        raise ValueError("Unknown documentation review state")
    edges = {name: [] for name in texts}
    inventory = []
    clusters = defaultdict(list)
    for name, text in texts.items():
        path = root / name
        record = reviewed[name]
        if record.get("action") not in {"new", "updated", "rewritten", "retained"} or not record.get("reason"):
            raise ValueError("Document lacks an explicit corpus decision: " + name)
        fingerprint = hashlib.sha256(path.read_bytes()).hexdigest()
        if review["status"] == "reviewed" and record.get("sha256") != fingerprint:
            raise ValueError("Document changed after its substance review: " + name)
        links = []
        for raw in LINK.findall(visible_markdown(text)):
            target = raw.strip().split(' "', 1)[0].strip("<>")
            parsed = urlsplit(target)
            if re.match(r"^[A-Za-z]:[\\/]", target) or parsed.scheme == "file":
                raise ValueError("Absolute local Markdown link: " + name)
            if parsed.scheme or parsed.netloc:
                continue
            decoded = unquote(parsed.path)
            if decoded.startswith(("/", "\\")) or re.match(r"^[A-Za-z]:", decoded):
                raise ValueError("Absolute local Markdown link: " + name)
            referenced = project_path(path.parent / decoded if decoded else path, root)
            if not referenced.is_file():
                raise ValueError("Broken local Markdown link: " + name + " -> " + target)
            linked = referenced.relative_to(root).as_posix()
            if parsed.fragment and referenced.suffix.lower() == ".md":
                if unquote(parsed.fragment) not in heading_ids(referenced.read_text()):
                    raise ValueError("Missing Markdown heading: " + name + " -> " + target)
            links.append(target)
            if linked in texts:
                edges[name].append(linked)
        line_count = len(text.splitlines())
        if line_count > 600 and not record.get("size_exception"):
            raise ValueError("Long document lacks a corpus-review reason: " + name)
        inventory.append(
            {
                "path": name,
                "lines": line_count,
                "bytes": path.stat().st_size,
                "sha256": fingerprint,
                "local_links": links,
                "action": record["action"],
            }
        )
        if "_" in path.stem:
            clusters[path.stem.split("_", 1)[0]].append(name)
    reached = set()

    def walk(name):
        if name in reached:
            return
        reached.add(name)
        for child in edges[name]:
            walk(child)

    for entry in ["README.md", "docs/index.md"]:
        if entry not in texts:
            raise ValueError("Missing reader entry point: " + entry)
        walk(entry)
    if reached != set(texts):
        raise ValueError("Orphan documentation: " + repr(sorted(set(texts) - reached)))
    repeated = {prefix: names for prefix, names in clusters.items() if len(names) > 1}
    report = {
        "gate": "documentation-check",
        "passed": True,
        "substance_review_status": review["status"],
        "documents": inventory,
        "repeated_filename_prefixes": repeated,
        "all_documents_reachable": True,
    }
    atomic_write(destination, (json.dumps(report, indent=2) + "\n").encode())
    print("[OK] Documentation inventory, local links and corpus decisions; substance review: " + review["status"])
    return report


def main():
    argparse.ArgumentParser(description=__doc__).parse_args()
    try:
        audit()
    except (OSError, ValueError) as exc:
        raise SystemExit(str(exc)) from exc


if __name__ == "__main__":
    main()
