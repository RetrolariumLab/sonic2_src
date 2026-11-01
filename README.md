# Sonic the Hedgehog 2 source reconstruction

This project reconstructs the original Mega Drive retail REV00 and REV01 images
from source code and the user's own verified ROMs. It contains no distributable
ROM, music, sound effects, graphics or extracted binary game assets. It is based
on sonicretro/s2disasm; upstream attribution and its
[disclaimer](docs/provenance.md#upstream-disclaimer) are preserved.

This is a preservation candidate on the way to Source Reconstruction 2.0. Both
canonical profiles reproduce their original images byte for byte. Controlled
relocation and direct original-RAM comparisons cover both revisions, including
two-player attract gameplay. The corrected import excludes private audio data
from every ancestor of this series. The complete preservation gate has passed
from a fresh clone supplied only with the verified ROMs. No release tag is
claimed or created.

## Quick start

Install Python 3.10+, Git, GNU Make and the pinned Retrolarium Kit build tools.
The validated host is Windows x86-64; Linux has a pinned assembler but has not
passed the full gate. Runtime also needs the pinned MAME registered with
`rltool movie mame`. See [build instructions](docs/build.md).

```sh
make split ROM_DIR="/path/to/your/rom/folder"
make verify-all
make build-relocated
make runtime-check
```

The importer accepts only images matching the size and hashes owned by
assets/manifest.json. REV00 and REV01 are required. Theoretical REV02,
prototypes, modifications, compilations and lock-on builds are excluded. Nothing
downloads a ROM. Extracted inputs live under ignored data/; all generated
outputs live under ignored build/. Bare make displays the available commands.

The aggregate preservation command is `make release-check`. It includes lint,
ROM-free tests, verified inputs, clean canonical builds, byte identity,
relocation, MAME comparisons, repository audits and a clean-tree check. It is
expected to remain red until all declared release requirements are satisfied.
The 2.0 aggregate builds on that same preservation gate.

## Working with the source

Read [the documentation index](docs/index.md),
[contribution rules](CONTRIBUTING.md), [runtime evidence](docs/runtime.md), and
[provenance](docs/provenance.md#upstream-disclaimer). Editing tools belong
outside this repository; there is no bundled GUI or external editor project.
Music and effects are stored inputs, not assembler content. Codecs and format
contracts describe how legal private assets can be inspected and edited.

The original game code and data remain the rightsholder's property. Upstream
annotations have no granted source license; the disclaimer is not a license.
Licensing of newly written project tooling is explicitly unassigned. AS and the
adapted authentic Saxman implementation carry their own notices. See provenance
for the separate statuses; no game-content redistribution rights are granted.

## Reviewed symbol evidence

Confirmed names and explicit uncertainty are documented in
[symbol meanings](docs/symbols.md). The preservation aggregate checks the single
rename registry, every remaining address-derived global and both compiled symbol
tables. Source layout and content authoring remain the separate 2.0 scope.

## Private content

The bounded byte APIs and format contracts are described in
[content workflow](docs/content_workflow.md) and
[formats](docs/data_formats.md). Prepare the pinned public Core CLI with
`make prepare-core CORE_SOURCE="path/to/core"`, then run
`make roundtrip-formats` or `make check-content-zero-edit`. The complete 2.0
structure, corpus and aggregate acceptance follows separately.
