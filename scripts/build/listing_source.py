"""Attribute active AS listing rows and include ends to project source files."""

from dataclasses import dataclass
from pathlib import Path
import re

ROW = re.compile(r"^(?:\((\d+)\))?\s*(\d+)/\s*([0-9A-Fa-f]+)\s*:")
INCLUDE = re.compile(r'^\s*(?:[A-Za-z_][\w.]*:\s*)?include\s+"([^"\n]+)"', re.I)
MACRO = re.compile(r"^\s*(?:[A-Za-z_][\w.]*:?\s+)?macro\b", re.I)
REPEAT = re.compile(r"^\s*(?:rept|irp|irpc)\b", re.I)
END_MACRO = re.compile(r"^\s*endm\b", re.I)


@dataclass(frozen=True)
class SourceRow:
    path: str
    line: int
    address: int
    rendered: str


@dataclass
class ListingIndex:
    addresses: dict
    rows: list
    source_lines: dict
    include_ends: dict

    def pc(self, name, number):
        key = (name, number)
        if key in self.addresses:
            return self.addresses[key]
        if number == len(self.source_lines[name]) + 1:
            values = self.include_ends.get(name, set())
            if len(values) == 1:
                return next(iter(values))
        raise ValueError("No unique active source address: " + name + ":" + str(number))

    def macro_definition_lines(self, name):
        """Return physical lines owned by a macro template, including nested repeats."""
        stack = []
        result = set()
        for number, raw in enumerate(self.source_lines[name], 1):
            code = raw.split(";", 1)[0]
            if MACRO.match(code):
                stack.append("macro")
            elif REPEAT.match(code):
                stack.append("repeat")
            if "macro" in stack:
                result.add(number)
            if END_MACRO.match(code) and stack:
                stack.pop()
        return result


def listing_index(listing, root, entry):
    root = Path(root).resolve()
    stack = [entry]
    pending = {}
    lines = {}
    addresses = {}
    rows = []
    ends = {}
    for raw in Path(listing).read_text(errors="replace").splitlines():
        match = ROW.match(raw)
        if not match:
            continue
        depth = int(match[1] or 0)
        number = int(match[2])
        address = int(match[3], 16)
        if number < 1:
            continue
        if depth >= len(stack):
            if depth != len(stack) or depth - 1 not in pending:
                raise ValueError("Unowned AS include depth " + str(depth))
            stack.append(pending.pop(depth - 1))
        else:
            for ended in stack[depth + 1 :]:
                ends.setdefault(ended, set()).add(address)
            stack = stack[: depth + 1]
        name = stack[depth]
        if name not in lines:
            source = (root / name).resolve()
            if not source.is_relative_to(root):
                raise ValueError("AS source include leaves its project root")
            lines[name] = source.read_text().splitlines()
        if number > len(lines[name]):
            continue
        addresses.setdefault((name, number), address)
        rows.append(SourceRow(name, number, address, raw[match.end() :]))
        code = lines[name][number - 1].split(";", 1)[0]
        include = INCLUDE.match(code)
        if include:
            pending[depth] = include[1]
    return ListingIndex(addresses, rows, lines, ends)


def source_pcs(listing, root, entry):
    """Preserve the simple physical-row API; EOF addresses use ListingIndex.pc."""
    return listing_index(listing, root, entry).addresses
