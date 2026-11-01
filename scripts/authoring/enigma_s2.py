"""Sonic 2 Enigma reconnaissance from EniDec; not a release codec yet."""


class Bits:
    def __init__(self, data):
        self.data = bytes(data)
        self.position = 48

    def read(self, count):
        if count < 0 or self.position + count > len(self.data) * 8:
            raise ValueError("Truncated Enigma bitstream")
        value = 0
        for _ in range(count):
            value = (value << 1) | ((self.data[self.position // 8] >> (7 - self.position % 8)) & 1)
            self.position += 1
        return value


def decode(data, base_tile=0, max_output=65536, trace=False):
    data = bytes(data)
    if len(data) < 8:
        raise ValueError("Enigma stream has no complete header/initial window")
    width, flags = data[0], data[1] & 31
    if width > 16:
        raise ValueError("Invalid Sonic 2 Enigma tile width")
    base_tile &= 65535
    increment = (int.from_bytes(data[2:4], "big") + base_tile) & 65535
    static = (int.from_bytes(data[4:6], "big") + base_tile) & 65535
    bits = Bits(data)
    out = bytearray()
    commands = []

    def tile():
        value = base_tile
        for flag, mask, operation in [
            (16, 0x8000, "or"),
            (8, 0x4000, "add"),
            (4, 0x2000, "add"),
            (2, 0x1000, "or"),
            (1, 0x800, "or"),
        ]:
            if flags & flag and bits.read(1):
                value = (value | mask) if operation == "or" else (value + mask) & 65535
        return (value + bits.read(width)) & 65535

    def emit(values):
        if len(out) + len(values) * 2 > max_output:
            raise ValueError("Enigma expansion exceeds capacity")
        for value in values:
            out.extend((value & 65535).to_bytes(2, "big"))

    while True:
        if not bits.read(1):
            mode = bits.read(1)
            count = bits.read(4) + 1
            if mode == 0:
                emit([(increment + i) & 65535 for i in range(count)])
                increment = (increment + count) & 65535
            else:
                emit([static] * count)
        else:
            mode = 4 + bits.read(2)
            count = bits.read(4) + 1
            if mode == 7:
                if count == 16:
                    break
                emit([tile() for _ in range(count)])
            else:
                value = tile()
                step = {4: 0, 5: 1, 6: -1}[mode]
                emit([(value + i * step) & 65535 for i in range(count)])
        commands.append((mode, count))
    return (
        (
            bytes(out),
            {
                "bits_consumed": bits.position,
                "static_commands": sum(mode == 1 for mode, count in commands),
                "flags": flags,
            },
        )
        if trace
        else bytes(out)
    )
