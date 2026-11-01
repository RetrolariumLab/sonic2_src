# Reconstruction boundary

The integrated candidate builds the accepted retail REV00 and REV01 images from
one engine and verified user ROMs. Its accepted preservation baseline is owned
by the predecessor entry in `config/source_reconstruction_2_0.json`; source
ranges refer to that same commit. No release tag is claimed or created.

The preservation boundary remains the full `make release-check`: legal inputs,
byte identity, source-only history, symbolic pointers, controlled relocation,
direct per-revision MAME goldens, licensing/provenance, clean tree and stop-word
checks. The 2.0 gate executes that implementation first on every invocation.
Previously saved reports cannot replace its execution.

The integrated delta adds semantic source ownership, original range proofs,
content format contracts and bounded byte APIs, complete zero-edit rebuilds,
revision ABI declarations, independent source-data inventory and a linked
reviewed documentation corpus. Shared tables retain one physical owner. There is
no GUI or external editor project in this repository.

`make source-2-check` is the complete acceptance command. It requires the exact
accepted predecessor, every substantive commit classified once, resolved source
table reviews, current runtime/content evidence, a reviewed corpus and clean
reachable history and working tree. Its success report is published only after
the entire run passes. The complete fresh-clone result has passed; the manifest
records checked readiness and retained limits. Later changes require the same
complete gate.

Retained limitations include the pinned AS fallback, unverified Linux aggregate
support, attract-only gameplay coverage, original-stream retention for semantic
compression, the unchanged Core Enigma decoder limitation and unresolved
source/tool licensing. See [known limits](unknowns.md),
[formats](data_formats.md) and
[architecture decisions](architecture_decisions.md). Tags remain owner-only.
