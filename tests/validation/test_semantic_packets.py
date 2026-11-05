"""Subsystem packets cannot drop or silently reclassify explicit unknowns."""

from copy import deepcopy
import unittest
from scripts.validation.semantic_packets import validate


class SemanticPacketTests(unittest.TestCase):
    def test_exact_partition_and_physical_owners(self):
        known = [{"old": "sub_10", "definitions": [{"source": "src/game/player/move.s"}]}]
        unknown = [{"symbol": "loc_20", "definitions": [{"source": "src/game/player/move.s"}]}]
        document = {
            "schema_version": 1,
            "packets": [
                {
                    "id": "player",
                    "reason": "Review movement entries",
                    "source_roots": ["src/game/player/"],
                    "renames": ["sub_10"],
                    "unknowns": ["loc_20"],
                }
            ],
        }
        self.assertEqual(validate(document, known, unknown), 1)
        for field, value in (("unknowns", []), ("renames", ["sub_10", "sub_10"]), ("source_roots", ["src/ui/"])):
            changed = deepcopy(document)
            changed["packets"][0][field] = value
            with self.subTest(field=field), self.assertRaises(ValueError):
                validate(changed, known, unknown)
        changed = deepcopy(document)
        changed["packets"] *= 2
        with self.assertRaises(ValueError):
            validate(changed, known, unknown)
