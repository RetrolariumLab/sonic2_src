"""Check semantic source ownership, includes and independently discovered data tables."""

import argparse
from collections import Counter
import hashlib
import json
import re
import subprocess
from scripts.build.project import ROOT, atomic_write, load, profiles, project_path
from scripts.build.source_asm import statements, source_files
from scripts.authoring.indexed_records import KINDS as INDEXED_KINDS

INCLUDE = re.compile(r'\binclude\s+"([^"\n]+)"', re.I)
DIGEST = re.compile(r"[0-9a-f]{64}")


def digest(data):
    return hashlib.sha256(data).hexdigest()


def ledger(text):
    allowed = {
        "mappingstable",
        "mappingstableentry.w",
        "spriteheader",
        "spritepiece",
        "dplcheader",
        "dplcentry",
        "even",
    }
    operations = Counter()
    labels = {}
    pending = []
    targets = []
    for number, label, scope, operation, arguments in statements(text):
        if label:
            pending.append(label)
        if not operation:
            continue
        if operation not in allowed:
            raise ValueError("Non-data operation in an oversized ledger at line " + str(number))
        for name in pending:
            labels[name] = operation
        pending = []
        operations[operation] += 1
        if operation == "mappingstableentry.w":
            target = (scope or "") + arguments if arguments.startswith(".") else arguments
            targets.append(target)
    if not targets or not operations["mappingstable"]:
        raise ValueError("Oversized ledger lacks an indexed frame table")
    if any(labels.get(target) not in {"spriteheader", "dplcheader"} for target in targets):
        raise ValueError("Oversized ledger frame reference has no complete header")
    return {
        "grammar": "sprite-mappings-and-dplc-macros",
        "frame_pointers": len(targets),
        "frame_bodies": operations["spriteheader"] + operations["dplcheader"],
        "pieces_or_runs": operations["spritepiece"] + operations["dplcentry"],
    }


def inventory(root=ROOT):
    from scripts.authoring.source_data import parent_scopes

    parents = parent_scopes(root)
    first_operations = {}
    local_operations = {}
    offset_tables = []
    sprite_files = set()
    mapping_tables = set()
    demo_runs = set()
    anonymous = {}
    for path in source_files(root):
        name = path.relative_to(root).as_posix()
        pending = []
        active = None
        previous_demo = False
        anonymous[name] = []
        for number, label, scope, operation, arguments in statements(path.read_text(), parents.get(name)):
            if label:
                pending.append(label)
                if label.startswith("@"):
                    anonymous[name].append((number, label.split(":", 1)[1], label))
                else:
                    previous_demo = False
            if not operation:
                continue
            declaration = pending[-1] if pending else scope
            for value in pending:
                local_operations[(name, value)] = operation
                if not value.startswith("@"):
                    first_operations[value] = operation
            pending = []
            if operation == "mappingstable":
                sprite_files.add(name)
                mapping_tables.add((name, declaration))
            if operation == "demoinput" and not previous_demo:
                demo_runs.add((name, scope))
            previous_demo = operation == "demoinput"
            if operation == "offsettable":
                active = {"source": name, "root_symbol": scope, "targets": []}
                offset_tables.append(active)
            elif operation == "offsettableentry.w" and active:
                target = scope + arguments if arguments.startswith(".") else arguments
                active["targets"].append((number, target))
            else:
                active = None
    data_tables = set()
    for item in offset_tables:
        operations = []
        for number, target in item["targets"]:
            if re.fullmatch(r"[+-]+", target):
                direction = target[0]
                labels = [
                    row
                    for row in anonymous[item["source"]]
                    if row[1] == direction and (row[0] > number if direction == "+" else row[0] < number)
                ]
                labels.sort(reverse=direction == "-")
                target = labels[len(target) - 1][2] if len(labels) >= len(target) else "unresolved"
            operations.append(local_operations.get((item["source"], target), first_operations.get(target)))
        if operations and all(value in {"dc.b", "specialtext", "obj1e67size"} for value in operations):
            data_tables.add((item["source"], item["root_symbol"]))
    return {
        "sprite_files": sprite_files,
        "mapping_tables": mapping_tables,
        "demo_runs": demo_runs,
        "data_tables": data_tables,
    }


def original_segments(row):
    """Keep legacy single-source rows readable and reject ambiguous composites."""
    if "original_segments" not in row:
        return [row]
    segments = row["original_segments"]
    if (
        not isinstance(segments, list)
        or not segments
        or any(key in row for key in ("original_path", "original_first_line", "original_last_line", "source_sha256"))
    ):
        raise ValueError("Ambiguous composite source coordinates: " + row["path"])
    if any(not isinstance(item, dict) or item.get("original_first_line") is None for item in segments):
        raise ValueError("Composite source segment lacks concrete coordinates: " + row["path"])
    return segments


def check_ranges(layout, root=ROOT, baseline=False):
    original = {item["path"]: item for item in layout["original_sources"]}
    if len(original) != len(layout["original_sources"]):
        raise ValueError("Duplicate preservation source owner")
    segments = [(row["path"], item) for row in layout["modules"] for item in original_segments(row)]
    if {item.get("original_path") for _, item in segments} != set(original):
        raise ValueError("Source modules refer to undeclared preservation owners")
    for path, item in segments:
        first, last = item.get("original_first_line"), item.get("original_last_line")
        if first is None and last is None and item.get("kind") == "include_order":
            continue
        if type(first) is not int or type(last) is not int or first < 1 or last < first:
            raise ValueError("Invalid original source coordinates: " + path)
        if not DIGEST.fullmatch(item.get("source_sha256", "")):
            raise ValueError("Missing original range fingerprint: " + path)
    for name, owner in original.items():
        if not DIGEST.fullmatch(owner["sha256"]) or owner["physical_lines"] < 1:
            raise ValueError("Invalid preservation source fingerprint: " + name)
        rows = [
            (path, item)
            for path, item in segments
            if item["original_path"] == name and item["original_first_line"] is not None
        ]
        cursor = 1
        for path, item in sorted(rows, key=lambda pair: pair[1]["original_first_line"]):
            if item["original_first_line"] != cursor:
                raise ValueError("Overlapping or missing source coordinates: " + name)
            cursor = item["original_last_line"] + 1
        if cursor != owner["physical_lines"] + 1:
            raise ValueError("Incomplete original source range: " + name)
        if baseline:
            commit = layout["baseline"]["commit"]
            if not isinstance(commit, str) or not re.fullmatch(r"[0-9a-f]{40}", commit):
                raise ValueError("Source layout has no accepted preservation commit")
            data = subprocess.check_output(["git", "show", commit + ":" + name], cwd=root)
            text = data.decode("utf-8").replace("\r\n", "\n")
            if digest(text.encode()) != owner["sha256"] or len(text.splitlines()) != owner["physical_lines"]:
                raise ValueError("Original source differs from the preservation commit: " + name)
            lines = text.splitlines(keepends=True)
            for path, item in rows:
                payload = "".join(lines[item["original_first_line"] - 1 : item["original_last_line"]]).encode()
                if digest(payload) != item["source_sha256"]:
                    raise ValueError("Original source slice differs: " + path)


def check_size(row, body):
    count = len(body.splitlines())
    exception = row.get("size_exception")
    if count > 900:
        if not exception or not isinstance(exception.get("reason"), str) or len(exception["reason"].strip()) < 30:
            raise ValueError("Oversized source lacks a justified size exception: " + row["path"])
        if exception.get("kind") == "machine_checked_data_ledger":
            proof = ledger(body)
            if any(exception.get("proof", {}).get(key) != value for key, value in proof.items()):
                raise ValueError("Data ledger exception has stale proof: " + row["path"])
        elif exception.get("kind") == "cohesive_object_module":
            maximum = exception.get("max_lines")
            labels = [label for _, label, _, _, _ in statements(body) if label and not label.startswith("@")]
            if (
                type(maximum) is not int
                or maximum <= 900
                or count > maximum
                or len(original_segments(row)) < 2
                or not labels
                or exception.get("root_symbol") != labels[0]
                or row.get("label") != labels[0]
            ):
                raise ValueError("Cohesive object exception exceeds its reviewed bound or root: " + row["path"])
        else:
            raise ValueError("Unknown oversized source exception: " + row["path"])
        return True
    if exception and exception.get("kind") == "cohesive_object_module":
        raise ValueError("Unnecessary cohesive object size exception: " + row["path"])
    if count < 25 and (not exception or not exception.get("reason")):
        raise ValueError("Tiny source module lacks a cohesive boundary reason: " + row["path"])
    return False


def audit(root=ROOT, baseline=False):
    destination = project_path("build/source-layout-check.json", root)
    destination.unlink(missing_ok=True)
    layout = load("config/reconstruction/source_layout.json", root)
    if layout.get("schema") != "sonic2.source_layout" or layout.get("schema_version") not in {1, 2}:
        raise ValueError("Unsupported source layout schema")
    rows = {item["path"]: item for item in layout["modules"]}
    actual = {path.relative_to(root).as_posix() for path in source_files(root)}
    if len(rows) != len(layout["modules"]) or set(rows) != actual:
        raise ValueError("Source registry does not own every assembly file exactly once")
    entry = profiles(root)["entry"]
    if entry != layout["entry"] or entry not in rows:
        raise ValueError("Source entry disagrees with the profile owner")
    audio = load("config/audio.json", root)
    generated = {"build/music/" + item["name"] + ".inc" for item in audio["songs"]}
    generated |= {"build/audio/sfx/" + item["name"] + ".inc" for item in audio["effects"]}
    generated |= {"build/samples/" + item["kind"] + "/" + item["name"] + ".inc" for item in audio["samples"]}
    edges = {}
    exceptions = []
    for name, row in rows.items():
        path = project_path(name, root)
        body = path.read_text()
        count = len(body.splitlines())
        if not row.get("responsibility") or not row.get("owner"):
            raise ValueError("Source module lacks a semantic owner: " + name)
        if name != entry and not name.startswith("src/" + row["owner"] + "/"):
            raise ValueError("Source owner differs from its semantic home: " + name)
        if count != row["physical_lines"] or digest(path.read_bytes()) != row["file_sha256"]:
            raise ValueError("Source registry has stale size or bytes: " + name)
        if check_size(row, body):
            exceptions.append(name)
        children = []
        for raw in body.splitlines():
            for target in INCLUDE.findall(raw.split(";", 1)[0]):
                project_path(target, root)
                if target in generated:
                    continue
                if target not in rows:
                    raise ValueError("Include has no declared source owner: " + target)
                children.append(target)
        edges[name] = children
    if edges != layout["include_graph"]:
        raise ValueError("Source registry include graph is stale")
    reached = set()

    def walk(name, active):
        if name in active:
            raise ValueError("Source include cycle: " + name)
        if name in reached:
            return
        reached.add(name)
        for child in edges[name]:
            walk(child, active | {name})

    walk(entry, set())
    if reached != set(rows):
        raise ValueError("Unreachable semantic source module")
    check_ranges(layout, root, baseline)
    renames = load("config/reconstruction/label_renames.json", root)
    if renames.get("schema") != "sonic2.label_renames" or renames.get("schema_version") != 1:
        raise ValueError("Unsupported label rename registry schema")
    if len({item["old"] for item in renames["renames"]}) != len(renames["renames"]):
        raise ValueError("Duplicate original label in rename registry")
    duplicates = [path for parent in (root / "docs", root / "config") for path in parent.rglob("*label*rename*.json")]
    if {path.relative_to(root).as_posix() for path in duplicates} != {"config/reconstruction/label_renames.json"}:
        raise ValueError("There must be exactly one canonical label rename registry")
    formats = load("config/authoring/data_formats.json", root)
    found = inventory(root)
    from scripts.validation.macro_roles import audit as macro_audit

    macro_review = macro_audit(root)
    from scripts.authoring.source_records import inventory as record_inventory

    actual_records = record_inventory(root)
    registered = [item for item in formats["artifacts"] if item["storage"] == "assembly"]
    record_owners = {
        (item["source"], item["root_symbol"]): item for item in registered if item["codec"] == "engine-records-s2"
    }
    if set(record_owners) != set(actual_records) or any(
        record_owners[key]["record_kinds"] != sorted({row["kind"] for row in value})
        for key, value in actual_records.items()
    ):
        raise ValueError("Source engine-record registry differs from the independent macro inventory")
    sprites = {
        (item["source"], item["root_symbol"])
        for item in registered
        if item["codec"] in {"sprite-s2", "dplc-s2"} and item.get("layout") != "shared_frame_views"
    }
    inline = {
        (item["source"], item["root_symbol"]) for item in registered if item.get("layout") == "shared_frame_views"
    }
    demos = {(item["source"], item["root_symbol"]) for item in registered if item["codec"] == "demo-input-s2"}
    data = {
        (item["source"], item["root_symbol"])
        for item in registered
        if item["codec"].startswith("animation-") or item["codec"] == "tube-path-s2" or item["codec"] in INDEXED_KINDS
    }
    pending = formats.get("source_table_inventory", {}).get("pending_review", [])
    pending_keys = {(item["source"], item["root_symbol"]) for item in pending}
    inline_pending = formats.get("source_table_inventory", {}).get("inline_mapping_reviews", [])
    inline_keys = {(item["source"], item["root_symbol"]) for item in inline_pending}
    actual_inline = found["mapping_tables"] - sprites
    if inline_keys & inline or inline_keys | inline != actual_inline:
        raise ValueError("Inline mapping review ledger differs from the independent inventory")
    if sprites | inline_keys | inline != found["mapping_tables"] or demos != found["demo_runs"]:
        raise ValueError("Source sprite/demo registry differs from the independent inventory")
    from scripts.authoring.source_regions import region_lines

    for artifact in registered:
        if "source_region" in artifact:
            region_lines(artifact, project_path(artifact["source"], root).read_text().splitlines())
    if data & pending_keys or data | pending_keys != found["data_tables"]:
        raise ValueError("Source byte-table registry differs from the independent inventory")
    report = {
        "gate": "source-layout-check",
        "macro_review": macro_review,
        "passed": True,
        "source_files": len(rows),
        "every_source_reachable": True,
        "original_source_files": len(layout["original_sources"]),
        "checked_size_exceptions": exceptions,
        "baseline_checked": baseline,
        "sprite_ledger_files": len({name for name, symbol in sprites}),
        "sprite_ledger_roots": len(sprites),
        "cohesive_object_size_exceptions": [
            name for name in exceptions if rows[name]["size_exception"]["kind"] == "cohesive_object_module"
        ],
        "inline_mapping_tables": len(inline),
        "demo_runs": len(demos),
        "indexed_content_tables": len(data),
        "source_table_reviews_pending": pending,
        "inline_mapping_reviews_pending": inline_pending,
    }
    atomic_write(destination, (json.dumps(report, indent=2) + "\n").encode())
    print(
        "[OK] Source ownership, ranges, include graph and data inventory; pending table reviews: "
        + str(len(pending) + len(inline_pending))
    )
    return report


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--baseline", action="store_true")
    args = parser.parse_args()
    try:
        audit(baseline=args.baseline)
    except (OSError, ValueError, subprocess.SubprocessError) as exc:
        raise SystemExit(str(exc)) from exc


if __name__ == "__main__":
    main()
