"""Ensure the upper gate cannot skip or reuse a failed preservation predecessor."""

from pathlib import Path
import json
import tempfile
import unittest
from unittest.mock import patch
from scripts.build.project import ROOT
from scripts.validation import source2


class Source2Tests(unittest.TestCase):
    def setUp(self):
        parent = ROOT / "build/tests/validation/source2"
        parent.mkdir(parents=True, exist_ok=True)
        self.directory = tempfile.TemporaryDirectory(dir=parent)
        self.addCleanup(self.directory.cleanup)
        self.root = Path(self.directory.name)
        (self.root / "build").mkdir()
        self.output = self.root / "build/source-2-check.json"
        self.output.write_text('{"passed": true}')

    def test_failed_predecessor_stops_the_gate_and_removes_stale_success(self):
        with patch("scripts.validation.source1.run", side_effect=ValueError("predecessor failed")) as predecessor:
            with patch.object(source2.structure, "audit") as layout:
                with self.assertRaisesRegex(ValueError, "predecessor failed"):
                    source2.run(self.root)
                predecessor.assert_called_once_with(self.root)
                layout.assert_not_called()
        self.assertFalse(self.output.exists())

    def test_returned_failure_is_not_a_passing_predecessor(self):
        with patch("scripts.validation.source1.run", return_value={"gate": "source-1-check", "passed": False}):
            with self.assertRaisesRegex(ValueError, "did not pass"):
                source2.run(self.root)
        self.assertFalse(self.output.exists())

    def test_identity_matrix_cannot_omit_an_accepted_revision(self):
        (self.root / "config").mkdir()
        (self.root / "config/revision_profiles.json").write_text(json.dumps({"profiles": [{"id": "rev00"}]}))
        with self.assertRaisesRegex(ValueError, "identity matrix"):
            source2.preservation_matrix(
                {"gate": "source-1-check", "passed": True, "identities": [], "runtime": []}, self.root
            )

    def test_runtime_matrix_cannot_omit_an_accepted_revision(self):
        (self.root / "config").mkdir()
        (self.root / "config/revision_profiles.json").write_text(json.dumps({"profiles": [{"id": "rev00"}]}))
        with self.assertRaisesRegex(ValueError, "runtime matrix"):
            source2.preservation_matrix(
                {"gate": "source-1-check", "passed": True, "identities": [{"profile": "rev00"}], "runtime": []},
                self.root,
            )

    def test_identity_row_must_record_a_successful_byte_comparison(self):
        (self.root / "config").mkdir()
        (self.root / "config/revision_profiles.json").write_text(json.dumps({"profiles": [{"id": "rev00"}]}))
        with self.assertRaisesRegex(ValueError, "failed byte comparison"):
            source2.preservation_matrix(
                {
                    "gate": "source-1-check",
                    "passed": True,
                    "identities": [{"profile": "rev00", "byte_identical": False}],
                    "runtime": [{"profile": "rev00"}],
                },
                self.root,
            )


if __name__ == "__main__":
    unittest.main()
