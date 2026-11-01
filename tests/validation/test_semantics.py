"""Reject missing, stale or invented symbol evidence without proprietary inputs."""

from pathlib import Path
import json
import tempfile
import unittest
from unittest.mock import patch
from scripts.build.project import ROOT
from scripts.validation import semantics


class SemanticsTests(unittest.TestCase):
    def test_suffix_coverage_does_not_misclassify_named_palette_fields(self):
        self.assertTrue(semantics.AUTO_LABEL.fullmatch("word_38A68.counter"))
        self.assertTrue(semantics.AUTO_LABEL.fullmatch("BranchTo_loc_1234"))
        self.assertFalse(semantics.AUTO_LABEL.fullmatch("Palette_fade_length"))

    def setUp(self):
        parent = ROOT / "build/tests/validation/semantics"
        parent.mkdir(parents=True, exist_ok=True)
        self.directory = tempfile.TemporaryDirectory(dir=parent)
        self.addCleanup(self.directory.cleanup)
        self.root = Path(self.directory.name)
        (self.root / "src").mkdir()
        (self.root / "config/reconstruction").mkdir(parents=True)
        (self.root / "src/main.s").write_text(
            "DrawCounter:\n                rts\nloc_20:\n                move.w d0,d1\nKnownEnd:\n                rts\n"
        )
        self.write("config/lint.json", {"assembly": {"paths": ["src"]}})
        self.write("config/revision_profiles.json", {"profiles": [{"id": "rev00", "output": "build/rev00/sonic2.bin"}]})
        inverse = {"DrawCounter": "sub_10"}
        d = semantics.definitions(self.root)

        def evidence(name):
            return [
                {
                    "source": "src/main.s",
                    "occurrence": 0,
                    "code_sha256": semantics.fingerprint(d[name][0]["body"], inverse),
                }
            ]

        self.registry = {
            "schema": "sonic2.label_renames",
            "schema_version": 1,
            "review_status": "reviewed",
            "renames": [
                {
                    "old": "sub_10",
                    "new": "DrawCounter",
                    "kind": "code",
                    "reason": "Synthetic reviewed counter renderer contract for evidence validation.",
                    "evidence": {"method": "reviewed_source_contract", "basis": "Synthetic fixture only"},
                    "definitions": evidence("DrawCounter"),
                    "profile_values": {"rev00": 16},
                }
            ],
        }
        self.unknowns = {
            "schema": "sonic2.unknown_symbols",
            "schema_version": 1,
            "review_status": "reviewed",
            "entries": [
                {
                    "symbol": "loc_20",
                    "status": "unknown",
                    "owner": "synthetic",
                    "known_role": "Internal branch target with a register copy.",
                    "unresolved": "Its complete entry state is not established.",
                    "reason": "One instruction cannot establish its larger purpose.",
                    "next_check": "Follow incoming edges and register state at this entry.",
                    "definitions": evidence("loc_20"),
                    "profile_values": {"rev00": 32},
                    "profile_ranges": {
                        "rev00": {
                            "address_space": "m68000-rom",
                            "start": 32,
                            "end_exclusive": 34,
                            "end_symbol": "KnownEnd",
                            "bound_reason": "Following declared symbol bounds this fixture.",
                        }
                    },
                }
            ],
        }

    def write(self, name, value):
        (self.root / name).write_text(json.dumps(value))

    def audit(self, compiled=False):
        self.write("config/reconstruction/label_renames.json", self.registry)
        self.write("config/reconstruction/unknown_symbols.json", self.unknowns)
        return semantics.audit(self.root, compiled)

    def test_complete_synthetic_evidence_passes_without_roms(self):
        self.assertEqual(self.audit()["explicit_unknowns"], 1)

    def test_unrecorded_address_label_fails_and_removes_stale_success(self):
        self.audit()
        self.unknowns["entries"] = []
        with self.assertRaisesRegex(ValueError, "exactly one"):
            self.audit()
        self.assertFalse((self.root / "build/semantic-symbols.json").exists())

    def test_new_source_instructions_invalidate_review(self):
        path = self.root / "src/main.s"
        path.write_text(path.read_text().replace("move.w d0,d1", "move.w d0,d2"))
        with self.assertRaisesRegex(ValueError, "Source changed"):
            self.audit()

    def test_missing_revision_evidence_fails(self):
        self.registry["renames"][0]["profile_values"] = {}
        with self.assertRaisesRegex(ValueError, "accepted profile"):
            self.audit()

    def test_forged_structural_meaning_is_rejected(self):
        row = self.registry["renames"][0]
        row["evidence"] = {"method": "counted_loop", "register": "d7", "basis": "Synthetic counter claim"}
        with self.assertRaisesRegex(ValueError, "counter edge"):
            self.audit()

    def test_unknown_requires_a_followup_check(self):
        self.unknowns["entries"][0]["next_check"] = ""
        with self.assertRaisesRegex(ValueError, "next_check"):
            self.audit()

    def test_unknown_range_cannot_run_backwards(self):
        self.unknowns["entries"][0]["profile_ranges"]["rev00"]["end_exclusive"] = 31
        with self.assertRaisesRegex(ValueError, "Invalid unknown range"):
            self.audit()

    def test_compiled_symbol_drift_is_rejected(self):
        with patch.object(semantics, "symbols", return_value={"DrawCounter": 18, "loc_20": 32, "KnownEnd": 34}):
            with self.assertRaisesRegex(ValueError, "moved or disappeared"):
                self.audit(compiled=True)

    def test_compiled_range_endpoint_drift_is_rejected(self):
        with patch.object(semantics, "symbols", return_value={"DrawCounter": 16, "loc_20": 32, "KnownEnd": 36}):
            with self.assertRaisesRegex(ValueError, "end marker changed"):
                self.audit(compiled=True)

    def test_a_confirmed_meaning_cannot_be_hidden_as_unknown(self):
        self.unknowns["entries"][0]["status"] = "confirmed"
        with self.assertRaisesRegex(ValueError, "must be named"):
            self.audit()

    def test_sign_extended_ram_values_keep_physical_bounds(self):
        row = self.unknowns["entries"][0]
        raw = (1 << 64) - 32
        row["profile_values"]["rev00"] = raw
        row["profile_ranges"]["rev00"].update(
            address_space="m68000-ram", symbol_mask=0xFFFFFF, start=0xFFFFE0, end_exclusive=0xFFFFE2
        )
        with patch.object(semantics, "symbols", return_value={"DrawCounter": 16, "loc_20": raw, "KnownEnd": raw + 2}):
            self.assertTrue(self.audit(compiled=True)["passed"])
        row["profile_ranges"]["rev00"].update(start=raw, end_exclusive=raw + 2)
        with self.assertRaisesRegex(ValueError, "physical 24-bit"):
            self.audit()
