"""Bind indexed source records to canonical table declarations and consumer limits."""

import hashlib
import re
from scripts.build.project import ROOT, project_path, profile
from scripts.authoring.asset_document import Document, Target
from scripts.authoring.struct_formats import Codec
from scripts.build.source_asm import statements
from scripts.authoring.indexed_records import Spec, decode, encode


class SourceTables:
    def __init__(self, context, root=ROOT):
        self.context = context
        self.root = root
        self.rows = {}
        self.labels = {}
        for name, lines in context["listing"].source_lines.items():
            if not name.startswith("src/"):
                continue
            rows = list(statements("\n".join(lines)))
            self.rows[name] = rows
            for index, row in enumerate(rows):
                number, label, scope, operation, arguments = row
                if label and not label.startswith("@") and (name, number) in context["listing"].addresses:
                    self.labels.setdefault(label, []).append((name, index))

    def locate(self, symbol):
        values = self.labels.get(symbol, [])
        if len(values) != 1:
            raise ValueError("Source table symbol has no unique active declaration: " + symbol)
        return values[0]

    def header(self, symbol, entry_operation="offsettableentry.w"):
        name, index = self.locate(symbol)
        rows = self.rows[name]
        while index < len(rows) and not rows[index][3]:
            index += 1
        if index == len(rows):
            raise ValueError("Table symbol has no declaration: " + symbol)
        if rows[index][3] == "include":
            match = re.fullmatch(r'"([^"\n]+)"', rows[index][4])
            if not match or match[1] not in self.rows:
                raise ValueError("Table alias has no registered source include")
            name = match[1]
            rows = self.rows[name]
            index = next((number for number, row in enumerate(rows) if row[3]), len(rows))
        if index == len(rows):
            raise ValueError("Empty source table")
        if entry_operation == "dc.l":
            if rows[index][3] != "dc.l":
                raise ValueError("Expected source-owned long pointer array")
        else:
            if rows[index][3] not in {"offsettable", "mappingstable"}:
                raise ValueError("Expected a source-owned indexed table")
            index += 1
        targets = []
        zone_targets = None
        while index < len(rows):
            row = rows[index]
            if not row[3]:
                index += 1
                continue
            if row[3] == "zoneorderedoffsettable" and entry_operation == "mappingstableentry.w":
                if row[4].replace(" ", "") != "2,1" or zone_targets is not None:
                    raise ValueError("Unsupported zone-ordered mapping selector ABI")
                zone_targets = []
                index += 1
                continue
            if row[3] == "zoneoffsettableentry.w" and zone_targets is not None:
                zone_targets.append(row[4])
                index += 1
                continue
            if row[3] == "zonetableend" and zone_targets is not None:
                ordered = [None] * len(zone_targets)
                for ordinal, value in enumerate(zone_targets):
                    position = self.context["symbols"]["zone_id_" + format(ordinal, "X")]
                    if not 0 <= position < len(ordered) or ordered[position] is not None:
                        raise ValueError("Zone-ordered selector mapping is not a permutation")
                    ordered[position] = value
                targets.extend(ordered)
                zone_targets = None
                index += 1
                continue
            if row[3] != entry_operation or zone_targets is not None:
                break
            targets.extend(part.strip() for part in row[4].split(","))
            index += 1
        if zone_targets is not None:
            raise ValueError("Unterminated zone-ordered mapping selector table")
        if not targets:
            raise ValueError("Empty source-owned selector array: " + symbol)
        return name, rows, index, targets

    def count(self, symbol, entry_operation="offsettableentry.w"):
        return len(self.header(symbol, entry_operation)[3])

    def extent(self, name, rows, begin):
        allowed = {"dc.b", "specialtext", "even"}
        for row in rows[begin:]:
            if row[3] and row[3] not in allowed:
                return self.context["listing"].pc(name, row[0])
        return self.context["listing"].pc(name, len(self.context["listing"].source_lines[name]) + 1)


def tables(context, root=ROOT):
    if "source_table_index" not in context:
        context["source_table_index"] = SourceTables(context, root)
    return context["source_table_index"]


def roundtrip(artifact, context, root=ROOT):
    source = tables(context, root)
    symbol = artifact["root_symbol"]
    name, rows, index, targets = source.header(symbol)
    if name != artifact["source"]:
        raise ValueError("Indexed source owner differs from its registry")
    start = context["symbols"][symbol]
    end = source.extent(name, rows, index)
    data = context["rom"][start:end]
    if not 0 <= start < end <= len(context["rom"]):
        raise ValueError("Indexed source content leaves its ROM")
    addresses = {target: context["symbols"][target] for target in targets}
    starts = sorted(set(addresses.values()))
    slots = []
    kind = artifact["codec"]
    for position, address in enumerate(starts):
        bound = starts[position + 1] if position + 1 < len(starts) else end
        if not start + len(targets) * 2 <= address < bound <= end:
            raise ValueError("Indexed source record overlaps its header or next record")
        payload = context["rom"][address:bound]
        if kind == "track-frames-s2":
            owners = [label for label, value in addresses.items() if value == address]
            stops = {context["symbols"][label + "_End"] for label in owners}
            if len(stops) != 1:
                raise ValueError("Track frame sequence has inconsistent source ends")
            stop = next(iter(stops))
        elif kind == "background-scroll-s2":
            stop = address + 5
        elif kind in {"phrase-words-s2", "message-glyphs-s2"}:
            terminator = next((at for at, value in enumerate(payload) if value >= 0x80), None)
            if terminator is None:
                raise ValueError("Message list lacks a signed terminator")
            stop = address + terminator + 1
        elif kind == "hud-layout-s2":
            stop = address + 2 + payload[0]
        elif kind == "ending-frames-s2":
            stop = address + 28
        elif kind == "pulley-path-s2":
            stop = address + 2 + int.from_bytes(payload[:2], "big")
        elif kind == "pulley-children-s2":
            stop = address + 2 + 6 * (int.from_bytes(payload[:2], "big") + 1)
        else:
            raise ValueError("Unsupported indexed source ABI: " + kind)
        if not address < stop <= bound:
            raise ValueError("Indexed source record leaves its owned extent")
        slots.append((address - start, stop - start))
    limit = 256
    if artifact.get("frame_table_symbol"):
        operation = artifact.get("frame_table_entry", "mappingstableentry.w")
        limit = source.count(artifact["frame_table_symbol"], operation)
    if kind == "phrase-words-s2":
        limit = source.count(artifact["word_table_symbol"])
    symbols = context["symbols"]
    capacity = 0
    if kind == "hud-layout-s2":
        capacity = (symbols["object_size"] - symbols["subspr_data"]) // symbols["next_subspr"]
    if kind == "pulley-children-s2":
        capacity = (symbols["Dynamic_Object_RAM_End"] - symbols["Dynamic_Object_RAM"]) // symbols["object_size"]
    exceptions = tuple(
        (symbols[row["record_symbol"]] - start + row["element"], row["value"])
        for row in artifact.get("retail_invalid_selectors", [])
    )
    for offset, value in exceptions:
        if not 0 <= offset < len(data) or data[offset] != value:
            raise ValueError("Retail invalid selector differs from its declared source cell")
    spec = Spec(kind, len(targets), len(data), tuple(slots), limit, capacity, exceptions)
    target = Target(
        symbol,
        kind,
        profile(context["revision"], root)["content_abi"],
        "m68000-rom",
        start,
        len(data),
        len(data),
        address_limit=len(context["rom"]),
    )
    handler = Codec(lambda stream: decode(stream, spec), lambda model: encode(model, spec))
    document, model = Document.open(data, target, handler=handler)
    if document.encode(model, target) != data:
        raise ValueError("Indexed source structural round trip differs: " + symbol)
    return {
        "source": name,
        "codec": kind,
        "root_symbol": symbol,
        "revision": context["revision"],
        "start": start,
        "end_exclusive": end,
        "references": len(targets),
        "records": len(slots),
        "alignment_bytes": len(model["alignment"]),
        "selector_limit": limit,
        "object_capacity": capacity,
        "retail_invalid_selectors": list(exceptions),
        "size": len(data),
        "sha256": hashlib.sha256(data).hexdigest(),
        "zero_edit": True,
    }
