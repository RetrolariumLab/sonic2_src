"""Animation bytecode and demo controller/hold records from the S2 engines."""

from scripts.authoring.struct_formats import uint, keys


def decode_demo(data):
    if len(data) % 2:
        raise ValueError("Truncated demo controller/hold pair")
    return [{"buttons": data[index], "frames": data[index + 1] + 1} for index in range(0, len(data), 2)]


def encode_demo(rows):
    result = bytearray()
    for row in rows:
        keys(row, "buttons frames")
        frames = uint(row["frames"], 9, "hold frames")
        if not 1 <= frames <= 256:
            raise ValueError("Demo hold must be one through 256 frames")
        result.extend([uint(row["buttons"], 8, "buttons"), frames - 1])
    return bytes(result)


def decode_animation(data, count, player=False):
    if type(count) is not int or not 1 <= count <= 256 or len(data) < count * 2:
        raise ValueError("Invalid animation table count")
    values = [int.from_bytes(data[index : index + 2], "big") for index in range(0, count * 2, 2)]
    pointers = [value if value < 0x8000 else value - 0x10000 for value in values]
    starts = sorted({value for value in pointers if 0 <= value < len(data)})
    scripts = []
    covered = set(range(count * 2))
    for index, start in enumerate(starts):
        end = starts[index + 1] if index + 1 < len(starts) else len(data)
        cursor = start + 1
        events = []
        covered.add(start)
        while cursor < end:
            at = cursor
            value = data[cursor]
            cursor += 1
            covered.add(at)
            if value < (0xF0 if player else 0x80):
                events.append({"offset": at, "kind": "frame", "value": value})
            else:
                row = {"offset": at, "kind": "control", "opcode": value, "arguments": []}
                if value in {0xFD, 0xFE}:
                    if cursor >= len(data):
                        raise ValueError("Animation control argument leaves its source-owned byte range")
                    row["arguments"] = [data[cursor]]
                    covered.add(cursor)
                    cursor += 1
                events.append(row)
        scripts.append({"offset": start, "timing_code": data[start], "events": events})
    unclaimed = []
    cursor = 0
    while cursor < len(data):
        if cursor in covered:
            cursor += 1
            continue
        stop = cursor + 1
        while stop < len(data) and stop not in covered:
            stop += 1
        unclaimed.append({"offset": cursor, "bytes": list(data[cursor:stop])})
        cursor = stop
    return {"size": len(data), "pointers": pointers, "scripts": scripts, "unclaimed": unclaimed}


def encode_animation(model, player=False, allowed_external_offsets=None, allowed_hazards=None):
    keys(model, "size pointers scripts unclaimed")
    size = uint(model["size"], 16, "animation size")
    cells = [None] * size
    if not 1 <= len(model["pointers"]) <= 256:
        raise ValueError("Animation count exceeds its byte selector")

    def put(offset, payload):
        if type(offset) is not int or offset < 0 or offset + len(payload) > size:
            raise ValueError("Animation record leaves its fixed layout")
        for index, value in enumerate(payload, offset):
            if cells[index] is not None and cells[index] != value:
                raise ValueError("Conflicting edits to overlapping animation views")
            cells[index] = value

    local_starts = {script["offset"] for script in model["scripts"]}
    for index, value in enumerate(model["pointers"]):
        if type(value) is not int or not -32768 <= value <= 32767:
            raise ValueError("Animation pointer exceeds signed-word addressing")
        if 0 <= value < size and value not in local_starts:
            raise ValueError("Animation pointer enters an undeclared local script")
        if not 0 <= value < size and allowed_external_offsets is not None and value not in allowed_external_offsets:
            raise ValueError("Animation pointer introduces an undeclared external script")
        put(index * 2, (value & 65535).to_bytes(2, "big"))
    for script in model["scripts"]:
        keys(script, "offset timing_code events")
        put(script["offset"], bytes([uint(script["timing_code"], 8, "timing code")]))
        for row in script["events"]:
            if row["kind"] == "frame":
                keys(row, "offset kind value")
                value = uint(row["value"], 8, "mapping frame")
                if value >= (0xF0 if player else 0x80):
                    raise ValueError("Animation frame collides with control range")
                put(row["offset"], bytes([value]))
            else:
                keys(row, "offset kind opcode arguments")
                opcode = uint(row["opcode"], 8, "control opcode")
                if row["kind"] != "control" or opcode < (0xF0 if player else 0x80):
                    raise ValueError("Invalid animation control")
                if len(row["arguments"]) != (1 if opcode in {0xFD, 0xFE} else 0):
                    raise ValueError("Wrong animation control argument count")
                put(
                    row["offset"],
                    bytes([opcode]) + bytes(uint(value, 8, "control argument") for value in row["arguments"]),
                )
    for row in model["unclaimed"]:
        keys(row, "offset bytes")
        put(row["offset"], bytes(uint(value, 8, "unclaimed byte") for value in row["bytes"]))
    if None in cells:
        raise ValueError("Animation byte has no owner")
    result = bytes(cells)
    parsed = decode_animation(result, len(model["pointers"]), player)
    if allowed_hazards is not None and set(animation_hazards(parsed)) - set(allowed_hazards):
        raise ValueError("Edited animation introduces a new control-flow hazard")
    return result


def animation_hazards(model):
    hazards = []
    for script in model["scripts"]:
        for row in script["events"]:
            if row["kind"] != "control":
                continue
            if row["opcode"] == 0xFE and row["arguments"][0] > row["offset"] - script["offset"] - 1:
                hazards.append(("backward_cursor_wrap", row["offset"], row["arguments"][0]))
            if row["opcode"] == 0xFD and row["arguments"][0] >= len(model["pointers"]):
                hazards.append(("animation_switch_out_of_table", row["offset"], row["arguments"][0]))
    return hazards
