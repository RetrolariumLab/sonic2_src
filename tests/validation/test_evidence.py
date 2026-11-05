"""Reject cached successes when their source tree or actual artifacts change."""

from pathlib import Path
import tempfile
import unittest
from scripts.build.project import ROOT
from scripts.validation.evidence import output_hashes, public_hash, validate


class EvidenceTests(unittest.TestCase):
    def test_source_output_and_missing_evidence_invalidate_success(self):
        parent = ROOT / "build/tests/evidence"
        parent.mkdir(parents=True, exist_ok=True)
        with tempfile.TemporaryDirectory(dir=parent) as folder:
            root = Path(folder)
            (root / "src").mkdir()
            source = root / "src/main.s"
            source.write_text("Entry: rts\n")
            (root / "build").mkdir()
            output = root / "build/result.bin"
            output.write_bytes(b"actual output")
            report = {
                "passed": True,
                "public_sha256": public_hash(root),
                "evidence": output_hashes(["build/result.bin"], root),
            }
            validate(report, root)
            source.write_text("Entry: nop\n")
            with self.assertRaisesRegex(ValueError, "public tree"):
                validate(report, root)
            source.write_text("Entry: rts\n")
            output.write_bytes(b"substituted output")
            with self.assertRaisesRegex(ValueError, "changed"):
                validate(report, root)
            output.unlink()
            with self.assertRaises(ValueError):
                validate(report, root)
            with self.assertRaises(ValueError):
                output_hashes(["src/main.s"], root)
            with self.assertRaises(ValueError):
                output_hashes([], root)
