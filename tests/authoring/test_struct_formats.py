"""Research regressions for structural formats and transactional asset output."""

import unittest
from dataclasses import replace
from scripts.authoring.struct_formats import FORMATS, tile_decode, tile_encode, block_decode, block_encode
from scripts.authoring.asset_document import Document, Target


class RecordTests(unittest.TestCase):
    def test_tile_and_chunk_flag_layouts(self):
        self.assertEqual(tile_decode(0xED55), dict(index=0x555, x_flip=True, y_flip=False, palette=3, priority=True))
        self.assertEqual(
            block_decode(0xDEAA), dict(index=0x2AA, x_flip=True, y_flip=True, primary_solidity=1, secondary_solidity=3)
        )
        for word in range(65536):
            self.assertEqual(tile_encode(tile_decode(word)), word)
            self.assertEqual(block_encode(block_decode(word)), word)

    def test_tile_scan_order_and_pixels(self):
        raw = b"\x12\x34\x56\x78" * 8
        tiles = FORMATS["tiles-4bpp"].decode(raw)
        self.assertEqual(tiles[0][:8], list(range(1, 9)))
        with self.assertRaises(ValueError):
            FORMATS["tiles-4bpp"].decode(raw[:-1])
        tiles[0][0] = 16
        with self.assertRaises(ValueError):
            FORMATS["tiles-4bpp"].encode(tiles)

    def test_plane_rows_are_interleaved_in_storage(self):
        raw = b"".join(bytes([y]) * 128 + bytes([128 + y]) * 128 for y in range(16))
        codec = FORMATS["level-layout-s2"]
        model = codec.decode(raw)
        self.assertEqual(model["foreground"][3], [3] * 128)
        self.assertEqual(model["background"][3], [131] * 128)
        self.assertEqual(codec.encode(model), raw)
        model["foreground"][3].append(0)
        with self.assertRaises(ValueError):
            codec.encode(model)

    def test_object_flag_word_and_partial_record(self):
        codec = FORMATS["object-placement-s2"]
        row = codec.decode(bytes.fromhex("1234FABC7F80"))[0]
        self.assertEqual(
            row,
            dict(
                x=0x1234, y=0xABC, respawn=True, y_flip=True, x_flip=True, mode_flag=True, object_id=0x7F, subtype=0x80
            ),
        )
        with self.assertRaises(ValueError):
            codec.decode(b"\0" * 5)
        row["y"] = 4096
        with self.assertRaises(ValueError):
            codec.encode([row])

    def test_ring_terminator_and_expanded_capacity(self):
        codec = FORMATS["ring-groups-s2"]
        rows = codec.decode(bytes.fromhex("0100F020FFFF"))
        self.assertEqual(rows, [dict(x=256, y=32, count=8, vertical=True)])
        self.assertEqual(codec.encode(rows), bytes.fromhex("0100F020FFFF"))
        with self.assertRaises(ValueError):
            codec.decode(b"\xff\xff\0\0\xff\xff")
        with self.assertRaises(ValueError):
            codec.encode(rows * 32)

    def test_palette_unused_bits_are_preserved(self):
        codec = FORMATS["palette-md"]
        row = codec.decode(b"\xff\xff")[0]
        self.assertEqual(row, dict(red=7, green=7, blue=7, reserved=0xF111))
        self.assertEqual(codec.encode([row]), b"\xff\xff")
        row["reserved"] = 2
        with self.assertRaises(ValueError):
            codec.encode([row])

    def test_special_stage_row_count_and_ignored_trailer(self):
        codec = FORMATS["special-stage-tile-rows"]
        raw = bytes.fromhex("0001123456780000")
        model = codec.decode(raw)
        self.assertEqual(model, dict(rows=[list(range(1, 9))], trailer=[0, 0]))
        self.assertEqual(codec.encode(model), raw)
        with self.assertRaises(ValueError):
            codec.decode(bytes.fromhex("000212345678"))


class DocumentTests(unittest.TestCase):
    def setUp(self):
        self.target = Target("sample", "start-position-s2", "s2-retail", "m68000-rom", 0x100, 16, 4)

    def test_zero_edit_retains_original_compressed_representation(self):
        doc, model = Document.open(b"original", self.target, "example", lambda _: b"\0\x10\0\x20")
        self.assertEqual(doc.encode(model, self.target), b"original")
        model["x"] = 17
        with self.assertRaises(ValueError):
            doc.encode(model, self.target)
        self.assertEqual(doc.encode(model, self.target, lambda plain: b"new" + plain), b"new\0\x11\0\x20")

    def test_abi_asset_and_address_space_are_checked_for_zero_edit(self):
        doc, model = Document.open(b"\0" * 4, self.target)
        for field, value in [
            ("abi", "other"),
            ("asset_id", "other"),
            ("address_space", "z80-window"),
            ("format_id", "tilemap"),
        ]:
            with self.subTest(field=field), self.assertRaises(ValueError):
                doc.encode(model, replace(self.target, **{field: value}))

    def test_decoded_capacity_rejects_before_compression(self):
        doc, model = Document.open(b"original", self.target, "example", lambda _: b"\0" * 4)
        model["x"] = 1
        calls = []
        with self.assertRaises(ValueError):
            doc.encode(model, replace(self.target, decoded_capacity=3), lambda b: calls.append(b))
        self.assertEqual(calls, [])

    def test_encoded_capacity_and_bank_boundary(self):
        target = replace(self.target, bank_size=0x8000, fixed_start=False)
        doc, model = Document.open(b"\0" * 4, target)
        with self.assertRaises(ValueError):
            doc.encode(model, replace(target, encoded_capacity=3))
        with self.assertRaises(ValueError):
            doc.encode(model, replace(target, start=0x7FFE))
        self.assertEqual(doc.encode(model, replace(target, start=0x8000)), b"\0" * 4)

    def test_missing_decoder_and_invalid_target(self):
        with self.assertRaises(ValueError):
            Document.open(b"original", self.target, "example")
        with self.assertRaises(ValueError):
            Document.open(b"\0" * 4, replace(self.target, bank_size=3))

    def test_fixed_placement_and_allocation_cannot_be_widened(self):
        doc, model = Document.open(b"\0" * 4, self.target)
        for target in [
            replace(self.target, start=0x200),
            replace(self.target, encoded_capacity=17),
            replace(self.target, decoded_capacity=5),
            replace(self.target, address_limit=0x200000),
            replace(self.target, fixed_start=False),
        ]:
            with self.subTest(target=target), self.assertRaises(ValueError):
                doc.encode(model, target)

    def test_original_nonzero_tail_is_preserved_even_when_other_fields_change(self):
        target = replace(self.target, protected_ranges=((2, 4),))
        doc, model = Document.open(b"\0\x10\x40\0", target)
        model["x"] = 17
        self.assertEqual(doc.encode(model, target), b"\0\x11\x40\0")
        model["y"] = 0
        with self.assertRaises(ValueError):
            doc.encode(model, target)
        with self.assertRaises(ValueError):
            doc.encode(model, replace(target, protected_ranges=()))

    def test_protected_ranges_cannot_use_mutable_nested_containers(self):
        for ranges in [[(2, 4)], ([2, 4],)]:
            with self.subTest(ranges=ranges), self.assertRaisesRegex(ValueError, "immutable pairs"):
                Document.open(b"\0" * 4, replace(self.target, protected_ranges=ranges))

    def test_target_slot_and_protected_ranges_are_bounded(self):
        for target in [
            replace(self.target, start=0xFFFFF),
            replace(self.target, protected_ranges=((0, 5),)),
            replace(self.target, protected_ranges=((2, 4), (1, 2))),
        ]:
            with self.subTest(target=target), self.assertRaises(ValueError):
                Document.open(b"\0" * 4, target)


if __name__ == "__main__":
    unittest.main()
