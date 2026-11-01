"""Check source-address attribution across include returns and malformed paths."""

from pathlib import Path
from scripts.build.project import ROOT
import tempfile, unittest
from scripts.build.listing_source import source_pcs, listing_index


class ListingSourceTests(unittest.TestCase):
    def fixture(self, root):
        (root / "entry.asm").write_text('include "body.asm"\ndc.b 0\n')
        (root / "body.asm").write_text("dc.w 1\neven\n")
        listing = root / "main.lst"
        listing.write_text(' 1/ 200 : include "body.asm"\n(1) 1/ 200 : dc.w 1\n(1) 2/ 202 : even\n 2/ 202 : dc.b 0\n')
        return listing

    def test_include_address_ownership_and_return(self):
        parent = ROOT / "build/tests/authoring/listing"
        parent.mkdir(parents=True, exist_ok=True)
        with tempfile.TemporaryDirectory(dir=parent) as folder:
            root = Path(folder)
            listing = self.fixture(root)
            self.assertEqual(
                source_pcs(listing, root, "entry.asm"),
                {("entry.asm", 1): 512, ("body.asm", 1): 512, ("body.asm", 2): 514, ("entry.asm", 2): 514},
            )

    def test_unowned_depth_is_rejected(self):
        parent = ROOT / "build/tests/authoring/listing"
        parent.mkdir(parents=True, exist_ok=True)
        with tempfile.TemporaryDirectory(dir=parent) as folder:
            root = Path(folder)
            listing = self.fixture(root)
            listing.write_text("(2) 1/ 200 : invalid\n")
            with self.assertRaises(ValueError):
                source_pcs(listing, root, "entry.asm")

    def test_source_include_cannot_leave_project(self):
        parent = ROOT / "build/tests/authoring/listing"
        parent.mkdir(parents=True, exist_ok=True)
        with tempfile.TemporaryDirectory(dir=parent) as folder:
            root = Path(folder)
            listing = self.fixture(root)
            (root / "entry.asm").write_text('include "../escape.asm"\ndc.b 0\n')
            with self.assertRaises(ValueError):
                source_pcs(listing, root, "entry.asm")

    def test_include_eof_has_the_parent_return_address(self):
        parent = ROOT / "build/tests/authoring/listing"
        parent.mkdir(parents=True, exist_ok=True)
        with tempfile.TemporaryDirectory(dir=parent) as folder:
            root = Path(folder)
            listing = self.fixture(root)
            index = listing_index(listing, root, "entry.asm")
            self.assertEqual(index.pc("body.asm", 3), 514)
            self.assertEqual(index.rows[1].path, "body.asm")
            with self.assertRaises(ValueError):
                index.pc("entry.asm", 3)

    def test_macro_template_scope_includes_nested_repeats(self):
        parent = ROOT / "build/tests/authoring/listing"
        parent.mkdir(parents=True, exist_ok=True)
        with tempfile.TemporaryDirectory(dir=parent) as folder:
            root = Path(folder)
            listing = self.fixture(root)
            (root / "body.asm").write_text(
                'asset macro path\n rept 2\n binclude "path"\n endm\n endm\n binclude "real.bin"\n'
            )
            index = listing_index(listing, root, "entry.asm")
            self.assertEqual(index.macro_definition_lines("body.asm"), {1, 2, 3, 4, 5})


if __name__ == "__main__":
    unittest.main()
