"""Private data stays forbidden even after removal from the current tree."""

import hashlib
from pathlib import Path
import subprocess
import tempfile
import unittest
from scripts.build.project import ROOT
from scripts.validation.private_data import current_problems, history_problems, payload_problem


class PrivateDataTests(unittest.TestCase):
    def test_manifest_payload_cannot_be_disguised_as_source(self):
        data = b"synthetic private fixture"
        private = {hashlib.sha1(data).hexdigest()}
        self.assertIn("private", payload_problem(data, "src/example.asm", private, {}))

    def test_audio_content_is_rejected_when_expressed_as_source(self):
        for name in ["sound/music/synthetic.asm", "sound/sfx/synthetic.asm", "sound/_smps2asm_inc.asm"]:
            with self.subTest(path=name):
                self.assertIsNotNone(payload_problem(b"synthetic text", name, set(), {}))
        source = b"zPSG_Env1:\n    db 0,1,80h\n"
        for suffix in (".asm", ".s", ".inc"):
            with self.subTest(suffix=suffix):
                self.assertIn("inline PSG", payload_problem(source, "src/audio/driver" + suffix, set(), {}))
                self.assertIn(
                    "SMPS content",
                    payload_problem(b"Song:\n    smpsHeaderTempo 1,2\n", "src/renamed" + suffix, set(), {}),
                )

    def test_binary_allowlist_pins_bytes_and_size(self):
        data = b"\x00test compiler\xff"
        record = {"size": len(data), "sha256": hashlib.sha256(data).hexdigest()}
        allowed = {"tools/compiler": record}
        self.assertIsNone(payload_problem(data, "tools/compiler", set(), allowed))
        self.assertIsNotNone(payload_problem(data + b"x", "tools/compiler", set(), allowed))
        self.assertIsNotNone(payload_problem(data, "tools/other", set(), allowed))

    def test_ascii_payload_with_binary_extension_is_forbidden(self):
        self.assertIsNotNone(payload_problem(b"plain text", "data.bin", set(), {}))

    def test_deleted_payload_is_still_rejected_in_history(self):
        parent = ROOT / "build/tests"
        parent.mkdir(parents=True, exist_ok=True)
        with tempfile.TemporaryDirectory(dir=parent) as directory:
            root = Path(directory)

            def git(*args):
                return subprocess.check_output(["git", *args], cwd=root, stderr=subprocess.DEVNULL)

            git("init", "-b", "main")
            git("config", "user.name", "Synthetic Fixture")
            git("config", "user.email", "fixture@example.invalid")
            data = b"synthetic historical private payload"
            (root / "removed.txt").write_bytes(data)
            git("add", "removed.txt")
            git("commit", "-m", "Add synthetic fixture")
            (root / "removed.txt").unlink()
            git("add", "--all")
            git("commit", "-m", "Remove synthetic fixture")
            private = {hashlib.sha1(data).hexdigest()}
            self.assertEqual(current_problems(root, private, {}), [])
            self.assertEqual(len(history_problems(root, private, {})), 1)

    def test_project_tree_and_history(self):
        self.assertEqual(current_problems(), [])
        self.assertEqual(history_problems(), [])
