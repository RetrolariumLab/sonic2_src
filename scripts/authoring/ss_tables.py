"""S2 special-stage tables and shared trigonometric lookup records."""

import struct
from scripts.authoring.struct_formats import keys, uint


def signed(value, bits):
    return value if value < 1 << (bits - 1) else value - (1 << bits)


def sbyte(value, name):
    if type(value) is not int or not -128 <= value <= 127:
        raise ValueError(name + " must fit a signed byte")
    return value & 255


def boundaries(data, count, trailer_size=0):
    header = count * 2
    end = len(data) - trailer_size
    if end < header:
        raise ValueError("Truncated offset table")
    offsets = list(struct.unpack(">" + str(count) + "H", data[:header]))
    unique = sorted(set(offsets))
    if not unique or unique[0] != header or any(offset >= end or offset >= 0x8000 for offset in offsets):
        raise ValueError("Offset leaves the table or its signed-word addressing range")
    return (
        offsets,
        unique,
        {start: (unique[index + 1] if index + 1 < len(unique) else end) for index, start in enumerate(unique)},
    )


def pack_container(references, records, expected):
    if len(references) != expected or not records:
        raise ValueError("Wrong offset-table entry count")
    offsets = []
    at = expected * 2
    for record in records:
        if at >= 0x8000:
            raise ValueError("Table offset exceeds signed-word addressing")
        offsets.append(at)
        at += len(record)
    if at > 0x8000:
        raise ValueError("Table payload exceeds signed-word addressing")
    pointers = []
    for ref in references:
        if type(ref) is not int or not 0 <= ref < len(records):
            raise ValueError("Table reference has no owned record")
        pointers.append(offsets[ref])
    if set(references) != set(range(len(records))):
        raise ValueError("Unreferenced record in an indexed container")
    return b"".join(pointer.to_bytes(2, "big") for pointer in pointers) + b"".join(records)


def decode_geometry(data):
    offsets, unique, ends = boundaries(data, 7)
    if len(unique) != 7 or offsets != unique:
        raise ValueError("Retail stage geometry uses seven ordered independent stage arrays")
    stages = []
    for start in offsets:
        stage = []
        for value in data[start : ends[start]]:
            if value & 0x7F > 4:
                raise ValueError("Stage geometry refers to an unknown animation")
            stage.append({"animation": value & 0x7F, "flipped": bool(value & 128)})
        stages.append(stage)
    return stages


def encode_geometry(stages):
    if len(stages) != 7:
        raise ValueError("Seven retail special stages are required")
    records = []
    for stage in stages:
        if not 1 <= len(stage) <= 256:
            raise ValueError("Segment count exceeds the byte-index ABI")
        record = []
        for row in stage:
            keys(row, "animation flipped")
            kind = uint(row["animation"], 3, "animation")
            if kind > 4 or type(row["flipped"]) is not bool:
                raise ValueError("Unknown animation or flip flag")
            record.append(kind | (int(row["flipped"]) << 7))
        records.append(bytes(record))
    return pack_container(list(range(7)), records, 7)


def decode_objects(data, trailer_size=3):
    offsets, unique, ends = boundaries(data, 7, trailer_size)
    if len(unique) != 7 or offsets != unique:
        raise ValueError("Retail object streams use seven ordered stage arrays")
    stages = []
    for start in offsets:
        at = start
        end = ends[start]
        groups = []
        objects = []
        while at < end:
            value = data[at]
            at += 1
            if value & 128:
                groups.append({"objects": objects, "marker": value})
                objects = []
            else:
                if at >= end:
                    raise ValueError("Truncated special-stage object pair")
                objects.append(
                    {"kind": "bomb" if value & 64 else "ring", "distance_steps": value & 63, "angle": data[at]}
                )
                at += 1
        if objects:
            raise ValueError("Special-stage object group has no closing marker")
        stages.append(groups)
    return {"stages": stages, "trailer": list(data[-trailer_size:]) if trailer_size else []}


def encode_objects(model, trailer_size=3, max_objects_per_group=None):
    keys(model, "stages trailer")
    if len(model["stages"]) != 7 or len(model["trailer"]) != trailer_size:
        raise ValueError("Wrong stage count or retail trailer extent")
    records = []
    for stage in model["stages"]:
        if len(stage) > 256:
            raise ValueError("Object group count exceeds the segment index ABI")
        record = bytearray()
        for group in stage:
            keys(group, "objects marker")
            marker = uint(group["marker"], 8, "group marker")
            if marker < 128:
                raise ValueError("Object group marker must have its sign bit set")
            if max_objects_per_group is not None and len(group["objects"]) > max_objects_per_group:
                raise ValueError("Special-stage group exceeds the dynamic object slots")
            for row in group["objects"]:
                keys(row, "kind distance_steps angle")
                if row["kind"] not in {"ring", "bomb"}:
                    raise ValueError("Unknown special-stage object kind")
                record.extend(
                    [
                        uint(row["distance_steps"], 6, "distance steps") | (64 if row["kind"] == "bomb" else 0),
                        uint(row["angle"], 8, "angle"),
                    ]
                )
            record.append(marker)
        records.append(bytes(record))
    return pack_container(list(range(7)), records, 7) + bytes(
        uint(value, 8, "trailer byte") for value in model["trailer"]
    )


PERSPECTIVE_FIELDS = ["center_x", "center_y", "radius_x", "radius_y", "occlusion_min", "occlusion_max"]


def decode_perspective(data):
    offsets, unique, ends = boundaries(data, 56)
    records = []
    for start in unique:
        body = data[start : ends[start]]
        if len(body) < 2 or (len(body) - 2) % 6:
            raise ValueError("Truncated six-byte perspective sample")
        limit = int.from_bytes(body[:2], "big")
        samples = []
        for values in struct.iter_unpack("6B", body[2:]):
            row = dict(zip(PERSPECTIVE_FIELDS, values))
            row["center_y"] = signed(row["center_y"], 8)
            samples.append(row)
        if limit > len(samples):
            raise ValueError("Perspective visible depth exceeds available samples")
        records.append({"visible_depth": limit, "samples": samples})
    return {"frames": [unique.index(offset) for offset in offsets], "records": records}


def encode_perspective(model):
    keys(model, "frames records")
    records = []
    for row in model["records"]:
        keys(row, "visible_depth samples")
        limit = uint(row["visible_depth"], 16, "visible depth")
        if limit > len(row["samples"]):
            raise ValueError("Perspective visible depth exceeds available samples")
        body = bytearray(limit.to_bytes(2, "big"))
        for sample in row["samples"]:
            keys(sample, " ".join(PERSPECTIVE_FIELDS))
            body.extend(
                sbyte(sample[name], name) if name == "center_y" else uint(sample[name], 8, name)
                for name in PERSPECTIVE_FIELDS
            )
        records.append(bytes(body))
    return pack_container(model["frames"], records, 56)


def decode_angles(data):
    if len(data) != 258:
        raise ValueError("Angle lookup needs 257 ratio entries and one preserved alignment byte")
    return {"angles": list(data[:257]), "alignment": data[257]}


def encode_angles(model):
    keys(model, "angles alignment")
    if len(model["angles"]) != 257:
        raise ValueError("Angle ratio domain must remain 0 through 256")
    return bytes(uint(value, 8, "angle") for value in model["angles"]) + bytes(
        [uint(model["alignment"], 8, "alignment")]
    )


def decode_sine(data):
    if len(data) != 640:
        raise ValueError("Sine table needs 256 cycle words and 64 cosine-extension words")
    values = list(struct.unpack(">320h", data))
    if values[256:] != values[:64]:
        raise ValueError("Cosine extension differs from the first sine quadrant")
    return values[:256]


def encode_sine(values):
    if len(values) != 256 or any(type(value) is not int or not -32768 <= value <= 32767 for value in values):
        raise ValueError("Sine table needs 256 signed words")
    return struct.pack(">320h", *(values + values[:64]))
