"""Exercise source-derived DPLC bounds through the public frozen document API."""

from dataclasses import replace
from pathlib import Path
import json
import tempfile
import unittest
from scripts.build.project import ROOT
from scripts.authoring.source_data import mapping_document
from scripts.validation.semantics import fingerprint


class MappingDocumentTests(unittest.TestCase):
    def setUp(self):
        parent = ROOT / "build/tests/authoring/mapping_document"
        parent.mkdir(parents=True, exist_ok=True)
        self.directory = tempfile.TemporaryDirectory(dir=parent)
        self.addCleanup(self.directory.cleanup)
        self.root = Path(self.directory.name)
        for directory in ["src", "config", "assets", "data"]:
            (self.root / directory).mkdir()
        (self.root / "src/table.asm").write_text(
            "DPLC_Test: mappingsTable\n    mappingsTableEntry.w Frame\n"
            "Frame: dplcHeader\n    dplcEntry 2,0\nFrame_End\n"
        )
        (self.root / "config/revision_profiles.json").write_text(
            json.dumps({"profiles": [{"id": "rev00", "content_abi": "test-rev00"}]})
        )
        payload = bytes(range(128))
        (self.root / "data/art.bin").write_bytes(payload)
        (self.root / "assets/manifest.json").write_text(
            json.dumps({"output": "data", "assets": [{"path": "art.bin", "size": len(payload)}]})
        )
        rom = bytearray(256)
        rom[32:38] = bytes.fromhex("0002 0001 1000")
        rom[64:192] = payload
        self.context = {
            "revision": "rev00",
            "rom": bytes(rom),
            "symbols": {"DPLC_Test": 32, "Frame": 34, "Frame_End": 38, "Art": 64},
        }
        self.artifact = {
            "source": "src/table.asm",
            "codec": "dplc-s2",
            "root_symbol": "DPLC_Test",
            "transfer_contract": {
                "source_asset": "art.bin",
                "source_symbol": "Art",
                "destination_policy": "original_per_frame_transfer",
            },
        }

    def document(self):
        return mapping_document(self.artifact, self.context, {}, self.root)

    def test_zero_edit_and_valid_source_read_at_the_end(self):
        document, model, report = self.document()
        self.assertEqual(document.encode(model, document.target), bytes.fromhex("0002 0001 1000"))
        self.assertEqual(report["transfer_source_bytes"], 128)
        model["frames"][0][0]["source_tile"] = 2
        self.assertEqual(document.encode(model, document.target)[-2:], bytes.fromhex("1002"))

    def test_legal_width_source_read_outside_art_is_rejected(self):
        document, model, report = self.document()
        model["frames"][0][0]["source_tile"] = 3
        with self.assertRaisesRegex(ValueError, "source art allocation"):
            document.encode(model, document.target)

    def test_edit_cannot_expand_original_per_frame_transfer(self):
        document, model, report = self.document()
        model["frames"][0][0]["tiles"] = 3
        with self.assertRaisesRegex(ValueError, "destination pattern allocation"):
            document.encode(model, document.target)

    def test_other_profile_or_widened_slot_is_rejected(self):
        document, model, report = self.document()
        with self.assertRaisesRegex(ValueError, "abi"):
            document.encode(model, replace(document.target, abi="test-rev01"))
        with self.assertRaisesRegex(ValueError, "widens"):
            document.encode(model, replace(document.target, encoded_capacity=128))

    def test_inline_mapping_excludes_code_and_the_following_ledger(self):
        path = self.root / "src/table.asm"
        table = path.read_text()
        path.write_text(
            "Entry: rts\n"
            + table
            + "Other: mappingsTable\n mappingsTableEntry.w OtherFrame\nOtherFrame: spriteHeader\nOtherFrame_End\n",
            newline="\n",
        )
        self.artifact["source_region"] = {
            "first_line": 2,
            "last_line": 6,
            "initial_scope": None,
            "code_sha256": fingerprint(table, {}),
        }
        document, model, report = self.document()
        self.assertEqual(document.encode(model, document.target), bytes.fromhex("0002 0001 1000"))
        self.assertEqual(report["end_exclusive"], 38)
        path.write_text(path.read_text().replace("dplcEntry 2,0", "dplcEntry 3,0"), newline="\n")
        with self.assertRaisesRegex(ValueError, "changed after review"):
            self.document()

    def test_inline_mapping_rejects_out_of_file_or_boolean_bounds(self):
        for first, last in [(0, 5), (1, 99), (True, 5), (4, 2)]:
            with self.subTest(first=first, last=last):
                self.artifact["source_region"] = {"first_line": first, "last_line": last, "code_sha256": "0" * 64}
                with self.assertRaisesRegex(ValueError, "invalid bounds"):
                    self.document()


if __name__ == "__main__":
    unittest.main()
