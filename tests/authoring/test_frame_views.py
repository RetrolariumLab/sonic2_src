"""Check signed/shared frame references, headerless ABIs and atomic source patches."""

from dataclasses import replace
from types import SimpleNamespace
import unittest
from scripts.authoring.frame_views import Frame, Table, Spec, Patch, Document, decode, encode, apply
from scripts.authoring.dplc_capacity import Budget


class FrameViewTests(unittest.TestCase):
    def fixture(self):
        spec = Spec(
            "rev00-content",
            96,
            (Table("TableA", 32, ("sprite-counted",) * 2), Table("TableB", 48, ("sprite-counted",) * 2)),
            (
                Frame("Shared", 8, 10, "sprite-counted"),
                Frame("Empty", 64, 2, "sprite-counted"),
                Frame("Unused", 80, 2, "sprite-counted"),
            ),
        )
        rom = bytearray([0xA5] * 96)
        rom[8:18] = bytes.fromhex("0001 FF04 E800 1801 FFF0")
        rom[64:66] = rom[80:82] = b"\0\0"
        rom[32:36] = bytes.fromhex("FFE8 0020")
        rom[48:52] = bytes.fromhex("FFD8 FFD8")
        return bytes(rom), spec

    def test_signed_backward_and_shared_aliases_retain_bytes(self):
        rom, spec = self.fixture()
        document, model = Document.open(rom, spec)
        self.assertEqual(model["tables"][0]["references"], ["Shared", "Empty"])
        self.assertEqual(model["tables"][1]["references"], ["Shared", "Shared"])
        patches = document.encode(model, spec)
        self.assertEqual(sum(row.owner == "Shared" for row in patches), 1)
        self.assertEqual(apply(rom, patches), rom)
        self.assertIn("Unused", [row["name"] for row in model["frames"]])

    def test_sprite_fields_can_change_inside_the_original_slot(self):
        rom, spec = self.fixture()
        model = decode(rom, spec)
        shared = next(row for row in model["frames"] if row["name"] == "Shared")
        shared["entries"][0]["x"] = -8
        edited = apply(rom, encode(model, spec))
        self.assertEqual(edited[16:18], bytes.fromhex("FFF8"))
        self.assertEqual(edited[32:36], rom[32:36])
        self.assertEqual(edited[48:52], rom[48:52])

    def test_pointer_cannot_enter_a_sprite_piece(self):
        rom, spec = self.fixture()
        edited = bytearray(rom)
        edited[32:34] = bytes.fromhex("FFEA")
        with self.assertRaisesRegex(ValueError, "typed frame"):
            decode(edited, spec)

    def test_frame_cannot_grow_into_adjacent_source(self):
        rom, spec = self.fixture()
        model = decode(rom, spec)
        model["frames"][0]["entries"] *= 2
        with self.assertRaisesRegex(ValueError, "original source slot"):
            encode(model, spec)

    def test_duplicate_or_missing_physical_frame_owner_is_rejected(self):
        rom, spec = self.fixture()
        with self.assertRaisesRegex(ValueError, "one physical owner"):
            replace(spec, frames=spec.frames + (Frame("Alias", 8, 10, "sprite-counted"),)).validate()
        model = decode(rom, spec)
        model["frames"].pop()
        with self.assertRaisesRegex(ValueError, "ownership changed"):
            encode(model, spec)

    def test_document_rejects_another_profile_even_if_model_is_relabelled(self):
        rom, spec = self.fixture()
        document, model = Document.open(rom, spec)
        model["abi"] = "rev01-content"
        with self.assertRaisesRegex(ValueError, "frozen ABI"):
            document.encode(model, replace(spec, abi="rev01-content"))

    def test_frozen_source_spec_cannot_contain_a_mutable_owner(self):
        rom, spec = self.fixture()
        fake = SimpleNamespace(name="Shared", address=8, size=10, kind="sprite-counted")
        with self.assertRaisesRegex(ValueError, "frozen typed"):
            replace(spec, frames=(fake,)).validate()
        with self.assertRaisesRegex(ValueError, "immutable mapping selector"):
            replace(spec, tables=(replace(spec.tables[0], selector_kinds=["sprite-counted"]),)).validate()

    def test_headerless_ring_frame_has_one_piece_and_no_count_word(self):
        spec = Spec("rev00", 32, (Table("Rings", 0, ("sprite-single",)),), (Frame("Ring", 8, 8, "sprite-single"),))
        rom = bytearray(32)
        rom[:2] = b"\0\x08"
        rom[8:16] = bytes.fromhex("FF04 E800 1801 FFF0")
        model = decode(rom, spec)
        self.assertEqual(len(model["frames"][0]["entries"]), 1)
        self.assertEqual(apply(rom, encode(model, spec)), rom)
        model["frames"][0]["entries"] *= 2
        with self.assertRaisesRegex(ValueError, "exactly one"):
            encode(model, spec)

    def test_special_stage_dplc_keeps_word_offsets_and_headerless_tail(self):
        spec = Spec(
            "rev00",
            96,
            (
                Table(
                    "SS",
                    32,
                    ("ss-dplc-counted", "ss-dplc-single"),
                    transfer_budgets=(Budget(2048, 16, 2), Budget(512, 6, 2)),
                ),
            ),
            (Frame("Character", 64, 4, "ss-dplc-counted"), Frame("Tail", 72, 2, "ss-dplc-single")),
        )
        rom = bytearray(96)
        rom[32:36] = bytes.fromhex("0020 0028")
        rom[64:68] = bytes.fromhex("0001 F120")
        rom[72:74] = bytes.fromhex("5000")
        model = decode(rom, spec)
        self.assertEqual(model["frames"][0]["entries"], [{"tiles": 16, "source_word_offset": 0x120}])
        self.assertEqual(model["frames"][1]["entries"], [{"tiles": 6, "source_word_offset": 0}])
        self.assertEqual(apply(rom, encode(model, spec)), rom)
        model["tables"][0]["references"].reverse()
        with self.assertRaisesRegex(ValueError, "consumer frame ABI"):
            encode(model, spec)

    def test_dplc_view_checks_source_and_destination_before_patches(self):
        spec = Spec(
            "rev00",
            32,
            (Table("SS", 0, ("ss-dplc-single",), transfer_budgets=(Budget(64, 2, 2),)),),
            (Frame("Frame", 8, 2, "ss-dplc-single"),),
        )
        rom = bytearray(32)
        rom[:2] = b"\0\x08"
        document, model = Document.open(rom, spec)
        model["frames"][0]["entries"][0]["source_word_offset"] = 32
        with self.assertRaisesRegex(ValueError, "source art allocation"):
            document.encode(model, spec)
        model["frames"][0]["entries"][0] = {"tiles": 3, "source_word_offset": 0}
        wider_source = replace(spec, tables=(replace(spec.tables[0], transfer_budgets=(Budget(256, 2, 2),)),))
        with self.assertRaisesRegex(ValueError, "frozen ABI"):
            document.encode(model, wider_source)
        with self.assertRaisesRegex(ValueError, "source and destination bounds"):
            replace(spec, tables=(replace(spec.tables[0], transfer_budgets=()),)).validate()

    def test_null_reference_requires_a_zero_first_header_word(self):
        rom, spec = self.fixture()
        spec = replace(spec, tables=(replace(spec.tables[0], allow_null=True),))
        altered = bytearray(rom)
        altered[32:34] = b"\0\0"
        model = decode(altered, spec)
        self.assertIsNone(model["tables"][0]["references"][0])
        model["tables"][0]["references"] = ["Shared", None]
        with self.assertRaisesRegex(ValueError, "zero word"):
            encode(model, spec)

    def test_signed_word_reference_cannot_overflow(self):
        spec = Spec(
            "rev00", 100000, (Table("Root", 32, ("sprite-counted",)),), (Frame("Far", 70000, 2, "sprite-counted"),)
        )
        model = {
            "abi": "rev00",
            "tables": [{"name": "Root", "references": ["Far"]}],
            "frames": [{"name": "Far", "entries": []}],
        }
        with self.assertRaisesRegex(ValueError, "signed-word"):
            encode(model, spec)

    def test_conflicting_shared_writes_fail_before_mutation(self):
        original = bytes(8)
        with self.assertRaisesRegex(ValueError, "Conflicting edits"):
            apply(original, [Patch("A", 1, b"ab"), Patch("B", 2, b"x")])
        self.assertEqual(original, bytes(8))
        self.assertEqual(apply(original, [Patch("A", 1, b"ab"), Patch("B", 2, b"b")]), b"\0ab" + bytes(5))
        with self.assertRaisesRegex(ValueError, "address space"):
            apply(original, [Patch("Out", 8, b"x")])


if __name__ == "__main__":
    unittest.main()
