"""Authentic bytes, bounded decoding, and ring-buffer regressions."""
import random
import unittest
from scripts.authoring.saxman import decode, encode


class SaxmanTests(unittest.TestCase):
    def test_original_encoder_vectors(self):
        # Generated with upstream saxman -a from synthetic data, never game data.
        vectors = [
            (b"", "0000"),
            (b"abc", "040007616263"),
            (bytes(18), "030000dcff"),
            (b"ABCD" * 12, "0b000f41424344eeff000f0a05"),
            (bytes(range(32)), "2400ff0001020304050607ff08090a0b0c0d0e0fff1011121314151617ff18191a1b1c1d1e1f"),
        ]
        for source, expected in vectors:
            with self.subTest(size=len(source)):
                self.assertEqual(encode(source), bytes.fromhex(expected))
                self.assertEqual(decode(bytes.fromhex(expected)), source)

    def test_window_wrap_and_overlapping_matches(self):
        rng = random.Random(212313)
        for size in [1, 2, 3, 17, 18, 19, 255, 4095, 4096, 4097, 9000]:
            for source in [bytes(size), bytes(rng.randrange(16) for _ in range(size)), (b"SYNTHETIC" * (size // 9 + 1))[:size]]:
                with self.subTest(size=size, prefix=source[:6]):
                    self.assertEqual(decode(encode(source)), source)

    def test_repeated_calls_do_not_reuse_the_previous_window(self):
        expected = encode(bytes(64))
        encode(bytes(range(256)) * 32)
        self.assertEqual(encode(bytes(64)), expected)

    def test_raw_stream(self):
        source = b"AAAABBBB" * 12
        self.assertEqual(decode(encode(source, with_size=False), with_size=False), source)

    def test_rejects_truncated_tokens_and_size_mismatch(self):
        for value in [b"", b"\x01", b"\x02\x00\x00", b"\x02\x00\x00\x01", b"\x01\x00\x00"]:
            with self.subTest(value=value), self.assertRaises(ValueError):
                decode(value)

    def test_rejects_expansion_beyond_capacity(self):
        with self.assertRaisesRegex(ValueError, "capacity"):
            decode(encode(bytes(100)), max_output=99)
