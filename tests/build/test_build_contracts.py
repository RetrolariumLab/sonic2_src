"""Build patch safety, stale output rejection, and the actual Make interface."""

from pathlib import Path
import re
import struct
import subprocess
import tempfile
import unittest
from unittest.mock import patch
from scripts.build.build_rom import assemble, patch_image, prepare_audio
from scripts.build.project import ROOT, load, project_path, toolchain


class BuildContractTests(unittest.TestCase):
    def test_header_and_driver_patch(self):
        original = bytes(1024)
        data = patch_image(original, "comp_z80_size 0x123\n#define movewZ80CompSize 0x200\n")
        self.assertEqual(len(data), len(original))
        self.assertEqual(data[0x202:0x204], b"\x01\x23")
        self.assertEqual(int.from_bytes(data[0x1A4:0x1A8], "big"), 1023)
        self.assertEqual(int.from_bytes(data[0x18E:0x190], "big"), sum(struct.unpack(">256H", data[0x200:])) & 65535)

    def test_rejects_bad_patch_contracts(self):
        for header in ["", "comp_z80_size 0x10000 movewZ80CompSize 0x200", "comp_z80_size 0x10 movewZ80CompSize 0x3FF"]:
            with self.subTest(header=header), self.assertRaises(ValueError):
                patch_image(bytes(1024), header)

    def test_paths_cannot_leave_the_root(self):
        with self.assertRaises(ValueError):
            project_path("../elsewhere")

    def test_assembler_cannot_accept_a_stale_object(self):
        parent = ROOT / "build/tests"
        parent.mkdir(parents=True, exist_ok=True)
        with tempfile.TemporaryDirectory(dir=parent) as directory:
            root = Path(directory)
            entry = root / "main.asm"
            entry.write_text("synthetic")
            entry.with_suffix(".p").write_bytes(b"stale")
            result = subprocess.CompletedProcess([], 1, b"failed")
            with patch("scripts.build.build_rom.run", return_value=result), self.assertRaises(ValueError):
                assemble(entry, Path("synthetic-assembler"), root)
            self.assertFalse(entry.with_suffix(".p").exists())

    def test_manifests_have_one_input_owner_and_bounded_assets(self):
        manifest = load("assets/manifest.json")
        images = {item["id"]: item for item in manifest["images"]}
        profiles = load("config/revision_profiles.json")
        self.assertIn(profiles["default"], {item["id"] for item in profiles["profiles"]})
        for item in profiles["profiles"]:
            self.assertIn(item["image"], images)
            self.assertNotIn("sha1", item)
            self.assertTrue(item["output"].startswith("build/"))
        paths = set()
        for asset in manifest["assets"]:
            self.assertNotIn(asset["path"], paths)
            paths.add(asset["path"])
            self.assertGreater(asset["size"], 0)
            self.assertLessEqual(asset["offset"] + asset["size"], images[asset["image"]]["size"])

    def test_real_make_help_without_private_inputs(self):
        result = subprocess.run(["make", "help"], cwd=ROOT, text=True, capture_output=True, timeout=30)
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertIn("verify-all", result.stdout)
        self.assertIn("split ROM_DIR=folder", result.stdout)

    def test_all_compressed_songs_round_trip_from_user_assets(self):
        from scripts.authoring.saxman import decode, encode

        manifest = load("assets/manifest.json")
        songs = [item for item in load("config/audio.json")["songs"] if item["compressed"]]
        paths = [ROOT / manifest["output"] / item["asset"] for item in songs]
        if not all(path.is_file() for path in paths):
            self.skipTest("Song round trips require make split with the user's ROMs")
        for song, path in zip(songs, paths):
            with self.subTest(song=song["name"]):
                payload = path.read_bytes()
                self.assertEqual(encode(decode(payload)), payload)

