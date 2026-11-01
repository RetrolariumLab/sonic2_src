"""Typed source-owned sprite/DPLC views with shared frame ownership and signed offsets."""

from dataclasses import dataclass
from scripts.authoring.struct_formats import keys, uint
from scripts.authoring.sprite_formats import entries_decode, entries_encode
from scripts.authoring.dplc_capacity import Budget, check as check_transfer

FRAME_KINDS = {"sprite-counted", "sprite-single", "ss-dplc-counted", "ss-dplc-single"}


@dataclass(frozen=True)
class Frame:
    name: str
    address: int
    size: int
    kind: str


@dataclass(frozen=True)
class Table:
    name: str
    address: int
    selector_kinds: tuple
    allow_null: bool = False
    transfer_budgets: tuple = ()


@dataclass(frozen=True)
class Spec:
    abi: str
    address_limit: int
    tables: tuple
    frames: tuple

    def validate(self):
        if type(self.abi) is not str or not self.abi or type(self.address_limit) is not int or self.address_limit < 1:
            raise ValueError("Invalid source-view ABI or address space")
        if type(self.tables) is not tuple or type(self.frames) is not tuple or not self.tables:
            raise ValueError("Source-view allocations must be immutable")
        if any(type(row) is not Table for row in self.tables) or any(type(row) is not Frame for row in self.frames):
            raise ValueError("Source-view owners must be frozen typed allocations")
        if any(
            type(row.name) is not str or not row.name or type(row.address) is not int
            for row in (*self.tables, *self.frames)
        ):
            raise ValueError("Invalid source-view owner or address")
        if len({row.name for row in self.tables}) != len(self.tables) or len({row.name for row in self.frames}) != len(
            self.frames
        ):
            raise ValueError("Duplicate source-view owner")
        if len({row.address for row in self.frames}) != len(self.frames):
            raise ValueError("Shared source frame must have one physical owner")
        ranges = []
        for table in self.tables:
            if type(table.selector_kinds) is not tuple or not 1 <= len(table.selector_kinds) <= 256:
                raise ValueError("Invalid immutable mapping selector ABI")
            if any(kind not in FRAME_KINDS for kind in table.selector_kinds) or type(table.allow_null) is not bool:
                raise ValueError("Unknown mapping frame ABI")
            if type(table.transfer_budgets) is not tuple:
                raise ValueError("Source transfer budgets must be immutable")
            if any(kind.startswith("ss-dplc-") for kind in table.selector_kinds):
                if len(table.transfer_budgets) != len(table.selector_kinds):
                    raise ValueError("Every DPLC selector needs its source and destination bounds")
                for budget in table.transfer_budgets:
                    if type(budget) is not Budget or budget.offset_scale != 2:
                        raise ValueError("Special-stage DPLC needs frozen word-offset bounds")
                    budget.validate()
            elif table.transfer_budgets:
                raise ValueError("Sprite tables cannot own DPLC transfer budgets")
            ranges.append((table.address, table.address + len(table.selector_kinds) * 2, table.name))
        for frame in self.frames:
            if frame.kind not in FRAME_KINDS or type(frame.size) is not int or frame.size < 2:
                raise ValueError("Invalid source frame allocation")
            ranges.append((frame.address, frame.address + frame.size, frame.name))
        previous = 0
        for start, end, name in sorted(ranges):
            if type(start) is not int or not previous <= start < end <= self.address_limit:
                raise ValueError("Source-view allocations overlap or leave their ROM: " + name)
            previous = end


@dataclass(frozen=True)
class Patch:
    owner: str
    address: int
    data: bytes


def decode_frame(data, kind):
    if kind not in FRAME_KINDS:
        raise ValueError("Unknown source frame ABI")
    counted = kind.endswith("-counted")
    if counted:
        if len(data) < 2:
            raise ValueError("Truncated source frame count")
        count = int.from_bytes(data[:2], "big")
        body = data[2:]
    else:
        count = 1
        body = data
    if kind.startswith("sprite-"):
        entries = entries_decode(body, "sprite")
    else:
        if len(body) % 2:
            raise ValueError("Truncated special-stage DPLC word")
        entries = []
        for at in range(0, len(body), 2):
            word = int.from_bytes(body[at : at + 2], "big")
            entries.append({"tiles": (word >> 12) + 1, "source_word_offset": word & 0xFFF})
    if len(entries) != count:
        raise ValueError("Source frame count differs from its typed body")
    return entries


def encode_frame(entries, kind):
    if kind not in FRAME_KINDS:
        raise ValueError("Unknown source frame ABI")
    if kind.endswith("-single") and len(entries) != 1:
        raise ValueError("Headerless source frame must have exactly one entry")
    if kind.startswith("sprite-"):
        if len(entries) > 80:
            raise ValueError("Sprite view exceeds the hardware piece budget")
        body = entries_encode(entries, "sprite")
    else:
        body = bytearray()
        for row in entries:
            keys(row, "tiles source_word_offset")
            count = uint(row["tiles"], 5, "DPLC tile count")
            if not 1 <= count <= 16:
                raise ValueError("Special-stage DPLC run must contain one through sixteen tiles")
            word = ((count - 1) << 12) | uint(row["source_word_offset"], 12, "DPLC source word offset")
            body.extend(word.to_bytes(2, "big"))
        body = bytes(body)
    return len(entries).to_bytes(2, "big") + body if kind.endswith("-counted") else bytes(body)


def decode(rom, spec):
    spec.validate()
    if len(rom) != spec.address_limit:
        raise ValueError("Source-view input differs from its address space")
    by_address = {row.address: row for row in spec.frames}
    tables = []
    for table in spec.tables:
        references = []
        for index, kind in enumerate(table.selector_kinds):
            at = table.address + index * 2
            offset = int.from_bytes(rom[at : at + 2], "big")
            if offset == 0:
                if not table.allow_null:
                    raise ValueError("Mapping introduces an undeclared null frame")
                references.append(None)
                continue
            offset = offset if offset < 0x8000 else offset - 0x10000
            owner = by_address.get(table.address + offset)
            if owner is None or owner.kind != kind:
                raise ValueError("Mapping pointer does not reach a typed frame with the consumer ABI")
            references.append(owner.name)
        tables.append({"name": table.name, "references": references})
    frames = [
        {"name": row.name, "entries": decode_frame(rom[row.address : row.address + row.size], row.kind)}
        for row in spec.frames
    ]
    model = {"abi": spec.abi, "tables": tables, "frames": frames}
    for patch in encode(model, spec):
        if rom[patch.address : patch.address + len(patch.data)] != patch.data:
            raise ValueError("Typed source view does not retain original bytes")
    return model


def encode(model, spec):
    spec.validate()
    keys(model, "abi tables frames")
    if model["abi"] != spec.abi:
        raise ValueError("Source view belongs to another profile ABI")
    tables = {row["name"]: row for row in model["tables"]}
    frames = {row["name"]: row for row in model["frames"]}
    if len(tables) != len(model["tables"]) or set(tables) != {row.name for row in spec.tables}:
        raise ValueError("Source table ownership changed")
    if len(frames) != len(model["frames"]) or set(frames) != {row.name for row in spec.frames}:
        raise ValueError("Source frame ownership changed")
    frame_specs = {row.name: row for row in spec.frames}
    patches = []
    for table in spec.tables:
        row = tables[table.name]
        keys(row, "name references")
        references = row["references"]
        if len(references) != len(table.selector_kinds):
            raise ValueError("Mapping selector count changes its source ABI")
        words = bytearray()
        for index, reference in enumerate(references):
            if reference is None:
                if not table.allow_null or references[0] is not None:
                    raise ValueError("A null frame requires the original zero word at the table root")
                offset = 0
            else:
                owner = frame_specs.get(reference)
                if owner is None or owner.kind != table.selector_kinds[index]:
                    raise ValueError("Mapping reference leaves a typed consumer frame ABI")
                if owner.kind.startswith("ss-dplc-"):
                    check_transfer(frames[owner.name]["entries"], table.transfer_budgets[index])
                offset = owner.address - table.address
                if not -32768 <= offset <= 32767 or offset == 0:
                    raise ValueError("Mapping reference exceeds signed-word addressing")
            words.extend((offset & 0xFFFF).to_bytes(2, "big"))
        patches.append(Patch(table.name, table.address, bytes(words)))
    for frame in spec.frames:
        row = frames[frame.name]
        keys(row, "name entries")
        body = encode_frame(row["entries"], frame.kind)
        if len(body) != frame.size:
            raise ValueError("Edited frame exceeds or changes its original source slot")
        patches.append(Patch(frame.name, frame.address, body))
    return tuple(sorted(patches, key=lambda row: row.address))


@dataclass(frozen=True)
class Document:
    spec: Spec

    @classmethod
    def open(cls, rom, spec):
        return cls(spec), decode(rom, spec)

    def encode(self, model, target):
        if target != self.spec:
            raise ValueError("Source-view target changes the frozen ABI or allocation")
        return encode(model, target)


def apply(rom, patches):
    """Return a byte view only after all overlapping writes agree and fit."""
    result = bytearray(rom)
    cells = {}
    for patch in patches:
        if type(patch.address) is not int or not 0 <= patch.address <= len(result) - len(patch.data):
            raise ValueError("Source patch leaves its address space")
        for at, value in enumerate(patch.data, patch.address):
            if at in cells and cells[at] != value:
                raise ValueError("Conflicting edits to shared source views")
            cells[at] = value
    for at, value in cells.items():
        result[at] = value
    return bytes(result)
