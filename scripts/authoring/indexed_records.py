"""Fixed source-owned indexed records with aliases, padding and retail exceptions."""

from dataclasses import dataclass
from scripts.authoring.struct_formats import keys, uint

KINDS = {
    "track-frames-s2",
    "background-scroll-s2",
    "phrase-words-s2",
    "message-glyphs-s2",
    "hud-layout-s2",
    "pulley-path-s2",
    "pulley-children-s2",
    "ending-frames-s2",
}


@dataclass(frozen=True)
class Spec:
    kind: str
    count: int
    size: int
    slots: tuple
    limit: int = 256
    object_slots: int = 0
    exceptions: tuple = ()

    def validate(self):
        if self.kind not in KINDS or type(self.count) is not int or not 1 <= self.count <= 256:
            raise ValueError("Unknown indexed-record ABI or invalid selector count")
        if type(self.size) is not int or not self.count * 2 < self.size <= 0x8000:
            raise ValueError("Indexed container leaves signed-word addressing")
        if type(self.slots) is not tuple or not self.slots:
            raise ValueError("Indexed source slots must be immutable")
        cursor = self.count * 2
        for row in self.slots:
            if type(row) is not tuple or len(row) != 2:
                raise ValueError("Indexed source slots must be immutable pairs")
            start, end = row
            if type(start) is not int or type(end) is not int or start != cursor or not start < end <= self.size:
                raise ValueError("Indexed source record slots overlap or leave a gap")
            cursor = end
        if self.size - cursor not in {0, 1}:
            raise ValueError("Only one explicit trailing alignment byte may be unclaimed")
        if type(self.object_slots) is not int or self.object_slots < 0:
            raise ValueError("Invalid object record capacity")
        if self.kind in {"hud-layout-s2", "pulley-children-s2"} and self.object_slots == 0:
            raise ValueError("Object layout has no allocated child capacity")
        if self.kind == "pulley-path-s2" and self.count > 16:
            raise ValueError("Pulley path selector exceeds its four-bit subtype")
        if self.kind == "pulley-children-s2" and self.count > 128:
            raise ValueError("Pulley child group selector exceeds its seven-bit subtype")
        if type(self.limit) is not int or self.limit < 1:
            raise ValueError("Invalid source-owned value capacity")
        if type(self.exceptions) is not tuple or any(
            type(row) is not tuple or len(row) != 2 for row in self.exceptions
        ):
            raise ValueError("Retail exceptions must be immutable byte cells")


def signed_word(value):
    return value if value < 0x8000 else value - 0x10000


def word_signed(value, name):
    if type(value) is not int or not -32768 <= value <= 32767:
        raise ValueError(name + " must fit a signed word")
    return (value & 0xFFFF).to_bytes(2, "big")


def decode_record(data, spec):
    kind = spec.kind
    if kind in {"track-frames-s2", "ending-frames-s2"}:
        return {"frames": list(data)}
    if kind == "background-scroll-s2":
        return {"increments": list(data)}
    if kind in {"phrase-words-s2", "message-glyphs-s2"}:
        if not data or data[-1] < 0x80 or any(value >= 0x80 for value in data[:-1]):
            raise ValueError("Message record lacks its final signed terminator")
        return {"selectors" if kind == "phrase-words-s2" else "frames": list(data[:-1]), "terminator": data[-1]}
    if kind == "hud-layout-s2":
        if len(data) < 3 or data[0] + 2 != len(data):
            raise ValueError("HUD sprite count differs from its frame selectors")
        return {"x": data[1], "frames": list(data[2:])}
    if kind == "pulley-path-s2":
        if len(data) < 6 or (len(data) - 2) % 4 or int.from_bytes(data[:2], "big") != len(data) - 2:
            raise ValueError("Pulley path byte length differs from XY records")
        return {
            "points": [
                {
                    "x": signed_word(int.from_bytes(data[at : at + 2], "big")),
                    "y": signed_word(int.from_bytes(data[at + 2 : at + 4], "big")),
                }
                for at in range(2, len(data), 4)
            ]
        }
    if kind == "pulley-children-s2":
        if len(data) < 8 or (len(data) - 2) % 6 or int.from_bytes(data[:2], "big") + 1 != (len(data) - 2) // 6:
            raise ValueError("Pulley child count differs from its six-byte records")
        return {
            "children": [
                {
                    "x": signed_word(int.from_bytes(data[at : at + 2], "big")),
                    "y": signed_word(int.from_bytes(data[at + 2 : at + 4], "big")),
                    "subtype": data[at + 5],
                    "reserved_subtype_high": data[at + 4],
                }
                for at in range(2, len(data), 6)
            ]
        }
    raise ValueError("Unknown indexed record kind")


def bounded_frames(values, limit, name):
    result = bytes(uint(value, 8, name) for value in values)
    if any(value >= limit for value in result):
        raise ValueError(name + " leaves its source-owned frame table")
    return result


def encode_record(model, spec, offset):
    kind = spec.kind
    if kind in {"track-frames-s2", "ending-frames-s2"}:
        keys(model, "frames")
        if kind == "ending-frames-s2" and len(model["frames"]) != 28:
            raise ValueError("Ending schedule must have 28 frame samples")
        return bounded_frames(model["frames"], spec.limit, "frame selector")
    if kind == "background-scroll-s2":
        keys(model, "increments")
        if len(model["increments"]) != 5:
            raise ValueError("Background scroll row needs five unsigned increments")
        return bytes(uint(value, 8, "zero-extended scroll increment") for value in model["increments"])
    if kind in {"phrase-words-s2", "message-glyphs-s2"}:
        field = "selectors" if kind == "phrase-words-s2" else "frames"
        keys(model, field + " terminator")
        result = bytearray()
        for index, value in enumerate(model[field]):
            uint(value, 7, "message selector")
            valid = value % 2 == 0 and value // 2 < spec.limit if kind == "phrase-words-s2" else value < spec.limit
            if not valid and (offset + index, value) not in spec.exceptions:
                raise ValueError("Message selector introduces an undeclared invalid reference")
            result.append(value)
        terminator = uint(model["terminator"], 8, "message terminator")
        if terminator < 0x80:
            raise ValueError("Message terminator must be negative in the engine's byte test")
        return bytes(result) + bytes([terminator])
    if kind == "hud-layout-s2":
        keys(model, "x frames")
        if not 1 <= len(model["frames"]) <= spec.object_slots:
            raise ValueError("HUD child sprites exceed their object record capacity")
        return bytes([len(model["frames"]), uint(model["x"], 8, "HUD X")]) + bounded_frames(
            model["frames"], spec.limit, "HUD frame"
        )
    if kind == "pulley-path-s2":
        keys(model, "points")
        if not 1 <= len(model["points"]) <= 63:
            raise ValueError("Pulley path exceeds its byte cursor")
        result = bytearray()
        for point in model["points"]:
            keys(point, "x y")
            result.extend(word_signed(point["x"], "path X") + word_signed(point["y"], "path Y"))
        return len(result).to_bytes(2, "big") + result
    if kind == "pulley-children-s2":
        keys(model, "children")
        if not 1 <= len(model["children"]) <= spec.object_slots:
            raise ValueError("Pulley children exceed the object allocation capacity")
        result = bytearray((len(model["children"]) - 1).to_bytes(2, "big"))
        for child in model["children"]:
            keys(child, "x y subtype reserved_subtype_high")
            result.extend(word_signed(child["x"], "child X") + word_signed(child["y"], "child Y"))
            result.extend(
                [
                    uint(child["reserved_subtype_high"], 8, "reserved subtype byte"),
                    uint(child["subtype"], 8, "child subtype"),
                ]
            )
        return result
    raise ValueError("Unknown indexed record kind")


def decode(data, spec):
    spec.validate()
    data = bytes(data)
    if len(data) != spec.size:
        raise ValueError("Indexed container differs from its source-owned allocation")
    references = [int.from_bytes(data[at : at + 2], "big") for at in range(0, spec.count * 2, 2)]
    starts = {start for start, end in spec.slots}
    if set(references) != starts:
        raise ValueError("Indexed references do not cover the complete owned records")
    records = [{"offset": start, "value": decode_record(data[start:end], spec)} for start, end in spec.slots]
    end = spec.slots[-1][1]
    model = {"references": references, "records": records, "alignment": list(data[end:])}
    if encode(model, spec) != data:
        raise ValueError("Indexed structural decode does not retain all original bytes")
    return model


def encode(model, spec):
    spec.validate()
    keys(model, "references records alignment")
    if len(model["references"]) != spec.count:
        raise ValueError("Indexed selector count changes its source ABI")
    slots = {start: end for start, end in spec.slots}
    if len(model["records"]) != len(slots) or {row["offset"] for row in model["records"]} != set(slots):
        raise ValueError("Indexed records change the owned source slots")
    if set(model["references"]) != set(slots):
        raise ValueError("Indexed reference leaves a typed record or introduces an orphan")
    result = bytearray(spec.size)
    for index, value in enumerate(model["references"]):
        result[index * 2 : index * 2 + 2] = uint(value, 15, "relative record offset").to_bytes(2, "big")
    for row in model["records"]:
        keys(row, "offset value")
        start = row["offset"]
        body = encode_record(row["value"], spec, start)
        if len(body) != slots[start] - start:
            raise ValueError("Edited record changes a source-owned boundary")
        result[start : slots[start]] = body
    end = spec.slots[-1][1]
    if len(model["alignment"]) != spec.size - end:
        raise ValueError("Indexed alignment extent changed")
    result[end:] = bytes(uint(value, 8, "alignment byte") for value in model["alignment"])
    return bytes(result)
