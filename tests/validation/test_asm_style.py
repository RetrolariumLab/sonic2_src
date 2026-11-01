"""The Kit bridge must preserve AS tokens and the assembled program."""
import hashlib
import json
import re
from pathlib import Path
import subprocess
import tempfile
import unittest
from scripts.build.project import ROOT, toolchain
from scripts.validation.asm_style import encode_source, restore_source, normalize, code_signature

SOURCE = """    CPU 68000
    padding off
foo = 3
other := 7
start:
    moveq #foo,d0
.loop: addq.w #1,d0
    bne.s +
    nop
+   rts
Payload: dc.b "literal; keep  two spaces"
"""


class AssemblyStyleTests(unittest.TestCase):
    def test_label_protection_roundtrip(self):
        for source in [SOURCE, "field.name set 4\n.local: nop\n++\n", 'Data: dc.b "literal; text" ; comment\n']:
            protected, records = encode_source(source)
            restored = restore_source(protected, records)
            self.assertEqual([re.sub(r"\s+", " ", line.strip()) for line in restored.splitlines()], [re.sub(r"\s+", " ", line.strip()) for line in source.splitlines()])

    def test_bridge_rejects_a_changed_nonblank_line_count(self):
        protected, records = encode_source(SOURCE)
        with self.assertRaises(ValueError):
            restore_source(protected + "extra\n", records)

    def test_real_kit_format_is_idempotent_and_byte_neutral(self):
        parent = ROOT / "build/tests"
        parent.mkdir(parents=True, exist_ok=True)
        with tempfile.TemporaryDirectory(dir=parent) as directory:
            root = Path(directory)
            (root / "config").mkdir()
            config = {"schema": "retrolarium.lint", "schema_version": 1, "assembly": {"dialect": "asl", "paths": ["probe.asm"]}, "code": False}
            (root / "config/lint.json").write_text(json.dumps(config))
            source = root / "probe.asm"
            source.write_text(SOURCE)
            assembler, _ = toolchain()
            def assemble():
                source.with_suffix(".p").unlink(missing_ok=True)
                result = subprocess.run([str(assembler), "-xx", "-n", "-q", "-A", "-U", "-E", "-i", ".", "probe.asm"], cwd=root, capture_output=True)
                self.assertEqual(result.returncode, 0, result.stdout.decode(errors="replace") + (source.with_suffix(".log").read_text() if source.with_suffix(".log").exists() else ""))
                return source.with_suffix(".p").read_bytes()
            before = assemble()
            original = source.read_bytes()
            self.assertEqual(normalize(root, fix=False), ["probe.asm"])
            self.assertEqual(source.read_bytes(), original)
            self.assertEqual(normalize(root, fix=True), ["probe.asm"])
            self.assertEqual(normalize(root, fix=False), [])
            self.assertEqual(assemble(), before)

    def test_signature_distinguishes_z80_registers_and_quoted_spaces(self):
        self.assertEqual(code_signature("    ex af,af'\t; swap af with af'\n"), code_signature("  ex af,af'  ; other comment\n"))
        self.assertNotEqual(code_signature("    dc.b ' '"), code_signature("    dc.b ''"))
        self.assertNotEqual(code_signature('    dc.b "two  spaces"'), code_signature('    dc.b "two spaces"'))
