"""Bind emitted engine records to their physical source recipes and profile ABI."""

from collections import defaultdict
import hashlib
import re
from scripts.build.project import ROOT, profile
from scripts.build.source_asm import statements, source_files
from scripts.authoring import engine_records
from scripts.authoring.asset_document import Document, Target
from scripts.authoring.struct_formats import Codec

MACROS = {
    kind
    for kind in engine_records.KINDS
    if kind
    not in {"credits_layout", "credits_pages", "robot_program", "robot_children", "sprite_scale", "projectile_burst"}
}
MACROS.add("creditsptrs")
SKIP = {"if", "else", "elseif", "endif", "charset", ":=", "=", "label", "function", "message", "fatal"}


def inventory(root=ROOT):
    result = defaultdict(list)
    for path in source_files(root):
        name = path.relative_to(root).as_posix()
        rows = list(statements(path.read_text()))
        for index, (number, label, scope, operation, args) in enumerate(rows):
            kind = "credits_layout" if operation == "creditsptrs" else operation
            if operation in MACROS:
                owner = "Obj28_Properties_" + scope if kind == "obj28decl" else scope
                result[(name, owner)].append({"line": number, "kind": kind, "arguments": args})
            elif operation == "dc.l" and re.fullmatch(r"ObjC7_GroupAni_[0-9A-Fa-f]+", args):
                result[(name, scope)].append({"line": number, "kind": "robot_program", "arguments": args})
            elif label == "ObjC7_ChildDeltas":
                # This header is followed by explicit byte triples, not a macro.
                following = next((row for row in rows[index:] if row[3]), None)
                result[(name, scope)].append({"line": following[0], "kind": "robot_children", "arguments": ""})
            elif label == "Credits_PageLayouts":
                following = next((row for row in rows[index:] if row[3]), None)
                result[(name, scope)].append({"line": following[0], "kind": "credits_pages", "arguments": ""})
            elif label == "SonicRunningSpriteScaleData":
                result[(name, label)].append({"line": number, "kind": "sprite_scale", "arguments": ""})
            elif label in {"Asteron_ProjectileSpawnRecords", "MechaSonic_ProjectileSpawnRecords"}:
                following = next(row for row in rows[index:] if row[3])
                result[(name, label)].append({"line": following[0], "kind": "projectile_burst", "arguments": ""})
    return dict(result)


def size(kind, data, start, end):
    import struct

    if kind in engine_records.SCHEMAS:
        return struct.calcsize(engine_records.SCHEMAS[kind][0])
    if kind == "credittext":
        return data.index(0xFF, start + 1, end) + 1 - start
    if kind == "menutxt":
        return data[start] + 2
    if kind in {"c7anilistheader", "robot_children"}:
        return (2 if kind == "c7anilistheader" else 1) + 3 * (data[start] + 1)
    if kind == "credits_layout":
        cursor = start
        while cursor + 2 <= end and data[cursor : cursor + 2] != b"\xff\xff":
            cursor += 6
        return cursor + 2 - start
    if kind == "credits_pages":
        cursor = start
        while cursor + 4 <= end and data[cursor : cursor + 4] != b"\xff" * 4:
            cursor += 4
        return cursor + 4 - start
    if kind == "titleletters":
        cursor = start
        while cursor + 2 <= end and data[cursor : cursor + 2] != b"\xff\xff":
            cursor += 2
        return cursor + 2 - start
    return end - start


def protected(kind, original):
    """Freeze references and control-flow topology; expose bounded numeric fields."""
    fixed = {
        "subobjdata": ((0, 4), (6, 8), (9, 10)),
        "childobjectdata": ((0, 4),),
        "obj63_data": ((0, 2), (6, 7)),
        "titlecardobjdata": ((0, 2),),
        "c9palinfo": ((0, 8), (9, 10)),
        "boxdata": ((0, 8),),
        "icondata": ((0, 16),),
        "robot_program": ((0, len(original)),),
        "begin_animpat": ((0, 4),),
        "palptr": ((0, 8),),
    }
    if kind in fixed:
        return fixed[kind]
    if kind == "credittext":
        return ((0, 1),)
    if kind in {"c7anilistheader", "robot_children"}:
        header = 2 if kind == "c7anilistheader" else 1
        return ((0, 1), *((index, index + 1) for index in range(header, len(original), 3)))
    if kind == "credits_layout":
        return ((0, len(original)),)
    if kind == "credits_pages":
        return ((0, len(original)),)
    if kind == "sprite_scale":
        return tuple((index, index + 8) for index in range(0, len(original), 10))
    if kind == "projectile_burst":
        return tuple((index + 4, index + 6) for index in range(0, len(original), 6))
    if kind in {"dbglistheader", "plrlistheader", "teleporttableentry"}:
        return ((0, len(original)),)
    if kind in {"obj7a_properties", "obj43_properties"}:
        return ((0, 1),)
    if kind == "objsubdecl":
        return ((0, 4), (7, 8))
    if kind == "obj6b_properties":
        return ((2, 4),)
    if kind == "obj28decl":
        return ((4, 8),)
    if kind == "results_screen_object":
        return ((6, 8),)
    if kind == "zoneanimstart":
        model = engine_records.decode(kind, original)
        cursor = 2
        ranges = [(0, 2)]
        for row in model["scripts"]:
            ranges.append((cursor, cursor + 8))
            cursor += 8 + len(row["events"]) * (2 if row["period"] == 0xFF else 1)
            cursor += cursor & 1
        return tuple(ranges)
    return ()


def open_record(kind, data, target):
    """Open a pure, fixed-size source record with mandatory reference guards."""
    if target.format_id != "engine-records-s2" or target.protected_ranges != protected(kind, data):
        raise ValueError("Source record requires its canonical protected-reference policy")
    original = engine_records.decode(kind, data)

    def encode(model):
        encoded = engine_records.encode(kind, model)
        if len(encoded) != len(data):
            raise ValueError("Engine record edits must preserve the source allocation size")
        if kind == "sprite_scale" and any(
            new[field] > old[field]
            for new, old in zip(model["regions"], original["regions"])
            for field in ("width_minus_one", "height_minus_one")
        ):
            raise ValueError("Scaled sprite region exceeds its original transfer window")
        if kind == "zoneanimstart" and any(
            event["tile"] > max(old["events"], key=lambda value: value["tile"])["tile"]
            for new, old in zip(model["scripts"], original["scripts"])
            for event in new["events"]
        ):
            raise ValueError("Animated tile source exceeds its original transfer extent")
        return encoded

    handler = Codec(lambda value: engine_records.decode(kind, value), encode)
    return Document.open(data, target, handler=handler)


def roundtrip(artifact, context, root=ROOT):
    key = (artifact["source"], artifact["root_symbol"])
    if "engine_record_inventory" not in context:
        context["engine_record_inventory"] = inventory(root)
    recipes = context["engine_record_inventory"].get(key, [])
    if sorted({row["kind"] for row in recipes}) != artifact["record_kinds"]:
        raise ValueError("Engine record owner has stale or missing recipe kinds")
    source, symbol = key
    rows = list(statements((root / source).read_text()))
    listing, rom, table = context["listing"], context["rom"], context["symbols"]
    records = []
    for recipe in recipes:
        number, kind = recipe["line"], recipe["kind"]
        if (source, number) not in listing.addresses:
            continue
        start = listing.pc(source, number)
        if not 0 <= start < len(rom):
            raise ValueError("Engine record leaves the canonical ROM")
        # The following physical emission is an independent bound. Composite
        # macros own explicit end markers or a terminating source directive.
        if kind == "projectile_burst":
            end = table[symbol + ".end"]
            if table[symbol + ".count_minus_one"] + 1 != (end - start) // 6:
                raise ValueError("Projectile source count disagrees with its actual record span")
        elif kind == "sprite_scale":
            # Four repetitions of two region descriptors. The following code
            # label independently owns the end, rather than a guessed byte scan.
            end = table["ObjB0_RunLeft"]
        elif kind in {"c7anilistheader", "begin_animpat", "dbglistheader", "plrlistheader"}:
            end = table[symbol + "_End"]
        elif kind == "zoneanimstart":
            end_line = next(n for n, _, _, op, _ in rows if n > number and op == "zoneanimend")
            end = listing.pc(source, end_line)
        elif kind in {"robot_program", "robot_children", "credits_pages"}:
            globals_after = [
                (n, label)
                for n, label, _, _, _ in rows
                if n > number
                and label
                and not label.startswith(("@", symbol + "."))
                and label in table
                and table[label] >= start
            ]
            end = (
                table[globals_after[0][1]]
                if globals_after
                else listing.pc(source, len(listing.source_lines[source]) + 1)
            )
            if kind == "robot_children":
                end = start + 1 + 3 * (rom[start] + 1)
        else:
            candidates = [
                (n, op)
                for n, _, _, op, _ in rows
                if n > number
                and op
                and op not in SKIP
                and (source, n) in listing.addresses
                and listing.pc(source, n) > start
            ]
            end = (
                listing.pc(source, candidates[0][0])
                if candidates
                else listing.pc(source, len(listing.source_lines[source]) + 1)
            )
        count = size(kind, rom, start, end)
        if count <= 0 or start + count > end:
            raise ValueError("Engine record exceeds its physical source allocation: " + symbol)
        data = rom[start : start + count]
        if kind == "robot_program":
            model = engine_records.decode(kind, data)
            target = next(
                (
                    name
                    for name, value in table.items()
                    if value == model["table"] and name.startswith("ObjC7_GroupAni_")
                ),
                None,
            )
            if target is None:
                raise ValueError("Motion program has no source-owned frame table")
            fields = [args for _, _, scope, op, args in rows if scope == target and op == "offsettableentry.w"]
            if not fields or any(
                event.get("index", event.get("fallback_frame", 0)) >= len(fields)
                for event in model["events"]
                if event["kind"] != "restart"
            ):
                raise ValueError("Motion program selects beyond its owned frame table")
        target = Target(
            source + ":" + str(number),
            "engine-records-s2",
            profile(context["revision"], root)["content_abi"],
            "m68000-rom",
            start,
            count,
            count,
            address_limit=len(rom),
            protected_ranges=protected(kind, data),
        )
        document, model = open_record(kind, data, target)
        encoded = document.encode(model, target)
        if encoded != data:
            raise ValueError("Engine source record does not round-trip exactly")
        records.append(
            {
                "line": number,
                "kind": kind,
                "start": start,
                "end_exclusive": start + count,
                "sha256": hashlib.sha256(encoded).hexdigest(),
            }
        )
    if not records:
        raise ValueError("Registered engine source owner has no active records")
    return {
        "source": source,
        "root_symbol": symbol,
        "codec": "engine-records-s2",
        "revision": context["revision"],
        "records": records,
        "zero_edit": True,
        "start": min(row["start"] for row in records),
        "end_exclusive": max(row["end_exclusive"] for row in records),
    }
