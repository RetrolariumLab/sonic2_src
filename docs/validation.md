# Validation

`make release-check` (also `make source-1-check`) owns the common preservation
guarantee set. Later reconstruction gates call this same implementation first.
It runs fail-fast in this order:

1. Shared repository/configuration lint.
2. ROM-free tool tests, including the full reachable-history privacy detector.
3. Accepted legal input identities and executable tool pins, followed by fresh
   extraction of the declared preservation assets. Changed existing assets are
   rejected before any extraction write.
4. Removal of canonical/probe output directories and clean builds of both
   profiles, followed by size, every-byte and full-hash identity checks.
5. Reviewed symbol names, explicit unknowns and compiled-value/range checks;
   numeric pointer/fixed-region audit and fresh relocation builds.
6. Serialized MAME checks against complete original goldens for both profiles.
7. Required documents, licensing/provenance references, history ownership,
   nonempty commits, monotonic dates, privacy and clean working-tree audit.
8. Core stop-word audit over all reachable refs.

The gate deletes only declared profile outputs under build/, after checking that
they resolve inside the project. It never removes data/ or unrelated research.
Every AS object and flattened image is independently refreshed by the build.
Generated wrappers and derived inputs have explicit owners and hash checks.
Fresh-clone acceptance is still required to prove the absence of hidden local
inputs. Keep full emulator runs sequential across projects.

Useful focused commands are make verify-all, make test, make lint, make
pointer-audit, make build-relocated, make runtime-check and make
check-private-data. Reports live in ignored build/. The runtime validator
requires every cell at every checkpoint and checks AS-resolved addresses;
missing expected data cannot turn a failed or partial run green.

The Core Python package must be importable by the Python used for the gate's
stop-word history command. Install the public dependency or expose its python/
directory through PYTHONPATH. Kit is invoked through rltool; project Python does
not import Kit's isolated environment. config/toolchain.json records the public
source pins and checks the compiler/p2bin executable identities.

The corrected series passed both the preservation and complete 2.0 gates from
fresh clones, including the all-ref privacy detector. Focused byte, test,
content and runtime results remain separate evidence; future candidates must
repeat the complete aggregate rather than infer acceptance from those parts.

The project creates no tags or pushes. An owner may review a clean passing
candidate and create their release tags separately. Rewritten draft candidates
are checked in an isolated fresh clone. The final source checkout must also pass
the all-ref privacy audit; retained review refs are not an exemption.

## Content and source-layout checks

`make roundtrip-formats` validates every registered private input, each active
revision placement, context-bound serialization, compression semantics and
assembly-owned sprite/DPLC, animation, path, indexed record, palette timing,
demo and typed engine-record ledgers. `make check-content-zero-edit` also writes
a separate build view and reconstructs both complete original images. Neither
command claims release acceptance. See [content workflow](content_workflow.md)
for the exact APIs, preparation and report paths.

The semantic source registry owns every assembly module and include edge.
Canonical byte identity, relocation byte equality, original source-coordinate
coverage and preserved symbol values are separate evidence. A source move must
also keep imports, manifests, runtime paths, Make commands and documentation in
sync. The larger data ledgers have explicit machine-checkable size exceptions.

The complete 2.0 aggregate must call the full preservation gate first, then
validate source structure, content, profiles, documentation and release state.
It cannot report success when the predecessor gate is unavailable or red.
Scaffold checks and ROM-free tests are useful early checks; they do not replace
that final clean-clone run.

## Public static and aggregate entry points

`make source-layout-check` validates actual module bytes, continuous original
source ranges, include reachability, large-ledger grammar, the single rename
registry and an independent inventory of data tables. Pending table reviews are
reported explicitly. `make documentation-check` checks the complete corpus,
local links/anchors, reader reachability and the separate substance-review
ledger. Neither static command claims that pending implementation is accepted.

`make scaffold-check` runs those static contracts, checks the real Make/help
interface, and executes pure authoring tests plus synthetic structure, corpus,
release-command and predecessor tests. The full `make test` suite additionally
checks actual reachable project history. A passing scaffold does not waive that
audit or require a private ROM.

`make source-2-check` and its `source-2-audit` alias execute the full
preservation implementation first. Fresh identity, runtime and relocation
evidence must cover every accepted profile. The delta then checks the exact
predecessor source fingerprints, content, corpus and complete nonempty Git
delta. Pending source tables, unreviewed docs, old private history, stale
reports or a dirty tree keep this command red. Its success report is removed
before each invocation and published only after the complete run passes.

## Names, release values and output ownership

`make semantic-symbols-check` requires current canonical listings and validates
the [symbol evidence](symbols.md). The ROM-free scaffold validates declaration
coverage and source fingerprints; it cannot replace compiled symbol checks.
`source-layout-check` additionally audits every data-emitting macro against its
content or program role, so a missing content category cannot hide behind the
existing artifact names.

Release requirements use stable IDs and the states `satisfied`,
`not_applicable`, `partial`, `unsupported` or `planned`. Non-satisfied entries
need a reason; a ready aggregate rejects open requirements. Evidence files, real
public targets, profile artifacts, direct runtime scenario IDs, host/tool pins
and deviation paths are checked as values. Source 2.0 explicitly inherits the
canonical preservation contract instead of duplicating those facts.

`make clean` removes only `build/<profile>` and `build/relocated/<profile>`. It
rejects redirected output paths and links to other workspaces. ROM inputs,
`data/`, dependency builds, worktrees, research and backups remain available.

The project does not create tags. After the owner creates an annotated tag on
the checked candidate, `make release-tag-audit LINE=1.0` or `LINE=2.0` checks
its object type, target commit and tagged manifest. A lightweight tag, wrong
target or stale manifest fails. Before tagging, `make release-audit` and the
full aggregate remain the acceptance interface. Tests inspect synthetic tag
responses without creating project tags.

## Numeric pointer coverage

`make pointer-audit` checks absolute numeric memory operands, address operands
of `lea`, `pea`, `jmp` and `jsr`, numeric ROM-range `dc.l` entries and immediate
word/long loads into `a0` through `a7` or `sp` with `move` or `movea`. Numeric
`equ`, `=`, `:=` and `set` chains are collected across the configured sources;
forward references, local scope, integer arithmetic and bit operations are
resolved without executing assembler expressions. Cyclic, oversized or
unsupported numeric expressions cannot silently supply a pointer owner. Word
address-register loads use sign extension and addresses use the 24-bit bus.
Named RAM and hardware addresses remain separate from the accepted ROM range.

Some address registers hold collision dimensions or decompression counters.
`config/reconstruction/fixed_regions.json` records 16 reviewed scalar patterns
covering 20 loads. Every exception binds its source, lexical owner, instruction,
expression, destination register, resolved value and occurrence count, with a
reason tied to its consumer. Changing or removing a load fails the contract; the
same literal in another location is not exempt. The original deliberate crash
symbol is a separate exact-value exception. Decimal place values retain their
existing bounded table contract.

This is a bounded static audit of the listed positions. Named assembler
functions and expressions derived from relocatable labels remain compiler
expressions; the audit does not implement the full AS language, track register
arithmetic or prove every runtime dereference. Fresh compiled fixed-region,
relocation, identity and runtime checks remain independent requirements. A
failed pointer audit removes its prior success report before checking sources.
The ROM-free scaffold includes the pointer regressions.

## Current acceptance evidence

The complete 2.0 aggregate includes the real edited-ROM proof and all extended
controller routes. Successful reports bind the complete tracked and unignored
public input tree, including documentation and tests. They also bind the actual
ROMs, listings, runtime logs and subordinate reports by SHA-256. Preservation
listings are saved as stage-owned evidence because later canonical reassembly
refreshes AS listing timestamps. Final acceptance additionally binds the current
canonical listings and both private export workspaces.

`make acceptance-audit` checks the completed current-commit aggregate, its exact
artifacts, subordinate reports and full extended runtime matrix. Changing a
public input, replacing a generated output or removing a scenario invalidates
the result. A failed rerun removes the previous success report before work
starts. This re-audit does not replace a fresh complete gate for changed inputs.
GNU Make stages are serial even when invoked with `-j`.
