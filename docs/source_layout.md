# Source layout

The integrated source layout preserves canonical assembly order and symbol
values. `config/reconstruction/source_layout.json` owns module responsibilities,
coordinates and fingerprints against the accepted preservation commit.
`config/reconstruction/label_renames.json` records original-label changes; the
mechanical move and subsequent semantic review have separate evidence. See
[symbol meanings](symbols.md) for confirmed renames and unresolved entries.

`src/main.s` sets up the assembler and includes the modules in their original
order. Include order controls physical ROM layout; folder order does not. Both
revisions use this same engine and select retail differences with the profile's
`gameRevision` define. There are no per-revision engine copies.

| Directory                           | Responsibility                                                                 |
| ----------------------------------- | ------------------------------------------------------------------------------ |
| `src/system`                        | Entry, interrupts, initialization, math, compression and assembler support     |
| `src/memory`                        | General RAM, overlays and hardware register declarations                       |
| `src/game/player/sonic` and `tails` | Player state, movement, collision entry points, animation and dynamic graphics |
| `src/game/player/collision`         | Shared surface alignment, floor and clearance queries                          |
| `src/game/objects`                  | Object dispatch, individual object implementations and shared object behavior  |
| `src/game/objects/bosses`           | Boss controllers and their named component responsibilities                    |
| `src/game/level`                    | Level setup, events, collision, plane drawing and streaming                    |
| `src/game/special_stage`            | Special-stage game logic and rendering orchestration                           |
| `src/game/demo`                     | Source-owned attract-mode controller recordings                                |
| `src/rendering`                     | Sprite queues/builders, palettes, tile animation and art declarations          |
| `src/audio`                         | 68000 audio interface, container, capacities and Z80 engine modules            |
| `src/ui`                            | Title/menu, result screens, HUD and other screen modes                         |

A cohesive object normally lives in one named file, such as
`environment/mcz/sliding_spikes.s`. Its source-owned mappings, DPLC and small
path tables are inline at their original include positions. Compound owners,
shared tables and physically separated fragments retain named component files or
an explicit `data/` owner. Sonic and Tails keep their large mapping and pattern
ledgers. Math, generic sprite output and audio resume procedures remain in their
subsystems.

Player movement and large boss implementations are split at named functional
boundaries. The constants wrapper includes independent files for object ABI,
identifiers, general RAM, RAM overlays, hardware and tile reservations. The Z80
wrapper includes modules for boot, DAC, channel updates, queues, music/SFX
selection, global controls, SMPS commands, tables, decompression and state.
Private song/SFX/sample includes remain generated build inputs, not source
modules or tracked content.

The registry gives each source file an owner, responsibility and byte hash.
Schema 2 adds `original_segments` for a module containing more than one original
source slice; legacy single-slice rows retain their original coordinate fields.
Every segment keeps its accepted source path, physical line coordinates and
SHA-256. The baseline audit covers all original source lines exactly once,
including setup and tail directives, and checks each segment against the exact
accepted commit. Main modules also retain both canonical ROM ranges. Every
literal source include reaches a registered module or a declared generated audio
wrapper; the include graph has no cycle or orphan.

The ordinary physical-line limit remains 900. Two pure Sonic mapping/DPLC
ledgers retain their machine-checked macro grammar and frame-reference proofs.
Seven complete object files have separate `cohesive_object_module` exceptions,
each with a named root, a reason, multiple checked original segments and an
explicit maximum. Growth beyond that module's reviewed maximum fails the check;
these exceptions do not raise the general limit. Small complete declarations and
synchronization entry points retain explicit boundary reasons.

Mechanical moves preserve exact canonical ROM bytes. Relocation probes are
regenerated from the current source boundaries and checked against unchanged
original-input runtime goldens. An inline table may expose another unreachable
return site to the probe generator, so the experimental probe image need not
have its former hash. This byte and runtime evidence complements a semantic
review of names, ownership and cohesion; it does not establish them by itself.
See [architecture](architecture.md), [formats](data_formats.md) and
[content workflow](content_workflow.md).

## Source names and processor suffixes

Source basenames use lowercase snake_case and at most three words. Directories
provide the zone, subsystem and primary entity context; filenames do not repeat
object IDs or enumerate every child object. Original assembly labels and object
dispatch IDs remain unchanged by file moves. Confirmed label changes are
recorded separately in the canonical rename registry.

The `.s` suffix identifies 68000 code and emitted tables. Shared constants,
hardware/RAM declarations, macros and assembler setup use `.inc`. Z80 driver
modules retain `.asm`. All three suffixes participate in source ownership,
content discovery, style checks and private-data audits.

Object implementations are grouped by `enemies`, `items`, `bosses`, `effects`,
`player`, `scenery` and `environment` under `src/game/objects`. Environment
owners use zone directories where the implementation belongs to one zone; shared
implementations use `common`. Special-stage objects live under
`src/game/special_stage/objects`, and screen objects under `src/ui/objects`.
Preserved unused implementations have an explicit `unused` owner. Retained
separate ledgers use short names such as `mappings.s`, `smoke_mappings.s` and
`paths.s`; directly owned ledgers are inline in the named object module.

Zone ownership follows actual placement consumers and source use rather than an
imported filename alone. The formerly ARZ-named swinging platform serves ARZ,
MCZ and OOZ; the CNZ-named conveyor also serves MTZ and WFZ. Both belong to
`environment/common`. Round and hexagonal CNZ bumpers have distinct owners.
Moving these files changes no include position, source-range origin, symbolic
label or ROM byte.

## Cohesive object modules

The tree has 425 assembly modules after flattening 170 single-entry object
owners: 139 incorporate their 175 local source-data files, and 31 already had
one implementation file. Data was inserted exactly where its include appeared;
no emitted statement, declaration order or compiled symbol value moved. Four
adjacent standalone mapping groups later replace twelve more source files.
Shared or physically separated owners retain their existing boundaries.

| Module                                                                     | Responsibility                                     | Physical lines |
| -------------------------------------------------------------------------- | -------------------------------------------------- | -------------: |
| [Object dispatch](../src/game/objects/dispatch.s)                          | RunObjects and the owned Obj_Index table           |            337 |
| [Platform contacts](../src/game/objects/common/platform_object.s)          | Platform contacts and player-carry helpers         |            451 |
| [Starpost](../src/game/objects/items/starpost.s)                           | Checkpoint, special-stage stars and their mappings |            442 |
| [MCZ sliding spikes](../src/game/objects/environment/mcz/sliding_spikes.s) | Sliding spike object and its mappings              |            145 |
| [OOZ sliding spikes](../src/game/objects/environment/ooz/sliding_spikes.s) | OOZ spike object and its mappings                  |            191 |

Inline ordinary sprite/DPLC and tube-path ledgers have a `source_region` in the
format registry. Its physical bounds, entry scope and normalized code hash keep
parsers inside that ledger, excluding surrounding instructions and other tables.
Sprite inventory compares qualified table roots rather than whole filenames.

| Explicit object exception                  | Maximum physical lines |
| ------------------------------------------ | ---------------------: |
| `game/objects/environment/cpz/spin_tube.s` |                    906 |
| `game/objects/bosses/arz.s`                |                    967 |
| `game/objects/scenery/tornado.s`           |                    999 |
| `game/objects/bosses/mecha_sonic.s`        |                   1002 |
| `game/objects/bosses/wfz.s`                |                   1026 |
| `game/objects/bosses/ehz.s`                |                   1053 |
| `game/special_stage/objects/results.s`     |                   1101 |

The symbol proof registry and explicit unknown ledger follow the current
physical owners. Three declaration fingerprints change only because their
file-boundary/include context became inline; their original compiled endpoints
and the complete expanded source text remain checked. No label is renamed by
this consolidation.

## Standalone mapping ledgers

A `data` directory with one mapping file adds no useful ownership boundary.
Eleven such files now sit directly beside their owner modules; for example,
[Death Egg Robot mappings](../src/game/objects/bosses/death_egg_robot/mappings.s)
are beside the robot's animation and body modules. The Sonic and Tails `data`
directories retain both mappings and DPLC, so those two-file groups stay intact.

Contiguous tables for one owner share a physical file. Include-site aliases and
intervening comments move with their original positions; the caller includes
that group once. Each original data ledger keeps a separate reviewed source
region, while original segments account for both the data files and the moved
include-site source lines. The baseline still covers every original line once.

| Shared mapping file                                                                  | Physical lines | Distinct original ledgers |
| ------------------------------------------------------------------------------------ | -------------: | ------------------------: |
| [Animals](../src/game/objects/items/animals/mappings.s)                              |            106 |                         5 |
| [Shared decorations](../src/game/objects/environment/common/bridge_stake/mappings.s) |            146 |                         5 |
| [HUD](../src/ui/hud/mappings.s)                                                      |            164 |                         3 |
| [CPZ eggpod and effects](../src/game/objects/bosses/cpz/data/eggpod_mappings.s)      |            103 |                         3 |

Tables separated by animation or controller code retain distinct files. Their
names describe checked consumers instead of letter suffixes: CPZ
`machine_mappings.s` and `eggpod_mappings.s`, HTZ `smoke_mappings.s` and
`boss_mappings.s`, and CNZ `bomb_mappings.s` and `cage_mappings.s`. The CPZ art
references, HTZ smoke setup and CNZ bomb/cage consumers establish these roles;
no sprite label or gameplay behavior is renamed.
