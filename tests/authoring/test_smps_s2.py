"""SMPS regressions for real Z80 pointer and event boundaries."""

import copy, unittest
from scripts.authoring.smps_s2 import decode, encode, encode_header

BASE = 0x9000


def header(pointer, voices=0, channels=(0x80,)):
    return {
        "voices": voices,
        "tempo_divider": 1,
        "tracks": [
            {"playback_control": 0x80, "channel": channel, "pointer": pointer + index, "transposition": -4, "volume": 6}
            for index, channel in enumerate(channels)
        ],
    }


def source(body, voices=0, channels=(0x80,)):
    head = header(BASE + 4 + 6 * len(channels), voices, channels)
    return encode_header(head, "sfx") + body


class SMPSTests(unittest.TestCase):
    def test_header_little_endian_and_voice_record(self):
        raw = source(b"\xef\x00\xb0\x04\xf2" + bytes(range(25)), BASE + 15, (2,))
        model, analysis = decode(raw, "sfx", BASE)
        self.assertEqual(model["header"]["tracks"][0]["transposition"], -4)
        self.assertEqual(raw[:2], b"\x0f\x90")
        self.assertEqual(analysis["voices"], 1)
        self.assertEqual(encode(model, "sfx", BASE, analysis["external"]), raw)

    def test_calls_returns_and_no_argument_prevent_attack(self):
        raw = source(b"\xf8\x11\x90\xd0\x02\xf2\xf2\xe7\x80\x03\xe3")
        model, analysis = decode(raw, "sfx", BASE)
        self.assertEqual([row["offset"] for row in model["events"]], [10, 13, 14, 15, 17, 18, 19, 20])
        self.assertEqual(model["unclaimed"], [{"offset": 16, "bytes": [0xF2]}])
        self.assertEqual(encode(model, "sfx", BASE), raw)

    def test_loop_target_is_bounded_without_unrolling(self):
        raw = source(b"\xf7\x00\x03\x0a\x90\xf2")
        model, analysis = decode(raw, "sfx", BASE)
        self.assertEqual(analysis["events"], 2)
        self.assertEqual(model["events"][0]["arguments"]["target"], BASE + 10)
        self.assertEqual(encode(model, "sfx", BASE), raw)

    def test_external_voice_contract_rejects_new_target(self):
        raw = source(b"\xef\0\xf2", 0x9500, (2,))
        model, analysis = decode(raw, "sfx", BASE)
        self.assertEqual(analysis["external"], [{"kind": "voice", "address": 0x9500, "size": 25}])
        self.assertEqual(encode(model, "sfx", BASE, analysis["external"]), raw)
        model["header"]["voices"] += 25
        with self.assertRaises(ValueError):
            encode(model, "sfx", BASE, analysis["external"])

    def test_truncated_and_unknown_commands_are_rejected(self):
        for body in [b"\xf0\x01\x02", b"\xfa"]:
            with self.subTest(body=body), self.assertRaises(ValueError):
                decode(source(body), "sfx", BASE)

    def test_track_cannot_enter_header(self):
        raw = encode_header(header(BASE + 2), "sfx") + b"\xf2"
        with self.assertRaises(ValueError):
            decode(raw, "sfx", BASE)

    def test_overlapping_views_cannot_receive_conflicting_edits(self):
        raw = source(b"\xe0\x80\xf2", channels=(0x80, 0xA0))
        model, _ = decode(raw, "sfx", BASE)
        self.assertEqual(encode(model, "sfx", BASE), raw)
        model["events"][0]["arguments"]["value"] = 0x81
        with self.assertRaises(ValueError):
            encode(model, "sfx", BASE)

    def test_every_fixed_layout_byte_requires_an_owner(self):
        raw = source(b"\xf2\0")
        model, _ = decode(raw, "sfx", BASE)
        model["unclaimed"] = []
        with self.assertRaises(ValueError):
            encode(model, "sfx", BASE)

    def test_unused_ed_really_consumes_one_following_byte(self):
        raw = source(b"\xed\x80\xf2")
        model, _ = decode(raw, "sfx", BASE)
        self.assertEqual(len(model["events"]), 2)
        self.assertEqual(model["events"][0]["arguments"], {"skipped_byte": 0x80})

    def test_music_psg_header_preserves_ignored_byte(self):
        head = {
            "voices": 0,
            "tempo_divider": 2,
            "tempo": 7,
            "fm_dac_tracks": [],
            "psg_tracks": [{"pointer": BASE + 12, "transposition": -1, "volume": 4, "unused": 0x7F, "tone": 3}],
        }
        raw = encode_header(head, "music") + b"\xf2"
        model, _ = decode(raw, "music", BASE)
        self.assertEqual(model["header"]["psg_tracks"][0]["unused"], 0x7F)
        self.assertEqual(encode(model, "music", BASE), raw)

    def test_call_recursion_cannot_overflow_track_workspace(self):
        raw = source(b"\xf8\x0a\x90\xf2")
        model, _ = decode(raw, "sfx", BASE)
        with self.assertRaises(ValueError):
            encode(model, "sfx", BASE)

    def test_loop_index_cannot_leave_track_workspace(self):
        raw = source(b"\xf7\x0a\x02\x0a\x90\xf2")
        model, _ = decode(raw, "sfx", BASE)
        with self.assertRaises(ValueError):
            encode(model, "sfx", BASE)

    def test_loop_lifetime_cannot_alias_deeper_call_stack(self):
        raw = source(b"\xf7\x08\x02\x0a\x90\xf8\x13\x90\xf2\xe3")
        model, _ = decode(raw, "sfx", BASE)
        with self.assertRaises(ValueError):
            encode(model, "sfx", BASE)

    def test_root_return_cannot_underflow_track_workspace(self):
        model, _ = decode(source(b"\xe3"), "sfx", BASE)
        with self.assertRaises(ValueError):
            encode(model, "sfx", BASE)


if __name__ == "__main__":
    unittest.main()
