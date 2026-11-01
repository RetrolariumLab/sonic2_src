"""Reject legal-width DPLC fields that exceed actual art or VRAM allocations."""

from dataclasses import FrozenInstanceError
import unittest
from scripts.authoring.dplc_capacity import Budget, check


class DplcCapacityTests(unittest.TestCase):
    def test_ordinary_tile_offset_end_is_inclusive(self):
        check([{"tiles": 2, "source_tile": 2}], Budget(128, 2, 32))
        with self.assertRaisesRegex(ValueError, "source art allocation"):
            check([{"tiles": 2, "source_tile": 3}], Budget(128, 2, 32))

    def test_special_offsets_are_words_instead_of_tiles(self):
        check([{"tiles": 2, "source_word_offset": 32}], Budget(128, 2, 2))
        with self.assertRaisesRegex(ValueError, "source art allocation"):
            check([{"tiles": 2, "source_word_offset": 33}], Budget(128, 2, 2))

    def test_sum_of_legal_runs_can_overflow_destination(self):
        with self.assertRaisesRegex(ValueError, "destination pattern allocation"):
            check([{"tiles": 8, "source_tile": 0}, {"tiles": 9, "source_tile": 0}], Budget(512, 16, 32))

    def test_bounds_are_frozen_and_typed(self):
        budget = Budget(512, 16, 32)
        with self.assertRaises(FrozenInstanceError):
            budget.source_bytes = 1024
        for item in [Budget(0, 16, 32), Budget(32, -1, 32), Budget(32, 16, 1), Budget(True, 16, 32)]:
            with self.subTest(item=item), self.assertRaises(ValueError):
                item.validate()


if __name__ == "__main__":
    unittest.main()
