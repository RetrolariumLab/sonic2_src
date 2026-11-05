# Sonic the Hedgehog 2 (SMD) Source Reconstruction

A byte-identical source reconstruction of **Sonic the Hedgehog 2** for the Sega
Mega Drive / Genesis, maintained as a fork of
[Sonic Retro's Sonic 2 disassembly](https://github.com/sonicretro/s2disasm). The
shared 68000 and Z80 source rebuilds retail REV00 and REV01 from legally
obtained reference images.

The fork starts from the upstream master branch at
[`4ef457c`](https://github.com/sonicretro/s2disasm/commit/4ef457c18fc4902396c43ab06fabc119ac6ecb64).
Its Git history begins with a text-only snapshot import; the original authors
are credited in [CONTRIBUTORS.md](CONTRIBUTORS.md).

## Status

[Source Reconstruction 1.0](https://github.com/RetrolariumLab/sonic2_src/tree/source-reconstruction-1.0)
establishes the byte-identical build, reviewed symbol evidence, symbolic address
checks, relocated-source probes and original-ROM runtime comparisons.
[Source Reconstruction 2.0](https://github.com/RetrolariumLab/sonic2_src/tree/source-reconstruction-2.0)
adds:

- 425 source modules organized by subsystem and semantic owner;
- shared REV00 and REV01 profiles, with REV01 as the default;
- 44 registered format IDs with bounded, revision-aware contracts;
- round trips for 695 private inputs and 1580 source-ledger checks;
- two byte-identical rebuilds from a zero-edit content export;
- direct attract RAM checks in MAME for both revisions, including two-player
  gameplay.

The entry point is `src/main.s`. Data extracted from the ROM stays in ignored
`data/`; generated ROMs, listings, reports and scratch files stay in ignored
`build/`. ROM images, extracted graphics, music, effects and samples are not
distributed with this repository. Confirmed names and remaining unknowns have
separate [reviewed evidence](docs/symbols.md); complete reverse engineering is
not claimed.

The release tags identify fixed, checked snapshots. Main may contain later
maintenance and documentation changes. Current main also checks four
original-ROM controller routes on canonical and relocated images, proves two
palette edits in rebuilt ROMs, and binds complete acceptance to the actual
public inputs and generated artifacts. See [validation](docs/validation.md).

## Quick start

The supported host is Windows x64 with Python 3.10+, Git, GNU Make and the
pinned Retrolarium Kit and Core dependencies. Runtime checks also need MAME
registered with `rltool movie mame`. See [building](docs/build.md) for
installation and version checks.

Sonic 2 uses the exact external AS Macro Assembler build 313, downloaded and
hash-checked into ignored `build/tools/as-313/`. Kit supplies p2bin and its
authentic driver compression. Compiler executables are not stored in Git.

```sh
git clone https://github.com/RetrolariumLab/sonic2_src.git
cd sonic2_src

# Keep your legally obtained dumps in a separate folder.
# The importer identifies both accepted images by size and hashes.
make split ROM_DIR="path/to/dumps"
make verify-all
```

Each verification compares the rebuilt image byte for byte with the supplied ROM
and checks its SHA-1 and SHA-256. Both reference images are required for
extraction. Supported profiles are:

| Profile | Reference image       | Selection               |
| ------- | --------------------- | ----------------------- |
| `rev00` | Original retail REV00 | `REV=rev00`             |
| `rev01` | Revised retail REV01  | Default, or `REV=rev01` |

Stored filenames, sizes and hashes belong to `assets/manifest.json`. REV02,
prototypes, modifications, compilations and lock-on builds are excluded. A Linux
assembler is pinned, but the full Linux gate has not been validated.

## Build and verify

```sh
make help                         # Show the public command catalog
make check-assets                 # Check every extracted and derived asset
make build REV=rev01               # Assemble the selected revision
make verify                       # Build and compare the default revision
make verify REV=rev00
make verify-all                   # Build and compare both revisions
make clean                        # Remove profile outputs; keep private data
```

Outputs are written to `build/<profile>/sonic2.bin`. The 68000 source and Z80
driver assemble together. The build retains the original Saxman driver
compression, header and checksum rules, including original revision behavior.

```sh
make format                       # Apply the project style, then lint
make lint                         # Check source, code and text style
make test                         # Run the Python tooling tests
make scaffold-check               # Check static contracts without ROMs
make check-private-data           # Audit the tree and all reachable history
make pointer-audit                # Check address expressions and fixed regions
make semantic-symbols-check       # Check reviewed names against both listings
make source-layout-check          # Check source ownership and data inventory
make documentation-check          # Check the linked corpus and review hashes
make build-relocated              # Build the controlled relocation probes
make runtime-check                # Compare their RAM traces in MAME
```

Symbol and runtime checks need current builds and extracted inputs. MAME runs
are sequential. Each recorded scenario covers a 60000-frame attract cycle,
including EHZ two-player and CPZ/ARZ/CNZ demos. Special-stage gameplay, every
stage, ending and menu path, and every instruction are outside that coverage.
The relocation image is an experimental probe, not a general expansion profile.

## Content models

The headless models describe tiles, palettes, blocks, chunks, layouts,
collision, object and ring placements, mappings, DPLC, animations, paths,
special-stage data, demo input, SMPS and samples. Source-owned engine records
also include text, palette timing and object topology. Their revision, capacity
and address-space contracts are declared in `config/authoring/data_formats.json`
and explained in [data formats](docs/data_formats.md).

```sh
make prepare-core CORE_SOURCE="path/to/retrolarium-core"
make roundtrip-formats            # Decode and encode all registered content
make check-content-zero-edit      # Export content and rebuild both ROMs
```

Core preparation requires a clean checkout at the pinned commit, CMake and a C++
compiler. The [content workflow](docs/content_workflow.md) describes the pure
byte APIs, revision contexts, tool receipt and export contracts. There is no
bundled GUI or external editor project.

Unchanged decoded content retains the original compressed stream. Nemesis,
Enigma and Kosinski recompression is checked for semantic equivalence; authentic
Saxman reconstruction is checked for exact bytes. Edited payloads must fit their
original slots, banks and protected record contracts. The 2.0 baseline covers
bounded models and zero-edit rebuilds; a general edited-ROM composer is outside
this release. See [known limits](docs/unknowns.md) and
[architecture decisions](docs/architecture_decisions.md).

## Release checks

The complete 2.0 command first runs the full 1.0 preservation gate, including
fresh extraction, both original images, pointer and relocation checks, and MAME.
It then checks source ownership, all content round trips, zero-edit rebuilds,
documentation and the classified source history.

Gates apply to the exact committed tree. To check a current main candidate
without confusing it with the already published release tags, use a disposable
clone without tags:

```sh
git clone --no-tags https://github.com/RetrolariumLab/sonic2_src.git sonic2-check
cd sonic2-check
make scaffold-check

# Supply only your two verified ROMs at the paths in assets/manifest.json.
make source-2-check CORE_SOURCE="path/to/retrolarium-core"
```

The aggregate extracts its own private inputs and rejects changed existing
preservation assets before writing. `make release-check` and
`make source-1-check` run the common preservation guarantee set;
`make source-2-audit` is an alias for the full 2.0 aggregate.

To inspect a published milestone, check out its annotated tag and run
`make release-tag-audit LINE=1.0` or `LINE=2.0` for that milestone. This check
compares HEAD with the tag target; it is not intended for a later maintenance
commit. [Validation](docs/validation.md) describes the commands, dependencies,
evidence and retained coverage limits.

## Repository map

```text
assets/                 Reference image identities and extraction manifest
config/authoring/       Content formats, capacities and revision contracts
config/reconstruction/ Source origins, ownership, symbols and fixed regions
docs/                   Architecture, formats, workflows and evidence
mk/                     Build, runtime, validation and content Make targets
scripts/authoring/      Headless models, codecs and bounded export APIs
scripts/build/          Extraction, assembly and byte-identity checks
scripts/runtime/        MAME execution and runtime validation
scripts/validation/     Static, source-layout and release audits
src/                    Shared 68000/Z80 source, definitions and data declarations
tests/                  Tests mirroring the script package layout
tests/runtime/          Original-input movie, RAM goldens and runtime tests
data/                   Ignored private inputs extracted from user ROMs
build/                  Ignored generated outputs, tool caches and local evidence
```

Start with the [documentation index](docs/index.md),
[architecture](docs/architecture.md), [source layout](docs/source_layout.md) and
[memory interfaces](docs/memory.md). See [CONTRIBUTING.md](CONTRIBUTING.md) for
the change and verification workflow.

## Credits

- Original game: SEGA, 1992.
- Original disassembly and community work: Sonic Retro and the
  [upstream contributors](CONTRIBUTORS.md).
- AS Macro Assembler: Alfred Arnold.
- Authentic Saxman encoder: Haruhiko Okumura and Clownacy.
- Build and codec dependencies: Retrolarium Kit and Retrolarium Core.
- Runtime validation: MAME.

The import revision, removed optional modifications, tool origins and
attribution boundaries are recorded in [provenance](docs/provenance.md).

## Copyright and licensing

Original game copyright (C) 1992 SEGA. Game code, graphics, music and other game
data remain the property of their respective rights holders.

This repository does not distribute ROM images or extracted copyrighted assets.
Users supply their own legally obtained reference images. No licence to the game
or the imported upstream annotations is granted by this project. Licensing of
new project tools and documentation remains unassigned; external components
retain their separate notices in [provenance](docs/provenance.md). The original
Sonic Retro disclaimer is retained below, including its original spelling.

# DISCLAIMER

Any and all content presented in this repository is presented for informational
and educational purposes only. Commercial usage is expressly prohibited. Sonic
Retro claims no ownership of any code in these repositories. You assume any and
all responsibility for using this content responsibly. Sonic Retro claims no
responsibiliy or warranty.
