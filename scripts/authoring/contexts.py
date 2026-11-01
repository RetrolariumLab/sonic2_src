"""Build revision-specific authoring contracts from fresh canonical symbols."""

import struct
from scripts.build.project import ROOT, load, profile
from scripts.authoring import smps_s2
from scripts.authoring.asset_document import Target


def audio_contexts(plain, context, root=ROOT):
    config = load("config/audio.json", root)
    symbols = context["symbols"]
    bank_size = symbols["z80_bank_size"]
    records = {}
    for kind, items in [("music", config["songs"]), ("sfx", config["effects"])]:
        for item in items:
            name = item["asset"]
            at = symbols[item["label"]]
            if at % bank_size != item["bank_offset"]:
                raise ValueError("Audio bank offset differs from its canonical symbol: " + name)
            compressed = item.get("compressed", False)
            base = config["music_buffer_address"] if compressed else 0x8000 + at % bank_size
            if compressed and len(plain[name]) > config["music_buffer_capacity"]:
                raise ValueError("Music exceeds its Z80 decode buffer: " + name)
            model, analysis = smps_s2.decode(plain[name], kind, base)
            records[name] = {
                "model": model,
                "analysis": analysis,
                "base": base,
                "compressed": compressed,
                "bank": at & -bank_size,
                "rom_start": at,
                "kind": kind,
            }
    result = {}
    dependencies = []
    for name, record in records.items():
        external_events = {}
        if not record["compressed"]:
            for owner in records.values():
                if not owner["compressed"] and owner["bank"] == record["bank"]:
                    for node in owner["model"]["events"]:
                        address = owner["base"] + node["offset"]
                        if address in external_events and external_events[address] != node:
                            raise ValueError("Conflicting SMPS event owners")
                        external_events[address] = node
        for dependency in record["analysis"]["external"]:
            if record["compressed"]:
                raise ValueError("Compressed music introduces an external buffer dependency: " + name)
            address = record["bank"] + dependency["address"] - 0x8000
            size = dependency["size"]
            owners = [
                (owner_name, owner, address - owner["rom_start"])
                for owner_name, owner in records.items()
                if not owner["compressed"]
                and owner["bank"] == record["bank"]
                and owner["rom_start"] <= address
                and address + size <= owner["rom_start"] + len(plain[owner_name])
            ]
            if len(owners) != 1:
                raise ValueError("SMPS external dependency has no unique owner: " + name)
            owner_name, owner, offset = owners[0]
            nodes = owner["model"]["voices" if dependency["kind"] == "voice" else "events"]
            if not any(node["offset"] == offset for node in nodes):
                raise ValueError("SMPS external dependency enters an untyped record: " + name)
            if context["rom"][address : address + size] != plain[owner_name][offset : offset + size]:
                raise ValueError("SMPS external dependency differs from the legal ROM")
            dependencies.append(
                {
                    "revision": context["revision"],
                    "source": name,
                    "target": owner_name,
                    "target_offset": offset,
                    "kind": dependency["kind"],
                    "size": size,
                    "z80_address": dependency["address"],
                    "rom_address": address,
                }
            )
        memory = smps_s2.validate_control_flow(record["model"], record["kind"], record["base"], external_events)
        result[name] = {
            "base": record["base"],
            "external": record["analysis"]["external"],
            "external_events": external_events,
            "track_memory": memory,
        }
    return result, dependencies


def shared_context(context):
    symbols = context["symbols"]
    rom = context["rom"]

    def words(first, last):
        payload = rom[symbols[first] : symbols[last]]
        if not payload or len(payload) % 2:
            raise ValueError("Invalid source-owned special-stage LUT")
        return list(struct.unpack(">" + str(len(payload) // 2) + "H", payload))

    literal = words("SSPNT_UncLUT", "SSPNT_RLELUT")
    runs = words("SSPNT_RLELUT", "SSTrackSetOrientation")
    if len(runs) % 2:
        raise ValueError("Truncated special-stage run LUT")
    object_bytes = symbols["SS_Dynamic_Object_RAM_End"] - symbols["SS_Dynamic_Object_RAM"]
    if object_bytes <= 0 or object_bytes % symbols["object_size"]:
        raise ValueError("Invalid special-stage dynamic object region")
    return {
        "object_slots": object_bytes // symbols["object_size"],
        "block_capacity": (symbols["Block_Table_End"] - symbols["Block_Table"]) // 8,
        "track_lut": {
            "literal_lut": literal,
            "run_lut": list(zip(runs[::2], runs[1::2])),
            "literal_split": (symbols["SSPNT_UncLUT_Part2"] - symbols["SSPNT_UncLUT"]) // 2,
            "run_split": (symbols["SSPNT_RLELUT_Part2"] - symbols["SSPNT_RLELUT"]) // 4,
            "palette_flags": symbols["palette_line_3"],
            "priority_flag": symbols["high_priority"],
        },
    }


def target_for(artifact, placement, plain, encoded, context, root=ROOT):
    name = artifact["path"]
    kind = artifact["codec"]
    symbols = context["symbols"]
    space = placement["address_space"]
    capacity = len(plain)
    protected = ()
    if kind == "chunks-128x128":
        capacity = min(capacity, symbols["Chunk_Table_End"] - symbols["Chunk_Table"])
    elif kind == "level-layout-s2":
        capacity = min(capacity, symbols["Level_Layout_End"] - symbols["Level_Layout"])
    elif kind == "blocks-16x16":
        available = symbols["Block_Table_End"] - symbols["Block_Table"]
        if len(plain) > available:
            if name != "mappings/16x16/ARZ.kos":
                raise ValueError("Block map exceeds its source-owned RAM region: " + name)
            # Retail ARZ deliberately writes a tail into the following scratch
            # region. Preserve it exactly; it is not additional live block RAM.
            protected = ((available, len(plain)),)
        else:
            capacity = min(capacity, available)
    audio = load("config/audio.json", root)
    if kind == "driver-program":
        capacity = min(capacity, audio["driver_data"]["decoded_size"])
        protected = ((0, len(plain)),)
    if kind == "smps-music-s2" and artifact["compression"] == "saxman":
        capacity = min(capacity, audio["music_buffer_capacity"])
    bank = symbols["z80_bank_size"] if name.startswith("sound/") and space == "m68000-rom" else None
    limit = audio["driver_data"]["decoded_size"] if space == "z80-driver-data" else len(context["rom"])
    target = Target(
        name,
        kind,
        profile(context["revision"], root)["content_abi"],
        space,
        placement["start"],
        len(encoded),
        capacity,
        bank_size=bank,
        address_limit=limit,
        protected_ranges=protected,
    )
    target.validate()
    return target
