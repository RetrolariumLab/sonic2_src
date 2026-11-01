"""Check path aliases, signed-word offsets and word-indexed point capacities."""

import unittest
from scripts.authoring.tube_paths import decode, encode


class TubePathTests(unittest.TestCase):
    def fixture(self):
        return {"references": [0, 0, 1], "paths": [[{"x": 16, "y": 32}], [{"x": 0xFFFF, "y": 0}, {"x": 128, "y": 256}]]}

    def test_aliases_and_coordinate_words_round_trip(self):
        model = self.fixture()
        stream = encode(model)
        self.assertEqual(decode(stream, 3), model)
        self.assertEqual(stream[:4], bytes([0, 6, 0, 6]))

    def test_size_word_must_match_complete_points(self):
        stream = bytearray(encode(self.fixture()))
        stream[6:8] = bytes([0, 3])
        with self.assertRaisesRegex(ValueError, "byte length"):
            decode(stream, 3)

    def test_point_cursor_cannot_wrap(self):
        model = self.fixture()
        model["paths"][0] *= 8192
        with self.assertRaisesRegex(ValueError, "word-indexed"):
            encode(model)

    def test_more_than_63_points_is_valid_with_the_word_cursor(self):
        model = {"references": [0], "paths": [[{"x": 1, "y": 2}] * 64]}
        self.assertEqual(decode(encode(model), 1), model)

    def test_selector_count_cannot_exceed_subtype(self):
        model = self.fixture()
        model["references"] = [0] * 17
        with self.assertRaisesRegex(ValueError, "four-bit subtype"):
            encode(model)

    def test_unowned_and_out_of_range_coordinates_are_rejected(self):
        model = self.fixture()
        model["references"][0] = 2
        with self.assertRaises(ValueError):
            encode(model)
        model = self.fixture()
        model["paths"][0][0]["x"] = 65536
        with self.assertRaises(ValueError):
            encode(model)


if __name__ == "__main__":
    unittest.main()
