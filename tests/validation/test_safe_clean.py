"""Keep clean bounded to build outputs and preserve ROMs and private workspaces."""

from pathlib import Path
import json
import tempfile
import unittest
from scripts.build.project import ROOT
from scripts.validation.source1 import clean_profile_outputs


class SafeCleanTests(unittest.TestCase):
    def setUp(self):
        parent = ROOT / "build/tests/validation/clean"
        parent.mkdir(parents=True, exist_ok=True)
        self.directory = tempfile.TemporaryDirectory(dir=parent)
        self.addCleanup(self.directory.cleanup)
        self.root = Path(self.directory.name)
        (self.root / "config").mkdir()
        self.config("build/rev00/sonic2.bin")

    def config(self, output):
        (self.root / "config/revision_profiles.json").write_text(
            json.dumps({"profiles": [{"id": "rev00", "output": output}]})
        )

    def test_preserves_inputs_and_other_build_workspaces(self):
        for name in [
            "data/private.bin",
            "build/roms/original.bin",
            "build/worktree/keep.txt",
            "build/rev00/output.bin",
            "build/relocated/rev00/output.bin",
        ]:
            path = self.root / name
            path.parent.mkdir(parents=True, exist_ok=True)
            path.write_bytes(b"synthetic")
        clean_profile_outputs(self.root)
        for name in ["data/private.bin", "build/roms/original.bin", "build/worktree/keep.txt"]:
            self.assertEqual((self.root / name).read_bytes(), b"synthetic")
        self.assertFalse((self.root / "build/rev00").exists())
        self.assertFalse((self.root / "build/relocated/rev00").exists())

    def test_refuses_manifest_redirect_to_a_workspace_or_outside_build(self):
        for output in ["build/worktree/sonic2.bin", "../outside/sonic2.bin", "data/sonic2.bin"]:
            self.config(output)
            with self.assertRaisesRegex(ValueError, "owned profile"):
                clean_profile_outputs(self.root)
