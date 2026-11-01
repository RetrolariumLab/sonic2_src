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
5. Numeric pointer/fixed-region audit and fresh relocation builds.
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

The corrected import excludes private audio content from the complete candidate
history. Every reachable ref must still pass the normal privacy detector. A
passing byte build, focused test or runtime run is recorded as its own evidence
and never substituted for the complete clean-clone aggregate.

The project creates no tags or pushes. An owner may review a clean passing
candidate and create their release tags separately. Rewritten draft candidates
are checked in an isolated fresh clone so retained review refs do not masquerade
as part of the publishable series; the source repository remains unaccepted
until its old forbidden refs are removed with the required approval.

## Symbol and release contracts

After canonical verification, the aggregate checks reviewed names and explicit
unknown ranges against current source fingerprints and both compiled symbol
tables, before relocation and runtime execution. `make semantic-symbols-check`
runs this focused compiled check.

Release readiness validates requirement states, actual evidence files and Make
targets, profile artifact identities, direct runtime scenario IDs, supported
host fields, tool pins and deviation paths. `make clean` removes only canonical
and relocated profile directories and rejects redirected paths; private inputs,
workspaces and backups remain.

No tags are created by the project. After the owner creates an annotated tag at
this candidate, `make release-tag-audit LINE=1.0` inspects its type, target and
manifest. Tests inspect synthetic responses without creating refs.
