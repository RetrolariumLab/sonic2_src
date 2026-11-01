"""The ignored AS cache never replaces dependency identity verification."""

import hashlib
from pathlib import Path
import tempfile
import unittest
from unittest.mock import patch
from scripts.build.external_as import assembler, cached_file
from scripts.build.project import ROOT, load
from scripts.validation.private_data import payload_problem


class ExternalAssemblerTests(unittest.TestCase):
    def setUp(self):
        self.temporary = tempfile.TemporaryDirectory()
        self.addCleanup(self.temporary.cleanup)
        self.root = Path(self.temporary.name)
        self.data = b"synthetic dependency"
        self.record = {
            "path": "build/tools/as-313/synthetic/tool",
            "url": "https://raw.githubusercontent.com/example/project/pinned/tool",
            "size": len(self.data),
            "sha256": hashlib.sha256(self.data).hexdigest(),
        }

    def test_cached_dependency_is_verified_on_every_use(self):
        target = self.root / self.record["path"]
        target.parent.mkdir(parents=True)
        target.write_bytes(self.data)
        with patch("scripts.build.external_as.urlopen") as download:
            self.assertEqual(cached_file(self.record, self.root), target)
            download.assert_not_called()
            target.write_bytes(self.data + b"changed")
            with self.assertRaisesRegex(ValueError, "hash or size"):
                cached_file(self.record, self.root)
            download.assert_not_called()

    def test_fresh_download_is_bounded_and_verified_before_cache_write(self):
        with patch("scripts.build.external_as.urlopen") as download:
            stream = download.return_value.__enter__.return_value
            stream.read.return_value = self.data
            target = cached_file(self.record, self.root)
            stream.read.assert_called_once_with(len(self.data) + 1)
            self.assertEqual(target.read_bytes(), self.data)
        target.unlink()
        with patch("scripts.build.external_as.urlopen") as download:
            download.return_value.__enter__.return_value.read.return_value = b"wrong"
            with self.assertRaisesRegex(ValueError, "hash or size"):
                cached_file(self.record, self.root)
        self.assertFalse(target.exists())
        self.assertFalse(target.with_name(target.name + ".tmp").exists())

    def test_download_failure_does_not_leave_a_cache_entry(self):
        with patch("scripts.build.external_as.urlopen", side_effect=OSError("offline")):
            with self.assertRaisesRegex(OSError, "offline"):
                cached_file(self.record, self.root)
        self.assertFalse((self.root / self.record["path"]).exists())

    def test_cache_paths_and_download_origins_are_bounded(self):
        for name in ("../outside", "src/tool", "build/tools/as-313/../elsewhere", "build/tools/as-313/x\\tool"):
            with self.subTest(name=name), self.assertRaises(ValueError):
                cached_file({**self.record, "path": name}, self.root)
        for url in ("http://raw.githubusercontent.com/x", "https://example.invalid/tool", "file:///tool"):
            with self.subTest(url=url), self.assertRaises(ValueError):
                cached_file({**self.record, "url": url}, self.root)

    def test_unsupported_host_and_missing_dependency_fail_closed(self):
        with patch("scripts.build.external_as.host_id", return_value="unsupported"):
            with self.assertRaisesRegex(ValueError, "no pinned"):
                assembler({"hosts": {}}, self.root)
        with patch("scripts.build.external_as.urlopen", side_effect=OSError("missing dependency")):
            with self.assertRaises(OSError):
                cached_file(self.record, self.root)

    def test_project_has_no_binary_exception_even_for_the_old_compilers(self):
        self.assertEqual(load("config/binary_allowlist.json")["files"], [])
        for name in ("build_tools/Linux-x86_64/asl", "build_tools/Windows-x86_64/asw.exe"):
            with self.subTest(name=name):
                self.assertIsNotNone(payload_problem(b"\x00synthetic compiler", name, set(), {}))

    def test_tool_versions_and_external_files_remain_hash_pinned(self):
        spec = load("config/toolchain.json")["assembler"]
        self.assertEqual(spec["version"], "1.42-beta-build-313")
        self.assertNotIn("allowlist", spec)
        self.assertTrue(spec["license"]["path"].startswith("build/"))
        for record in [spec["license"], *spec["hosts"].values()]:
            self.assertEqual(len(record["sha256"]), 64)
            self.assertGreater(record["size"], 0)
        for record in spec["hosts"].values():
            self.assertIn("4ef457c18fc4902396c43ab06fabc119ac6ecb64/", record["url"])
        self.assertIn("b2803d77b610522ae85c46ded89b8c15460381d5/", spec["license"]["url"])
