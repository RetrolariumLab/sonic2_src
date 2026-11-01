"""Sonic 2 special-stage track mappings: three cooperating MSB bitstreams."""

from scripts.authoring.struct_formats import uint, keys


class Bits:
    def __init__(self, data):
        self.data = bytes(data)
        self.position = 0

    def take(self, count):
        if self.position + count > len(self.data) * 8:
            raise ValueError("Truncated special-stage bitstream")
        result = 0
        for _ in range(count):
            result = (result << 1) | ((self.data[self.position // 8] >> (7 - self.position % 8)) & 1)
            self.position += 1
        return result

    def tail(self):
        return [self.take(1) for _ in range(len(self.data) * 8 - self.position)]


def put(bits, value, width):
    uint(value, width, "bitstream index")
    bits.extend((value >> shift) & 1 for shift in range(width - 1, -1, -1))


def pack(bits):
    if any(type(bit) is not int or bit not in {0, 1} for bit in bits):
        raise ValueError("Tail bits must be zero or one")
    data = bits + [0] * ((-len(bits)) % 8)
    return bytes(sum(data[index + offset] << (7 - offset) for offset in range(8)) for index in range(0, len(data), 8))


def sections(data):
    at = 0
    result = []
    for _ in range(3):
        if at + 4 > len(data):
            raise ValueError("Missing special-stage section header")
        tag = int.from_bytes(data[at : at + 2], "big")
        size = int.from_bytes(data[at + 2 : at + 4], "big")
        if size > 0x7FFB or at + 4 + size > len(data):
            raise ValueError("Special-stage section offset leaves its signed-word range or input")
        result.append((tag, data[at + 4 : at + 4 + size]))
        at += 4 + size
    return result, data[at:]


def decode(data):
    parts, trailer = sections(bytes(data))
    selectors, literals, runs = [Bits(body) for _, body in parts]
    rows = []
    row = []
    tokens = 0
    while len(rows) < 28:
        tokens += 1
        if tokens > 28 * 129:
            raise ValueError("Special-stage token count exceeds full-frame capacity")
        if selectors.take(1):
            wide = literals.take(1)
            index = literals.take(10 if wide else 6)
            row.append({"kind": "literal", "wide": bool(wide), "index": index})
        else:
            wide = runs.take(1)
            index = runs.take(7 if wide else 6)
            if wide and index == 127:
                rows.append(row)
                row = []
                continue
            row.append({"kind": "run", "wide": bool(wide), "index": index})
    model = {
        "tags": [tag for tag, _ in parts],
        "rows": rows,
        "tails": {"selectors": selectors.tail(), "literals": literals.tail(), "runs": runs.tail()},
        "trailer": list(trailer),
    }
    return model


def encode(model):
    keys(model, "tags rows tails trailer")
    keys(model["tails"], "selectors literals runs")
    if len(model["tags"]) != 3 or len(model["rows"]) != 28:
        raise ValueError("Special-stage frame needs three sections and 28 rows")
    bits = [[], [], []]
    for row in model["rows"]:
        if len(row) > 128:
            raise ValueError("Too many tokens in a special-stage row")
        for token in row:
            keys(token, "kind wide index")
            if type(token["wide"]) is not bool:
                raise ValueError("Index width must be Boolean")
            wide = int(token["wide"])
            index = token["index"]
            if token["kind"] == "literal":
                put(bits[0], 1, 1)
                put(bits[1], wide, 1)
                put(bits[1], index, 10 if wide else 6)
            elif token["kind"] == "run":
                if wide and index == 127:
                    raise ValueError("Run index collides with end-of-line marker")
                put(bits[0], 0, 1)
                put(bits[2], wide, 1)
                put(bits[2], index, 7 if wide else 6)
            else:
                raise ValueError("Unknown special-stage token kind")
        put(bits[0], 0, 1)
        put(bits[2], 255, 8)
    output = bytearray()
    for index, name in enumerate(["selectors", "literals", "runs"]):
        body = pack(bits[index] + model["tails"][name])
        if len(body) > 0x7FFB:
            raise ValueError("Special-stage section exceeds signed word-offset capacity")
        output.extend(uint(model["tags"][index], 16, "section tag").to_bytes(2, "big"))
        output.extend(len(body).to_bytes(2, "big"))
        output.extend(body)
    output.extend(uint(value, 8, "trailer byte") for value in model["trailer"])
    return bytes(output)


def render(model, literal_lut, run_lut, literal_split, run_split, palette_flags=0x6000, priority_flag=0x8000):
    rows = []
    for tokens in model["rows"]:
        row = []
        for token in tokens:
            index = token["index"]
            index += (literal_split if token["kind"] == "literal" else run_split) if token["wide"] else 0
            if token["kind"] == "literal":
                if not 0 <= index < len(literal_lut):
                    raise ValueError("Literal index leaves the original engine LUT")
                row.append(literal_lut[index] | palette_flags)
            else:
                if not 0 <= index < len(run_lut):
                    raise ValueError("Run index leaves the original engine LUT")
                word, repeat_minus_one = run_lut[index]
                if repeat_minus_one >= 128:
                    raise ValueError("Run exceeds a complete special-stage row")
                row.extend([word | palette_flags | priority_flag] * (repeat_minus_one + 1))
            if len(row) > 128:
                raise ValueError("Expanded special-stage row exceeds 128 cells")
        if len(row) != 128:
            raise ValueError("Expanded special-stage row has " + str(len(row)) + " cells instead of 128")
        rows.append(row)
    return rows
