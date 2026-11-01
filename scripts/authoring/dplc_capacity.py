"""Pure immutable bounds for DPLC source reads and destination pattern transfers."""

from dataclasses import dataclass


@dataclass(frozen=True)
class Budget:
    source_bytes: int
    max_tiles: int
    offset_scale: int

    def validate(self):
        if type(self.source_bytes) is not int or self.source_bytes < 1:
            raise ValueError("Invalid DPLC source allocation")
        if type(self.max_tiles) is not int or not 0 <= self.max_tiles <= 2048:
            raise ValueError("Invalid DPLC destination tile capacity")
        if type(self.offset_scale) is not int or self.offset_scale not in {2, 32}:
            raise ValueError("Invalid DPLC source offset ABI")


def check(entries, budget):
    if type(budget) is not Budget:
        raise ValueError("DPLC transfer needs an immutable budget")
    budget.validate()
    field = "source_word_offset" if budget.offset_scale == 2 else "source_tile"
    total = 0
    for row in entries:
        count, offset = row["tiles"], row[field]
        if type(count) is not int or not 1 <= count <= 16 or type(offset) is not int or not 0 <= offset <= 0xFFF:
            raise ValueError("Invalid DPLC run fields")
        if offset * budget.offset_scale + count * 32 > budget.source_bytes:
            raise ValueError("DPLC run reads beyond its source art allocation")
        total += count
    if total > budget.max_tiles:
        raise ValueError("DPLC frame exceeds its destination pattern allocation")
