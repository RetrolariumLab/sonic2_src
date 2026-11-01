"""Check null sprite frames, unused pieces and DPLC field/capacity limits."""

import copy, unittest
from scripts.authoring.sprite_formats import decode, encode
from scripts.authoring.struct_formats import tile_decode


def piece():
    return {
        "x": -16,
        "y": -8,
        "width": 4,
        "height": 2,
        "size_reserved": 0,
        "single_player": tile_decode(0xE123),
        "two_player": tile_decode(0xE091),
    }


class SpriteTests(unittest.TestCase):
    def test_null_frame_alias_and_unused_piece_gap(self):
        model = {"references": [None, 0, 0], "frames": [[piece()]], "gaps": [{"before_frame": 0, "entries": [piece()]}]}
        raw = encode(model, "sprite")
        self.assertEqual(raw[:6], b"\0\0\0\x0e\0\x0e")
        self.assertEqual(decode(raw, 3, "sprite", [14]), model)
        with self.assertRaises(ValueError):
            decode(raw, 3, "sprite")

    def test_null_reference_requires_zero_root_header(self):
        model = {"references": [0, None], "frames": [[piece()]], "gaps": []}
        with self.assertRaises(ValueError):
            encode(model, "sprite")

    def test_pointer_cannot_enter_piece_body(self):
        raw = bytearray(encode({"references": [0], "frames": [[piece()]], "gaps": []}, "sprite"))
        raw[:2] = b"\0\x04"
        with self.assertRaises(ValueError):
            decode(raw, 1, "sprite")

    def test_sprite_coordinate_dimensions_and_piece_budget(self):
        model = {"references": [0], "frames": [[piece()]], "gaps": []}
        model["frames"][0][0]["y"] = -129
        with self.assertRaises(ValueError):
            encode(model, "sprite")
        model["frames"] = [[piece()] * 81]
        with self.assertRaises(ValueError):
            encode(model, "sprite")

    def test_dplc_runs_and_transfer_capacity(self):
        model = {
            "references": [0, 0],
            "frames": [[{"tiles": 16, "source_tile": 4095}, {"tiles": 1, "source_tile": 0}]],
            "gaps": [],
        }
        raw = encode(model, "dplc", max_transfer_tiles=17)
        self.assertEqual(raw, b"\0\x04\0\x04\0\x02\xff\xff\0\0")
        self.assertEqual(decode(raw, 2, "dplc"), model)
        with self.assertRaises(ValueError):
            encode(model, "dplc", max_transfer_tiles=16)
        model["frames"][0][0]["tiles"] = 17
        with self.assertRaises(ValueError):
            encode(model, "dplc")


if __name__ == "__main__":
    unittest.main()
