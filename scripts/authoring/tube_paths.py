"""CPZ and MTZ spin-tube path tables: relative aliases and word XY records."""

from scripts.authoring.struct_formats import keys, uint
from scripts.authoring.ss_tables import boundaries, pack_container


def decode(data, count):
    if type(count) is not int or not 1 <= count <= 16:
        raise ValueError("Tube path selector exceeds its four-bit subtype ABI")
    if len(data) > 0x8000:
        raise ValueError("Tube path container exceeds signed-word addressing")
    offsets, unique, ends = boundaries(data, count)
    paths = []
    for start in unique:
        stop = ends[start]
        if stop - start < 6:
            raise ValueError("Tube path has no complete point")
        size = int.from_bytes(data[start : start + 2], "big")
        if size == 0 or size % 4 or size > 0x7FFC or start + size + 2 != stop:
            raise ValueError("Tube path byte length differs from its word cursor or point records")
        points = []
        for cursor in range(start + 2, stop, 4):
            points.append(
                {
                    "x": int.from_bytes(data[cursor : cursor + 2], "big"),
                    "y": int.from_bytes(data[cursor + 2 : cursor + 4], "big"),
                }
            )
        paths.append(points)
    return {"references": [unique.index(value) for value in offsets], "paths": paths}


def encode(model):
    keys(model, "references paths")
    count = len(model["references"])
    if not 1 <= count <= 16:
        raise ValueError("Tube path selector exceeds its four-bit subtype ABI")
    records = []
    for points in model["paths"]:
        if not 1 <= len(points) <= 8191:
            raise ValueError("Tube path exceeds its word-indexed XY point capacity")
        body = bytearray()
        for point in points:
            keys(point, "x y")
            body.extend(uint(point["x"], 16, "path X").to_bytes(2, "big"))
            body.extend(uint(point["y"], 16, "path Y").to_bytes(2, "big"))
        records.append(len(body).to_bytes(2, "big") + body)
    return pack_container(model["references"], records, count)
