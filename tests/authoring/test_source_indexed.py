"""Check source alias and zone-order binding independently of compiled data payloads."""

import unittest
from scripts.build.listing_source import ListingIndex
from scripts.authoring.source_indexed import SourceTables


class SourceIndexedTests(unittest.TestCase):
    def context(self, files, symbols=None):
        addresses = {(name, number): number * 2 for name, lines in files.items() for number in range(1, len(lines) + 1)}
        return {"listing": ListingIndex(addresses, [], files, {}), "symbols": symbols or {}}

    def test_include_alias_reaches_the_leaf_mapping_header(self):
        context = self.context(
            {
                "src/entry.asm": ['Alias: include "src/leaf.asm"'],
                "src/leaf.asm": [".offsets: mappingsTable", " mappingsTableEntry.w Frame", "Frame: spriteHeader"],
            }
        )
        source = SourceTables(context)
        self.assertEqual(source.count("Alias", "mappingstableentry.w"), 1)

    def test_zone_order_uses_the_compiled_zone_permutation(self):
        lines = [
            "Root: mappingsTable",
            ".zone_names: zoneOrderedOffsetTable 2,1",
            " zoneOffsetTableEntry.w A",
            " zoneOffsetTableEntry.w B",
            " zoneTableEnd",
            " mappingsTableEntry.w C",
            "A: spriteHeader",
        ]
        source = SourceTables(self.context({"src/entry.asm": lines}, {"zone_id_0": 1, "zone_id_1": 0}))
        self.assertEqual(source.header("Root", "mappingstableentry.w")[3], ["B", "A", "C"])

    def test_unclosed_zone_table_cannot_be_treated_as_an_empty_table(self):
        lines = [
            "Root: mappingsTable",
            ".zone_names: zoneOrderedOffsetTable 2,1",
            " zoneOffsetTableEntry.w A",
            "A: spriteHeader",
        ]
        source = SourceTables(self.context({"src/entry.asm": lines}, {"zone_id_0": 0}))
        with self.assertRaisesRegex(ValueError, "Unterminated"):
            source.header("Root", "mappingstableentry.w")


if __name__ == "__main__":
    unittest.main()
