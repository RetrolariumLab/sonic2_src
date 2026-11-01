"""Sonic 2 sprite/DPLC tables, aliases, null frames and unused piece gaps."""

import struct
from scripts.authoring.struct_formats import uint, keys, tile_decode, tile_encode


def entries_decode(data, kind):
    stride = 8 if kind == "sprite" else 2
    if len(data) % stride:
        raise ValueError("Truncated mapping entry")
    rows = []
    for at in range(0, len(data), stride):
        if kind == "sprite":
            y, size, p1, p2, x = struct.unpack(">bBHHh", data[at : at + 8])
            rows.append(
                {
                    "x": x,
                    "y": y,
                    "width": ((size >> 2) & 3) + 1,
                    "height": (size & 3) + 1,
                    "size_reserved": size >> 4,
                    "single_player": tile_decode(p1),
                    "two_player": tile_decode(p2),
                }
            )
        else:
            word = int.from_bytes(data[at : at + 2], "big")
            rows.append({"tiles": (word >> 12) + 1, "source_tile": word & 0xFFF})
    return rows


def entries_encode(rows, kind):
    result = bytearray()
    for entry in rows:
        if kind == "sprite":
            keys(entry, "x y width height size_reserved single_player two_player")
            x = entry["x"]
            y = entry["y"]
            width = uint(entry["width"], 3, "width")
            height = uint(entry["height"], 3, "height")
            if type(x) is not int or not -32768 <= x <= 32767 or type(y) is not int or not -128 <= y <= 127:
                raise ValueError("Sprite position exceeds its signed coordinate ABI")
            if not 1 <= width <= 4 or not 1 <= height <= 4:
                raise ValueError("Sprite dimensions must be one through four tiles")
            size = (uint(entry["size_reserved"], 4, "size reserved") << 4) | ((width - 1) << 2) | (height - 1)
            result.extend(
                struct.pack(">bBHHh", y, size, tile_encode(entry["single_player"]), tile_encode(entry["two_player"]), x)
            )
        else:
            keys(entry, "tiles source_tile")
            count = uint(entry["tiles"], 5, "DPLC tile count")
            if not 1 <= count <= 16:
                raise ValueError("DPLC runs contain one through sixteen tiles")
            result.extend((((count - 1) << 12) | uint(entry["source_tile"], 12, "DPLC source tile")).to_bytes(2, "big"))
    return bytes(result)


def decode(data, frame_count, kind, frame_offsets=None):
    uint(frame_count, 16, "frame count")
    if kind not in {"sprite", "dplc"}:
        raise ValueError("Unknown mapping ABI")
    header = frame_count * 2
    stride = 8 if kind == "sprite" else 2
    if len(data) < header:
        raise ValueError("Truncated frame pointer table")
    offsets = list(struct.unpack(">" + str(frame_count) + "H", data[:header]))
    at = header
    frames = []
    starts = []
    gaps = []
    if frame_offsets is None:
        frame_offsets = []
        cursor = header
        while cursor < len(data):
            if cursor + 2 > len(data):
                raise ValueError("Truncated frame header")
            frame_offsets.append(cursor)
            cursor += 2 + int.from_bytes(data[cursor : cursor + 2], "big") * stride
        if cursor != len(data):
            raise ValueError(
                "Frame body leaves its table; source-owned frame boundaries are required for unused piece gaps"
            )
    if frame_offsets != sorted(set(frame_offsets)):
        raise ValueError("Frame boundaries must be distinct and ordered")
    for start in frame_offsets:
        if start < at or start + 2 > len(data):
            raise ValueError("Frame boundary overlaps another record or leaves its table")
        if start > at:
            gaps.append({"before_frame": len(frames), "entries": entries_decode(data[at:start], kind)})
        count = int.from_bytes(data[start : start + 2], "big")
        end = start + 2 + count * stride
        if end > len(data):
            raise ValueError("Frame body leaves its table")
        frames.append(entries_decode(data[start + 2 : end], kind))
        starts.append(start)
        at = end
    if at < len(data):
        gaps.append({"before_frame": len(frames), "entries": entries_decode(data[at:], kind)})
    references = []
    for offset in offsets:
        if offset == 0:
            if not offsets or offsets[0] != 0:
                raise ValueError("A null frame requires an empty first word at the table root")
            references.append(None)
        elif offset in starts:
            references.append(starts.index(offset))
        else:
            raise ValueError("Frame pointer does not reach an owned frame header")
    return {"references": references, "frames": frames, "gaps": gaps}


def encode(model, kind, max_pieces=80, max_transfer_tiles=None):
    keys(model, "references frames gaps")
    if kind not in {"sprite", "dplc"}:
        raise ValueError("Unknown mapping ABI")
    gap_map = {}
    for gap in model["gaps"]:
        keys(gap, "before_frame entries")
        index = gap["before_frame"]
        if type(index) is not int or not 0 <= index <= len(model["frames"]) or index in gap_map:
            raise ValueError("Unused-piece gap has no unique physical owner")
        gap_map[index] = entries_encode(gap["entries"], kind)
    offsets = []
    body = bytearray()
    header = len(model["references"]) * 2
    for index, frame in enumerate(model["frames"]):
        body.extend(gap_map.get(index, b""))
        if kind == "sprite" and len(frame) > max_pieces:
            raise ValueError("Sprite frame exceeds the hardware piece budget")
        if len(frame) > 65535:
            raise ValueError("Frame count exceeds its word header")
        if (
            kind == "dplc"
            and max_transfer_tiles is not None
            and sum(entry["tiles"] for entry in frame) > max_transfer_tiles
        ):
            raise ValueError("DPLC frame exceeds its pattern-transfer capacity")
        offsets.append(header + len(body))
        body.extend(len(frame).to_bytes(2, "big"))
        body.extend(entries_encode(frame, kind))
    body.extend(gap_map.get(len(model["frames"]), b""))
    pointers = []
    for reference in model["references"]:
        if reference is None:
            if not model["references"] or model["references"][0] is not None:
                raise ValueError("A null frame requires a zero first pointer")
            pointers.append(0)
            continue
        if type(reference) is not int or not 0 <= reference < len(offsets):
            raise ValueError("Frame reference has no owned body")
        pointer = offsets[reference]
        if pointer >= 0x8000:
            raise ValueError("Frame pointer exceeds signed word-offset capacity")
        pointers.append(pointer)
    return b"".join(pointer.to_bytes(2, "big") for pointer in pointers) + bytes(body)
