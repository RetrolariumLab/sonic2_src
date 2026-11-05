# Known limits and resolved investigations

Each item has a stable ID and an explicit control. An implemented command is not
a substitute for its recorded passing evidence.

| ID                  | Status              | Limit and control                                                                                                                                                                                                                                                   |
| ------------------- | ------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| S2-AS               | partial             | Shared AS build 212 truncates the original long trampoline macro argument lists. The two hash-pinned AS build-313 binaries are a documented temporary fallback; shared p2bin is used unchanged.                                                                     |
| S2-LINUX            | unverified          | A Linux x86-64 assembler is pinned, but the full preservation/runtime gate has only been exercised on Windows. Linux is not claimed supported.                                                                                                                      |
| S2-RUNTIME          | partial             | Original RAM goldens cover a 60000-frame attract cycle with EHZ two-player and CPZ/ARZ/CNZ demos. Additional controller routes cover character selection, pause/resume, versus play and one special stage; endings and exhaustive gameplay remain outside coverage. |
| S2-PROBE            | controlled          | The 2 MiB experimental probe preserves the original logical checksum extent, original sound layout and two CNZ code-as-data dependencies. It is not a general ROM-expansion feature or a hardware test.                                                             |
| S2-UPSTREAM-LICENSE | license_not_granted | The upstream disclaimer grants no annotation/source license. Original game code and content remain the rightsholder's property.                                                                                                                                     |
| S2-TOOLS-LICENSE    | unassigned          | Licensing of newly written project tools/documentation has not been assigned. External AS and Saxman notices are separate; no project-wide license is inferred.                                                                                                     |
| S2-LAYOUT           | accepted            | The semantic split has 425 modules with bounded inline and shared source data, complete original-source fingerprints, preserved symbol values and canonical/probe byte checks. The complete 2.0 aggregate verified this evidence.                                   |
| S2-CONTENT          | accepted            | Every registered private input and source ledger passes the public zero-edit workflow for both revisions. The complete 2.0 aggregate verified this evidence.                                                                                                        |

REV02 is excluded because no supplied real original image matched its
theoretical identity. Prototypes, modifications, compilations, lock-on and
alternate editor projects are excluded scope rather than silently accepted
profiles.

## Unresolved symbol meanings

[Symbol meanings](symbols.md) describes the canonical rename evidence and the
explicit unknown ledger. Every remaining address-derived global entry has
revision-specific physical bounds, known role, unresolved meaning, reason and
next investigation. Confirmed routines and typed structural identities are
renamed; internal continuations with incomplete entry-state contracts remain
unknown. Neither zero address-style names nor complete gameplay coverage is
claimed by the naming gate.

## Controlled format differences

The pinned Core Enigma decoder disagrees with the S2 retail engine. The local S2
decoder plus Core encoder is the explicit project backend; Core is left
unchanged. Re-encoded streams are checked locally, and original 68000 decoder
experiments supplied additional development evidence. This is not a claim that
the public dependency's decoder has been repaired.

Nemesis and Enigma compressed bytes are not reproduced by their current
encoders. Kosinski is checked for semantic equivalence. Unchanged decoded
content retains the original compressed stream; edits must fit the original
slot. These policies are documented limits, not opaque codec exemptions.

## Resolved development investigations

ROM-only audio generation now reproduces the original compressed driver and all
music inputs without tracked song/SFX data. Thirteen PSG inputs are derived from
the private driver image. The corrected import excludes this audio content from
every ancestor of the candidate; the all-ref detector remains mandatory.

Special-stage track mappings are three cooperating bitstreams with engine LUT
expansion, not an ordinary tilemap. The codecs preserve their bit tails and
validate full row capacity. Assembly-owned sprite gaps, shared animation
scripts, the existing `Ani_obj52` cursor hazard, the ARZ protected block tail
and the HTZ overlay are explicit contracts in [formats](data_formats.md) and
[architecture decisions](architecture_decisions.md).

The source message-phrase table has two original out-of-range word selectors in
its final phrase. They remain explicit retail exception cells; the format codec
rejects newly introduced invalid selectors. The original background scroll
sample `0xFF` is zero-extended by the engine. The special-stage DPLC format also
mixes counted and headerless frames with source-word offsets. See
[formats](data_formats.md) for the exact representation and limits.
