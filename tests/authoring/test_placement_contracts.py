"""Reject engine-unsafe placements before the public document returns bytes."""

import copy
import hashlib
import json
from pathlib import Path
import tempfile
import struct
import unittest
from scripts.authoring.asset_document import Document, Target
from scripts.authoring.catalog import codec
from scripts.authoring.contexts import bumper_order_context, object_respawn_capacity
from scripts.build.project import ROOT
from scripts.authoring.struct_formats import FORMATS


def ram_symbols(size=190, base=0xFFFFFC00):
    return dict(
        Object_Respawn_Table=base,
        Obj_respawn_index=base,
        Obj_respawn_index_End=base + 2,
        Obj_respawn_data=base + 2,
        Obj_respawn_data_End=base + 2 + size,
    )


class PlacementContractTests(unittest.TestCase):
    def object_document(self, respawns=0, capacity=189):
        raw = b"".join(struct.pack(">HHBB", x, 0x8000 if x < respawns else 0, 1, 0) for x in range(200))
        target = Target(
            "level/objects/test.bin", "object-placement-s2", "s2-retail", "m68000-rom", 0x200, len(raw), len(raw)
        )
        handler = codec(target.asset_id, {"respawn_capacity": capacity})
        document, model = Document.open(raw, target, handler=handler)
        return document, model, target

    def test_respawn_limit_is_the_ram_extent_minus_reserved_index_zero(self):
        self.assertEqual(object_respawn_capacity(ram_symbols()), 189)
        self.assertEqual(object_respawn_capacity(ram_symbols(4)), 3)
        self.assertEqual(object_respawn_capacity(ram_symbols(300)), 255)
        self.assertEqual(object_respawn_capacity(ram_symbols(base=0xFFFC00)), 189)

    def test_missing_or_inconsistent_ram_layout_is_rejected(self):
        for changes in [
            {"Obj_respawn_index_End": 0},
            {"Obj_respawn_data_End": True},
            {"Obj_respawn_data_End": 0xFFFFFC02},
            {"Object_Respawn_Table": 0},
        ]:
            with self.subTest(changes=changes), self.assertRaises(ValueError):
                object_respawn_capacity({**ram_symbols(), **changes})
        with self.assertRaisesRegex(ValueError, "symbols are required"):
            object_respawn_capacity({})

    def test_public_export_accepts_189_and_rejects_190_without_widening_the_slot(self):
        document, model, target = self.object_document()
        for row in model[:189]:
            row["respawn"] = True
        self.assertEqual(len(document.encode(model, target)), 1200)
        model[189]["respawn"] = True
        before = copy.deepcopy(model)
        with self.assertRaisesRegex(ValueError, "respawn flags exceed"):
            document.encode(model, target)
        self.assertEqual(model, before)
        self.assertEqual(document.original_plain, bytes(document.original_stream))

    def test_smaller_canonical_ram_is_enforced_by_the_bound_handler(self):
        document, model, target = self.object_document(capacity=object_respawn_capacity(ram_symbols(4)))
        for row in model[:3]:
            row["respawn"] = True
        self.assertEqual(len(document.encode(model, target)), 1200)
        model[3]["respawn"] = True
        with self.assertRaisesRegex(ValueError, "respawn flags exceed"):
            document.encode(model, target)

    def test_missing_capacity_fails_closed_in_factory_and_default_document(self):
        document, model, target = self.object_document()
        for capacity in [None, True, -1, 256, "189"]:
            with self.subTest(capacity=capacity), self.assertRaisesRegex(ValueError, "canonical respawn RAM capacity"):
                codec(target.asset_id, {"respawn_capacity": capacity})
        with self.assertRaisesRegex(ValueError, "canonical respawn RAM capacity"):
            Document.open(document.original_stream, target)
        with self.assertRaisesRegex(ValueError, "canonical respawn RAM capacity"):
            FORMATS[target.format_id].encode(model)

    def test_capacity_is_frozen_and_generator_cannot_bypass_the_count(self):
        document, model, target = self.object_document()
        context = {"respawn_capacity": 189}
        handler = codec(target.asset_id, context)
        context["respawn_capacity"] = 255
        for row in model[:190]:
            row["respawn"] = True
        for rows in [model, iter(model)]:
            with self.subTest(rows=type(rows)), self.assertRaisesRegex(ValueError, "respawn flags exceed"):
                handler.encode(rows)

    def test_object_x_order_is_required_but_equal_x_is_preserved(self):
        document, model, target = self.object_document()
        model[1]["x"] = model[0]["x"]
        self.assertEqual(len(document.encode(model, target)), 1200)
        model[0]["x"] = 2
        before = copy.deepcopy(model)
        with self.assertRaisesRegex(ValueError, "nondecreasing X"):
            document.encode(model, target)
        self.assertEqual(model, before)

    def test_cnz_bumper_x_order_is_required_without_sorting_equal_rows(self):
        raw = bytes.fromhex("0001001000200002001000300000FFFF0000")
        target = Target("bumpers", "cnz-bumper-placement", "s2-retail", "m68000-rom", 0x200, len(raw), len(raw))
        document, model = Document.open(raw, target)
        self.assertEqual(document.encode(model, target), raw)
        model["bumpers"][0]["x"] = 0x0F
        self.assertEqual(len(document.encode(model, target)), len(raw))
        model["bumpers"][0]["x"] = 0x11
        before = copy.deepcopy(model)
        with self.assertRaisesRegex(ValueError, "nondecreasing X"):
            document.encode(model, target)
        self.assertEqual(model, before)

    def test_ring_x_sign_bit_is_a_terminator_on_decode_and_encode(self):
        handler = FORMATS["ring-groups-s2"]
        model = [dict(x=0x7FFF, y=0, count=1, vertical=False)]
        self.assertEqual(handler.decode(handler.encode(model)), model)
        for x in [0x8000, 0xFFFE, 0xFFFF]:
            with self.subTest(x=x), self.assertRaisesRegex(ValueError, "negative-X"):
                handler.encode([{**model[0], "x": x}])
            for prefix in [b"", bytes.fromhex("00100000")]:
                raw = prefix + struct.pack(">HH", x, 0) + b"\xff\xff"
                with self.subTest(x=x, prefix=prefix), self.assertRaisesRegex(ValueError, "negative-X"):
                    handler.decode(raw)

    def test_ring_document_checks_edits_before_returning_the_stream(self):
        raw = bytes.fromhex("01000000FFFF")
        target = Target("rings", "ring-groups-s2", "s2-retail", "m68000-rom", 0x200, len(raw), len(raw))
        document, model = Document.open(raw, target)
        model[0]["x"] = 0x8000
        with self.assertRaisesRegex(ValueError, "negative-X"):
            document.encode(model, target)

    def test_ring_group_order_is_not_object_stream_order(self):
        handler = FORMATS["ring-groups-s2"]
        # The engine sorts expanded ring positions, not the stored group list.
        raw = bytes.fromhex("0200000001000000FFFF")
        self.assertEqual(handler.encode(handler.decode(raw)), raw)
        self.assertEqual(handler.encode([]), b"\xff\xff")


class RetailBumperOrderTests(unittest.TestCase):
    def fixture(self):
        parent = ROOT / "build/tests/authoring/bumper-order"
        parent.mkdir(parents=True, exist_ok=True)
        directory = tempfile.TemporaryDirectory(dir=parent)
        self.addCleanup(directory.cleanup)
        root = Path(directory.name)
        (root / "config/authoring").mkdir(parents=True)
        raw = bytes.fromhex("0000010000000000008000000000FFFF0000")
        name = "level/objects/CNZ 2 bumpers.bin"
        record = dict(
            asset=name,
            sha256=hashlib.sha256(raw).hexdigest(),
            descending_pairs=[[0, 1]],
            policy="unchanged_stream_only",
            reason="A reviewed original inversion must remain byte-exact; edited lists require nondecreasing X.",
        )
        (root / "config/authoring/data_formats.json").write_text(
            json.dumps({"retail_bumper_order_exceptions": [record]})
        )
        return root, name, raw

    def test_reviewed_inversion_preserves_only_the_complete_original_stream(self):
        root, name, raw = self.fixture()
        context = bumper_order_context(name, raw, root)
        handler = codec(name, context)
        target = Target(name, "cnz-bumper-placement", "s2-retail", "m68000-rom", 0x200, len(raw), len(raw))
        document, model = Document.open(raw, target, handler=handler)
        self.assertEqual(document.encode(model, target), raw)
        context["bumper_order_exception"]["stream"] = b""
        self.assertEqual(document.encode(model, target), raw)
        model["bumpers"][0]["y"] = 1
        with self.assertRaisesRegex(ValueError, "nondecreasing X"):
            document.encode(model, target)
        model["bumpers"][0]["x"] = 0x70
        self.assertEqual(len(document.encode(model, target)), len(raw))
        with self.assertRaisesRegex(ValueError, "nondecreasing X"):
            Document.open(raw, target)

    def test_reviewed_inversion_cannot_be_transferred_to_another_asset_or_payload(self):
        root, name, raw = self.fixture()
        with self.assertRaisesRegex(ValueError, "reviewed bytes"):
            bumper_order_context(name, raw[:-1] + b"\x01", root)
        context = bumper_order_context(name, raw, root)
        with self.assertRaisesRegex(ValueError, "reviewed identity"):
            codec("level/objects/Other bumpers.bin", context)
        context["bumper_order_exception"]["sha256"] = "0" * 64
        with self.assertRaisesRegex(ValueError, "reviewed identity"):
            codec(name, context)
        self.assertEqual(bumper_order_context("level/objects/Other bumpers.bin", raw, root), {})

    def test_reviewed_inversion_requires_correct_record_pair_evidence(self):
        root, name, raw = self.fixture()
        path = root / "config/authoring/data_formats.json"
        config = json.loads(path.read_text())
        config["retail_bumper_order_exceptions"][0]["descending_pairs"] = [[1, 2]]
        path.write_text(json.dumps(config))
        with self.assertRaisesRegex(ValueError, "invalid evidence"):
            bumper_order_context(name, raw, root)
