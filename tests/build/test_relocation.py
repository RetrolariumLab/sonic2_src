"""Protect conditional exits, fixed-stride instruction tables and listing parsing."""

from pathlib import Path
import tempfile
import unittest
from scripts.build.listing import symbols
from scripts.build.project import ROOT
from scripts.build.relocate import duplicate_epilogues
from scripts.build.build_rom import patch_image


class RelocationTests(unittest.TestCase):
    def test_conditional_exits_and_instruction_slots_are_not_padded(self):
        source = "Table:\n    rts\n    bra.w Handler\n    rts\nHandler:\n    beq.s +\n    rts\n+   moveq #0,d0\n    rts\nNext:\n    rte\n"
        result, records, _ = duplicate_epilogues(source)
        self.assertIn("Table:\n    rts\n    bra.w Handler\n    rts\n                rts", result)
        self.assertIn("    beq.s +\n    rts\n+   moveq", result)
        self.assertEqual(len(records), 3)
        self.assertEqual([row["opcode"] for row in records], ["rts", "rts", "rte"])

    def test_aliases_are_inserted_only_at_the_named_terminal_owner(self):
        anchor = {"symbol": "JmpTo_Test", "anchor_owner": "Owner", "alias": "Near_Test", "target": "Target"}
        result, _, used = duplicate_epilogues("Owner:\n    rts\nNext:\n    rts\n", [anchor])
        self.assertEqual(used, ["JmpTo_Test"])
        self.assertEqual(result.count("Near_Test:"), 1)
        self.assertIn("jmp (Target).l", result)

    def test_listing_instruction_addresses_are_not_symbols(self):
        parent = ROOT / "build/tests"
        parent.mkdir(parents=True, exist_ok=True)
        with tempfile.TemporaryDirectory(dir=parent) as directory:
            path = Path(directory) / "synthetic.lst"
            path.write_text("(1)12/ A0D8 : 24D9 - move.l (a1)+,(a2)+\n Owner : 1234 C | RAM : FFF000 -\n")
            self.assertEqual(symbols(path), {"Owner": 0x1234, "RAM": 0xFFF000})

    def test_probe_logical_checksum_extent_does_not_change_default_patching(self):
        original = bytearray(2048)
        original[1500:1502] = b"\x12\x34"
        header = "comp_z80_size 0x10 movewZ80CompSize 0x200"
        normal = patch_image(original, header)
        probe = patch_image(original, header, logical_size=1024)
        self.assertEqual(int.from_bytes(normal[0x1A4:0x1A8], "big"), 2047)
        self.assertEqual(int.from_bytes(probe[0x1A4:0x1A8], "big"), 1023)
        self.assertEqual(
            (int.from_bytes(normal[0x18E:0x190], "big") - int.from_bytes(probe[0x18E:0x190], "big")) & 65535, 0x1234
        )
        with self.assertRaises(ValueError):
            patch_image(original, header, logical_size=2049)
