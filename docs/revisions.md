# Revisions and scope

`config/revision_profiles.json` owns accepted profile IDs, defines, output paths
and the default revision. `assets/manifest.json` owns legal input identities and
extraction slices. The source does not duplicate those hashes in another profile
table. Both profiles passed the complete preservation and 2.0 gates with clean
reachable history. Runtime coverage remains limited to the declared scenario.

| Profile | Engine selection   | Verification                                                                      |
| ------- | ------------------ | --------------------------------------------------------------------------------- |
| `rev00` | `gameRevision = 0` | Direct original-image byte comparison and direct relocated MAME golden comparison |
| `rev01` | `gameRevision = 1` | Direct original-image byte comparison and direct relocated MAME golden comparison |

Both profiles enter `src/main.asm` and share the same engine modules. The
original revision conditionals remain in place; community modification switches
do not. A path selected only in one profile is still registered as a private
input. Fresh AS listing consumers determine the selection and addresses for each
run.

Runtime coverage uses the same scenario contract for each revision and that
revision's own original-ROM goldens. The attract sequence includes normal and
two-player gameplay. Coverage does not rely on an inferred equivalence between
REV00 and REV01. Exact snapshots are compared without tolerances or injected RAM
corrections. Runtime evidence is generated separately from content reports. See
[runtime](runtime.md).

REV02 remains unsupported because no supplied original image matches the
proposed identity. A theoretical assembler switch is not evidence of an accepted
retail revision. Prototypes, modifications, compilations and lock-on variants
are outside scope. Their exclusion is recorded in the profile file; no
fabricated input or copied engine is used to expand the accepted set.

The source preserves original behavior, including the REV00 intentional crash
path and unusual original lookups documented in [unknowns](unknowns.md). An
optional relocation probe may make those code addresses move, but it must
preserve the values that original code actually reads and its boot timing.
