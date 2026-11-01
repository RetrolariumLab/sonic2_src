"""Verify transient cleanup locks and the boundary on owned temporary files."""

from pathlib import Path
import tempfile
import unittest
from unittest.mock import patch
from scripts.build.project import ROOT
from scripts.build.temporary import remove_owned, temporary_directory
import scripts.build.temporary as temporary


class TemporaryTests(unittest.TestCase):
    def setUp(self):
        self.parent = ROOT / "build/tests/authoring/temporary"
        self.parent.mkdir(parents=True, exist_ok=True)

    def test_one_transient_permission_lock_is_retried(self):
        original = temporary.shutil.rmtree
        attempts = []

        def remove(path):
            attempts.append(path)
            if len(attempts) == 1:
                raise PermissionError("transient scanner lock")
            return original(path)

        with patch.object(temporary.shutil, "rmtree", side_effect=remove), patch.object(temporary.time, "sleep"):
            with temporary_directory(self.parent) as directory:
                (directory / "output.bin").write_bytes(b"synthetic")
            self.assertFalse(directory.exists())
            self.assertEqual(len(attempts), 2)

    def test_windows_directory_not_empty_race_is_retried(self):
        original = temporary.shutil.rmtree
        attempts = []

        def remove(path):
            attempts.append(path)
            if len(attempts) == 1:
                error = OSError("directory changed during cleanup")
                error.winerror = 145
                raise error
            return original(path)

        with patch.object(temporary.shutil, "rmtree", side_effect=remove), patch.object(temporary.time, "sleep"):
            with temporary_directory(self.parent) as directory:
                (directory / "output.bin").write_bytes(b"synthetic")
            self.assertFalse(directory.exists())
            self.assertEqual(len(attempts), 2)

    def test_permanent_permission_failure_is_not_hidden(self):
        with tempfile.TemporaryDirectory(dir=self.parent) as name:
            directory = Path(name)
            with (
                patch.object(temporary.shutil, "rmtree", side_effect=PermissionError("locked")),
                patch.object(temporary.time, "sleep"),
            ):
                with self.assertRaises(PermissionError):
                    remove_owned(directory, self.parent)
                self.assertTrue(directory.exists())

    def test_cleanup_cannot_remove_the_parent_or_another_directory(self):
        with patch.object(temporary.shutil, "rmtree") as remove:
            for directory in (self.parent, self.parent.parent):
                with self.assertRaises(ValueError):
                    remove_owned(directory, self.parent)
            remove.assert_not_called()


if __name__ == "__main__":
    unittest.main()
