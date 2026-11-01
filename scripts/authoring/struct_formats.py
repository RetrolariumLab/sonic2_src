"""Lossless structural codecs for Sonic 2 retail level and graphics records.

This API consumes decoded payloads. Compression and ROM placement are
separate contracts; no filesystem or user-interface operations occur here.
"""

from dataclasses import dataclass
from typing import Callable
import struct


def uint(value, bits, name):
    if type(value) is not int or not 0 <= value < 1 << bits:
        raise ValueError(f"{name} must be an unsigned {bits}-bit integer")
    return value


def flag(value, name):
    if type(value) is not bool:
        raise ValueError(name + " must be Boolean")
    return int(value)


def keys(record, names):
    if not isinstance(record, dict) or set(record) != set(names.split()):
        raise ValueError("Unexpected fields; expected " + names)


def words(data):
    if len(data) % 2:
        raise ValueError("Truncated 16-bit record")
    return [int.from_bytes(data[i : i + 2], "big") for i in range(0, len(data), 2)]


def pack_words(values):
    return b"".join(uint(value, 16, "word").to_bytes(2, "big") for value in values)


def tile_decode(value):
    return dict(
        index=value & 0x7FF,
        x_flip=bool(value & 0x800),
        y_flip=bool(value & 0x1000),
        palette=(value >> 13) & 3,
        priority=bool(value & 0x8000),
    )


def tile_encode(row):
    keys(row, "index x_flip y_flip palette priority")
    return (
        uint(row["index"], 11, "tile index")
        | (flag(row["x_flip"], "x_flip") << 11)
        | (flag(row["y_flip"], "y_flip") << 12)
        | (uint(row["palette"], 2, "palette") << 13)
        | (flag(row["priority"], "priority") << 15)
    )


def block_decode(value):
    return dict(
        index=value & 0x3FF,
        x_flip=bool(value & 0x400),
        y_flip=bool(value & 0x800),
        primary_solidity=(value >> 12) & 3,
        secondary_solidity=(value >> 14) & 3,
    )


def block_encode(row):
    keys(row, "index x_flip y_flip primary_solidity secondary_solidity")
    return (
        uint(row["index"], 10, "block index")
        | (flag(row["x_flip"], "x_flip") << 10)
        | (flag(row["y_flip"], "y_flip") << 11)
        | (uint(row["primary_solidity"], 2, "primary solidity") << 12)
        | (uint(row["secondary_solidity"], 2, "secondary solidity") << 14)
    )


def decode_tiles(data):
    if len(data) % 32:
        raise ValueError("Truncated 8x8 4bpp tile")
    return [[nibble for byte in data[i : i + 32] for nibble in (byte >> 4, byte & 15)] for i in range(0, len(data), 32)]


def encode_tiles(tiles):
    output = bytearray()
    for tile in tiles:
        if len(tile) != 64:
            raise ValueError("An 8x8 tile needs 64 pixels")
        output.extend((uint(tile[i], 4, "pixel") << 4) | uint(tile[i + 1], 4, "pixel") for i in range(0, 64, 2))
    return bytes(output)


def decode_map(data):
    return [tile_decode(value) for value in words(data)]


def encode_map(rows):
    return pack_words(tile_encode(row) for row in rows)


def decode_groups(data, size, decoder):
    values = words(data)
    if len(values) % size:
        raise ValueError("Truncated grouped tile/block record")
    return [[decoder(value) for value in values[i : i + size]] for i in range(0, len(values), size)]


def encode_groups(rows, size, encoder):
    if any(len(row) != size for row in rows):
        raise ValueError("Wrong grouped tile/block dimensions")
    return pack_words(encoder(value) for row in rows for value in row)


def decode_layout(data):
    if len(data) != 4096:
        raise ValueError("Sonic 2 layout needs 16 rows of 128 FG and 128 BG bytes")
    return {
        name: [list(data[y * 256 + plane * 128 : y * 256 + plane * 128 + 128]) for y in range(16)]
        for plane, name in enumerate(["foreground", "background"])
    }


def encode_layout(rows):
    keys(rows, "foreground background")
    if any(len(rows[name]) != 16 or any(len(row) != 128 for row in rows[name]) for name in rows):
        raise ValueError("Sonic 2 layout dimensions must remain 128x16 per plane")
    return bytes(
        uint(value, 8, "chunk index")
        for y in range(16)
        for name in ["foreground", "background"]
        for value in rows[name][y]
    )


def decode_objects(data):
    if len(data) % 6:
        raise ValueError("Truncated six-byte object placement")
    result = []
    for x, value, kind, subtype in struct.iter_unpack(">HHBB", data):
        result.append(
            dict(
                x=x,
                y=value & 0xFFF,
                respawn=bool(value & 0x8000),
                y_flip=bool(value & 0x4000),
                x_flip=bool(value & 0x2000),
                mode_flag=bool(value & 0x1000),
                object_id=kind,
                subtype=subtype,
            )
        )
    return result


def encode_objects(rows):
    output = bytearray()
    for row in rows:
        keys(row, "x y respawn y_flip x_flip mode_flag object_id subtype")
        x = uint(row["x"], 16, "x")
        if x == 0xFFFF:
            raise ValueError("Object X collides with the generated boundary marker")
        value = uint(row["y"], 12, "y")
        for shift, name in [(15, "respawn"), (14, "y_flip"), (13, "x_flip"), (12, "mode_flag")]:
            value |= flag(row[name], name) << shift
        output.extend(
            struct.pack(">HHBB", x, value, uint(row["object_id"], 8, "object_id"), uint(row["subtype"], 8, "subtype"))
        )
    if sum(row["respawn"] for row in rows) > 255:
        raise ValueError("Object respawn index exceeds its byte ABI")
    return bytes(output)


def decode_rings(data):
    if len(data) < 2 or len(data) % 4 != 2 or data[-2:] != b"\xff\xff":
        raise ValueError("Ring groups need complete four-byte records and an FFFF X terminator")
    rows = []
    for x, value in struct.iter_unpack(">HH", data[:-2]):
        if x == 0xFFFF:
            raise ValueError("Premature ring terminator")
        rows.append(dict(x=x, y=value & 0xFFF, count=((value >> 12) & 7) + 1, vertical=bool(value & 0x8000)))
    return rows


def encode_rings(rows):
    output = bytearray()
    total = 0
    for row in rows:
        keys(row, "x y count vertical")
        x = uint(row["x"], 16, "x")
        y = uint(row["y"], 12, "y")
        count = uint(row["count"], 4, "ring count")
        vertical = flag(row["vertical"], "vertical")
        if not 1 <= count <= 8:
            raise ValueError("Ring groups need one to eight rings")
        if x == 0xFFFF:
            raise ValueError("Ring X collides with the terminator")
        if (y if vertical else x) + (count - 1) * 24 > 0xFFFF:
            raise ValueError("Ring group wraps its 16-bit coordinates")
        output.extend(struct.pack(">HH", x, y | ((count - 1) << 12) | (vertical << 15)))
        total += count
    if total > 255:
        raise ValueError("Expanded rings exceed the 255 usable position slots")
    return bytes(output) + b"\xff\xff"


def decode_start(data):
    if len(data) != 4:
        raise ValueError("Start position needs two big-endian words")
    x, y = struct.unpack(">HH", data)
    return dict(x=x, y=y)


def encode_start(row):
    keys(row, "x y")
    return pack_words([row["x"], row["y"]])


def decode_palette(data):
    return [dict(red=(v >> 1) & 7, green=(v >> 5) & 7, blue=(v >> 9) & 7, reserved=v & 0xF111) for v in words(data)]


def encode_palette(rows):
    values = []
    for row in rows:
        keys(row, "red green blue reserved")
        reserved = uint(row["reserved"], 16, "reserved")
        if reserved & ~0xF111:
            raise ValueError("Palette reserved bits overlap RGB bits")
        values.append(
            (uint(row["red"], 3, "red") << 1)
            | (uint(row["green"], 3, "green") << 5)
            | (uint(row["blue"], 3, "blue") << 9)
            | reserved
        )
    return pack_words(values)


def decode_special_tile_rows(data):
    if len(data) < 2:
        raise ValueError("Missing special-stage row count")
    count = int.from_bytes(data[:2], "big")
    end = 2 + count * 4
    if not count or end > len(data):
        raise ValueError("Truncated special-stage tile rows")
    return {
        "rows": [[n for byte in data[i : i + 4] for n in (byte >> 4, byte & 15)] for i in range(2, end, 4)],
        "trailer": list(data[end:]),
    }


def encode_special_tile_rows(model):
    keys(model, "rows trailer")
    rows = model["rows"]
    if not 0 < len(rows) <= 2048:
        raise ValueError("Special-stage tiles exceed VRAM tile index capacity")
    if any(len(row) != 8 for row in rows):
        raise ValueError("Special-stage tile rows need eight 4bpp pixels")
    result = len(rows).to_bytes(2, "big") + bytes(
        (uint(row[i], 4, "pixel") << 4) | uint(row[i + 1], 4, "pixel") for row in rows for i in range(0, 8, 2)
    )
    return result + bytes(uint(v, 8, "trailer byte") for v in model["trailer"])


def decode_bumpers(data):
    if len(data) < 6 or len(data) % 6 or data[-4:-2] != b"\xff\xff":
        raise ValueError("Bumper records need a complete six-byte X terminator")
    rows = []
    for kind, x, y in struct.iter_unpack(">HHH", data[:-6]):
        if x == 0xFFFF:
            raise ValueError("Premature bumper X terminator")
        rows.append({"kind": kind, "x": x, "y": y})
    kind, _, y = struct.unpack(">HHH", data[-6:])
    return {"bumpers": rows, "terminator": {"kind": kind, "y": y}}


def encode_bumpers(model):
    keys(model, "bumpers terminator")
    result = bytearray()
    for row in model["bumpers"]:
        keys(row, "kind x y")
        x = uint(row["x"], 16, "x")
        if x == 0xFFFF:
            raise ValueError("Bumper X collides with terminator")
        result.extend(struct.pack(">HHH", uint(row["kind"], 16, "bumper kind"), x, uint(row["y"], 16, "y")))
    end = model["terminator"]
    keys(end, "kind y")
    result.extend(
        struct.pack(">HHH", uint(end["kind"], 16, "terminator kind"), 0xFFFF, uint(end["y"], 16, "terminator y"))
    )
    return bytes(result)


def decode_collision_heights(data):
    if len(data) != 4096:
        raise ValueError("Collision height arrays need 256 shapes of 16 signed samples")
    return [[v if v < 128 else v - 256 for v in data[i : i + 16]] for i in range(0, len(data), 16)]


def encode_collision_heights(rows):
    if len(rows) != 256 or any(len(row) != 16 for row in rows):
        raise ValueError("Collision height dimensions must remain 256x16")
    values = []
    for row in rows:
        for value in row:
            if type(value) is not int or not -128 <= value <= 127:
                raise ValueError("Collision sample must fit a signed byte")
            values.append(value & 255)
    return bytes(values)


def decode_byte_table(data, size):
    if len(data) != size:
        raise ValueError("Wrong fixed byte-table capacity")
    return list(data)


def encode_byte_table(values, size):
    if len(values) != size:
        raise ValueError("Wrong fixed byte-table capacity")
    return bytes(uint(value, 8, "table entry") for value in values)


@dataclass(frozen=True)
class Codec:
    decode: Callable
    encode: Callable


FORMATS = {
    "cnz-bumper-placement": Codec(decode_bumpers, encode_bumpers),
    "collision-heights-s2": Codec(decode_collision_heights, encode_collision_heights),
    "collision-angles-s2": Codec(lambda data: decode_byte_table(data, 256), lambda rows: encode_byte_table(rows, 256)),
    "collision-index-s2": Codec(lambda data: decode_byte_table(data, 768), lambda rows: encode_byte_table(rows, 768)),
    "special-stage-tile-rows": Codec(decode_special_tile_rows, encode_special_tile_rows),
    "tiles-4bpp": Codec(decode_tiles, encode_tiles),
    "tilemap": Codec(decode_map, encode_map),
    "blocks-16x16": Codec(
        lambda data: decode_groups(data, 4, tile_decode), lambda rows: encode_groups(rows, 4, tile_encode)
    ),
    "chunks-128x128": Codec(
        lambda data: decode_groups(data, 64, block_decode), lambda rows: encode_groups(rows, 64, block_encode)
    ),
    "level-layout-s2": Codec(decode_layout, encode_layout),
    "object-placement-s2": Codec(decode_objects, encode_objects),
    "ring-groups-s2": Codec(decode_rings, encode_rings),
    "start-position-s2": Codec(decode_start, encode_start),
    "palette-md": Codec(decode_palette, encode_palette),
}
