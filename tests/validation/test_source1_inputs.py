"""Preserve edits while making the aggregate reproducible from original ROMs only."""

from pathlib import Path
import hashlib
import json
import tempfile
import unittest
from unittest.mock import patch
from scripts.build.project import ROOT
from scripts.validation.source1 import prepare_inputs


class PreservationInputTests(unittest.TestCase):
    def setUp(self):
        parent = ROOT / "build/tests/validation/source1_inputs"
        parent.mkdir(parents=True, exist_ok=True)
        self.directory = tempfile.TemporaryDirectory(dir=parent)
        self.addCleanup(self.directory.cleanup)
        self.root = Path(self.directory.name)
        for folder in ["assets", "config", "data/roms"]:
            (self.root / folder).mkdir(parents=True)
        rom = b"synthetic original ROM"
        self.payload = rom[3:9]
        (self.root / "data/roms/input.bin").write_bytes(rom)
        image = {
            "id": "rev00",
            "file": "data/roms/input.bin",
            "size": len(rom),
            "sha1": hashlib.sha1(rom).hexdigest(),
            "sha256": hashlib.sha256(rom).hexdigest(),
        }
        self.asset = {"path": "cut.bin", "size": len(self.payload), "sha1": hashlib.sha1(self.payload).hexdigest()}
        self.config("assets/manifest.json", {"output": "data", "images": [image], "assets": [self.asset]})
        self.config("config/revision_profiles.json", {"profiles": [{"id": "rev00", "image": "rev00"}]})
        self.config("config/audio.json", {"psg_envelopes": []})

    def config(self, name, value):
        (self.root / name).write_text(json.dumps(value))

    def test_rom_only_input_reaches_extraction_without_preexisting_assets(self):
        self.assertFalse((self.root / "data/cut.bin").exists())
        with patch("scripts.validation.source1.split") as extract:
            report = prepare_inputs(self.root)
        extract.assert_called_once_with(root=self.root)
        self.assertEqual(report["extraction"], "fresh from verified ROMs")
        self.assertEqual(report["direct_assets"], 1)

    def test_changed_direct_input_is_rejected_before_any_extraction_write(self):
        path = self.root / "data/cut.bin"
        path.write_bytes(b"edited")
        with patch("scripts.validation.source1.split") as extract:
            with self.assertRaisesRegex(ValueError, "Refusing to replace changed"):
                prepare_inputs(self.root)
        extract.assert_not_called()
        self.assertEqual(path.read_bytes(), b"edited")

    def test_changed_derived_envelope_is_rejected_before_any_write(self):
        (self.root / "data/cut.bin").write_bytes(self.payload)
        self.config(
            "config/audio.json",
            {"psg_envelopes": [{"path": "env.bin", "size": 2, "sha1": hashlib.sha1(b"ok").hexdigest()}]},
        )
        path = self.root / "data/env.bin"
        path.write_bytes(b"no")
        with patch("scripts.validation.source1.split") as extract:
            with self.assertRaisesRegex(ValueError, "env.bin"):
                prepare_inputs(self.root)
        extract.assert_not_called()
        self.assertEqual(path.read_bytes(), b"no")


if __name__ == "__main__":
    unittest.main()
