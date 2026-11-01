"""Resolve private input consumers and round-trip source-owned content ledgers."""

import hashlib
import re
from scripts.build.project import ROOT, load, profile, profiles, project_path, reference
from scripts.build.listing import symbols
from scripts.build.listing_source import listing_index
from scripts.authoring import (
    control_formats,
    sprite_formats,
    tube_paths,
    source_indexed,
    source_frames,
    palette_cycles,
    dplc_contexts,
    dplc_capacity,
)
from scripts.authoring.asset_document import Document, Target
from scripts.authoring.struct_formats import Codec
from scripts.authoring.indexed_records import KINDS as INDEXED_KINDS

BINCLUDE = re.compile(r'\bbinclude\s+"([^"\n]+)"', re.I)
GLOBAL = re.compile(r"^([A-Za-z_][\w]*):")
DEMO = re.compile(r"^\s*demoinput\b", re.I)


def digest(data):
    return hashlib.sha256(data).hexdigest()


def canonical_context(revision, root=ROOT):
    selected = profile(revision, root)
    listing = project_path(selected["output"], root).parent / "main.lst"
    return {
        "revision": selected["id"],
        "rom": reference(selected["id"], root),
        "symbols": symbols(listing),
        "listing": listing_index(listing, root, listing.with_suffix(".asm").relative_to(root).as_posix()),
    }


def private_placements(context, root=ROOT):
    """Bind actual emitted includes to legal private inputs, including repeated copies.

    Listing addresses, unlike extraction offsets, follow the active revision.
    The generated compressed driver is checked as a source-owned reference.
    Derived PSG envelopes belong to the driver's uncompressed address space.
    """
    manifest = load("assets/manifest.json", root)
    audio = load("config/audio.json", root)
    assets = {item["path"]: item for item in manifest["assets"]}
    envelopes = {item["path"]: item for item in audio["psg_envelopes"]}
    prefix = manifest["output"].rstrip("/") + "/"
    payloads = {name: project_path(prefix + name, root).read_bytes() for name in assets | envelopes}
    found = {}
    templates = set()
    macro_lines = {}
    index = context["listing"]
    for row in index.rows:
        match = BINCLUDE.search(row.rendered.split(";", 1)[0])
        if not match:
            continue
        name = match[1]
        if not name.startswith(prefix) or name[len(prefix) :] not in payloads:
            if row.path not in macro_lines:
                macro_lines[row.path] = index.macro_definition_lines(row.path)
            if row.line in macro_lines[row.path] and not project_path(name, root).exists():
                templates.add((row.path, row.line, name))
                continue
            raise ValueError("Binary include has no private input owner: " + name)
        name = name[len(prefix) :]
        data = payloads[name]
        if name in envelopes:
            if row.address != envelopes[name]["offset"] or len(data) != envelopes[name]["size"]:
                raise ValueError("Derived envelope address differs from its driver ABI: " + name)
            space = "z80-driver-data"
        else:
            if row.address < 0 or row.address + len(data) > len(context["rom"]):
                raise ValueError("Private include leaves its ROM: " + name)
            if context["rom"][row.address : row.address + len(data)] != data:
                raise ValueError("Active listing input differs from its ROM consumer: " + name)
            space = "m68000-rom"
        key = (space, row.address)
        found.setdefault(name, {})[key] = {
            "address_space": space,
            "start": row.address,
            "source": row.path,
            "line": row.line,
            "kind": "binary_include",
        }
    driver = audio["driver_data"]["asset"]
    driver_label = load("config/reconstruction/relocation.json", root)["audio_layout"]["driver"]
    start = context["symbols"][driver_label]
    data = payloads[driver]
    if context["rom"][start : start + len(data)] != data:
        raise ValueError("Source-assembled driver differs from its private reference")
    if driver in found:
        raise ValueError("Driver code unexpectedly became a private binary include")
    found[driver] = {
        ("m68000-rom", start): {
            "address_space": "m68000-rom",
            "start": start,
            "source_symbol": driver_label,
            "kind": "assembled_code_reference",
        }
    }
    missing = set(envelopes) - set(found)
    if missing:
        raise ValueError("Derived envelopes are not consumed: " + repr(sorted(missing)))
    return {
        "revision": context["revision"],
        "placements": {name: list(items.values()) for name, items in sorted(found.items())},
        "macro_templates": [
            {"source": name, "line": number, "path_template": path} for name, number, path in sorted(templates)
        ],
    }


def parent_scopes(root=ROOT):
    """Find the lexical global label at each registered include site."""
    result = {}
    for source in sorted((root / "src").rglob("*.asm")):
        scope = None
        for raw in source.read_text().splitlines():
            body = raw.split(";", 1)[0]
            label = GLOBAL.match(body)
            if label:
                scope = label[1]
            include = re.search(r'\binclude\s+"([^"\n]+)"', body, re.I)
            if include and scope:
                name = include[1]
                if name in result and result[name] != scope:
                    raise ValueError("Source ledger has conflicting parent scopes: " + name)
                result[name] = scope
    return result


def source_bytes(context, start, end, name):
    if not 0 <= start <= end <= len(context["rom"]):
        raise ValueError("Source content leaves its ROM: " + name)
    return context["rom"][start:end]


def mapping_document(artifact, context, parents, root=ROOT):
    name = artifact["source"]
    table = context["symbols"]
    scope = parents.get(name)
    first = None
    active = None
    ends = []
    frames = []
    count = 0
    kind = None
    for raw in project_path(name, root).read_text().splitlines():
        body = raw.split(";", 1)[0].rstrip()
        if not body.strip():
            continue
        if not body[0].isspace():
            token, _, tail = body.partition(" ")
            label = token.rstrip(":")
            if not label.startswith("."):
                scope = label
            if not scope:
                raise ValueError("Local mapping label has no parent: " + name)
            active = scope + label if label.startswith(".") else label
            if active not in table:
                raise ValueError("Missing mapping symbol: " + active)
            if first is None:
                first = active
            if label.endswith("_End"):
                ends.append(table[active])
            body = tail.strip()
        operation = body.split(None, 1)[0].lower() if body else ""
        if operation == "mappingstableentry.w":
            count += 1
        if operation in {"spriteheader", "dplcheader"}:
            discovered = "sprite" if operation == "spriteheader" else "dplc"
            if kind is not None and discovered != kind:
                raise ValueError("Mixed frame grammars in " + name)
            kind = discovered
            frames.append(table[active])
    if first != artifact["root_symbol"] or not ends or kind is None or kind + "-s2" != artifact["codec"]:
        raise ValueError("Source mapping contract differs: " + name)
    start = table[first]
    end = max(ends)
    data = source_bytes(context, start, end, name)
    frame_offsets = tuple(sorted({value - start for value in frames}))
    initial = sprite_formats.decode(data, count, kind, list(frame_offsets))
    transfer_counts = tuple(sum(row["tiles"] for row in frame) for frame in initial["frames"]) if kind == "dplc" else ()
    budget = dplc_contexts.ordinary(artifact, context, max(transfer_counts), root) if kind == "dplc" else None

    def decode_mapping(payload):
        return sprite_formats.decode(payload, count, kind, list(frame_offsets))

    def encode_mapping(model):
        if budget:
            if len(model["frames"]) != len(transfer_counts):
                raise ValueError("DPLC frame ownership changes its transfer allocations")
            for frame, maximum in zip(model["frames"], transfer_counts):
                dplc_capacity.check(frame, dplc_capacity.Budget(budget.source_bytes, maximum, 32))
        return sprite_formats.encode(model, kind, max_transfer_tiles=budget.max_tiles if budget else None)

    target = Target(
        first,
        artifact["codec"],
        profile(context["revision"], root)["content_abi"],
        "m68000-rom",
        start,
        len(data),
        len(data),
        address_limit=len(context["rom"]),
    )
    document, model = Document.open(data, target, handler=Codec(decode_mapping, encode_mapping))
    if document.encode(model, target) != data:
        raise ValueError("Source mapping round trip differs: " + name)
    record = {
        "source": name,
        "codec": artifact["codec"],
        "root_symbol": first,
        "revision": context["revision"],
        "start": start,
        "end_exclusive": end,
        "frame_references": count,
        "frame_bodies": len(model["frames"]),
        "null_frame_references": sum(value is None for value in model["references"]),
        "unused_piece_gaps": sum(len(gap["entries"]) for gap in model["gaps"]),
        "transfer_source_bytes": budget.source_bytes if budget else None,
        "transfer_max_tiles": budget.max_tiles if budget else None,
        "transfer_frame_max_tiles": list(transfer_counts) if budget else None,
        "size": len(data),
        "sha256": digest(data),
        "zero_edit": True,
    }
    return document, model, record


def mapping_roundtrip(artifact, context, parents, root=ROOT):
    return mapping_document(artifact, context, parents, root)[2]


def root_line(artifact, context):
    name = artifact["source"]
    lines = context["listing"].source_lines[name]
    found = [
        number
        for number, line in enumerate(lines)
        if (match := GLOBAL.match(line.split(";", 1)[0])) and match[1] == artifact["root_symbol"]
    ]
    if len(found) != 1:
        raise ValueError("Source table root is not unique: " + artifact["root_symbol"])
    return lines, found[0]


def animation_roundtrip(artifact, context):
    lines, begin = root_line(artifact, context)
    name = artifact["source"]
    count = 0
    stop = begin + 1
    for number in range(begin + 1, len(lines)):
        code = lines[number].split(";", 1)[0].strip()
        code = re.sub(r"^(?:[A-Za-z_.][\w.]*:|[+-]+)\s*", "", code)
        if not code or re.fullmatch(r"[\w.]+", code) and code.lower() not in {"even", "offsettable"}:
            stop = number + 1
            continue
        operation = code.split(None, 1)[0].lower()
        if operation == "offsettableentry.w":
            count += 1
        if operation not in {"offsettableentry.w", "dc.b", "dc.w", "dcb.b", "dcb.w", "even"}:
            stop = number
            break
        stop = number + 1
    if not count:
        raise ValueError("Animation has no pointer entries: " + artifact["root_symbol"])
    start = context["symbols"][artifact["root_symbol"]]
    end = context["listing"].pc(name, stop + 1)
    data = source_bytes(context, start, end, name)
    player = artifact["codec"] == "animation-player-s2"
    model = control_formats.decode_animation(data, count, player)
    hazards = control_formats.animation_hazards(model)
    if hazards != [tuple(item) for item in artifact.get("retail_control_hazards", [])]:
        raise ValueError("Animation retail control hazards changed: " + artifact["root_symbol"])
    external = sorted({value for value in model["pointers"] if not 0 <= value < len(data)})
    if control_formats.encode_animation(model, player, external, hazards) != data:
        raise ValueError("Animation round trip differs: " + artifact["root_symbol"])
    record = {
        "source": name,
        "codec": artifact["codec"],
        "root_symbol": artifact["root_symbol"],
        "revision": context["revision"],
        "start": start,
        "end_exclusive": end,
        "frame_references": count,
        "scripts": len(model["scripts"]),
        "retail_control_hazards": hazards,
        "external_script_offsets": external,
        "size": len(data),
        "sha256": digest(data),
        "zero_edit": True,
    }
    return record, model


def demo_roundtrip(artifact, context):
    lines, begin = root_line(artifact, context)
    cursor = begin + 1
    while cursor < len(lines) and not DEMO.match(lines[cursor]):
        code = lines[cursor].split(";", 1)[0].strip()
        if code:
            raise ValueError("Unexpected statement before demo run: " + artifact["root_symbol"])
        cursor += 1
    first = cursor
    while cursor < len(lines) and DEMO.match(lines[cursor]):
        cursor += 1
    if first == cursor:
        raise ValueError("Missing demo records: " + artifact["root_symbol"])
    start = context["listing"].pc(artifact["source"], first + 1)
    if context["symbols"][artifact["root_symbol"]] != start:
        raise ValueError("Demo root does not address its first record")
    end = start + (cursor - first) * 2
    data = source_bytes(context, start, end, artifact["source"])
    model = control_formats.decode_demo(data)
    if control_formats.encode_demo(model) != data:
        raise ValueError("Demo round trip differs: " + artifact["root_symbol"])
    return {
        "source": artifact["source"],
        "codec": artifact["codec"],
        "root_symbol": artifact["root_symbol"],
        "revision": context["revision"],
        "start": start,
        "end_exclusive": end,
        "records": len(model),
        "frames": sum(row["frames"] for row in model),
        "size": len(data),
        "sha256": digest(data),
        "zero_edit": True,
    }


def tube_path_roundtrip(artifact, context):
    name = artifact["source"]
    lines, begin = root_line(artifact, context)
    count = sum(bool(re.search(r"\boffsetTableEntry\.w\b", raw.split(";", 1)[0], re.I)) for raw in lines[begin + 1 :])
    start = context["symbols"][artifact["root_symbol"]]
    end = context["listing"].pc(name, len(lines) + 1)
    data = source_bytes(context, start, end, name)
    model = tube_paths.decode(data, count)
    if tube_paths.encode(model) != data:
        raise ValueError("Tube path round trip differs: " + artifact["root_symbol"])
    return {
        "source": name,
        "codec": artifact["codec"],
        "root_symbol": artifact["root_symbol"],
        "revision": context["revision"],
        "start": start,
        "end_exclusive": end,
        "references": count,
        "paths": len(model["paths"]),
        "maximum_points": max(map(len, model["paths"])),
        "size": len(data),
        "sha256": digest(data),
        "zero_edit": True,
    }


def palette_cycle_roundtrip(artifact, context, root=ROOT):
    index = source_indexed.tables(context, root)
    name, position = index.locate(artifact["root_symbol"])
    if name != artifact["source"]:
        raise ValueError("Palette timing table has the wrong source owner")
    start = context["symbols"][artifact["root_symbol"]]
    end = index.extent(name, index.rows[name], position + 1)
    data = source_bytes(context, start, end, name)
    target = Target(
        artifact["root_symbol"],
        artifact["codec"],
        profile(context["revision"], root)["content_abi"],
        "m68000-rom",
        start,
        len(data),
        len(data),
        address_limit=len(context["rom"]),
    )
    document, model = Document.open(data, target, handler=Codec(palette_cycles.decode, palette_cycles.encode))
    if document.encode(model, target) != data:
        raise ValueError("Palette timing round trip differs")
    return {
        "source": name,
        "codec": artifact["codec"],
        "root_symbol": artifact["root_symbol"],
        "revision": context["revision"],
        "start": start,
        "end_exclusive": end,
        "periods": len(model),
        "size": len(data),
        "sha256": digest(data),
        "zero_edit": True,
    }


def source_roundtrips(contexts, root=ROOT):
    artifacts = [
        item for item in load("config/authoring/data_formats.json", root)["artifacts"] if item["storage"] == "assembly"
    ]
    parents = parent_scopes(root)
    records = []
    dependencies = []
    frame_records = []
    frame_dependencies = []
    for context in contexts:
        animations = []
        for artifact in artifacts:
            if artifact.get("layout") == "shared_frame_views":
                continue
            if context["revision"] not in artifact["revisions"]:
                continue
            kind = artifact["codec"]
            if kind in {"sprite-s2", "dplc-s2"}:
                record = mapping_roundtrip(artifact, context, parents, root)
            elif kind.startswith("animation-"):
                record, model = animation_roundtrip(artifact, context)
                animations.append((record, model))
            elif kind == "palette-cycle-timing-s2":
                record = palette_cycle_roundtrip(artifact, context, root)
            elif kind in INDEXED_KINDS:
                record = source_indexed.roundtrip(artifact, context, root)
            elif kind == "tube-path-s2":
                record = tube_path_roundtrip(artifact, context)
            elif kind == "demo-input-s2":
                record = demo_roundtrip(artifact, context)
            else:
                raise ValueError("Unknown source ledger codec: " + kind)
            records.append(record)
        views = source_frames.roundtrip(
            [
                item
                for item in artifacts
                if item.get("layout") == "shared_frame_views" and context["revision"] in item["revisions"]
            ],
            context,
            parents,
            root,
        )
        records.extend(views["records"])
        frame_records.extend(views["frames"])
        frame_dependencies.extend(views["dependencies"])
        for record, model in animations:
            for offset in record["external_script_offsets"]:
                target = record["start"] + offset
                owners = [
                    other["root_symbol"]
                    for other, other_model in animations
                    if any(other["start"] + node["offset"] == target for node in other_model["scripts"])
                ]
                if len(owners) != 1:
                    raise ValueError("External animation script has no unique owner: " + record["root_symbol"])
                dependencies.append(
                    {
                        "revision": context["revision"],
                        "source": record["root_symbol"],
                        "target_owner": owners[0],
                        "target_address": target,
                        "signed_relative_offset": offset,
                    }
                )
    expected = sum(
        len(set(artifact["revisions"]) & {context["revision"] for context in contexts}) for artifact in artifacts
    )
    if len(records) != expected:
        raise ValueError("Source ledger coverage is incomplete")
    return {
        "records": records,
        "dependencies": dependencies,
        "source_view_frames": frame_records,
        "source_view_dependencies": frame_dependencies,
        "summary": {
            "source_ledgers": len(artifacts),
            "profile_checks": len(records),
            "external_script_checks": len(dependencies),
            "all_passed": True,
        },
    }
