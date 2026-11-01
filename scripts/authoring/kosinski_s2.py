"""Sonic 2 Kosinski reconnaissance with descriptor-prefetch semantics."""

from collections import defaultdict, deque


class Reader:
    def __init__(self, data):
        self.data = bytes(data)
        self.at = 0
        self.remaining = 16
        self.word = self.byte() | (self.byte() << 8)

    def byte(self):
        if self.at >= len(self.data):
            raise ValueError("Truncated Kosinski stream")
        value = self.data[self.at]
        self.at += 1
        return value

    def bit(self):
        value = self.word & 1
        self.word >>= 1
        self.remaining -= 1
        if not self.remaining:
            self.word = self.byte() | (self.byte() << 8)
            self.remaining = 16
        return value


def decode(data, max_output=1048576, trace=False):
    r = Reader(data)
    out = bytearray()
    tokens = 0
    while True:
        tokens += 1
        if r.bit():
            out.append(r.byte())
        elif not r.bit():
            length = ((r.bit() << 1) | r.bit()) + 2
            distance = r.byte() - 256
            if len(out) + distance < 0:
                raise ValueError("Kosinski match precedes output")
            for _ in range(length):
                out.append(out[len(out) + distance])
        else:
            low, high = r.byte(), r.byte()
            distance = (low | ((high & 248) << 5)) - 8192
            length = high & 7
            if length:
                length += 2
            else:
                length = r.byte()
                if not length:
                    return (bytes(out), {"consumed": r.at, "tokens": tokens}) if trace else bytes(out)
                if length == 1:
                    continue
                length += 1
            if len(out) + distance < 0:
                raise ValueError("Kosinski match precedes output")
            for _ in range(length):
                out.append(out[len(out) + distance])
        if len(out) > max_output:
            raise ValueError("Kosinski output exceeds capacity")


class Writer:
    def __init__(self):
        self.out = bytearray(2)
        self.descriptor = 0
        self.used = 0

    def bit(self, value):
        if value:
            self.out[self.descriptor + self.used // 8] |= 1 << (self.used % 8)
        self.used += 1
        if self.used == 16:
            self.descriptor = len(self.out)
            self.out.extend(b"\0\0")
            self.used = 0

    def byte(self, value):
        self.out.append(value & 255)


def encode(data):
    data = bytes(data)
    w = Writer()
    index = defaultdict(deque)
    cursor = 0
    while cursor < len(data):
        best = (0, 0, 0, "literal")
        maximum = min(256, len(data) - cursor)
        if maximum >= 2:
            queue = index[data[cursor : cursor + 2]]
            while queue and queue[0] < cursor - 8192:
                queue.popleft()
            for candidate in list(queue)[-128:][::-1]:
                distance = cursor - candidate
                length = 2
                while length < maximum and data[candidate + length] == data[cursor + length]:
                    length += 1
                if distance <= 256:
                    count = min(length, 5)
                    choice = (count * 9 - 12, count, -distance, "short")
                    if choice > best:
                        best = choice
                if length >= 3:
                    cost = 18 + (8 if length > 9 else 0)
                    choice = (length * 9 - cost, length, -distance, "long")
                    if choice > best:
                        best = choice
                if length == maximum:
                    break
        _, length, negative_distance, kind = best
        if kind == "literal":
            w.bit(1)
            w.byte(data[cursor])
            length = 1
        elif kind == "short":
            w.bit(0)
            w.bit(0)
            w.bit((length - 2) >> 1)
            w.bit((length - 2) & 1)
            w.byte(negative_distance)
        else:
            displacement = negative_distance & 8191
            w.bit(0)
            w.bit(1)
            w.byte(displacement)
            w.byte(((displacement >> 5) & 248) | (length - 2 if length <= 9 else 0))
            if length > 9:
                w.byte(length - 1)
        for position in range(cursor, cursor + length):
            if position + 1 < len(data):
                index[data[position : position + 2]].append(position)
        cursor += length
    w.bit(0)
    w.bit(1)
    w.byte(0)
    w.byte(0)
    w.byte(0)
    return bytes(w.out)
