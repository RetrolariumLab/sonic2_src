"""Emulator cleanup must never select another project's process."""

import io
from pathlib import Path
import subprocess
import tempfile
import unittest
from unittest.mock import Mock, patch
from scripts.build.project import ROOT
from scripts.runtime.movies import invoke, stop_owned
from scripts.validation.source1 import clean_profile_outputs


class RuntimeSafetyTests(unittest.TestCase):
    def test_cleanup_filters_the_exact_staged_executable_path(self):
        own = ROOT / "build/runtime/mame/consoles.exe"
        foreign = ROOT / "build/foreign/consoles.exe"
        processes = [{"ProcessId": 123, "ExecutablePath": str(own)}, {"ProcessId": 456, "ExecutablePath": str(foreign)}]
        with (
            patch("scripts.runtime.movies.active_emulators", return_value=processes),
            patch("scripts.runtime.movies.subprocess.run") as run,
        ):
            stop_owned(own)
        self.assertEqual(run.call_count, 1)
        self.assertIn("-Id 123 ", run.call_args.args[0][-1])
        self.assertNotIn("456", run.call_args.args[0][-1])

    def test_timeout_cleans_the_invocation_and_reaps_the_launcher(self):
        parent = ROOT / "build/tests"
        parent.mkdir(parents=True, exist_ok=True)
        with tempfile.TemporaryDirectory(dir=parent) as directory:
            root = Path(directory)
            process = Mock()
            process.communicate.side_effect = [subprocess.TimeoutExpired("synthetic", 1), (b"partial output", None)]
            config = {"limits": {"timeout_seconds": 1}}
            executable = root / "build/runtime/mame/consoles.exe"
            with (
                patch("scripts.runtime.movies.wait_for_machine"),
                patch("scripts.runtime.movies.subprocess.Popen", return_value=process),
                patch("scripts.runtime.movies.terminate_invocation") as terminate,
                patch("scripts.runtime.movies.owned_emulators", return_value=[]),
                patch("sys.stdout", new=io.StringIO()),
            ):
                with self.assertRaisesRegex(ValueError, "timed out"):
                    invoke("check", root / "check.json", root / "image.bin", executable, config, root / "run.log", root)
            terminate.assert_called_once_with(process, executable)
            self.assertEqual(process.communicate.call_count, 2)
            self.assertEqual((root / "run.log").read_bytes(), b"partial output")

    def test_clean_gate_rejects_a_configured_path_outside_build(self):
        parent = ROOT / "build/tests"
        parent.mkdir(parents=True, exist_ok=True)
        with tempfile.TemporaryDirectory(dir=parent) as directory:
            root = Path(directory)
            keep = root / "keep"
            keep.mkdir()
            (keep / "sentinel").write_text("untouched")
            with patch(
                "scripts.validation.source1.profiles",
                return_value={"profiles": [{"id": "synthetic", "output": "keep/image.bin"}]},
            ):
                with self.assertRaises(ValueError):
                    clean_profile_outputs(root)
            self.assertEqual((keep / "sentinel").read_text(), "untouched")
