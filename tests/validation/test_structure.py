"""Reject stale or incomplete semantic source registries without private ROMs."""

from pathlib import Path
import hashlib
import json
import tempfile
import unittest
from unittest.mock import patch
from scripts.build.project import ROOT
from scripts.validation.structure import audit, inventory, ledger, check_size


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

    def composite(self):
        layout = self.fixture()
        row = layout["modules"][0]
        keys = ("original_path", "original_first_line", "original_last_line", "source_sha256")
        segment = {key: row.pop(key) for key in keys}
        data = "Data: dc.b 0\n"
        data_sha = hashlib.sha256(data.encode()).hexdigest()
        row["original_segments"] = [
            segment,
            {"original_path": "data.asm", "original_first_line": 1, "original_last_line": 1, "source_sha256": data_sha},
        ]
        body = "Entry: rts\n" + data
        self.write("src/main.s", body)
        row.update(physical_lines=2, file_sha256=hashlib.sha256(body.encode()).hexdigest())
        layout["schema_version"] = 2
        layout["original_sources"].append({"path": "data.asm", "physical_lines": 1, "sha256": data_sha})
        self.config("config/reconstruction/source_layout.json", layout)
        return layout

    def test_composite_keeps_both_original_sources_checked(self):
        layout = self.composite()
        layout["baseline"]["commit"] = "a" * 40
        self.config("config/reconstruction/source_layout.json", layout)
        originals = {"old.asm": b"Entry: rts\n", "data.asm": b"Data: dc.b 0\n"}
        with patch(
            "scripts.validation.structure.subprocess.check_output",
            side_effect=lambda args, cwd: originals[args[-1].split(":", 1)[1]],
        ):
            self.assertTrue(audit(self.root, baseline=True)["baseline_checked"])

    def test_composite_cannot_hide_duplicate_or_missing_original_ranges(self):
        for mode in ("duplicate", "missing", "ambiguous", "fingerprint"):
            with self.subTest(mode=mode):
                layout = self.composite()
                row = layout["modules"][0]
                if mode == "duplicate":
                    row["original_segments"].append(dict(row["original_segments"][0]))
                elif mode == "missing":
                    row["original_segments"].pop()
                elif mode == "ambiguous":
                    row["original_path"] = "old.asm"
                else:
                    row["original_segments"][0]["source_sha256"] = "bad"
                self.config("config/reconstruction/source_layout.json", layout)
                with self.assertRaises(ValueError):
                    audit(self.root)

    def test_composite_checks_each_segment_against_the_accepted_baseline(self):
        layout = self.composite()
        layout["baseline"]["commit"] = "a" * 40
        layout["modules"][0]["original_segments"][1]["source_sha256"] = "0" * 64
        self.config("config/reconstruction/source_layout.json", layout)
        originals = {"old.asm": b"Entry: rts\n", "data.asm": b"Data: dc.b 0\n"}
        with patch(
            "scripts.validation.structure.subprocess.check_output",
            side_effect=lambda args, cwd: originals[args[-1].split(":", 1)[1]],
        ):
            with self.assertRaisesRegex(ValueError, "Original source slice differs"):
                audit(self.root, baseline=True)

    def test_object_size_exception_is_bound_to_its_root_and_maximum(self):
        layout = self.composite()
        row = layout["modules"][0]
        body = "Entry: rts\n" + "; preserved object lines\n" * 900
        row.update(
            label="Entry",
            size_exception={
                "kind": "cohesive_object_module",
                "reason": "One reviewed complete object with its in-place data ledgers.",
                "root_symbol": "Entry",
                "max_lines": 901,
            },
        )
        self.assertTrue(check_size(row, body))
        with self.assertRaisesRegex(ValueError, "reviewed bound or root"):
            check_size(row, body + "; new line\n")
        row["size_exception"]["root_symbol"] = "Other"
        with self.assertRaisesRegex(ValueError, "reviewed bound or root"):
            check_size(row, body)
        row.pop("size_exception")
        with self.assertRaisesRegex(ValueError, "justified size exception"):
            check_size(row, body)

    def test_local_mapping_table_keeps_its_qualified_root(self):
        self.write("src/main.s", 'Root: include "src/data.s"\n')
        self.write("src/data.s", ".offsets: mappingsTable\n mappingsTableEntry.w .frame\n.frame: spriteHeader\n")
        self.assertIn(("src/data.s", "Root.offsets"), inventory(self.root)["mapping_tables"])


if __name__ == "__main__":
    unittest.main()
