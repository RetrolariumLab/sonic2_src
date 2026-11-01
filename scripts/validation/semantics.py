"""Bind reviewed symbol meanings and explicit unknowns to the source and profiles."""

import argparse
from collections import defaultdict
import hashlib
import json
import re
from scripts.build.project import ROOT, atomic_write, load, profiles, project_path
from scripts.build.listing import symbols
from scripts.build.source_asm import statements
from scripts.validation.asm_style import source_files, code_signature

AUTO_LABEL = re.compile(
    r"^(?:(?:(?:BranchTo[0-9]*|JmpTo[0-9]*)_)?(?:loc|locret|sub|nullsub|bra|return|byte|word|dword|off|unk|asc|ChildObject)_[0-9A-Fa-f]+(?:[._][A-Za-z0-9_]+)*|(?:Pal|pal|Palette)_[0-9A-Fa-f]+(?:_(?:End|Begin))?)$"
)
IDENTIFIER = re.compile(r"[A-Za-z_][A-Za-z0-9_]*(?:\.[A-Za-z_][A-Za-z0-9_]*)*")
DIGEST = re.compile(r"[0-9a-f]{64}")


def replacement_pattern(mapping):
    if not mapping:
        return None
    return re.compile(
        r"(?<![A-Za-z0-9_.])(?:"
        + "|".join(re.escape(x) for x in sorted(mapping, key=len, reverse=True))
        + r")(?![A-Za-z0-9_.])"
    )


def replace_symbols(text, mapping):
    pattern = replacement_pattern(mapping)
    return pattern.sub(lambda match: mapping[match[0]], text) if pattern else text


def definitions(root=ROOT):
    """Discover global declarations, including colonless data, outside templates."""
    result = defaultdict(list)
    for path in source_files(root):
        text = path.read_text()
        lines = text.splitlines()
        parsed = list(statements(text))
        headers = [
            (offset, number, label)
            for offset, (number, label, _, _, _) in enumerate(parsed)
            if label and re.match(r"^[A-Za-z_]", lines[number - 1])
        ]
        name = path.relative_to(root).as_posix()
        for index, (offset, number, label) in enumerate(headers):
            end = headers[index + 1][1] - 1 if index + 1 < len(headers) else len(lines)
            stop = headers[index + 1][0] if index + 1 < len(headers) else len(parsed)
            body = [(n, op, args) for n, _, _, op, args in parsed[offset:stop] if op]
            result[label].append(
                {
                    "source": name,
                    "line": number,
                    "end_line": end,
                    "body": "\n".join(lines[number - 1 : end]),
                    "operations": body,
                }
            )
    return dict(result)


def fingerprint(text, inverse):
    restored = replace_symbols(text, inverse)
    return hashlib.sha256(json.dumps(code_signature(restored), separators=(",", ":")).encode()).hexdigest()


def check_definitions(record, name, discovered, inverse):
    actual = discovered.get(name, [])
    expected = record.get("definitions", [])
    if not actual or len(expected) != len(actual):
        raise ValueError("Semantic evidence does not cover each declaration: " + name)
    claimed = {row["source"]: row for row in expected}
    if len(claimed) != len(expected):
        # Revision alternatives may declare the same label twice in one file.
        claimed = {(row["source"], row["occurrence"]): row for row in expected}
    occurrences = defaultdict(int)
    for item in actual:
        occurrence = occurrences[item["source"]]
        occurrences[item["source"]] += 1
        row = claimed.get((item["source"], occurrence), claimed.get(item["source"]))
        if row is None or not DIGEST.fullmatch(row.get("code_sha256", "")):
            raise ValueError("Missing semantic source fingerprint: " + name)
        if row["code_sha256"] != fingerprint(item["body"], inverse):
            raise ValueError("Source changed after symbol review: " + name)


def check_values(record, name, selected, tables):
    evidence = record.get("profile_values", {})
    if set(evidence) != {row["id"] for row in selected}:
        raise ValueError("Symbol evidence omits an accepted profile: " + name)
    for profile in selected:
        revision = profile["id"]
        expected = evidence[revision]
        if type(expected) is not int or expected < 0:
            raise ValueError("Invalid reviewed symbol value: " + name)
        if tables is not None and tables[revision].get(name) != expected:
            raise ValueError("Reviewed symbol moved or disappeared: " + name + " / " + revision)


def check_structural_role(record, discovered):
    """Verify the narrow claim used to name a structural entity."""
    evidence = record["evidence"]
    method = evidence.get("method")
    name = record["new"]
    actual = discovered.get(name, [])
    if method in {"reviewed_source_contract", "source_contract"}:
        return
    if not actual:
        raise ValueError("Structural meaning has no source declaration: " + name)
    heads = [item["operations"][0] if item["operations"] else (0, "", "") for item in actual]
    if method == "terminal_return":
        if evidence.get("opcode") not in {"rts", "rte"} or any(op != evidence["opcode"] for _, op, _ in heads):
            raise ValueError("A named return site is not the declared terminal instruction: " + name)
    elif method == "counted_loop":
        register = evidence["register"]
        edges = [
            (item, number)
            for values in discovered.values()
            for item in values
            for number, op, args in item["operations"]
            if op in {"dbf", "dbra"} and re.fullmatch(re.escape(register) + r",\s*" + re.escape(name), args, re.I)
        ]
        if not any(
            edge["source"] == target["source"] and number > target["line"]
            for edge, number in edges
            for target in actual
        ):
            raise ValueError("A named counted loop has no matching backward counter edge: " + name)
    elif method == "literal_text":
        values = []
        for _, op, args in heads:
            strings = re.findall(r'"([^"]*)"', args)
            if op != evidence["operation"] or op not in {"credittext", "specialtext"} or not strings:
                raise ValueError("Named text is not a literal text declaration: " + name)
            values.append(strings[0])
        if sorted(set(values)) != evidence["text_variants"]:
            raise ValueError("Named text variants changed: " + name)
    elif method == "child_template":
        expected = [evidence["parent_link"], evidence["object_id"], evidence["selector"]]
        if any(op != "childobjectdata" or [x.strip() for x in args.split(",")] != expected for _, op, args in heads):
            raise ValueError("Named child template disagrees with its spawn fields: " + name)
    elif method == "indexed_content_target":
        table = discovered.get(evidence["table"], [])
        targets = [
            [
                args.split(",", 1)[0].strip()
                for _, op, args in item["operations"]
                if op in {"offsettableentry.w", "mappingstableentry.w"}
            ]
            for item in table
        ]
        index = evidence["index"]
        if not any(type(index) is int and 0 <= index < len(items) and items[index] == name for items in targets):
            raise ValueError("Named content target is not at its declared pointer index: " + name)
        if any(op != evidence["head"] for _, op, _ in heads):
            raise ValueError("Named indexed content has a different declaration grammar: " + name)
    elif method == "registered_content_root":
        allowed = {
            "sprite-s2": {"mappingstable", "include"},
            "dplc-s2": {"mappingstable", "include"},
            "tube-path-s2": {"offsettable", "include"},
            "animation-object-s2": {"offsettable", "include"},
            "animation-player-s2": {"offsettable", "include"},
            "background-scroll-s2": {"offsettable"},
            "pulley-path-s2": {"offsettable"},
            "pulley-children-s2": {"offsettable"},
            "ending-frames-s2": {"offsettable"},
        }
        if evidence["codec"] not in allowed or any(op not in allowed[evidence["codec"]] for _, op, _ in heads):
            raise ValueError("Named content root has a different declaration grammar: " + name)
    elif method == "table_end":
        parents = discovered.get(evidence["parent"], [])
        if not any(
            parent["source"] == child["source"] and parent["line"] < child["line"]
            for parent in parents
            for child in actual
        ):
            raise ValueError("Named table end has no preceding checked parent: " + name)
    else:
        raise ValueError("Unknown semantic evidence method: " + str(method))


def audit(root=ROOT, compiled=False):
    destination = project_path("build/semantic-symbols.json", root)
    destination.unlink(missing_ok=True)
    registry = load("config/reconstruction/label_renames.json", root)
    unknowns = load("config/reconstruction/unknown_symbols.json", root)
    if registry.get("schema") != "sonic2.label_renames" or registry.get("schema_version") != 1:
        raise ValueError("Unsupported semantic rename registry")
    if unknowns.get("schema") != "sonic2.unknown_symbols" or unknowns.get("schema_version") != 1:
        raise ValueError("Unsupported unknown-symbol registry")
    if registry.get("review_status") != "reviewed" or unknowns.get("review_status") != "reviewed":
        raise ValueError("Symbol substance review is not finished")
    rows = registry["renames"]
    mapping = {row["old"]: row["new"] for row in rows}
    if len(mapping) != len(rows) or len(set(mapping.values())) != len(rows):
        raise ValueError("Rename registry must be a unique old-to-new mapping")
    if set(mapping) & set(mapping.values()):
        raise ValueError("Rename chains or cycles must be collapsed to their original names")
    inverse = {value: key for key, value in mapping.items()}
    discovered = definitions(root)
    selected = profiles(root)["profiles"]
    tables = (
        {row["id"]: symbols(project_path(row["output"], root).parent / "main.lst") for row in selected}
        if compiled
        else None
    )
    for row in rows:
        old, new = row["old"], row["new"]
        if row.get("kind") not in {
            "code",
            "data_table",
            "ram_variable",
            "generated_trampoline",
            "source_marker",
            "assembler_constant",
        }:
            raise ValueError("Unknown reviewed symbol kind: " + old)
        if not IDENTIFIER.fullmatch(old) or not IDENTIFIER.fullmatch(new) or old == new:
            raise ValueError("Invalid semantic rename: " + old)
        if len(row.get("reason", "").strip()) < 30 or not row.get("evidence", {}).get("basis"):
            raise ValueError("Rename lacks a specific semantic basis: " + old)
        if old in discovered:
            raise ValueError("Old symbol still has a source declaration: " + old)
        if row.get("kind") == "generated_trampoline":
            target = row["evidence"].get("target")
            if not target or not new.endswith("_" + target) or target not in discovered:
                raise ValueError("Generated trampoline has no checked named target: " + new)
            if not any(new in path.read_text() for path in source_files(root)):
                raise ValueError("Generated trampoline is absent from its source recipe: " + new)
        else:
            check_definitions(row, new, discovered, inverse)
            check_structural_role(row, discovered)
        check_values(row, new, selected, tables)
    derived = registry.get("generated_symbols", [])
    if len({row["old"] for row in derived}) != len(derived):
        raise ValueError("Duplicate derived assembler marker")
    for row in derived:
        parent = row["parent_old"]
        suffix = row["suffix"]
        if parent not in mapping or row["old"] != parent + suffix or row["new"] != mapping[parent] + suffix:
            raise ValueError("Derived marker does not follow its registered parent")
        if suffix != "_Begin" and not re.fullmatch(r"\.[A-Za-z_][A-Za-z0-9_]*", suffix):
            raise ValueError("Unreviewed assembler-derived symbol suffix")
        if not row.get("reason"):
            raise ValueError("Derived marker lacks provenance")
        if suffix == "_Begin":
            parents = discovered.get(mapping[parent], [])
            if not parents or any(
                not item["operations"] or item["operations"][0][1] not in {"spriteheader", "dplcheader"}
                for item in parents
            ):
                raise ValueError("Frame payload marker lacks its checked header")
        check_values(row, row["new"], selected, tables)
    # A symbolic pointer can still have a meaningless name. Track the remainder
    # independently instead of treating a passing pointer audit as name review.
    remaining = {name for name in discovered if AUTO_LABEL.fullmatch(name)}
    unknown_rows = unknowns["entries"]
    recorded = {row["symbol"]: row for row in unknown_rows}
    if len(recorded) != len(unknown_rows) or set(recorded) != remaining:
        raise ValueError("Every remaining address-style symbol needs exactly one explicit unknown record")
    for name, row in recorded.items():
        for field in ("owner", "known_role", "unresolved", "reason", "next_check"):
            if not isinstance(row.get(field), str) or len(row[field].strip()) < (1 if field == "owner" else 12):
                raise ValueError("Unknown lacks a concrete " + field + ": " + name)
        if row.get("status") != "unknown":
            raise ValueError("A confirmed meaning must be named rather than filed as unknown: " + name)
        check_definitions(row, name, discovered, inverse)
        check_values(row, name, selected, tables)
        ranges = row.get("profile_ranges", {})
        if set(ranges) != {profile["id"] for profile in selected}:
            raise ValueError("Unknown lacks revision-specific bounds: " + name)
        for revision, region in ranges.items():
            if region.get("address_space") not in {"m68000-rom", "m68000-ram", "assembler-value"}:
                raise ValueError("Unknown has no declared address space: " + name)
            start, end = region.get("start"), region.get("end_exclusive")
            if type(start) is not int or type(end) is not int or end < start:
                raise ValueError("Invalid unknown range: " + name)
            mask = region.get("symbol_mask")
            if region["address_space"] == "m68000-ram":
                if mask != 0xFFFFFF or not 0xFF0000 <= start <= end <= 0x1000000:
                    raise ValueError("RAM bounds must use physical 24-bit addresses: " + name)
            elif mask is not None or (region["address_space"] == "m68000-rom" and not 0 <= start <= end <= 0x1000000):
                raise ValueError("Invalid physical ROM or assembler-value range: " + name)
            value = row["profile_values"][revision]
            if start != (value & mask if mask is not None else value) or not region.get("bound_reason"):
                raise ValueError("Unknown range is not bound to its reviewed symbol: " + name)
            endpoint = region.get("end_symbol")
            if tables is not None and endpoint:
                actual = tables[revision].get(endpoint)
                if actual is None or (actual & mask if mask is not None else actual) != end:
                    raise ValueError("Unknown end marker changed: " + name)
    report = {
        "gate": "semantic-symbols-check",
        "passed": True,
        "renames": len(rows),
        "derived_markers": len(derived),
        "explicit_unknowns": len(recorded),
        "compiled_profiles_checked": sorted(tables) if tables is not None else [],
        "limits": "Static meanings are reviewed source contracts; unknown gameplay intent is not promoted to a fact.",
    }
    atomic_write(destination, (json.dumps(report, indent=2) + "\n").encode())
    print("[OK] Reviewed symbol meanings, rename bindings and explicit unknown ranges")
    return report


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--compiled", action="store_true")
    args = parser.parse_args()
    try:
        audit(compiled=args.compiled)
    except (OSError, ValueError, KeyError) as exc:
        raise SystemExit(str(exc)) from exc


if __name__ == "__main__":
    main()
