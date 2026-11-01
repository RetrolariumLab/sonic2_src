# Symbol meanings and uncertainty

The naming requirement distinguishes confirmed meanings from unresolved ones. A
byte-identical build alone cannot establish either. The canonical
[rename registry](../config/reconstruction/label_renames.json) records every
confirmed change. The separate
[unknown ledger](../config/reconstruction/unknown_symbols.json) accounts for
every remaining address-derived global declaration, including address-derived
`BranchTo` adapters. These files are evidence owners, not alternative source
definitions.

Each rename includes its original and current name, a specific reason and the
source contract used to justify it. Structural names state only the proven
representation: an indexed animation sequence, sprite frame, child template,
literal text, counted loop or terminal return. Frame numbers identify an actual
table index; they do not invent a pose or gameplay story. Procedure names
describe observed operations and callers, such as VDP command construction,
player contact updates or boss damage handling.

Examples include `sub_15792` to `TitleCard_MakeVramWriteCommand`, `sub_40984` to
`HUD2P_DrawThreeDigits`, `loc_175EA` to `CnzBumper_CalculateReflectedLaunch`,
and `byte_3E32A` to `DeathEggRobot_LimbMotion1_Frame0`. Consult the registry for
the exact proof, rather than treating these examples as a second mapping.

The registry binds every source declaration, including conditional alternatives,
to a normalized instruction/data fingerprint. Both accepted profile values are
recorded. Source-derived frame payload markers and qualified local scopes follow
their reviewed parent; their provenance and values are recorded separately.
Assembler-generated `JmpTo` names retain the assembler's suffix extraction
protocol. A named trampoline to `DeleteObject` already states its role and does
not become unknown merely because its name contains `JmpTo`.

Each unknown states its source owner, observable structural role, unresolved
meaning, reason for uncertainty and a concrete next investigation. Its physical
extent is recorded separately for each profile, with a following symbol or
active include boundary. An alias may have an empty extent. These are source
declaration bounds, not claims about the full transitive control-flow graph.
Reserved RAM fields use their own address space and declared bounds. AS can
print negative RAM constants as unsigned 64-bit symbol values. The ledger
preserves that exact assembler value while recording the physical RAM range with
an explicit 24-bit mask; it never presents a sign-extended integer as a physical
68000 address.

Most remaining `loc_*` names identify internal continuations whose complete
entry state and distinct gameplay intent have not been established. Some data
entries have a known representation but unconfirmed units or consumer intent.
Retaining an explicit unknown is preferable to asserting a purpose from the
first instruction. The ledger is a work queue, not a claim of complete reverse
engineering. Short lexical loop labels, object dispatch IDs and meaningful
target-named adapters are separate naming conventions.

`make semantic-symbols-check` checks complete coverage, unique mappings,
fingerprints, structural claims, both compiled symbol tables and range end
markers. The preservation aggregate executes it after fresh canonical builds and
before relocation or runtime checks. Negative tests reject omitted unknowns,
stale review, invented loop roles, missing revision evidence and moved symbols.
Human review remains necessary when establishing a new meaning: the validator
binds a reviewed assertion to code; it cannot infer gameplay intent.

Before recording a new confirmed meaning, inspect every caller or incoming edge,
the relevant continuation and data consumer. Rename exact identifier tokens,
update the single registry and remove its unknown record. Rebuild both profiles,
preserve original symbol values through the mapping, update source fingerprints
and repeat the complete aggregate before declaring readiness.
