# Source layout

The integrated source layout preserves canonical assembly order and original
labels. `config/reconstruction/source_layout.json` owns module responsibilities,
coordinates and fingerprints against the accepted preservation commit.
`config/reconstruction/label_renames.json` records original-label changes; the
mechanical move does not rename those symbols.

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

An object's `main.s` names one original object responsibility. Additional
component modules have behavior names. Source-owned mappings, DPLC and small
path tables live in that owner's `data/` folder. Shared tables have one physical
owner, even when several object IDs consume them. Sonic and Tails own their
mapping and dynamic pattern ledgers. Math, generic sprite output and audio
resume procedures belong to their subsystems rather than the object folder.

Player movement and large boss implementations are split at named functional
boundaries. The constants wrapper includes independent files for object ABI,
identifiers, general RAM, RAM overlays, hardware and tile reservations. The Z80
wrapper includes modules for boot, DAC, channel updates, queues, music/SFX
selection, global controls, SMPS commands, tables, decompression and state.
Private song/SFX/sample includes remain generated build inputs, not source
modules or tracked content.

The registry gives each source file an owner, responsibility, original source
coordinates and byte hash. Main source modules also carry canonical ROM ranges
for both accepted profiles. Original physical source coordinates are covered
once, including setup and tail directives. Every literal source include must
reach a registered module or an explicitly declared generated audio wrapper. The
include graph must have no cycle or orphan.

No executable module exceeds 900 physical lines. The two larger Sonic mapping
and DPLC ledgers are explicit size exceptions: each is one indexed table and its
complete frame bodies. Their macro grammar and every frame reference are
machine-checked. Small complete declarations and synchronization entry points
also carry reasons instead of being padded or merged across unrelated owners.

Mechanical moves preserve exact canonical ROM bytes and the relocated ROMs
already used for runtime validation. This byte evidence complements a semantic
review of names, ownership and cohesion; it does not by itself establish those
properties. See [architecture](architecture.md), [formats](data_formats.md) and
[content workflow](content_workflow.md).

## Source names and processor suffixes

Source basenames use lowercase snake_case and at most three words. Directories
provide the zone, subsystem and primary entity context; filenames do not repeat
object IDs or enumerate every child object. Original assembly labels and object
dispatch IDs remain unchanged.

The `.s` suffix identifies 68000 code and emitted tables. Shared constants,
hardware/RAM declarations, macros and assembler setup use `.inc`. Z80 driver
modules retain `.asm`. All three suffixes participate in source ownership,
content discovery, style checks and private-data audits.

Object implementations are grouped by `enemies`, `items`, `bosses`, `effects`,
`player`, `scenery` and `environment` under `src/game/objects`. Environment
owners use zone directories where the implementation belongs to one zone; shared
implementations use `common`. Special-stage objects live under
`src/game/special_stage/objects`, and screen objects under `src/ui/objects`.
Preserved unused implementations have an explicit `unused` owner. Their data
ledgers remain adjacent in each owner's `data` directory, with short names such
as `mappings.s`, `mappings_a.s` and `paths.s`.

Zone ownership follows actual placement consumers and source use rather than an
imported filename alone. The formerly ARZ-named swinging platform serves ARZ,
MCZ and OOZ; the CNZ-named conveyor also serves MTZ and WFZ. Both belong to
`environment/common`. Round and hexagonal CNZ bumpers have distinct owners.
Moving these files changes no include position, source-range origin, symbolic
label or ROM byte.
