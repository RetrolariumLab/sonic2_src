"""Fixed-layout semantic SMPS S2 records and bounded control-flow discovery.

Pointers remain original Z80 addresses. The caller owns the ROM bank/buffer ABI
and resolves external dependencies; this codec never synthesizes a new layout.
"""

from collections import deque
from scripts.authoring.audio_formats import decode_voices, encode_voices
from scripts.authoring.struct_formats import uint, keys

COMMANDS = {
    0xE0: ("panning_ams_fms", [("value", "u8")]),
    0xE1: ("detune", [("value", "s8")]),
    0xE2: ("communication", [("value", "u8")]),
    0xE3: ("return", []),
    0xE4: ("restore_previous_music", []),
    0xE5: ("tempo_divider", [("value", "u8")]),
    0xE6: ("fm_volume_delta", [("value", "s8")]),
    0xE7: ("prevent_attack", []),
    0xE8: ("note_fill", [("value", "u8")]),
    0xE9: ("transposition_delta", [("value", "s8")]),
    0xEA: ("tempo", [("value", "u8")]),
    0xEB: ("all_track_tempo_divider", [("value", "u8")]),
    0xEC: ("psg_volume_delta", [("value", "s8")]),
    0xED: ("unused_clear_push_consumes_byte", [("skipped_byte", "u8")]),
    0xEE: ("unused_special_fm4", []),
    0xEF: ("fm_voice", [("index", "u8")]),
    0xF0: ("modulation", [("delay", "u8"), ("speed", "u8"), ("delta", "s8"), ("steps", "u8")]),
    0xF1: ("enable_modulation", []),
    0xF2: ("stop_track", []),
    0xF3: ("psg_noise", [("value", "u8")]),
    0xF4: ("disable_modulation", []),
    0xF5: ("psg_tone", [("value", "u8")]),
    0xF6: ("jump", [("target", "u16le")]),
    0xF7: ("loop", [("index", "u8"), ("count", "u8"), ("target", "u16le")]),
    0xF8: ("call", [("target", "u16le")]),
    0xF9: ("special_fm_release", []),
}
TERMINAL = {0xE3, 0xE4, 0xF2, 0xF6}


def signed(value):
    return value if value < 128 else value - 256


def read(data, offset, size):
    if offset < 0 or offset + size > len(data):
        raise ValueError("Truncated SMPS record at " + hex(offset))
    return data[offset : offset + size]


def word(data, offset):
    return int.from_bytes(read(data, offset, 2), "little")


def byte(value, name):
    return bytes([uint(value, 8, name)])


def signed_byte(value, name):
    if type(value) is not int or not -128 <= value <= 127:
        raise ValueError(name + " must fit a signed byte")
    return bytes([value & 255])


def word_bytes(value, name):
    return uint(value, 16, name).to_bytes(2, "little")


def decode_header(data, kind):
    if kind == "music":
        read(data, 0, 6)
        fm, psg = data[2:4]
        if fm > 7 or psg > 3 or fm + psg == 0:
            raise ValueError("Music channel count exceeds driver track ABI")
        header = {
            "voices": word(data, 0),
            "tempo_divider": data[4],
            "tempo": data[5],
            "fm_dac_tracks": [],
            "psg_tracks": [],
        }
        at = 6
        for _ in range(fm):
            row = read(data, at, 4)
            header["fm_dac_tracks"].append({"pointer": word(row, 0), "transposition": signed(row[2]), "volume": row[3]})
            at += 4
        for _ in range(psg):
            row = read(data, at, 6)
            header["psg_tracks"].append(
                {
                    "pointer": word(row, 0),
                    "transposition": signed(row[2]),
                    "volume": row[3],
                    "unused": row[4],
                    "tone": row[5],
                }
            )
            at += 6
    elif kind == "sfx":
        read(data, 0, 4)
        count = data[3]
        if not 1 <= count <= 6:
            raise ValueError("SFX channel count exceeds driver track ABI")
        header = {"voices": word(data, 0), "tempo_divider": data[2], "tracks": []}
        at = 4
        for _ in range(count):
            row = read(data, at, 6)
            header["tracks"].append(
                {
                    "playback_control": row[0],
                    "channel": row[1],
                    "pointer": word(row, 2),
                    "transposition": signed(row[4]),
                    "volume": row[5],
                }
            )
            at += 6
    else:
        raise ValueError("Unknown SMPS header ABI")
    return header, at


def encode_header(header, kind):
    if kind == "music":
        keys(header, "voices tempo_divider tempo fm_dac_tracks psg_tracks")
        fm = header["fm_dac_tracks"]
        psg = header["psg_tracks"]
        if len(fm) > 7 or len(psg) > 3 or len(fm) + len(psg) == 0:
            raise ValueError("Music channel count exceeds driver track ABI")
        result = (
            word_bytes(header["voices"], "voices")
            + bytes([len(fm), len(psg)])
            + byte(header["tempo_divider"], "tempo_divider")
            + byte(header["tempo"], "tempo")
        )
        for rows, extra in [(fm, False), (psg, True)]:
            for row in rows:
                keys(row, "pointer transposition volume" + (" unused tone" if extra else ""))
                result += (
                    word_bytes(row["pointer"], "track pointer")
                    + signed_byte(row["transposition"], "transposition")
                    + byte(row["volume"], "volume")
                )
                if extra:
                    result += byte(row["unused"], "unused") + byte(row["tone"], "tone")
    elif kind == "sfx":
        keys(header, "voices tempo_divider tracks")
        tracks = header["tracks"]
        if not 1 <= len(tracks) <= 6:
            raise ValueError("SFX channel count exceeds driver track ABI")
        result = (
            word_bytes(header["voices"], "voices")
            + byte(header["tempo_divider"], "tempo_divider")
            + bytes([len(tracks)])
        )
        for row in tracks:
            keys(row, "playback_control channel pointer transposition volume")
            result += (
                byte(row["playback_control"], "playback_control")
                + byte(row["channel"], "channel")
                + word_bytes(row["pointer"], "track pointer")
                + signed_byte(row["transposition"], "transposition")
                + byte(row["volume"], "volume")
            )
    else:
        raise ValueError("Unknown SMPS header ABI")
    return result


def roots(header, kind):
    if kind == "music":
        return [
            (row["pointer"], "dac" if index == 0 else "fm") for index, row in enumerate(header["fm_dac_tracks"])
        ] + [(row["pointer"], "psg") for row in header["psg_tracks"]]
    return [(row["pointer"], "psg" if row["channel"] & 128 else "fm") for row in header["tracks"]]


def decode_event(data, at):
    opcode = read(data, at, 1)[0]
    if opcode < 0xE0:
        return {"offset": at, "kind": "duration" if opcode < 0x80 else "note", "value": opcode}, 1
    if opcode not in COMMANDS:
        raise ValueError("Unknown SMPS opcode " + hex(opcode) + " at " + hex(at))
    name, fields = COMMANDS[opcode]
    arguments = {}
    cursor = at + 1
    for field, representation in fields:
        size = 2 if representation == "u16le" else 1
        raw = read(data, cursor, size)
        value = int.from_bytes(raw, "little")
        arguments[field] = signed(value) if representation == "s8" else value
        cursor += size
    return {"offset": at, "kind": "command", "opcode": opcode, "name": name, "arguments": arguments}, cursor - at


def encode_event(row):
    if row["kind"] in {"note", "duration"}:
        keys(row, "offset kind value")
        value = uint(row["value"], 8, "note or duration")
        if (row["kind"] == "duration" and value >= 0x80) or (row["kind"] == "note" and not 0x80 <= value < 0xE0):
            raise ValueError("SMPS event class differs from its byte")
        return bytes([value])
    keys(row, "offset kind opcode name arguments")
    opcode = uint(row["opcode"], 8, "opcode")
    if opcode not in COMMANDS:
        raise ValueError("Unknown SMPS opcode")
    name, fields = COMMANDS[opcode]
    if row["kind"] != "command" or row["name"] != name:
        raise ValueError("SMPS command name differs from opcode")
    keys(row["arguments"], " ".join(field for field, _ in fields))
    result = bytes([opcode])
    for field, representation in fields:
        value = row["arguments"][field]
        result += (
            word_bytes(value, field)
            if representation == "u16le"
            else signed_byte(value, field)
            if representation == "s8"
            else byte(value, field)
        )
    return result


def decode(data, kind, base_address):
    data = bytes(data)
    uint(base_address, 16, "base address")
    if base_address + len(data) > 0x10000:
        raise ValueError("SMPS input crosses its Z80 address window")
    header, header_size = decode_header(data, kind)
    covered = set(range(header_size))
    queue = deque(roots(header, kind))
    seen = set()
    events = {}
    event_kinds = {}
    external = set()
    while queue:
        address, channel = queue.popleft()
        at = address - base_address
        while (at, channel) not in seen:
            if not 0 <= at < len(data):
                external.add(("stream", address, 1))
                break
            if at < header_size:
                raise ValueError("SMPS track enters its header")
            seen.add((at, channel))
            node, size = decode_event(data, at)
            events[at] = node
            event_kinds.setdefault(at, set()).add(channel)
            covered.update(range(at, at + size))
            next_at = at + size
            if node["kind"] == "command":
                opcode = node["opcode"]
                if opcode in {0xF6, 0xF7, 0xF8}:
                    queue.append((node["arguments"]["target"], channel))
                if opcode in TERMINAL:
                    break
            at = next_at
            address = base_address + at
    voice_pointer = header["voices"]
    voices = []
    requested = {0} if voice_pointer and any(channel == "fm" for _, channel in roots(header, kind)) else set()
    requested.update(
        node["arguments"]["index"]
        for at, node in events.items()
        if node.get("opcode") == 0xEF and "fm" in event_kinds[at]
    )
    if base_address <= voice_pointer < base_address + len(data):
        voice_start = voice_pointer - base_address
        for offset in range(voice_start, len(data) - 24, 25):
            # A stream may follow the voice table in a retail SFX; never reinterpret it.
            if any(index in covered for index in range(offset, offset + 25)):
                break
            voices.append({"offset": offset, "voice": decode_voices(data[offset : offset + 25])[0]})
            covered.update(range(offset, offset + 25))
        local_indices = {(row["offset"] - voice_start) // 25 for row in voices}
        for index in requested - local_indices:
            address = (voice_pointer + index * 25) & 0xFFFF
            if base_address <= address < base_address + len(data):
                raise ValueError("SMPS voice reference overlaps stream/header or is truncated")
            external.add(("voice", address, 25))
    elif voice_pointer:
        for index in requested:
            external.add(("voice", (voice_pointer + index * 25) & 0xFFFF, 25))
    elif requested:
        external.add(("voice", 0, 25))
    unclaimed = []
    at = 0
    while at < len(data):
        if at in covered:
            at += 1
            continue
        stop = at + 1
        while stop < len(data) and stop not in covered:
            stop += 1
        unclaimed.append({"offset": at, "bytes": list(data[at:stop])})
        at = stop
    model = {
        "size": len(data),
        "header": header,
        "events": [events[key] for key in sorted(events)],
        "voices": voices,
        "unclaimed": unclaimed,
    }
    analysis = {
        "base_address": base_address,
        "address_end": base_address + len(data),
        "header_bytes": header_size,
        "events": len(events),
        "voices": len(voices),
        "external": [{"kind": kind, "address": address, "size": size} for kind, address, size in sorted(external)],
        "unclaimed_bytes": sum(len(row["bytes"]) for row in unclaimed),
        "shared_event_views": sum(len(value) > 1 for value in event_kinds.values()),
    }
    return model, analysis


def validate_control_flow(model, kind, base_address, external_events=None, max_states=100000):
    """Check the shared ten-byte loop-counter/return-stack area on all paths."""
    nodes = {
        address: node
        for address, node in (external_events or {}).items()
        if not base_address <= address < base_address + model["size"]
    }
    nodes.update({base_address + node["offset"]: node for node in model["events"]})
    queue = deque((address, ()) for address, _ in roots(model["header"], kind))
    seen = set()
    maximum_depth = 0
    maximum_loop = -1
    while queue:
        address, stack = queue.popleft()
        while (address, stack) not in seen:
            if len(seen) >= max_states:
                raise ValueError("SMPS control-flow state budget exceeded")
            seen.add((address, stack))
            if address not in nodes:
                raise ValueError("Missing declared external SMPS event at " + hex(address))
            node = nodes[address]
            following = address + len(encode_event(node))
            if node["kind"] != "command":
                address = following
                continue
            opcode = node["opcode"]
            arguments = node["arguments"]
            if opcode in {0xE4, 0xF2}:
                break
            if opcode == 0xE3:
                if not stack:
                    raise ValueError("SMPS return would underflow its track call stack")
                address, stack = stack[-1], stack[:-1]
                continue
            if opcode == 0xF8:
                if len(stack) >= 5:
                    raise ValueError("SMPS calls exceed the ten-byte track stack")
                stack = stack + (following,)
                maximum_depth = max(maximum_depth, len(stack))
                address = arguments["target"]
                continue
            if opcode == 0xF6:
                address = arguments["target"]
                continue
            if opcode == 0xF7:
                index = arguments["index"]
                maximum_loop = max(maximum_loop, index)
                if index >= 10 - 2 * len(stack):
                    raise ValueError("SMPS loop counter overlaps the call stack or leaves the track")
                queue.append((arguments["target"], stack))
            address = following
    # Loop counter state can survive across calls; reserving disjoint areas is
    # conservative and avoids aliasing even on paths that do not execute F7 in
    # the deepest callee.
    if maximum_loop + 1 + 2 * maximum_depth > 10:
        raise ValueError("SMPS loop counters and maximum call depth share track bytes")
    return {
        "states": len(seen),
        "maximum_call_depth": maximum_depth,
        "maximum_loop_index": maximum_loop,
        "reserved_loop_bytes": maximum_loop + 1,
        "reserved_call_bytes": 2 * maximum_depth,
    }


def encode(model, kind, base_address, allowed_external=None, external_events=None):
    keys(model, "size header events voices unclaimed")
    size = uint(model["size"], 16, "SMPS size")
    cells = [None] * size

    def put(offset, payload):
        if type(offset) is not int or offset < 0 or offset + len(payload) > size:
            raise ValueError("SMPS record leaves its fixed layout")
        for index, value in enumerate(payload, offset):
            if cells[index] is not None and cells[index] != value:
                raise ValueError("Conflicting edits to overlapping SMPS records")
            cells[index] = value

    put(0, encode_header(model["header"], kind))
    for row in model["events"]:
        put(row["offset"], encode_event(row))
    for row in model["voices"]:
        keys(row, "offset voice")
        put(row["offset"], encode_voices([row["voice"]]))
    for row in model["unclaimed"]:
        keys(row, "offset bytes")
        put(row["offset"], bytes(uint(value, 8, "unclaimed byte") for value in row["bytes"]))
    if None in cells:
        raise ValueError("SMPS fixed layout contains an unowned byte")
    result = bytes(cells)
    parsed, analysis = decode(result, kind, base_address)
    validate_control_flow(parsed, kind, base_address, external_events)
    if allowed_external is not None:
        permitted = {(row["kind"], row["address"], row["size"]) for row in allowed_external}
        if any((row["kind"], row["address"], row["size"]) not in permitted for row in analysis["external"]):
            raise ValueError("Edited SMPS pointer introduces an undeclared external dependency")
    return result
