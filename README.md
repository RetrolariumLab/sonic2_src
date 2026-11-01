# Sonic the Hedgehog 2 Source Reconstruction 2.0

This repository is an independently maintained source reconstruction fork of
[Sonic Retro's Sonic 2 disassembly](https://github.com/sonicretro/s2disasm),
based on its master branch at
[`4ef457c`](https://github.com/sonicretro/s2disasm/commit/4ef457c18fc4902396c43ab06fabc119ac6ecb64).
The upstream work is represented by a text-only snapshot import into a new Git
history. Credit for the original disassembly and community work belongs to the
[upstream contributors](CONTRIBUTORS.md).

This project reconstructs the original Mega Drive retail REV00 and REV01 images
from source code and the user's own verified ROMs. REV01 is the default profile.
It contains no distributable ROM, music, sound effects, graphics or extracted
binary game assets. The upstream
[disclaimer](docs/provenance.md#upstream-disclaimer) is preserved.

Complete acceptance requires the Source Reconstruction 2.0 gate from a fresh
clone: run scaffold before supplying ROMs, then supply only the two verified
ROMs. The aggregate checks both retail images, relocation/runtime evidence,
content, source structure, reviewed names and explicit unknowns, documentation
and reachable history. Reports apply to the exact checked tree. No release tag
is claimed or created.

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
relocation, MAME comparisons, repository audits and a clean-tree check. Every
declared preservation requirement must pass in that same run. The complete 2.0
command is `make source-2-check`; it runs that preservation gate first.
`make scaffold-check` checks static contracts and synthetic fixtures without
ROMs. Semantic source, content and release tooling are integrated; the complete
clean-clone 2.0 gate remains the final acceptance command.

From a clean clone, place the verified ROMs at the manifest paths and run
`make source-2-check CORE_SOURCE="path/to/retrolarium-core"`. The aggregate
extracts the declared private inputs itself and prepares the pinned Core tool
when needed. Existing changed preservation assets are rejected before any
extraction write. The split command above remains the optional ROM-folder import
convenience.

## Working with the source

Read [the documentation index](docs/index.md),
[contribution rules](CONTRIBUTING.md), [runtime evidence](docs/runtime.md), and
[provenance](docs/provenance.md#upstream-disclaimer). Editing tools belong
outside this repository; there is no bundled GUI or external editor project.
Music and effects are stored inputs, not assembler content. The
[semantic layout](docs/source_layout.md) and
[content workflow](docs/content_workflow.md) describe source ownership and the
commands `make roundtrip-formats` and `make check-content-zero-edit`. Prepare
the pinned Core CLI first with `make prepare-core CORE_SOURCE="path/to/core"`.
Formats and bounded byte APIs describe how legal private content can be edited.

The original game code and data remain the rightsholder's property. Upstream
annotations have no granted source license; the disclaimer is not a license.
Licensing of newly written project tooling is explicitly unassigned. AS and the
adapted authentic Saxman implementation carry their own notices. See provenance
for the separate statuses; no game-content redistribution rights are granted.
