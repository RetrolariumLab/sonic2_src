"""Exercise source-owned record boundaries, signed fields and protected references."""

import unittest
from scripts.authoring import engine_records as records
from scripts.authoring.source_records import protected, open_record
from scripts.authoring.asset_document import Document, Target
from scripts.authoring.struct_formats import Codec


class EngineRecordTests(unittest.TestCase):
    def test_bound_prototype_keeps_unproven_control_selectors(self):
        data = b"\0\0\x10\0\x20\0\x10\x04\x10\x0b"
        target = Target(
            "prototype",
            "engine-records-s2",
            "rev00",
            "m68000-rom",
            0,
            10,
            10,
            protected_ranges=protected("subobjdata", data),
        )
        document, model = open_record("subobjdata", data, target)
        model["width"] = 17
        self.assertEqual(document.encode(model, target)[8], 17)
        model["priority"] = 255
        with self.assertRaisesRegex(ValueError, "protected"):
            document.encode(model, target)

    def roundtrip(self, kind, stream):
        self.assertEqual(records.encode(kind, records.decode(kind, stream)), stream)

    def test_credit_glyphs_and_menu_counts(self):
        self.roundtrip("credittext", b"\x60\x02\x03\xff")
        self.roundtrip("menutxt", b"\x02\x1e\x1f\x20")
        for kind, data in [("credittext", b"\0ABC"), ("credittext", b"\0\xfe\xff"), ("menutxt", b"\x04ABC")]:
            with self.assertRaises(ValueError):
                records.decode(kind, data)

    def test_signed_robot_motion_and_count(self):
        data = bytes([0, 8, 0x30, 0xE0, 0x0C])
        model = records.decode("c7anilistheader", data)
        self.assertEqual(model["children"][0]["dx"], -32)
        self.roundtrip("c7anilistheader", data)
        for invalid in [data[:-1], bytes([0, 8, 0x31, 0, 0]), bytes([1, 8, 0x30, 0, 0])]:
            with self.assertRaises(ValueError):
                records.decode("c7anilistheader", invalid)

    def test_palette_ram_and_signed_counter_limits(self):
        data = b"\0\0\x10\0\0\0\x20\0\x60\x0f\x02\x07"
        self.roundtrip("c9palinfo", data)
        for offset, value in [(8, 0x61), (9, 0x20), (10, 0x80), (11, 0x80)]:
            invalid = bytearray(data)
            invalid[offset] = value
            with self.assertRaises(ValueError):
                records.decode("c9palinfo", invalid)

    def test_credit_layout_uses_two_byte_terminal_word(self):
        data = b"\0\0\x10\0\xc0\0\xff\xff"
        self.roundtrip("credits_layout", data)
        with self.assertRaises(ValueError):
            records.decode("credits_layout", data[:-1])
        with self.assertRaises(ValueError):
            records.decode("credits_layout", data + b"\xff\xff")

    def test_pointers_are_protected_and_other_abis_are_rejected(self):
        data = b"\0\0\x10\0\0\0\x20\0\x60\x0f\x02\x07"
        target = Target(
            "palette-test",
            "engine-records-s2",
            "rev00",
            "m68000-rom",
            0,
            12,
            12,
            protected_ranges=protected("c9palinfo", data),
        )
        handler = Codec(
            lambda value: records.decode("c9palinfo", value), lambda value: records.encode("c9palinfo", value)
        )
        document, model = Document.open(data, target, handler=handler)
        model["period"] = 3
        self.assertEqual(document.encode(model, target)[10], 3)
        model["palette"] += 2
        with self.assertRaisesRegex(ValueError, "protected"):
            document.encode(model, target)
        from dataclasses import replace

        with self.assertRaisesRegex(ValueError, "abi"):
            document.encode(model, replace(target, abi="rev01"))

    def test_animated_tiles_count_alignment_and_art_frames(self):
        data = b"\0\0\xff\0\x10\0\0\x20\x02\x02\0\x07\x02\x08"
        self.roundtrip("zoneanimstart", data)
        with self.assertRaises(ValueError):
            records.decode("zoneanimstart", data[:-1])

    def test_fixed_records_reject_overflow_boolean_and_missing_fields(self):
        row = {"parent_slot": 0x2C, "object_id": 1, "subtype": 2}
        self.roundtrip("childobjectdata", records.encode("childobjectdata", row))
        for bad in [
            dict(row, parent_slot=0x3F),
            dict(row, subtype=256),
            dict(row, object_id=True),
            {"parent_slot": 0x2C},
        ]:
            with self.assertRaises(ValueError):
                records.encode("childobjectdata", bad)

    def test_motion_program_control_codes_are_typed_and_bounded(self):
        data = b"\0\0\x10\0\x00\x81\x40\xbd\xff\0"
        self.roundtrip("robot_program", data)
        model = records.decode("robot_program", data)
        self.assertTrue(model["events"][1]["mirrored"])
        self.assertEqual(model["events"][2]["kind"], "sound")
        self.assertEqual(model["events"][3]["kind"], "restart")
        for invalid in [data[:-2], data[:-2] + b"\x40", data + b"\0\0"]:
            with self.assertRaises(ValueError):
                records.decode("robot_program", invalid)

    def test_debug_and_pattern_load_counts_are_not_interchangeable(self):
        self.roundtrip("dbglistheader", b"\0\0")
        self.roundtrip("plrlistheader", b"\xff\xff")
        with self.assertRaises(ValueError):
            records.decode("plrlistheader", b"\0\0")
        with self.assertRaises(ValueError):
            records.decode("dbglistheader", b"\xff\xff")

    def test_projectile_high_velocity_bytes_and_partial_records(self):
        data = b"\0\xf8\0\xfc\x02\0"
        self.roundtrip("projectile_burst", data)
        model = records.decode("projectile_burst", data)
        self.assertEqual(model["projectiles"][0]["y_velocity_high"], -4)
        for invalid in [data[:-1], data[:-1] + b"\x80"]:
            with self.assertRaises(ValueError):
                records.decode("projectile_burst", invalid)
