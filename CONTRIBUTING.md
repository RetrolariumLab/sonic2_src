# Contributing

Use your own accepted ROM images. Never add ROMs, extracted assets, audio
bytecode expressed as assembler, screenshots or generated build outputs to Git.
The single private-data root is data/; temporary and generated work belongs in
build/. No binaries may be tracked, including external compilers. Run make
check-private-data to audit both the current tree and all reachable history.
Removing a forbidden file later does not erase its historical blobs.

Keep tracked code, comments, documentation, JSON and commit messages in English.
Preserve upstream attribution. Use the configured owner identity and truthful
co-author credit. Do not create tags or push as part of an automated change.

Keep preservation changes separate from source moves and mechanical formatting.
Rebuild and byte-compare both accepted profiles after each source/build commit.
Do not introduce community fixes or optional optimization modes into the
original profiles. A deliberate authoring change needs its own declared contract
rather than silently changing preservation bytes.

Use make format for the shared style tools and make lint for a read-only check.
Never edit generated relocation sources or golden expected values to hide a
failure. Runtime goldens come only from verified original inputs. Run emulator
jobs sequentially and leave other projects' processes alone.

Before proposing acceptance, run make release-check and the applicable 2.0 gate
from a fresh clone with only the required private inputs supplied. Record the
actual command results and limits. Do not call a partial result complete.
Unpublished history repair requires an approved commit map before rewriting;
keep main as the reference until the rewritten series has been reviewed.
