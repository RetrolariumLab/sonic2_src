# Known limits and acceptance blockers

Each item has a stable ID and an explicit control. An implemented command is not
a substitute for its recorded passing evidence.

| ID                  | Status              | Limit and control                                                                                                                                                                                       |
| ------------------- | ------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| S2-AS               | partial             | Shared AS build 212 truncates the original long trampoline macro argument lists. The two hash-pinned AS build-313 binaries are a documented temporary fallback; shared p2bin is used unchanged.         |
| S2-LINUX            | unverified          | A Linux x86-64 assembler is pinned, but the full preservation/runtime gate has only been exercised on Windows. Linux is not claimed supported.                                                          |
| S2-RUNTIME          | partial             | Original RAM goldens cover a 60000-frame attract cycle with EHZ two-player and CPZ/ARZ/CNZ demos. Special-stage play, every stage, menu paths and all instructions are not covered.                     |
| S2-PROBE            | controlled          | The 2 MiB experimental probe preserves the original logical checksum extent, original sound layout and two CNZ code-as-data dependencies. It is not a general ROM-expansion feature or a hardware test. |
| S2-UPSTREAM-LICENSE | license_not_granted | The upstream disclaimer grants no annotation/source license. Original game code and content remain the rightsholder's property.                                                                         |
| S2-TOOLS-LICENSE    | unassigned          | Licensing of newly written project tools/documentation has not been assigned. External AS and Saxman notices are separate; no project-wide license is inferred.                                         |
| S2-LAYOUT           | planned             | The imported 68000 source remains monolithic for the intermediate preservation point. Semantic module extraction, naming evidence and complete content contracts belong to 2.0.                         |
| S2-CONTENT          | planned             | Authentic Saxman song round trips are tested. Complete per-asset codecs, capacities and editing round trips for every content format are not yet accepted.                                              |

REV02 is excluded because no supplied real original image matched its
theoretical identity. Prototypes, modifications, compilations, lock-on and
alternate editor projects are excluded scope rather than silently accepted
profiles.

## Symbol uncertainty

The [symbol review](symbols.md) records confirmed meanings separately from
unresolved internal continuations and data interpretations. Every
address-derived global that remains has physical per-profile bounds, a reason
and a next investigation. Complete reverse engineering is not claimed.
