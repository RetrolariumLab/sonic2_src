"""Check effective frame periods rather than confusing timer reloads with durations."""

import unittest
from scripts.authoring.palette_cycles import decode, encode


class PaletteCycleTests(unittest.TestCase):
    def test_reload_zero_and_255_mean_one_and_256_frames(self):
        data = bytes([0, 255] + list(range(14)))
        periods = decode(data)
        self.assertEqual(periods[:2], [1, 256])
        self.assertEqual(encode(periods), data)

    def test_fixed_cycle_step_count_is_preserved(self):
        for data in [bytes(15), bytes(17)]:
            with self.assertRaises(ValueError):
                decode(data)
        with self.assertRaises(ValueError):
            encode([1] * 17)

    def test_periods_must_fit_the_original_reload_byte(self):
        for value in [0, 257, -1, True]:
            with self.subTest(value=value), self.assertRaises(ValueError):
                encode([value] + [1] * 15)


if __name__ == "__main__":
    unittest.main()
