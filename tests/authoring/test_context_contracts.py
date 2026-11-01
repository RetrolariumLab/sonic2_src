"""Exercise target ABI, live RAM and context-dependent track safety checks."""

from dataclasses import replace
from pathlib import Path
import json
import tempfile
import unittest
from scripts.build.project import ROOT
from scripts.authoring.asset_document import Document
from scripts.authoring.catalog import codec
from scripts.authoring.contexts import target_for
from scripts.authoring.struct_formats import FORMATS


class ContextContractTests(unittest.TestCase):
    def fixture(self):
        parent = ROOT / "build/tests/authoring/contexts"
        parent.mkdir(parents=True, exist_ok=True)
        directory = tempfile.TemporaryDirectory(dir=parent)
        self.addCleanup(directory.cleanup)
        root = Path(directory.name)
        (root / "config").mkdir()
        (root / "config/audio.json").write_text(
            json.dumps({"driver_data": {"decoded_size": 4872}, "music_buffer_capacity": 1984})
        )
        (root / "config/revision_profiles.json").write_text(
            json.dumps({"profiles": [{"id": "rev00", "content_abi": "s2-retail-rev00-content-v1"}]})
        )
        context = {
            "revision": "rev00",
            "rom": bytes(0x10000),
            "symbols": {"Block_Table": 0xFF9000, "Block_Table_End": 0xFFA800, "z80_bank_size": 0x8000},
        }
        return root, context

    def test_chunk_block_number_is_limited_by_live_ram(self):
        model = FORMATS["chunks-128x128"].decode(bytes(128))
        model[0][0]["index"] = 768
        self.assertEqual(len(FORMATS["chunks-128x128"].encode(model)), 128)
        with self.assertRaisesRegex(ValueError, "live block RAM"):
            codec("mappings/128x128/ARZ.kos", {"block_capacity": 768}).encode(model)

    def test_track_index_must_exist_in_the_engine_lut(self):
        model = {
            "tags": [0, 0, 0],
            "rows": [[{"kind": "run", "wide": False, "index": 0}] for _ in range(28)],
            "tails": {"selectors": [], "literals": [], "runs": []},
            "trailer": [],
        }
        handler = codec(
            "mappings/special stage/frame.bin",
            {"track_lut": {"literal_lut": [0], "run_lut": [(0, 127)], "literal_split": 64, "run_split": 64}},
        )
        self.assertTrue(handler.encode(model))
        model["rows"][0][0]["index"] = 1
        with self.assertRaisesRegex(ValueError, "original engine LUT"):
            handler.encode(model)

    def test_arz_tail_is_preserved_but_not_live_block_capacity(self):
        root, context = self.fixture()
        plain = bytes(6144) + bytes([0, 0x40]) * 128
        artifact = {"path": "mappings/16x16/ARZ.kos", "codec": "blocks-16x16", "compression": "kosinski"}
        target = target_for(artifact, {"address_space": "m68000-rom", "start": 0x200}, plain, plain, context, root)
        self.assertEqual(target.protected_ranges, ((6144, 6400),))
        handler = FORMATS["blocks-16x16"]
        document, model = Document.open(plain, target, handler=handler)
        model[-1][0]["index"] = 1
        with self.assertRaisesRegex(ValueError, "protected retail tail"):
            document.encode(model, target)

    def test_a_different_revision_abi_is_rejected_before_output(self):
        root, context = self.fixture()
        plain = bytes(32)
        artifact = {"path": "art/uncompressed/example.bin", "codec": "tiles-4bpp", "compression": "none"}
        target = target_for(artifact, {"address_space": "m68000-rom", "start": 0x200}, plain, plain, context, root)
        document, model = Document.open(plain, target)
        with self.assertRaisesRegex(ValueError, "differs in abi"):
            document.encode(model, replace(target, abi="s2-retail-rev01-content-v1"))

    def test_driver_reference_cannot_be_edited_as_content(self):
        root, context = self.fixture()
        plain = bytes([0, 1, 2, 3])
        artifact = {"path": "sound/driver.sax", "codec": "driver-program", "compression": "saxman-driver-trailer"}
        target = target_for(artifact, {"address_space": "m68000-rom", "start": 0x200}, plain, plain, context, root)
        document, model = Document.open(plain, target, handler=codec(artifact["path"]))
        model[0] = 1
        with self.assertRaisesRegex(ValueError, "protected retail tail"):
            document.encode(model, target)


if __name__ == "__main__":
    unittest.main()
