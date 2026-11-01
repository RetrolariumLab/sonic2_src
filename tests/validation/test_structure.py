"""Reject stale or incomplete semantic source registries without private ROMs."""

from pathlib import Path
import hashlib
import json
import tempfile
import unittest
from scripts.build.project import ROOT
from scripts.validation.structure import audit, inventory, ledger


class StructureTests(unittest.TestCase):
    def setUp(self):
        parent = ROOT / "build/tests/validation/structure"
        parent.mkdir(parents=True, exist_ok=True)
        self.directory = tempfile.TemporaryDirectory(dir=parent)
        self.addCleanup(self.directory.cleanup)
        self.root = Path(self.directory.name)

    def write(self, name, value):
        path = self.root / name
        path.parent.mkdir(parents=True, exist_ok=True)
        path.write_text(value, newline="\n")

    def config(self, name, value):
        self.write(name, json.dumps(value))

    def fixture(self, body="Entry: rts\n"):
        self.write("src/main.s", body)
        sha = hashlib.sha256(body.encode()).hexdigest()
        lines = len(body.splitlines())
        row = {
            "path": "src/main.s",
            "owner": "entry",
            "responsibility": "Synthetic entry",
            "physical_lines": lines,
            "file_sha256": sha,
            "original_path": "old.asm",
            "original_first_line": 1,
            "original_last_line": lines,
            "source_sha256": sha,
            "size_exception": {"kind": "tiny_entry_point", "reason": "One complete synthetic entry"},
        }
        layout = {
            "schema": "sonic2.source_layout",
            "schema_version": 1,
            "entry": "src/main.s",
            "modules": [row],
            "include_graph": {"src/main.s": []},
            "baseline": {"commit": None},
            "original_sources": [{"path": "old.asm", "physical_lines": lines, "sha256": sha}],
        }
        self.config("config/reconstruction/source_layout.json", layout)
        self.config(
            "config/reconstruction/label_renames.json",
            {"schema": "sonic2.label_renames", "schema_version": 1, "renames": []},
        )
        self.config("config/revision_profiles.json", {"entry": "src/main.s", "profiles": []})
        self.config("config/audio.json", {"songs": [], "effects": [], "samples": []})
        self.config("config/authoring/data_formats.json", {"artifacts": [], "format_ids": []})
        self.config("config/authoring/source_macro_roles.json", {"review_status": "reviewed", "definitions": []})
        return layout

    def test_complete_synthetic_structure_runs_the_real_audit(self):
        self.fixture()
        self.assertTrue(audit(self.root)["every_source_reachable"])

    def test_stale_success_report_is_removed_on_failure(self):
        self.fixture()
        self.write("build/source-layout-check.json", '{"passed":true}')
        self.write("src/main.s", "Changed: rts\n")
        with self.assertRaisesRegex(ValueError, "stale size or bytes"):
            audit(self.root)
        self.assertFalse((self.root / "build/source-layout-check.json").exists())

    def test_undeclared_source_file_is_rejected(self):
        for suffix in (".s", ".inc", ".asm"):
            with self.subTest(suffix=suffix):
                self.fixture()
                self.write("src/orphan" + suffix, "Orphan: rts\n")
                with self.assertRaisesRegex(ValueError, "every assembly file"):
                    audit(self.root)
                (self.root / ("src/orphan" + suffix)).unlink()

    def test_include_cycle_is_rejected(self):
        layout = self.fixture(' include "src/main.s"\n')
        layout["include_graph"]["src/main.s"] = ["src/main.s"]
        self.config("config/reconstruction/source_layout.json", layout)
        with self.assertRaisesRegex(ValueError, "include cycle"):
            audit(self.root)

    def test_missing_original_range_is_rejected(self):
        layout = self.fixture()
        layout["modules"][0]["original_first_line"] = 2
        self.config("config/reconstruction/source_layout.json", layout)
        with self.assertRaisesRegex(ValueError, "source coordinates"):
            audit(self.root)

    def test_inventory_finds_a_byte_table_without_an_animation_name(self):
        for suffix in (".s", ".inc", ".asm"):
            with self.subTest(suffix=suffix):
                name = "src/data" + suffix
                self.write(name, "off_unusual: offsetTable\n offsetTableEntry.w First\nFirst: dc.b 3,0,$FF\n")
                self.assertEqual(inventory(self.root)["data_tables"], {(name, "off_unusual")})
                (self.root / name).unlink()

    def test_macro_definition_is_not_an_authored_demo_run(self):
        self.write("src/macros.asm", "demoinput macro buttons,time\n dc.b 0,0\n endm\n")
        self.assertEqual(inventory(self.root)["demo_runs"], set())

    def test_data_ledger_accepts_colonless_end_labels(self):
        text = "Root: mappingsTable\n mappingsTableEntry.w Frame\nFrame: spriteHeader\nFrame_End\n"
        self.assertEqual(ledger(text)["frame_pointers"], 1)
        with self.assertRaisesRegex(ValueError, "Non-data operation"):
            ledger(text + " rts\n")

    def test_data_ledger_rejects_a_reference_into_a_piece(self):
        text = "Root: mappingsTable\n mappingsTableEntry.w Piece\nFrame: spriteHeader\nPiece: spritePiece 0,0,1,1,0,0,0,0,0\n"
        with self.assertRaisesRegex(ValueError, "complete header"):
            ledger(text)


if __name__ == "__main__":
    unittest.main()
