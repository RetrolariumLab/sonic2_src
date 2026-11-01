"""Reject false readiness values and inspect tags without creating refs."""

import copy
import json
import unittest
from unittest.mock import patch
from scripts.build.project import ROOT, load
from scripts.validation import release_contract as contract


class ReleaseContractTests(unittest.TestCase):
    def setUp(self):
        self.manifest = copy.deepcopy(load("config/source_reconstruction_1_0.json"))
        self.manifest["status"] = "tag-ready"
        self.manifest["open_milestones"] = {}

    def validate(self, ready=True):
        def data(name, root=ROOT):
            return self.manifest if name == "config/source_reconstruction_1_0.json" else load(name, root)

        with patch.object(contract, "load", side_effect=data):
            return contract.validate(ready=ready)

    def test_ready_values_resolve_to_real_evidence(self):
        self.assertEqual(self.validate()["release_line"], "1.0")

    def test_nonstandard_requirement_status_fails_even_in_development(self):
        self.manifest["status"] = "development"
        self.manifest["requirements"]["semantic_symbols"]["status"] = "implemented"
        with self.assertRaisesRegex(ValueError, "identifier or status"):
            self.validate(ready=False)

    def test_partial_requirement_cannot_pass_a_ready_gate(self):
        row = self.manifest["requirements"]["semantic_symbols"]
        row.update(status="partial", reason="Synthetic pending semantic review")
        with self.assertRaisesRegex(ValueError, "remains open"):
            self.validate()

    def test_excluded_requirement_needs_a_reason(self):
        row = self.manifest["requirements"]["semantic_symbols"]
        row["status"] = "not_applicable"
        with self.assertRaisesRegex(ValueError, "needs a reason"):
            self.validate()

    def test_fake_evidence_file_and_command_are_rejected(self):
        evidence = self.manifest["requirements"]["semantic_symbols"]["evidence"]
        evidence["files"] = ["config/nonexistent-synthetic-evidence.json"]
        with self.assertRaisesRegex(ValueError, "Missing release evidence"):
            self.validate()
        evidence["files"] = []
        evidence["targets"] = ["nonexistent-synthetic-command"]
        with self.assertRaisesRegex(ValueError, "unavailable public target"):
            self.validate()

    def test_runtime_scenario_must_belong_to_its_profile(self):
        self.manifest["runtime_coverage"][0]["scenarios"] = self.manifest["runtime_coverage"][1]["scenarios"]
        with self.assertRaisesRegex(ValueError, "different profile"):
            self.validate()

    def test_an_artifact_cannot_claim_another_revision_identity(self):
        self.manifest["artifacts"][0]["identity_image"] = "rev01"
        with self.assertRaisesRegex(ValueError, "canonical profile owner"):
            self.validate()

    def test_missing_post_tag_command_is_rejected(self):
        self.manifest["aggregate_gates"].pop("post_tag")
        with self.assertRaisesRegex(ValueError, "post_tag"):
            self.validate()

    def inspect(self, object_type="tag", target="a" * 40, head="a" * 40, tagged=None):
        tag = self.manifest["tag"]

        def git(args, **kwargs):
            command = tuple(args[1:])
            values = {
                ("cat-file", "-t", "refs/tags/" + tag): object_type,
                ("rev-parse", "refs/tags/" + tag + "^{commit}"): target,
                ("rev-parse", "HEAD"): head,
                ("show", tag + ":config/source_reconstruction_1_0.json"): json.dumps(
                    self.manifest if tagged is None else tagged
                ),
            }
            return values[command]

        with (
            patch.object(contract, "validate", return_value=self.manifest),
            patch.object(contract.subprocess, "check_output", side_effect=git),
        ):
            return contract.inspect_tag()

    def test_matching_annotated_tag_is_inspected_without_writes(self):
        self.assertTrue(self.inspect()["annotated"])

    def test_lightweight_wrong_target_or_stale_manifest_fails(self):
        for kwargs, message in [
            ({"object_type": "commit"}, "annotated"),
            ({"target": "b" * 40}, "different candidate"),
            ({"tagged": {}}, "manifest differs"),
        ]:
            with self.subTest(kwargs=kwargs), self.assertRaisesRegex(ValueError, message):
                self.inspect(**kwargs)
