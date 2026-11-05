"""A real-edit proof must reject unchanged images and writes outside typed slots."""

import unittest
from scripts.authoring.edit_probes import compare, expected_image


class EditProbeTests(unittest.TestCase):
    def test_exact_palette_edit_and_independent_checksum(self):
        original = bytes(1024)
        edits = [(0x220, bytes(4), bytes.fromhex("00020000")), (0x280, bytes(2), bytes.fromhex("0200"))]
        expected = expected_image(original, edits)
        self.assertEqual(expected[0x18E:0x190], bytes.fromhex("0202"))
        self.assertEqual(compare(expected, original, edits), [0x18E, 0x18F, 0x221, 0x280])
        for offset in (0x100, 0x224, 0x300):
            altered = bytearray(expected)
            altered[offset] = 1
            with self.subTest(offset=offset), self.assertRaisesRegex(ValueError, "outside"):
                compare(bytes(altered), original, edits)
        with self.assertRaises(ValueError):
            compare(original, original, edits)

    def test_overlapping_moved_and_wrong_original_allocations_fail(self):
        original = bytes(1024)
        for edits in (
            [(0x220, bytes(4), bytes(4)), (0x222, bytes(2), bytes(2))],
            [(0x100, bytes(2), bytes(2))],
            [(0x220, b"x", b"y")],
            [(0x220, bytes(4), bytes(2))],
        ):
            with self.subTest(edits=edits), self.assertRaises(ValueError):
                expected_image(original, edits)
