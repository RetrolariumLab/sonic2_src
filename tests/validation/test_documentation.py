"""Check corpus navigation, anchors, review freshness and local-path boundaries."""

from pathlib import Path
import hashlib
import json
import tempfile
import unittest
from scripts.build.project import ROOT
from scripts.validation.documentation import audit


class DocumentationTests(unittest.TestCase):
    def setUp(self):
        parent = ROOT / "build/tests/validation/documentation"
        parent.mkdir(parents=True, exist_ok=True)
        self.directory = tempfile.TemporaryDirectory(dir=parent)
        self.addCleanup(self.directory.cleanup)
        self.root = Path(self.directory.name)
        self.write("README.md", "# Synthetic project\n\n[Docs](docs/index.md)\n")
        self.write("docs/index.md", "# Documentation\n\n[Guide](guide.md#usable-section)\n")
        self.write("docs/guide.md", "# Guide\n\n## Usable section\n\nSynthetic instructions.\n")
        self.declare()

    def write(self, name, body):
        path = self.root / name
        path.parent.mkdir(parents=True, exist_ok=True)
        path.write_text(body, newline="\n")

    def declare(self, status="development"):
        names = [path.relative_to(self.root).as_posix() for path in self.root.rglob("*.md")]
        self.write("config/source_reconstruction_2_0.json", json.dumps({"required_documents": names}))
        self.write(
            "config/reconstruction/documentation_review.json",
            json.dumps(
                {
                    "status": status,
                    "documents": [
                        {
                            "path": name,
                            "action": "new",
                            "reason": "Synthetic reader journey",
                            "sha256": hashlib.sha256((self.root / name).read_bytes()).hexdigest(),
                        }
                        for name in names
                    ],
                }
            ),
        )

    def test_complete_reader_journey_and_heading_are_checked(self):
        self.assertTrue(audit(self.root)["all_documents_reachable"])

    def test_missing_local_target_is_rejected(self):
        self.write("docs/index.md", "# Documentation\n\n[Missing](missing.md)\n")
        with self.assertRaisesRegex(ValueError, "Broken local"):
            audit(self.root)

    def test_missing_heading_is_rejected(self):
        self.write("docs/index.md", "# Documentation\n\n[Guide](guide.md#wrong-heading)\n")
        with self.assertRaisesRegex(ValueError, "Missing Markdown heading"):
            audit(self.root)

    def test_declared_but_orphaned_document_is_rejected(self):
        self.write("docs/orphan.md", "# Orphan\n")
        self.declare()
        with self.assertRaisesRegex(ValueError, "Orphan documentation"):
            audit(self.root)

    def test_changed_document_invalidates_substance_review(self):
        self.declare("reviewed")
        self.write("docs/guide.md", "# Guide\n\n## Usable section\n\nChanged.\n")
        with self.assertRaisesRegex(ValueError, "changed after its substance review"):
            audit(self.root)

    def test_windows_absolute_path_is_not_an_external_url(self):
        self.write("docs/index.md", "# Documentation\n\n[Local](C:/outside.md)\n")
        with self.assertRaisesRegex(ValueError, "Absolute local"):
            audit(self.root)

    def test_link_cannot_escape_the_project(self):
        self.write("docs/index.md", "# Documentation\n\n[Escape](../../outside.md)\n")
        with self.assertRaisesRegex(ValueError, "leaves the project"):
            audit(self.root)


if __name__ == "__main__":
    unittest.main()
