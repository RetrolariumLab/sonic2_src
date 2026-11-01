"""Distinguish literal addresses from register offsets and declared scalars."""

import unittest
from scripts.validation.pointers import scan


class PointerAuditTests(unittest.TestCase):
    def test_literal_rom_and_absolute_ram_addresses_need_owners(self):
        for source in ["    jsr $1234", "    lea ($ff0000).l,a0", "    dc.l $1234", "    dc.l 100000"]:
            with self.subTest(source=source):
                self.assertTrue(scan(source, 0x100000))

    def test_symbolic_pointers_register_offsets_strings_and_comments_are_safe(self):
        source = '    lea 6(a0),a1\n    lea $A(a2),a2\n    lea 15*2(a2),a3\n    jsr (Procedure).l\n    dc.l Target\n    dc.b "($1234).l" ; jsr $1234\n'
        self.assertEqual(scan(source, 0x100000), [])

    def test_decimal_place_values_are_bounded_by_their_declared_scalar_contract(self):
        source = "Places:\n    dc.l 1000,100,10,1\n"
        self.assertEqual(scan(source, 0x100000, {"Places": [1000, 100, 10, 1]}), [])
        self.assertTrue(scan(source.replace("1000", "4660"), 0x100000, {"Places": [1000, 100, 10, 1]}))
