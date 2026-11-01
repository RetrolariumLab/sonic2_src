# Content workflow

The content APIs and commands are integrated into this candidate. Content checks
remain separate from history, runtime and complete release acceptance. See
[validation](validation.md) for the preservation requirements.

The repository supplies formats, pure codecs and bounded export contracts.
Private game content comes from a verified user ROM. There is no GUI editor and
no project for an external editor. Generated data stays in `build/`; extracted
inputs stay in the manifest's ignored output root.

## Prepare

Run `make split ROM_DIR="path/to/your/roms"` and `make verify-all` first. The
accepted inputs and profile defines are owned by `assets/manifest.json` and
`config/revision_profiles.json`; do not copy those values into a local script.

Content compression uses the public Core source pinned in
`config/toolchain.json`. Provide a clean checkout at that commit:

```sh
make prepare-core CORE_SOURCE="path/to/retrolarium-core"
make roundtrip-formats
make check-content-zero-edit
```

CMake and a C++ compiler are required for the first command. When necessary,
select an installed generator with `CMAKE_GENERATOR="generator name"`. The tool
builds outside the dependency checkout under `build/tools/core` with one build
worker. A receipt binds its executable hash, source commit and version. The
dependency checkout is checked before and after building and is never edited. A
later invocation reuses only the validated executable. Set `CORE_SOURCE` on a
content command to prepare a missing tool automatically.

## Public byte APIs

`scripts.authoring.catalog.codec(path, context)` returns a pair of pure
`decode(bytes)` and `encode(model)` functions. Format records use
JSON-compatible integers, Booleans, lists and dictionaries. They expose flags,
aliases, gaps and reserved bits instead of silently normalizing original bytes.

Context-dependent formats need the canonical engine context:

- SMPS needs its Z80 base, declared external typed references and the events of
  other tracks in the same bank.
- Special-stage objects need the dynamic object slot count.
- Special-stage track mappings need the original literal/run LUTs and flags.
- Chunk maps need the live block RAM capacity.

`scripts.authoring.contexts` derives those facts from fresh canonical assembly
symbols and the verified ROM. `scripts.authoring.source_data` attributes listing
rows to their include files and finds the physical consumers of private inputs.
Extraction offsets in the asset manifest are not export addresses. One asset may
be included several times or selected only by one revision.

For export, open a `Document` with a frozen `Target`. A target identifies the
asset, format, revision ABI, address space, original destination, encoded and
decoded capacities, bank policy and any protected ranges. `Document.encode`
rejects incompatible targets and widened allocations before returning bytes. It
never writes files. A caller must publish the returned bytes only after all
checks succeed. Low-level record codecs intentionally do not choose ROM slots.

Unchanged decoded content retains the original compressed stream. Changed
content requires an encoder and must still fit the original encoded slot and
bank. Nemesis and Enigma recompression is checked for semantic equivalence;
original compressor choices are not claimed to be reproducible. Authentic Saxman
is checked for exact compressed bytes, including the driver's explicitly
retained retail trailer. See [formats](data_formats.md).

## Complete checks

`make roundtrip-formats` freshly builds and verifies every accepted revision,
checks every private input and its actual listing consumers, runs structural
round trips, tries every compression encoder, resolves external audio and
animation references, and checks all registered assembly-owned content ledgers.
Source-wide table inventory is checked independently against registered models;
any pending review prevents full 2.0 acceptance.

`make check-content-zero-edit` performs that same work, then creates a separate
build view under `build/authoring/zero-edit/project`. It copies public source
and pinned assembler files, writes round-tripped private streams, derives PSG
inputs, and rebuilds every accepted revision against the user image. The view
contains no Git history or dependency source checkout. Source files in the
calling repository must remain unchanged.

Reports are `build/authoring/roundtrip-formats.json` and
`build/authoring/content-zero-edit.json`. An old report for the requested
command is removed before any work starts; a successful report is published
atomically only after all checks pass. Reports record source hashes, revision
consumers, compression evidence, dependencies and exact output identities.
Content checks are prerequisites for 2.0 acceptance, not substitutes for the
complete preservation, runtime, history and clean-tree checks.

Assembly-owned indexed records use the profile document target plus immutable
source slots. Shared sprite/DPLC tables instead use `frame_views.Document`,
which owns all participating selector tables and complete physical frames as one
model. It emits named byte patches. `frame_views.apply` validates the whole
patch set, including shared-cell agreement, before returning a modified byte
view. Neither API writes to source files or replaces canonical private inputs.

`source_data.mapping_document` opens an ordinary assembly-owned sprite or DPLC
ledger from a fresh canonical context. Its frozen handler additionally binds
DPLC source-art bounds and each original frame's transfer window. A legal-width
pointer or tile count is insufficient when it leaves those allocations.
Special-stage shared frame views bind corresponding per-selector source RAM
partitions and VRAM transfer budgets. See [formats](data_formats.md).

The complete aggregate also supports a ROM-only checkout through
`make source-2-check CORE_SOURCE="path/to/retrolarium-core"`. Its preservation
implementation owns extraction and refuses to overwrite changed existing
preservation assets. Standalone content commands retain the preparation workflow
above; the aggregate does not rely on it being run beforehand.
