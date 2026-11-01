"""Distinguish owned pointers, numeric aliases and narrowly reviewed scalars."""

import json
from pathlib import Path
import tempfile
import unittest
from scripts.build.project import ROOT
from scripts.validation.pointers import audit, scan
from scripts.validation.pointer_expressions import Resolver, constant_definitions


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

    def test_numeric_immediates_in_every_address_register_are_audited(self):
        for operation in ["move.l", "movea.l", "move.w", "movea.w"]:
            for register in [*("a" + str(n) for n in range(8)), "sp"]:
                with self.subTest(operation=operation, register=register):
                    self.assertTrue(scan(f"    {operation} #$1234,{register}", 0x100000))
        self.assertTrue(scan("    movea.l #0,a0", 0x100000))

    def test_numeric_alias_chains_and_expressions_cannot_supply_pointer_ownership(self):
        aliases = constant_definitions("Alias equ Next+4\nNext = $1200\nOther := Alias\nLast set Other\n")
        for instruction in [
            "movea.l #Last,a0",
            "move.w #(Alias|2),a1",
            "lea Alias,a0",
            "pea Alias",
            "jmp Alias",
            "jsr Alias",
            "move.l (Alias).l,d0",
            "dc.l Alias,Last+2",
        ]:
            with self.subTest(instruction=instruction):
                self.assertTrue(scan("    " + instruction, 0x100000, aliases=aliases))

    def test_forward_and_local_aliases_are_resolved_in_their_source_scope(self):
        source = "Owner:\n.local equ Forward+4\n    movea.l #.local,a0\nForward equ $1000\n"
        self.assertTrue(scan(source, 0x100000))
        self.assertEqual(Resolver(constant_definitions(source)).resolve("Owner.local").values, {0x1004})

    def test_numeric_expression_grammar_and_casefolded_aliases(self):
        resolver = Resolver(constant_definitions("Base equ $1200\nAlias equ ((BASE|%11)<<1)/2\n"))
        self.assertEqual(resolver.resolve("alias").values, {0x1203})
        for expression in ["($1000+4)", "((4096|3)&65535)", "($400*4)/2", "(1<<12)"]:
            with self.subTest(expression=expression):
                self.assertTrue(scan("    movea.l #" + expression + ",a0", 0x100000))

    def test_symbolic_label_aliases_and_named_ram_remain_owned(self):
        source = "EntryAlias equ Procedure+4\nRam equ $FF0000\nPort equ $C00004\n    movea.l #EntryAlias,a0\n    lea Ram,a1\n    movea.l #Port,a2\n    dc.l EntryAlias,Ram\n    movea.w #$8000,a3\n    movea.w #-16,a4\n"
        self.assertEqual(scan(source, 0x100000), [])

    def test_nested_assembler_function_arguments_are_not_split_into_fake_pointers(self):
        self.assertEqual(scan("    dc.l vdpComm($4000,VRAM,DMA),vdpComm($6000,VRAM,WRITE)\n", 0x100000), [])
        self.assertTrue(scan("    dc.l vdpComm($4000,VRAM,DMA),$1234\n", 0x100000))

    def test_cyclic_unbounded_and_unsupported_numeric_aliases_fail_closed(self):
        for source in [
            "A equ B\nB equ A\n    movea.l #A,a0",
            "A equ 1<<1000\n    movea.l #A,a0",
            "A equ 2**12\n    movea.l #A,a0",
            "    movea.l #(2**12),a0",
        ]:
            with self.subTest(source=source):
                self.assertTrue(scan(source, 0x100000))

    def scalar(self):
        return dict(
            owner="Counter",
            operation="movea.w",
            expression="$10",
            register="a3",
            value=16,
            count=1,
            reason="Reviewed collision sample length; the register is consumed as a scalar counter.",
        )

    def test_scalar_exception_binds_owner_instruction_expression_register_and_count(self):
        source = "Counter:\n    movea.w #$10,a3\n"
        record = self.scalar()
        self.assertEqual(scan(source, 0x100000, scalar_loads=[record]), [])
        for changed in [
            source.replace("Counter", "Other"),
            source.replace("$10", "$12"),
            source.replace("a3", "a4"),
            source.replace("movea.w", "move.w"),
            source + "    movea.w #$10,a3\n",
            "Counter:\n",
        ]:
            with self.subTest(changed=changed):
                self.assertTrue(scan(changed, 0x100000, scalar_loads=[record]))
        self.assertTrue(scan(source + "Other:\n    movea.w #$10,a3\n", 0x100000, scalar_loads=[record]))

    def test_scalar_exception_cannot_change_its_numeric_value_or_be_duplicated(self):
        source = "Counter:\n    movea.w #$10,a3\n"
        record = self.scalar()
        self.assertTrue(scan(source, 0x100000, scalar_loads=[{**record, "value": 18}]))
        with self.assertRaises(ValueError):
            scan(source, 0x100000, scalar_loads=[record, record])

    def test_deliberate_crash_symbol_is_exact_and_not_a_general_address_allowance(self):
        source = "Crash equ 1\n    jmp (Crash).l\n"
        self.assertEqual(scan(source, 0x100000, fixed_symbols={"Crash": 1}), [])
        self.assertTrue(scan(source.replace("equ 1", "equ 2"), 0x100000, fixed_symbols={"Crash": 1}))
        self.assertTrue(scan("    movea.l #1,a0", 0x100000, fixed_symbols={"Crash": 1}))

    def test_failed_audit_removes_the_previous_success_receipt(self):
        parent = ROOT / "build/tests/pointers"
        parent.mkdir(parents=True, exist_ok=True)
        with tempfile.TemporaryDirectory(dir=parent) as directory:
            root = Path(directory)
            files = {
                "config/lint.json": {"assembly": {"paths": ["src"]}},
                "assets/manifest.json": {"images": [{"size": 0x100000}]},
                "config/revision_profiles.json": {"profiles": [{"id": "rev00", "defines": {}}]},
                "config/reconstruction/fixed_regions.json": {
                    "scalar_longword_tables": [],
                    "deliberate_exception": {"symbol": "Crash"},
                },
            }
            for name, value in files.items():
                path = root / name
                path.parent.mkdir(parents=True, exist_ok=True)
                path.write_text(json.dumps(value))
            (root / "src").mkdir()
            (root / "src/main.s").write_text("    movea.l #$1234,a0\n")
            (root / "build").mkdir()
            report = root / "build/pointer-audit.json"
            report.write_text('{"literal_pointer_candidates": 0}')
            with self.assertRaisesRegex(ValueError, "pointer audit failed"):
                audit(root, static=True)
            self.assertFalse(report.exists())
