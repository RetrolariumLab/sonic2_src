"""Exercise the actual release-audit CLI and Git history in disposable fixtures."""

from pathlib import Path
import hashlib
import json
import os
import shutil
import subprocess
import sys
import tempfile
import unittest
from scripts.build.project import ROOT
from scripts.validation.release_audit import OWNER


class ReleaseCommandTests(unittest.TestCase):
    def setUp(self):
        parent = ROOT / "build/tests/validation/release_command"
        parent.mkdir(parents=True, exist_ok=True)
        self.directory = tempfile.TemporaryDirectory(dir=parent)
        self.addCleanup(self.directory.cleanup)
        self.root = Path(self.directory.name)
        self.environment = dict(os.environ, PYTHONDONTWRITEBYTECODE="1")
        for name in [
            "scripts/__init__.py",
            "scripts/run.py",
            "scripts/build/__init__.py",
            "scripts/build/project.py",
            "scripts/validation/__init__.py",
            "scripts/validation/release_audit.py",
            "scripts/validation/private_data.py",
            "scripts/validation/asm_style.py",
        ]:
            target = self.root / name
            target.parent.mkdir(parents=True, exist_ok=True)
            shutil.copy2(ROOT / name, target)
        self.write(".gitignore", "build/\n__pycache__/\n")
        self.write("src/main.asm", "Synthetic: rts\n")
        self.config("config/lint.json", {"assembly": {"paths": ["src"]}})
        self.config("config/binary_allowlist.json", {"files": []})
        self.config("config/audio.json", {"psg_envelopes": []})
        self.config("assets/manifest.json", {"assets": [], "images": []})
        self.config("config/revision_profiles.json", {"profiles": []})
        self.config(
            "config/source_reconstruction_1_0.json",
            {
                "release_line": "1.0",
                "release_kind": "preservation",
                "status": "development",
                "profiles": [],
                "required_documents": [],
                "tag": "source-reconstruction-1.0",
            },
        )
        self.git("init", "--object-format=sha1", "-b", "main")
        self.git("config", "user.name", OWNER[0])
        self.git("config", "user.email", OWNER[1])
        self.git("config", "core.hooksPath", "build/no-hooks")
        self.commit("Add synthetic release audit fixture")

    def write(self, name, body):
        path = self.root / name
        path.parent.mkdir(parents=True, exist_ok=True)
        path.write_text(body, newline="\n")

    def config(self, name, value):
        self.write(name, json.dumps(value))

    def git(self, *args):
        return subprocess.check_output(
            ["git", *args], cwd=self.root, env=self.environment, stderr=subprocess.STDOUT, text=True
        )

    def commit(self, title, empty=False):
        self.git("add", "--all")
        message = (
            title
            + "\n\nExercise real repository checks using synthetic data.\n\nCo-Authored-By: Codex <noreply@openai.com>"
        )
        self.git("commit", *(["--allow-empty"] if empty else []), "-m", message)

    def command(self):
        return subprocess.run(
            [sys.executable, "scripts/run.py", "validation.release_audit", "--clean"],
            cwd=self.root,
            env=self.environment,
            text=True,
            stdout=subprocess.PIPE,
            stderr=subprocess.STDOUT,
            timeout=30,
        )

    def test_real_public_audit_accepts_a_valid_synthetic_history(self):
        result = self.command()
        self.assertEqual(result.returncode, 0, result.stdout)
        self.assertIn("Release ownership, privacy, documents and history audit", result.stdout)
        report = json.loads((self.root / "build/release-audit.json").read_text())
        self.assertEqual(report["problems"], [])
        self.assertEqual(report["reachable_commits"], 1)

    def test_empty_commit_is_rejected_by_the_public_command(self):
        self.commit("Add synthetic empty history entry", empty=True)
        result = self.command()
        self.assertNotEqual(result.returncode, 0, result.stdout)
        self.assertIn("empty commit", result.stdout)

    def merge_fixture(self, *, shared=False, main_extra=True):
        self.git("checkout", "-b", "topic")
        self.write("topic.txt", "synthetic topic change\n")
        self.commit("Add synthetic topic content")
        self.git("checkout", "main")
        if shared:
            self.write("topic.txt", "synthetic topic change\n")
        if main_extra:
            self.write("main.txt", "synthetic main change\n")
        self.commit("Add synthetic main content")
        # Git's automatic merge message intentionally has no authored trailer.
        self.git("merge", "--no-ff", "--no-edit", "topic")
        return [self.git("rev-parse", value).strip() for value in ["HEAD^{tree}", "HEAD^1^{tree}", "HEAD^2^{tree}"]]

    def test_meaningful_merge_with_standard_message_is_accepted(self):
        merged, first, second = self.merge_fixture()
        self.assertNotEqual(merged, first)
        self.assertNotEqual(merged, second)
        result = self.command()
        self.assertEqual(result.returncode, 0, result.stdout)

    def test_merge_equal_to_only_one_parent_is_accepted(self):
        merged, first, second = self.merge_fixture(shared=True)
        self.assertEqual(merged, first)
        self.assertNotEqual(merged, second)
        result = self.command()
        self.assertEqual(result.returncode, 0, result.stdout)

    def test_merge_equal_to_all_parents_is_rejected(self):
        merged, first, second = self.merge_fixture(shared=True, main_extra=False)
        self.assertEqual(merged, first)
        self.assertEqual(merged, second)
        result = self.command()
        self.assertNotEqual(result.returncode, 0, result.stdout)
        self.assertIn("empty commit", result.stdout)

    def test_deleted_private_payload_is_rejected_by_the_public_command(self):
        payload = "synthetic historical private payload"
        self.write("removed.txt", payload)
        self.commit("Add synthetic private history payload")
        (self.root / "removed.txt").unlink()
        self.config(
            "assets/manifest.json",
            {
                "assets": [
                    {"path": "private.bin", "size": len(payload), "sha1": hashlib.sha1(payload.encode()).hexdigest()}
                ],
                "images": [],
            },
        )
        self.commit("Remove synthetic payload from the working tree")
        result = self.command()
        self.assertNotEqual(result.returncode, 0, result.stdout)
        self.assertIn("matches a private manifest payload", result.stdout)

    def test_pre_audit_failure_cannot_leave_a_stale_success(self):
        self.assertEqual(self.command().returncode, 0)
        self.write("config/source_reconstruction_1_0.json", "invalid json")
        result = self.command()
        self.assertNotEqual(result.returncode, 0)
        self.assertFalse((self.root / "build/release-audit.json").exists())


if __name__ == "__main__":
    unittest.main()
