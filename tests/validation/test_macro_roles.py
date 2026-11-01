"""Catch omitted source-content categories independently of artifact naming."""

from pathlib import Path
import json
import tempfile
import unittest
from scripts.build.project import ROOT
from scripts.validation import macro_roles


class MacroRoleTests(unittest.TestCase):
    def setUp(self):
        parent = ROOT / "build/tests/validation/macro_roles"
        parent.mkdir(parents=True, exist_ok=True)
        self.directory = tempfile.TemporaryDirectory(dir=parent)
        self.addCleanup(self.directory.cleanup)
        self.root = Path(self.directory.name)
        (self.root / "src").mkdir()
        (self.root / "config/authoring").mkdir(parents=True)
        self.source = self.root / "src/data.s"
        self.source.write_text("newContent macro value\n dc.b value\n endm\nEntry: newContent 1\n")

    def ledger(self, rows):
        (self.root / "config/authoring/source_macro_roles.json").write_text(
            json.dumps({"review_status": "reviewed", "definitions": rows})
        )
        (self.root / "config/authoring/data_formats.json").write_text(json.dumps({"format_ids": ["synthetic"]}))

    def test_unregistered_emitter_cannot_hide_behind_existing_formats(self):
        self.ledger([])
        with self.assertRaisesRegex(ValueError, "incomplete"):
            macro_roles.audit(self.root)

    def test_review_binds_representation_and_explicit_format_owner(self):
        rows = macro_roles.inventory(self.root)
        rows[0].update(
            role="content_record",
            format_owner="synthetic",
            reason="Synthetic emitting grammar with an explicit source-owned format contract.",
        )
        self.ledger(rows)
        self.assertEqual(macro_roles.audit(self.root)["reviewed_emitting_macros"], 1)
        self.source.write_text(self.source.read_text().replace("dc.b", "dc.w"))
        with self.assertRaisesRegex(ValueError, "changed after review"):
            macro_roles.audit(self.root)

    def test_z80_byte_word_emitters_are_included(self):
        self.source.write_text("SoundData macro value\n db value\n dw value\n endm\n")
        self.assertEqual([row["macro"] for row in macro_roles.inventory(self.root)], ["SoundData"])
