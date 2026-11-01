"""Authentic Sonic 2 Saxman, translated from the upstream Okumura encoder.

Authentic Saxman encoder provenance

scripts/authoring/saxman.py is a Python translation of the ordered-tree LZSS
encoder in sonicretro/s2disasm at commit
4ef457c18fc4902396c43ab06fabc119ac6ecb64,
build_tools/source_code/lz_comp2/LZSS.c. Haruhiko Okumura wrote the original
encoder on 1989-04-06; Clownacy adapted its Saxman format on 2020-10-07.
The original permission notice reads:

Use, distribute, and modify this program freely.
Please send me your improved versions.

This is the implementation selected by saxman -a. The different clownlzss
implementation is not used or incorporated here. The game's source, music,
samples, and other content do not inherit this permission notice.

The ordered binary trees and tie-breaking are intentional: replacing them
with a longest-match search changes bytes.
"""

N = 4096
F = 18
THRESHOLD = 2
NIL = N


class _Encoder:
    def __init__(self):
        self.buffer = bytearray(N + F - 1)
        self.left = [0] * (N + 1)
        self.right = [0] * (N + 257)
        self.parent = [NIL] * (N + 1)
        for index in range(N + 1, N + 257):
            self.right[index] = NIL
        self.match_position = 0
        self.match_length = 0

    def insert(self, node):
        buf, left, right, parent = self.buffer, self.left, self.right, self.parent
        comparison = 1
        other = N + 1 + buf[node]
        left[node] = right[node] = NIL
        self.match_length = 0
        while True:
            if comparison >= 0:
                if right[other] == NIL:
                    right[other] = node
                    parent[node] = other
                    return
                other = right[other]
            else:
                if left[other] == NIL:
                    left[other] = node
                    parent[node] = other
                    return
                other = left[other]
            length = 1
            while length < F:
                comparison = buf[node + length] - buf[other + length]
                if comparison:
                    break
                length += 1
            if length > self.match_length:
                self.match_position = other
                self.match_length = length
                if length >= F:
                    break
        parent[node] = parent[other]
        left[node], right[node] = left[other], right[other]
        parent[left[other]] = parent[right[other]] = node
        if right[parent[other]] == other:
            right[parent[other]] = node
        else:
            left[parent[other]] = node
        parent[other] = NIL

    def delete(self, node):
        left, right, parent = self.left, self.right, self.parent
        if parent[node] == NIL:
            return
        if right[node] == NIL:
            replacement = left[node]
        elif left[node] == NIL:
            replacement = right[node]
        else:
            replacement = left[node]
            if right[replacement] != NIL:
                while right[replacement] != NIL:
                    replacement = right[replacement]
                right[parent[replacement]] = left[replacement]
                parent[left[replacement]] = parent[replacement]
                left[replacement] = left[node]
                parent[left[node]] = replacement
            right[replacement] = right[node]
            parent[right[node]] = replacement
        parent[replacement] = parent[node]
        if right[parent[node]] == node:
            right[parent[node]] = replacement
        else:
            left[parent[node]] = replacement
        parent[node] = NIL

    def encode(self, data):
        if not data:
            return b""
        buf = self.buffer
        start, current = 0, N - F
        remaining = min(F, len(data))
        buf[current : current + remaining] = data[:remaining]
        cursor = remaining
        for index in range(1, F + 1):
            self.insert(current - index)
        self.insert(current)
        output = bytearray()
        group = bytearray([0])
        mask = 1
        while remaining:
            length = min(self.match_length, remaining)
            if length <= THRESHOLD:
                length = 1
                group[0] |= mask
                group.append(buf[current])
            else:
                position = self.match_position
                group.extend((position & 255, ((position >> 4) & 240) | (length - 3)))
            mask <<= 1
            if mask == 256:
                output.extend(group)
                group = bytearray([0])
                mask = 1
            consumed = 0
            while consumed < length and cursor < len(data):
                value = data[cursor]
                cursor += 1
                self.delete(start)
                buf[start] = value
                if start < F - 1:
                    buf[start + N] = value
                start, current = (start + 1) & (N - 1), (current + 1) & (N - 1)
                self.insert(current)
                consumed += 1
            while consumed < length:
                self.delete(start)
                start, current = (start + 1) & (N - 1), (current + 1) & (N - 1)
                remaining -= 1
                if remaining:
                    self.insert(current)
                consumed += 1
        if len(group) > 1:
            output.extend(group)
        return bytes(output)


def encode(data, with_size=True):
    """Return authentic bytes, with the little-endian song size by default."""
    stream = _Encoder().encode(bytes(data))
    if with_size:
        if len(stream) > 65535:
            raise ValueError("Saxman song exceeds its 16-bit compressed-size field")
        return len(stream).to_bytes(2, "little") + stream
    return stream


def decode(data, with_size=True, max_output=65536):
    """Decode a bounded Saxman song; reject truncated tokens and bad lengths."""
    data = bytes(data)
    if with_size:
        if len(data) < 2:
            raise ValueError("Missing Saxman size")
        size = int.from_bytes(data[:2], "little")
        if size != len(data) - 2:
            raise ValueError("Saxman size differs from its container")
        data = data[2:]
    ring = bytearray(N)
    current = N - F
    cursor = 0
    output = bytearray()
    while cursor < len(data):
        flags = data[cursor]
        cursor += 1
        if cursor == len(data):
            raise ValueError("Saxman flag has no tokens")
        for bit in range(8):
            if cursor == len(data):
                break
            if flags & (1 << bit):
                values = [data[cursor]]
                cursor += 1
            else:
                if cursor + 2 > len(data):
                    raise ValueError("Truncated Saxman back-reference")
                low, high = data[cursor : cursor + 2]
                cursor += 2
                position = low | ((high & 240) << 4)
                length = (high & 15) + 3
                # Copy into the ring immediately, preserving overlapping matches.
                values = None
                for index in range(length):
                    value = ring[(position + index) & (N - 1)]
                    output.append(value)
                    ring[current] = value
                    current = (current + 1) & (N - 1)
            if values is not None:
                value = values[0]
                output.append(value)
                ring[current] = value
                current = (current + 1) & (N - 1)
            if len(output) > max_output:
                raise ValueError("Saxman output exceeds declared capacity")
    return bytes(output)
