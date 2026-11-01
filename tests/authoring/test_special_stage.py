"""Special-stage structure and bitstream boundary regressions."""

import unittest
from scripts.authoring.ss_track import decode, encode, render
from scripts.authoring.ss_tables import (
    decode_geometry,
    encode_geometry,
    decode_objects,
    encode_objects,
    decode_perspective,
    encode_perspective,
    decode_sine,
    encode_sine,
    decode_angles,
    encode_angles,
)


def frame():
    return {
        "tags": [0, 0, 0],
        "rows": [[{"kind": "run", "wide": False, "index": 0}] for _ in range(28)],
        "tails": {"selectors": [], "literals": [], "runs": []},
        "trailer": [],
    }


class TrackTests(unittest.TestCase):
    def test_bitstream_sections_padding_and_full_frame(self):
        raw = encode(frame())
        model = decode(raw)
        self.assertEqual(encode(model), raw)
        rows = render(model, [], [(0x123, 127)], 64, 64)
        self.assertEqual(rows, [[0xE123] * 128 for _ in range(28)])

    def test_wide_literal_uses_second_lut_region(self):
        model = frame()
        model["rows"][0].insert(0, {"kind": "literal", "wide": True, "index": 0})
        literal = [0] * 64 + [0x123]
        # Other rows keep one full-width run; only the first row uses the short run.
        model["rows"][0][1]["index"] = 1
        rows = render(model, literal, [(1, 127), (2, 126)], 64, 64)
        self.assertEqual(rows[0][0], 0x6123)
        self.assertEqual(rows[0][1:], [0xE002] * 127)

    def test_reserved_run_marker_and_lut_overflow(self):
        model = frame()
        model["rows"][0][0] = {"kind": "run", "wide": True, "index": 127}
        with self.assertRaises(ValueError):
            encode(model)
        model["rows"][0][0] = {"kind": "literal", "wide": True, "index": 1023}
        with self.assertRaises(ValueError):
            render(model, [0] * 65, [(0, 127)], 64, 64)

    def test_bad_section_extent_and_truncated_frame(self):
        raw = bytearray(encode(frame()))
        raw[2:4] = b"\x7f\xfc"
        with self.assertRaises(ValueError):
            decode(raw)
        with self.assertRaises(ValueError):
            decode(encode(frame())[:-1])

    def test_expansion_cannot_overrun_row(self):
        model = frame()
        model["rows"][0].append({"kind": "run", "wide": False, "index": 0})
        with self.assertRaises(ValueError):
            render(model, [], [(0, 127)], 64, 64)


class TableTests(unittest.TestCase):
    def test_geometry_flip_and_signed_offset_boundary(self):
        model = [[{"animation": index % 5, "flipped": bool(index & 1)}] for index in range(7)]
        raw = encode_geometry(model)
        self.assertEqual(decode_geometry(raw), model)
        bad = bytearray(raw)
        bad[0:2] = b"\x80\x00"
        with self.assertRaises(ValueError):
            decode_geometry(bad)
        model[0][0]["animation"] = 5
        with self.assertRaises(ValueError):
            encode_geometry(model)

    def test_perspective_aliases_and_signed_center(self):
        sample = {
            "center_x": 128,
            "center_y": -8,
            "radius_x": 16,
            "radius_y": 32,
            "occlusion_min": 64,
            "occlusion_max": 192,
        }
        model = {"frames": [0] * 56, "records": [{"visible_depth": 1, "samples": [sample]}]}
        raw = encode_perspective(model)
        self.assertEqual(raw[:112], b"\0\x70" * 56)
        self.assertEqual(decode_perspective(raw), model)
        model["records"][0]["visible_depth"] = 2
        with self.assertRaises(ValueError):
            encode_perspective(model)

    def test_object_groups_markers_trailer_and_slot_capacity(self):
        model = {"stages": [[{"objects": [], "marker": 255}] for _ in range(7)], "trailer": [0, 0, 0]}
        raw = encode_objects(model)
        self.assertEqual(decode_objects(raw), model)
        bad = bytearray(raw)
        bad[14] = 0
        with self.assertRaises(ValueError):
            decode_objects(bad)
        model["stages"][0][0]["objects"] = [{"kind": "ring", "distance_steps": 0, "angle": 0}] * 120
        with self.assertRaises(ValueError):
            encode_objects(model, max_objects_per_group=119)

    def test_sine_cosine_extension_has_one_data_owner(self):
        values = list(range(-128, 128))
        raw = encode_sine(values)
        self.assertEqual(decode_sine(raw), values)
        self.assertEqual(raw[:128], raw[512:])
        bad = bytearray(raw)
        bad[-1] ^= 1
        with self.assertRaises(ValueError):
            decode_sine(bad)

    def test_angle_table_preserves_alignment_byte(self):
        model = {"angles": [index & 255 for index in range(257)], "alignment": 255}
        self.assertEqual(decode_angles(encode_angles(model)), model)
        with self.assertRaises(ValueError):
            decode_angles(b"\0" * 257)


if __name__ == "__main__":
    unittest.main()
