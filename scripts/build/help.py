"""Show every public command, grouped by workflow, without touching build inputs."""

from scripts.build.project import load, profiles

GROUPS = [
    ("Project", [("help", "Show all public commands and selectors")]),
    (
        "Inputs and canonical builds",
        [
            ("split", "Import verified ROMs and extract assets; ROM_DIR=folder"),
            ("check-assets", "Check every extracted and derived private input"),
            ("build", "Build one accepted revision; REV=profile"),
            ("verify", "Build and compare one revision; REV=profile"),
            ("verify-all", "Compare every byte of all accepted revisions"),
        ],
    ),
    (
        "Development",
        [
            ("test", "Run the full tool test suite without requiring ROMs"),
            ("lint", "Check source, code, text and links without edits"),
            ("format", "Apply shared formatting and check its stable result"),
            ("format-check", "Alias for lint"),
        ],
    ),
    (
        "Content",
        [
            ("prepare-core", "Build pinned Core CLI; CORE_SOURCE=path, optional CMAKE_GENERATOR=name"),
            ("roundtrip-formats", "Check all registered formats and active placements"),
            ("check-content-zero-edit", "Round-trip content and rebuild every complete ROM"),
        ],
    ),
    (
        "Relocation and runtime",
        [
            ("pointer-audit", "Check symbolic pointers and fixed regions"),
            ("build-relocated", "Build the controlled relocation probe; optional REV=profile"),
            ("runtime-check", "Compare complete original MAME goldens; optional REV=profile"),
            ("runtime-golden", "Capture original-ROM goldens; optional REV=profile"),
        ],
    ),
    (
        "Structure and release",
        [
            ("source-layout-check", "Check semantic owners, source ranges and independent data inventory"),
            ("documentation-check", "Check document corpus, local links and review decisions"),
            ("scaffold-check", "Check static contracts and synthetic fixtures without ROMs"),
            ("check-private-data", "Reject private data in the current tree and every reachable ref"),
            ("check-stop-words", "Check every reachable history ref with Core"),
            ("release-audit", "Audit ownership, privacy, documents and a clean working tree"),
            ("release-check", "Run the complete Source 1.0 preservation guarantee set"),
            ("source-1-check", "Alias for release-check"),
            ("source-2-check", "Run preservation first, then the complete Source 2.0 delta"),
            ("source-2-audit", "Alias for the complete source-2-check"),
        ],
    ),
]


def main():
    names = [name for title, rows in GROUPS for name, summary in rows]
    if len(names) != len(set(names)) or set(names) != set(
        load("config/source_reconstruction_2_0.json")["release_commands"]
    ):
        raise SystemExit("Help and release command declarations disagree")
    print("Sonic the Hedgehog 2 source reconstruction")
    print("Default REV=" + profiles()["default"] + "; bare make shows this help.")
    for title, rows in GROUPS:
        print("\n" + title)
        for name, summary in rows:
            selector = " ROM_DIR=folder" if name == "split" else ""
            print("  " + (name + selector).ljust(25) + summary)
