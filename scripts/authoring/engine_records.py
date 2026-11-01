"""Typed codecs for source-owned text, object, palette and motion records.

These codecs consume one bounded record, never discover a record by scanning
arbitrary ROM memory. Reference fields are protected by the source binding.
"""

import struct
from scripts.authoring.struct_formats import keys, uint

# Explicit big-endian field schemas. Counts, pointers and rendering attributes
# retain their engine representation; placement belongs to the caller's ABI.
SCHEMAS = {
    "childobjectdata": (">HBB", "parent_slot object_id subtype"),
    "subobjdata": (">IHBBBB", "mappings art_tile render_flags priority width collision"),
    "c9palinfo": (">IIBBBB", "callback palette destination_offset count_minus_one period steps"),
    "obj63_data": (">HhhBB", "art_tile x_offset y_offset frame flip_flags"),
    "titlecardobjdata": (">BBBBhhh", "routine frame width delay start_x stop_x y"),
    "boxdata": (">II", "text vdp_command"),
    "icondata": (">IIII", "text suffix vdp_command palette_and_map"),
    "obj21_make_position": (">hh", "x y"),
    "palptr": (">IHH", "palette destination count_minus_one"),
    "results_screen_object": (">hhhBB", "start_x target_x y routine frame"),
    "obj0e_make_sprite_position": (">hh", "x y"),
    "objsubdecl": (">IHBB", "frame_and_mappings art_tile width priority"),
    "obj7a_properties": (">BBhh", "children_minus_one origin_x_bits parent_x child_x"),
    "obj43_properties": (">BBhh", "children_minus_one origin_x_bits parent_x child_x"),
    "obj6b_properties": (">BBBB", "width height frame reserved"),
    "obj28decl": (">hhI", "x_velocity y_velocity mappings"),
    "teleporttableentry": (">HHH", "player_one_address player_two_address count_minus_one"),
}
KINDS = {
    *SCHEMAS,
    "credittext",
    "menutxt",
    "credits_layout",
    "credits_pages",
    "c7anilistheader",
    "robot_program",
    "robot_children",
    "titleletters",
    "begin_animpat",
    "zoneanimstart",
    "objda_make_x_positions",
    "sprite_scale",
    "dbglistheader",
    "plrlistheader",
    "projectile_burst",
}


def slots(rows):
    for row in rows:
        if row[0] != 0 and (row[0] & 1 or not 0x2C <= row[0] <= 0x3E):
            raise ValueError("Robot child slot is not an object pointer field")


def decode(kind, data):
    data = bytes(data)
    if kind in SCHEMAS:
        grammar, fields = SCHEMAS[kind]
        if len(data) != struct.calcsize(grammar):
            raise ValueError("Truncated or oversized " + kind + " record")
        model = dict(zip(fields.split(), struct.unpack(grammar, data)))
        if kind == "childobjectdata" and (
            model["parent_slot"] & 1 or model["parent_slot"] > 0x3E or not model["object_id"]
        ):
            raise ValueError("Invalid child spawn object or parent-link field")
        if kind == "c9palinfo" and (
            model["destination_offset"] & 1
            or model["destination_offset"] + 2 * (model["count_minus_one"] + 1) > 128
            or model["period"] > 127
            or model["steps"] > 127
        ):
            raise ValueError("Palette transition exceeds palette RAM or signed counters")
        if kind == "obj63_data" and model["flip_flags"] not in {0, 1}:
            raise ValueError("Shadow record has unsupported render flags")
        if kind == "titlecardobjdata" and (model["routine"] & 1 or model["routine"] > 0xC):
            raise ValueError("Title-card routine is outside its dispatch table")
        if kind == "palptr" and (model["destination"] & 1 or model["count_minus_one"] > 31):
            raise ValueError("Palette descriptor leaves the palette-word allocation")
        if kind == "obj6b_properties" and model["reserved"] != 0:
            raise ValueError("Platform property reserved byte must remain zero")
        if kind == "teleporttableentry" and any(
            model[field] & 1 or model[field] + 2 * (model["count_minus_one"] + 1) > 0x10000
            for field in ("player_one_address", "player_two_address")
        ):
            raise ValueError("Teleport swap region leaves its RAM word address space")
        return model
    if kind in {"dbglistheader", "plrlistheader"}:
        width = 8 if kind == "dbglistheader" else 6
        if len(data) < 2:
            raise ValueError("Object/art list lacks its count word")
        count = int.from_bytes(data[:2], "big")
        if kind == "plrlistheader":
            count = (count + 1) & 0xFFFF
        if len(data) != 2 + width * count:
            raise ValueError("Object/art list count exceeds its source allocation")
        entries = []
        for index in range(2, len(data), width):
            if width == 8:
                combined, subtype, frame, art_tile = struct.unpack(">IBBH", data[index : index + width])
                entries.append(
                    {
                        "object_id": combined >> 24,
                        "mappings": combined & 0xFFFFFF,
                        "subtype": subtype,
                        "frame": frame,
                        "art_tile": art_tile,
                    }
                )
            else:
                art, destination = struct.unpack(">IH", data[index : index + width])
                if not 0 < art < 0x100000 or destination & 0x1F:
                    raise ValueError("Pattern load request has an invalid art pointer or VRAM tile address")
                entries.append({"art": art, "destination": destination})
        return {"entries": entries}
    if kind == "objda_make_x_positions":
        if not data or len(data) % 2:
            raise ValueError("Continue layout has a partial position word")
        return {"positions": list(struct.unpack(">" + "h" * (len(data) // 2), data))}
    if kind == "projectile_burst":
        if not data or len(data) % 6 or len(data) // 6 > 63:
            raise ValueError("Projectile burst exceeds its six-byte records or object capacity")
        entries = [
            dict(
                zip(
                    "x_offset y_offset x_velocity_high y_velocity_high frame flip_flags".split(),
                    struct.unpack(">bbbbBB", data[i : i + 6]),
                )
            )
            for i in range(0, len(data), 6)
        ]
        if any(row["flip_flags"] not in {0, 1} for row in entries):
            raise ValueError("Projectile record has unsupported render flags")
        return {"projectiles": entries}
    if kind == "sprite_scale":
        if not data or len(data) % 10:
            raise ValueError("Sprite scaling region has a partial descriptor")
        return {
            "regions": [
                dict(
                    zip(
                        "source destination width_minus_one height_minus_one".split(),
                        struct.unpack(">IIBB", data[i : i + 10]),
                    )
                )
                for i in range(0, len(data), 10)
            ]
        }
    if kind == "credittext":
        if len(data) < 2 or data[-1] != 0xFF or 0xFF in data[1:-1] or any(value > 0x41 for value in data[1:-1]):
            raise ValueError("Invalid bounded credits glyph stream or terminator")
        return {"attributes": data[0], "glyphs": list(data[1:-1])}
    if kind == "menutxt":
        if len(data) < 2 or len(data) != data[0] + 2:
            raise ValueError("Menu text count does not fit its bounded record")
        if any(value != 0 and not 0x10 <= value <= 0x37 for value in data[1:]):
            raise ValueError("Menu glyph is outside the declared source character set")
        return {"glyphs": list(data[1:])}
    if kind in {"c7anilistheader", "robot_children"}:
        header = 2 if kind == "c7anilistheader" else 1
        if len(data) < header or len(data) != header + (data[0] + 1) * 3:
            raise ValueError("Robot motion count exceeds the bounded record")
        rows = [list(struct.unpack(">Bbb", data[index : index + 3])) for index in range(header, len(data), 3)]
        slots(rows)
        model = {"children": [{"slot": slot, "dx": dx, "dy": dy} for slot, dx, dy in rows]}
        if header == 2:
            model["duration"] = data[1]
        return model
    if kind == "credits_layout":
        if len(data) < 2 or data[-2:] != b"\xff\xff" or (len(data) - 2) % 6:
            raise ValueError("Credits layout lacks its two-byte sentinel")
        rows = []
        for index in range(0, len(data) - 2, 6):
            pointer, destination = struct.unpack(">IH", data[index : index + 6])
            if not 0 < pointer < 0x100000 or destination & 1:
                raise ValueError("Credits layout has an invalid text pointer or VRAM word position")
            rows.append({"text": pointer, "destination": destination})
        return {"entries": rows}
    if kind == "credits_pages":
        if len(data) < 4 or len(data) % 4 or data[-4:] != b"\xff" * 4:
            raise ValueError("Credits page list lacks its long sentinel")
        values = list(struct.unpack(">" + "I" * (len(data) // 4 - 1), data[:-4]))
        if any(not 0 < value < 0x100000 or value & 1 for value in values):
            raise ValueError("Invalid credits page pointer")
        return {"pages": values}
    if kind == "titleletters":
        if len(data) < 2 or len(data) % 2 or data[-2:] != b"\xff\xff":
            raise ValueError("Title-letter records lack their word terminator")
        if any(data[i] & 1 or data[i] > 0x5A or data[i + 1] not in {2, 4, 6} for i in range(0, len(data) - 2, 2)):
            raise ValueError("Title letter is outside the source glyph/width codebook")
        return {"letters": [{"tile": data[i], "width": data[i + 1]} for i in range(0, len(data) - 2, 2)]}
    if kind == "begin_animpat":
        if len(data) < 4 or len(data) % 2:
            raise ValueError("Animated block pattern is truncated")
        offset, count = struct.unpack(">HH", data[:4])
        if (count + 1) * 2 != len(data) - 4 or offset + len(data) - 4 != 0x1800:
            raise ValueError("Animated block destination or count differs from its block-table slot")
        return {"destination": offset, "tiles": list(struct.unpack(">" + "H" * (count + 1), data[4:]))}
    if kind == "robot_program":
        if len(data) < 5:
            raise ValueError("Robot program has no bounded command stream")
        cursor, events = 4, []
        while cursor < len(data):
            value = data[cursor]
            cursor += 1
            if value >= 0xC0:
                events.append({"kind": "restart", "code": value})
                break
            if value & 0xC0 == 0x40:
                if cursor >= len(data):
                    raise ValueError("Robot sound control has no sound ID")
                events.append({"kind": "sound", "fallback_frame": value & 0x3F, "id": data[cursor]})
                cursor += 1
            else:
                events.append({"kind": "frame", "index": value & 0x3F, "mirrored": bool(value & 0x80)})
        tail = data[cursor:]
        if not events or events[-1]["kind"] != "restart" or len(tail) > 1 or any(tail):
            raise ValueError("Robot program lacks its restart control or has unclaimed commands")
        return {"table": int.from_bytes(data[:4], "big"), "events": events, "alignment": len(tail)}
    if kind == "zoneanimstart":
        if len(data) < 2:
            raise ValueError("Animated tile list has no count")
        count = int.from_bytes(data[:2], "big") + 1
        cursor = 2
        scripts = []
        for _ in range(count):
            if cursor + 8 > len(data):
                raise ValueError("Truncated animated tile descriptor")
            duration, art, destination, frames, tiles = (
                data[cursor],
                int.from_bytes(data[cursor + 1 : cursor + 4], "big"),
                int.from_bytes(data[cursor + 4 : cursor + 6], "big"),
                data[cursor + 6],
                data[cursor + 7],
            )
            cursor += 8
            width = 2 if duration == 0xFF else 1
            end = cursor + frames * width
            if not frames or not tiles or destination + tiles * 32 > 0x10000 or end > len(data):
                raise ValueError("Animated tile frames leave their record or VRAM destination")
            events = [
                {"tile": data[i], "duration": data[i + 1]} if width == 2 else {"tile": data[i]}
                for i in range(cursor, end, width)
            ]
            padding = data[end : end + (end & 1)]
            if padding not in {b"", b"\0"}:
                raise ValueError("Animated tile alignment is not zero")
            cursor = end + len(padding)
            scripts.append(
                {"period": duration, "art": art, "destination": destination, "tiles": tiles, "events": events}
            )
        if cursor != len(data):
            raise ValueError("Animated tile list has unclaimed bytes")
        return {"scripts": scripts}
    raise ValueError("Unknown engine record grammar: " + kind)


def encode(kind, model):
    if kind in SCHEMAS:
        grammar, fields = SCHEMAS[kind]
        keys(model, fields)
        if any(type(model[field]) is not int for field in fields.split()):
            raise ValueError("Engine numeric fields must be integers")
        try:
            result = struct.pack(grammar, *(model[field] for field in fields.split()))
        except (struct.error, TypeError) as error:
            raise ValueError("Engine field leaves its declared width") from error
    elif kind in {"dbglistheader", "plrlistheader"}:
        keys(model, "entries")
        count = len(model["entries"])
        stored = count if kind == "dbglistheader" else (count - 1) & 0xFFFF
        result = uint(stored, 16, "list count").to_bytes(2, "big")
        for row in model["entries"]:
            if kind == "dbglistheader":
                keys(row, "object_id mappings subtype frame art_tile")
                combined = uint(row["object_id"], 8, "debug object ID") << 24 | uint(
                    row["mappings"], 24, "debug mappings"
                )
                result += (
                    combined.to_bytes(4, "big")
                    + bytes([uint(row["subtype"], 8, "subtype"), uint(row["frame"], 8, "debug frame")])
                    + uint(row["art_tile"], 16, "debug art tile").to_bytes(2, "big")
                )
            else:
                keys(row, "art destination")
                result += uint(row["art"], 32, "art pointer").to_bytes(4, "big") + uint(
                    row["destination"], 16, "VRAM destination"
                ).to_bytes(2, "big")
    elif kind == "projectile_burst":
        keys(model, "projectiles")
        result = b""
        for row in model["projectiles"]:
            fields = "x_offset y_offset x_velocity_high y_velocity_high frame flip_flags"
            keys(row, fields)
            try:
                result += struct.pack(">bbbbBB", *(row[field] for field in fields.split()))
            except (struct.error, TypeError) as error:
                raise ValueError("Projectile field leaves its signed/unsigned byte") from error
    elif kind == "objda_make_x_positions":
        keys(model, "positions")
        try:
            result = struct.pack(">" + "h" * len(model["positions"]), *model["positions"])
        except struct.error as error:
            raise ValueError("Continue position leaves its signed word") from error
    elif kind == "sprite_scale":
        keys(model, "regions")
        result = b""
        for row in model["regions"]:
            keys(row, "source destination width_minus_one height_minus_one")
            result += (
                uint(row["source"], 32, "scale source").to_bytes(4, "big")
                + uint(row["destination"], 32, "scale destination").to_bytes(4, "big")
                + bytes(
                    [uint(row["width_minus_one"], 8, "scale width"), uint(row["height_minus_one"], 8, "scale height")]
                )
            )
    elif kind == "credittext":
        keys(model, "attributes glyphs")
        result = bytes(
            [
                uint(model["attributes"], 8, "text attributes"),
                *(uint(value, 8, "glyph") for value in model["glyphs"]),
                0xFF,
            ]
        )
    elif kind == "menutxt":
        keys(model, "glyphs")
        result = bytes(
            [uint(len(model["glyphs"]) - 1, 8, "glyph count"), *(uint(value, 8, "glyph") for value in model["glyphs"])]
        )
    elif kind in {"c7anilistheader", "robot_children"}:
        keys(model, "children duration" if kind == "c7anilistheader" else "children")
        result = bytes([uint(len(model["children"]) - 1, 8, "child count")])
        if kind == "c7anilistheader":
            result += bytes([uint(model["duration"], 8, "duration")])
        for row in model["children"]:
            keys(row, "slot dx dy")
            try:
                result += struct.pack(">Bbb", row["slot"], row["dx"], row["dy"])
            except struct.error as error:
                raise ValueError("Motion delta leaves its signed byte") from error
    elif kind == "credits_layout":
        keys(model, "entries")
        result = b""
        for row in model["entries"]:
            keys(row, "text destination")
            result += uint(row["text"], 32, "text pointer").to_bytes(4, "big") + uint(
                row["destination"], 16, "VRAM destination"
            ).to_bytes(2, "big")
        result += b"\xff\xff"
    elif kind == "credits_pages":
        keys(model, "pages")
        result = b"".join(uint(value, 32, "page pointer").to_bytes(4, "big") for value in model["pages"]) + b"\xff" * 4
    elif kind == "titleletters":
        keys(model, "letters")
        result = (
            b"".join(
                bytes([uint(row["tile"], 8, "letter tile"), uint(row["width"], 8, "letter width")])
                for row in model["letters"]
            )
            + b"\xff\xff"
        )
    elif kind == "begin_animpat":
        keys(model, "destination tiles")
        result = (
            uint(model["destination"], 16, "block destination").to_bytes(2, "big")
            + uint(len(model["tiles"]) - 1, 16, "block count").to_bytes(2, "big")
            + b"".join(uint(value, 16, "block tile").to_bytes(2, "big") for value in model["tiles"])
        )
    elif kind == "robot_program":
        keys(model, "table events alignment")
        result = uint(model["table"], 32, "motion table").to_bytes(4, "big")
        for row in model["events"]:
            if row["kind"] == "frame":
                keys(row, "kind index mirrored")
                if type(row["mirrored"]) is not bool:
                    raise ValueError("Motion mirroring must be Boolean")
                result += bytes([uint(row["index"], 6, "motion frame") | (0x80 if row["mirrored"] else 0)])
            elif row["kind"] == "sound":
                keys(row, "kind fallback_frame id")
                result += bytes(
                    [0x40 | uint(row["fallback_frame"], 6, "sound fallback frame"), uint(row["id"], 8, "sound ID")]
                )
            elif row["kind"] == "restart":
                keys(row, "kind code")
                value = uint(row["code"], 8, "restart code")
                if value < 0xC0:
                    raise ValueError("Restart code lacks its control flag")
                result += bytes([value])
            else:
                raise ValueError("Unknown motion control")
        result += bytes(uint(model["alignment"], 1, "alignment"))
    elif kind == "zoneanimstart":
        keys(model, "scripts")
        result = uint(len(model["scripts"]) - 1, 16, "script count").to_bytes(2, "big")
        for row in model["scripts"]:
            keys(row, "period art destination tiles events")
            result += (
                bytes([uint(row["period"], 8, "period")])
                + uint(row["art"], 24, "art pointer").to_bytes(3, "big")
                + uint(row["destination"], 16, "VRAM destination").to_bytes(2, "big")
                + bytes([uint(len(row["events"]), 8, "frame count"), uint(row["tiles"], 8, "tile count")])
            )
            for event in row["events"]:
                keys(event, "tile duration" if row["period"] == 0xFF else "tile")
                result += bytes([uint(event["tile"], 8, "art frame")])
                if row["period"] == 0xFF:
                    result += bytes([uint(event["duration"], 8, "frame duration")])
            result += bytes(len(result) & 1)
    else:
        raise ValueError("Unknown engine record grammar: " + kind)
    decode(kind, result)
    return result
