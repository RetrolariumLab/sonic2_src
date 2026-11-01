"""Check demo hold counts and fixed-layout animation byte ownership."""

import unittest
from scripts.authoring.control_formats import (
    decode_demo,
    encode_demo,
    decode_animation,
    encode_animation,
    animation_hazards,
)


class ControlTests(unittest.TestCase):
    def test_demo_duration_minus_one(self):
        self.assertEqual(decode_demo(b"\x10\xff"), [{"buttons": 16, "frames": 256}])
        self.assertEqual(encode_demo([{"buttons": 0, "frames": 1}]), b"\0\0")
        with self.assertRaises(ValueError):
            decode_demo(b"\0")
        with self.assertRaises(ValueError):
            encode_demo([{"buttons": 0, "frames": 0}])

    def test_player_and_object_frame_ranges_differ(self):
        raw = b"\0\x02\x09\xd5\xff"
        player = decode_animation(raw, 1, True)
        ordinary = decode_animation(raw, 1)
        self.assertEqual(player["scripts"][0]["events"][0]["kind"], "frame")
        self.assertEqual(ordinary["scripts"][0]["events"][0]["kind"], "control")
        self.assertEqual(encode_animation(player, True), raw)
        self.assertEqual(encode_animation(ordinary), raw)

    def test_argument_can_alias_next_script_timing_without_duplication(self):
        raw = bytes.fromhex("00040008050a0bfe030c0dff")
        model = decode_animation(raw, 2)
        hazards = animation_hazards(model)
        self.assertEqual(hazards, [("backward_cursor_wrap", 7, 3)])
        self.assertEqual(encode_animation(model, allowed_hazards=hazards), raw)
        with self.assertRaises(ValueError):
            encode_animation(model, allowed_hazards=[])
        model["scripts"][1]["timing_code"] = 2
        with self.assertRaises(ValueError):
            encode_animation(model)
        model["scripts"][0]["events"][-1]["arguments"] = [2]
        self.assertEqual(animation_hazards(model), [])
        self.assertNotEqual(encode_animation(model, allowed_hazards=hazards), raw)

    def test_external_script_requires_declared_target(self):
        raw = b"\xff\xfc\0"
        model = decode_animation(raw, 1)
        self.assertEqual(encode_animation(model, allowed_external_offsets=[-4]), raw)
        model["pointers"] = [-6]
        with self.assertRaises(ValueError):
            encode_animation(model, allowed_external_offsets=[-4])

    def test_pointer_cannot_enter_an_undeclared_local_script(self):
        model = decode_animation(b"\0\x02\x09\x01\xff", 1)
        model["pointers"] = [3]
        with self.assertRaises(ValueError):
            encode_animation(model)

    def test_control_argument_and_fixed_layout_bytes_are_required(self):
        with self.assertRaises(ValueError):
            decode_animation(b"\0\x02\x09\xfe", 1)
        model = decode_animation(b"\xff\xfc\0", 1)
        model["unclaimed"] = []
        with self.assertRaises(ValueError):
            encode_animation(model)

    def test_control_switch_hazard_is_explicit(self):
        model = decode_animation(b"\0\x02\x09\xfd\x08", 1)
        self.assertEqual(animation_hazards(model), [("animation_switch_out_of_table", 3, 8)])
        with self.assertRaises(ValueError):
            encode_animation(model, allowed_hazards=[])


if __name__ == "__main__":
    unittest.main()
