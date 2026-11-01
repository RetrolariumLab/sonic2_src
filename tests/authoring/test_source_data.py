"""Check emitted input ownership and source-owned EOF data without game ROMs."""

from pathlib import Path
import json
import tempfile
import unittest
from scripts.validation.semantics import fingerprint
from scripts.build.project import ROOT
from scripts.build.listing_source import ListingIndex, SourceRow
from scripts.authoring.source_data import private_placements, animation_roundtrip, demo_roundtrip, tube_path_roundtrip


class SourceDataTests(unittest.TestCase):
    def setUp(self):
        parent = ROOT / "build/tests/authoring/source_data"
        parent.mkdir(parents=True, exist_ok=True)
        self.directory = tempfile.TemporaryDirectory(dir=parent)
        self.addCleanup(self.directory.cleanup)
        self.root = Path(self.directory.name)

    def write(self, name, value):
        path = self.root / name
        path.parent.mkdir(parents=True, exist_ok=True)
        path.write_bytes(value if isinstance(value, bytes) else value.encode())

    def config(self, name, value):
        self.write(name, json.dumps(value))

    def fixture(self):
        # The extraction offset deliberately differs from both emitted consumers.
        self.config(
            "assets/manifest.json",
            {
                "output": "data",
                "assets": [
                    {"path": "map.bin", "offset": 4, "size": 4},
                    {"path": "sound/driver.sax", "offset": 12, "size": 4},
                ],
            },
        )
        self.config(
            "config/audio.json",
            {
                "driver_data": {"asset": "sound/driver.sax"},
                "psg_envelopes": [{"path": "sound/psg/env.bin", "offset": 1, "size": 2}],
            },
        )
        self.config("config/reconstruction/relocation.json", {"audio_layout": {"driver": "Driver"}})
        self.write("data/map.bin", b"map!")
        self.write("data/sound/driver.sax", b"code")
        self.write("data/sound/psg/env.bin", b"ps")
        rom = bytearray(48)
        rom[20:24] = rom[24:28] = b"map!"
        rom[32:36] = b"code"
        lines = [
            "asset macro path",
            " rept 2",
            ' binclude "path"',
            " endm",
            " endm",
            ' binclude "data/map.bin"',
            ' binclude "data/sound/psg/env.bin"',
        ]
        rows = [
            SourceRow("owner.asm", 3, 0, ' binclude "path"'),
            SourceRow("owner.asm", 6, 20, ' binclude "data/map.bin"'),
            SourceRow("owner.asm", 6, 20, ' binclude "data/map.bin"'),
            SourceRow("owner.asm", 6, 24, ' binclude "data/map.bin"'),
            SourceRow("owner.asm", 7, 1, ' binclude "data/sound/psg/env.bin"'),
        ]
        return {
            "revision": "test",
            "rom": bytes(rom),
            "symbols": {"Driver": 32},
            "listing": ListingIndex({}, rows, {"owner.asm": lines}, {}),
        }

    def test_repeated_consumers_and_macro_templates_are_distinct(self):
        context = self.fixture()
        report = private_placements(context, self.root)
        self.assertEqual([item["start"] for item in report["placements"]["map.bin"]], [20, 24])
        self.assertEqual(len(report["macro_templates"]), 1)
        self.assertEqual(report["placements"]["sound/driver.sax"][0]["kind"], "assembled_code_reference")
        self.assertEqual(report["placements"]["sound/psg/env.bin"][0]["address_space"], "z80-driver-data")

    def test_missing_input_outside_macro_is_rejected(self):
        context = self.fixture()
        context["listing"].rows.append(SourceRow("owner.asm", 6, 0, ' binclude "missing.bin"'))
        with self.assertRaisesRegex(ValueError, "no private input owner"):
            private_placements(context, self.root)

    def test_existing_undeclared_file_is_not_a_template(self):
        context = self.fixture()
        self.write("path", b"undeclared")
        with self.assertRaisesRegex(ValueError, "no private input owner"):
            private_placements(context, self.root)

    def test_actual_consumer_bytes_must_match(self):
        context = self.fixture()
        context["rom"] = bytes(len(context["rom"]))
        with self.assertRaisesRegex(ValueError, "differs from its ROM consumer"):
            private_placements(context, self.root)

    def test_driver_source_is_checked_separately(self):
        context = self.fixture()
        context["symbols"]["Driver"] = 36
        with self.assertRaisesRegex(ValueError, "driver differs"):
            private_placements(context, self.root)

    def test_virtual_envelope_offset_cannot_move(self):
        context = self.fixture()
        context["listing"].rows[-1] = SourceRow("owner.asm", 7, 2, ' binclude "data/sound/psg/env.bin"')
        with self.assertRaisesRegex(ValueError, "driver ABI"):
            private_placements(context, self.root)

    def test_animation_can_end_at_its_module_eof(self):
        name = "src/animation.asm"
        lines = ["Ani_Test: offsetTable", " offsetTableEntry.w .a", ".a: dc.b 0,1,$FF"]
        context = {
            "revision": "test",
            "rom": bytes(16) + bytes([0, 2, 0, 1, 255]),
            "symbols": {"Ani_Test": 16},
            "listing": ListingIndex({(name, 1): 16, (name, 2): 16, (name, 3): 18}, [], {name: lines}, {name: {21}}),
        }
        record, model = animation_roundtrip(
            {"source": name, "root_symbol": "Ani_Test", "codec": "animation-object-s2"}, context
        )
        self.assertEqual(record["end_exclusive"], 21)
        self.assertEqual(model["scripts"][0]["events"][0]["value"], 1)
        self.assertTrue(record["zero_edit"])

    def test_demo_hold_256_and_exact_named_root(self):
        name = "src/demo.asm"
        context = {
            "revision": "test",
            "rom": bytes(16) + bytes([4, 255, 0, 0]),
            "symbols": {"Demo_Test": 16},
            "listing": ListingIndex(
                {(name, 2): 16, (name, 3): 18}, [], {name: ["Demo_Test:", " demoinput R,$100", " demoinput ,1"]}, {}
            ),
        }
        record = demo_roundtrip({"source": name, "root_symbol": "Demo_Test", "codec": "demo-input-s2"}, context)
        self.assertEqual(record["frames"], 257)
        context["symbols"]["Demo_Test"] = 18
        with self.assertRaisesRegex(ValueError, "first record"):
            demo_roundtrip({"source": name, "root_symbol": "Demo_Test", "codec": "demo-input-s2"}, context)

    def test_inline_tube_paths_stop_before_the_next_table_and_code(self):
        name = "src/tube.s"
        data = ["Paths: offsetTable", " offsetTableEntry.w Point", "Point: dc.w 4", " dc.w 16,32"]
        lines = ["Entry: rts", *data, "Other: offsetTable", " offsetTableEntry.w Elsewhere", "After: rts"]
        context = {
            "revision": "test",
            "rom": bytes(16) + bytes.fromhex("0002 0004 0010 0020") + bytes(8),
            "symbols": {"Paths": 16},
            "listing": ListingIndex({(name, 6): 24}, [], {name: lines}, {}),
        }
        artifact = {
            "source": name,
            "codec": "tube-path-s2",
            "root_symbol": "Paths",
            "source_region": {"first_line": 2, "last_line": 5, "code_sha256": fingerprint("\n".join(data), {})},
        }
        report = tube_path_roundtrip(artifact, context)
        self.assertEqual(report["references"], 1)
        self.assertEqual(report["end_exclusive"], 24)
        self.assertTrue(report["zero_edit"])


if __name__ == "__main__":
    unittest.main()
