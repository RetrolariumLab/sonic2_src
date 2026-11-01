"""Check indexed source aliases, engine bounds, retail exceptions and reserved fields."""

from dataclasses import replace
import unittest
from scripts.authoring.indexed_records import Spec, decode, encode, encode_record


class IndexedRecordTests(unittest.TestCase):
    def test_track_aliases_and_original_alignment_round_trip(self):
        spec = Spec("track-frames-s2", 2, 7, ((4, 6),), limit=3)
        stream = bytes([0, 4, 0, 4, 1, 2, 0xA5])
        model = decode(stream, spec)
        self.assertEqual(model["references"], [4, 4])
        self.assertEqual(model["alignment"], [0xA5])
        self.assertEqual(encode(model, spec), stream)
        model["records"][0]["value"]["frames"][0] = 3
        with self.assertRaisesRegex(ValueError, "frame table"):
            encode(model, spec)

    def test_scroll_byte_255_is_unsigned_like_the_engine_read(self):
        spec = Spec("background-scroll-s2", 1, 8, ((2, 7),))
        stream = bytes([0, 2, 0, 255, 2, 3, 4, 0])
        model = decode(stream, spec)
        self.assertEqual(model["records"][0]["value"]["increments"][1], 255)
        self.assertEqual(encode(model, spec), stream)
        model["records"][0]["value"]["increments"][1] = -1
        with self.assertRaises(ValueError):
            encode(model, spec)

    def test_a_retail_invalid_selector_is_bound_to_its_exact_cell(self):
        spec = Spec("phrase-words-s2", 1, 5, ((2, 5),), limit=18, exceptions=((3, 36),))
        stream = bytes([0, 2, 0, 36, 255])
        model = decode(stream, spec)
        self.assertEqual(encode(model, spec), stream)
        with self.assertRaisesRegex(ValueError, "undeclared invalid"):
            decode(stream, replace(spec, exceptions=()))
        model["records"][0]["value"]["selectors"][0] = 36
        with self.assertRaisesRegex(ValueError, "undeclared invalid"):
            encode(model, spec)

    def test_replacing_a_retail_hazard_with_a_valid_word_is_allowed(self):
        spec = Spec("phrase-words-s2", 1, 5, ((2, 5),), limit=18, exceptions=((3, 36),))
        model = decode(bytes([0, 2, 0, 36, 255]), spec)
        model["records"][0]["value"]["selectors"][1] = 34
        self.assertEqual(encode(model, spec), bytes([0, 2, 0, 34, 255]))

    def test_phrase_word_selectors_must_be_even(self):
        spec = Spec("phrase-words-s2", 1, 4, ((2, 4),), limit=18)
        with self.assertRaisesRegex(ValueError, "undeclared invalid"):
            decode(bytes([0, 2, 3, 255]), spec)

    def test_message_glyphs_use_the_actual_sprite_frame_count(self):
        spec = Spec("message-glyphs-s2", 1, 5, ((2, 5),), limit=4)
        model = decode(bytes([0, 2, 0, 3, 255]), spec)
        model["records"][0]["value"]["frames"][1] = 4
        with self.assertRaisesRegex(ValueError, "undeclared invalid"):
            encode(model, spec)

    def test_message_terminator_remains_an_explicit_negative_byte(self):
        spec = Spec("message-glyphs-s2", 1, 4, ((2, 4),), limit=4)
        model = decode(bytes([0, 2, 1, 0x80]), spec)
        self.assertEqual(encode(model, spec), bytes([0, 2, 1, 0x80]))
        model["records"][0]["value"]["terminator"] = 0
        with self.assertRaisesRegex(ValueError, "negative"):
            encode(model, spec)

    def test_hud_count_and_mapping_limits_are_both_enforced(self):
        spec = Spec("hud-layout-s2", 1, 6, ((2, 6),), limit=4, object_slots=8)
        stream = bytes([0, 2, 2, 128, 0, 3])
        model = decode(stream, spec)
        self.assertEqual(encode(model, spec), stream)
        with self.assertRaisesRegex(ValueError, "object record"):
            encode(model, replace(spec, object_slots=1))
        model["records"][0]["value"]["frames"][1] = 4
        with self.assertRaisesRegex(ValueError, "frame table"):
            encode(model, spec)

    def test_pulley_relative_points_are_signed_words(self):
        spec = Spec("pulley-path-s2", 1, 8, ((2, 8),))
        stream = bytes([0, 2, 0, 4, 255, 224, 0, 16])
        model = decode(stream, spec)
        self.assertEqual(model["records"][0]["value"]["points"], [{"x": -32, "y": 16}])
        self.assertEqual(encode(model, spec), stream)

    def test_pulley_byte_cursor_rejects_a_word_sized_64_point_route(self):
        spec = Spec("pulley-path-s2", 1, 8, ((2, 8),))
        with self.assertRaisesRegex(ValueError, "byte cursor"):
            encode_record({"points": [{"x": 0, "y": 0}] * 64}, spec, 2)

    def test_child_layout_retains_the_unused_high_subtype_byte(self):
        spec = Spec("pulley-children-s2", 1, 10, ((2, 10),), object_slots=1)
        stream = bytes([0, 2, 0, 0, 255, 240, 0, 32, 0xA5, 5])
        model = decode(stream, spec)
        child = model["records"][0]["value"]["children"][0]
        self.assertEqual((child["x"], child["y"], child["subtype"], child["reserved_subtype_high"]), (-16, 32, 5, 0xA5))
        self.assertEqual(encode(model, spec), stream)
        child["x"] = -32769
        with self.assertRaisesRegex(ValueError, "signed word"):
            encode(model, spec)

    def test_ending_schedule_has_exactly_28_samples(self):
        spec = Spec("ending-frames-s2", 1, 30, ((2, 30),), limit=26)
        stream = bytes([0, 2]) + bytes(list(range(26)) + [0, 1])
        model = decode(stream, spec)
        self.assertEqual(encode(model, spec), stream)
        model["records"][0]["value"]["frames"].pop()
        with self.assertRaisesRegex(ValueError, "28 frame"):
            encode(model, spec)

    def test_pointer_must_reach_a_complete_owned_record(self):
        spec = Spec("track-frames-s2", 1, 4, ((2, 4),), limit=4)
        with self.assertRaisesRegex(ValueError, "complete owned"):
            decode(bytes([0, 3, 0, 1]), spec)

    def test_source_slots_and_selector_count_are_immutable(self):
        spec = Spec("track-frames-s2", 1, 4, ((2, 4),), limit=4)
        model = decode(bytes([0, 2, 0, 1]), spec)
        model["records"][0]["offset"] = 3
        with self.assertRaisesRegex(ValueError, "source slots"):
            encode(model, spec)
        with self.assertRaisesRegex(ValueError, "immutable"):
            replace(spec, slots=[(2, 4)]).validate()

    def test_inter_record_gaps_cannot_hide_unmodeled_payloads(self):
        with self.assertRaisesRegex(ValueError, "leave a gap"):
            Spec("track-frames-s2", 1, 9, ((2, 4), (5, 9))).validate()
        with self.assertRaisesRegex(ValueError, "alignment byte"):
            Spec("track-frames-s2", 1, 6, ((2, 4),)).validate()


if __name__ == "__main__":
    unittest.main()
