"""Validate PCM, DPCM, PSG envelopes and every FM voice register bit."""

import unittest
from scripts.authoring.audio_formats import AUDIO_FORMATS


class AudioTests(unittest.TestCase):
    def test_dpcm_exhaustive_codes_and_wrap(self):
        codec = AUDIO_FORMATS["dpcm-s2"]
        source = bytes(range(256))
        self.assertEqual(codec.encode(codec.decode(source)), source)
        self.assertEqual(codec.decode(b"\x48"), [136, 8])

    def test_dpcm_rejects_unrepresentable_pcm_and_partial_byte(self):
        codec = AUDIO_FORMATS["dpcm-s2"]
        with self.assertRaises(ValueError):
            codec.encode([131, 131])
        with self.assertRaises(ValueError):
            codec.encode([128])

    def test_psg_signed_offsets_hold_and_unused_tail(self):
        codec = AUDIO_FORMATS["psg-envelope-s2"]
        source = b"\x00\x01\xff\x80\x22"
        self.assertEqual(codec.decode(source), {"attenuation_offsets": [0, 1, -1], "trailer": [34]})
        self.assertEqual(codec.encode(codec.decode(source)), source)
        with self.assertRaises(ValueError):
            codec.decode(b"\x00\xff")
        with self.assertRaises(ValueError):
            codec.encode({"attenuation_offsets": [-128], "trailer": []})

    def test_voice_every_register_bit_is_preserved(self):
        codec = AUDIO_FORMATS["fm-voice-s2"]
        source = b"".join(bytes([value]) * 25 for value in range(256))
        self.assertEqual(codec.encode(codec.decode(source)), source)
        with self.assertRaises(ValueError):
            codec.decode(b"\0" * 24)
        voice = codec.decode(b"\0" * 25)
        voice[0]["algorithm"] = 8
        with self.assertRaises(ValueError):
            codec.encode(voice)

    def test_pcm_requires_unsigned_eight_bit_values(self):
        codec = AUDIO_FORMATS["pcm-u8"]
        self.assertEqual(codec.encode(codec.decode(bytes(range(256)))), bytes(range(256)))
        with self.assertRaises(ValueError):
            codec.encode([-1])
