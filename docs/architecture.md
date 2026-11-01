# Architecture and fact ownership

The canonical entry point is `src/main.asm`. `config/revision_profiles.json`
supplies the shared retail defines and output paths. Semantic modules preserve
the original include order and group code by its subsystem responsibilities.
Data stays beside its owner. The source registry records every module, original
range and justified size exception; labels and canonical behavior are unchanged.

## Engine subsystems

- The ROM vectors/header, hard initialization, checksum and game-mode dispatcher
  establish startup and the main loop. V_Int and H_Int drive frame work and the
  split-screen interrupt path.
- VDP/DMA, controller reads, palette transitions, plane transfers and the
  Nemesis, Kosinski, Enigma and Saxman decompressors provide system services.
- Game modes own the SEGA/title screens, level loading/play, special stages,
  continue, two-player/options menus, ending and credits.
- Level code loads layouts, blocks, chunks, collision and placements. Zone
  deformation, animated art, events, cameras and water logic update the world.
- Object managers allocate and load objects; Sonic/Tails and common collision
  helpers implement player motion. Badniks, bosses, stage mechanisms, rings,
  monitors and scoring share the engine services.
- The 68000 sound interface loads the compressed Z80 driver and sends commands.
  `src/audio/z80/driver.asm` includes executable driver modules and engine
  tables. Stored songs/effects, FM voices, PSG envelopes and DAC/PCM are private
  content inputs.
- Source-defined mappings, DPLC and engine tables live beside their subsystem
  owners. Their inline form is preserved; original binary graphics, level and
  collision assets are extracted under data/.

## Authoritative facts

| Fact                                                                      | Owner                                    |
| ------------------------------------------------------------------------- | ---------------------------------------- |
| Accepted input sizes/hashes and direct ROM extraction ranges              | assets/manifest.json                     |
| Revision defines, canonical entry and output paths                        | config/revision_profiles.json            |
| Stored audio classification, bank offsets, samples and derived PSG slices | config/audio.json                        |
| Executable dependency pins and host support limits                        | config/toolchain.json                    |
| External executable identities                                            | config/toolchain.json                    |
| Source style roots and dialect                                            | config/lint.json                         |
| RAM/hardware symbols                                                      | src/memory/ and object ABI modules       |
| Relocation transforms and legacy lookup owners                            | config/reconstruction/relocation.json    |
| Fixed header/hardware controls and scalar table classification            | config/reconstruction/fixed_regions.json |
| Movie requirements, watches and emulator identity                         | config/runtime.json                      |
| Original per-profile expected RAM snapshots                               | tests/runtime/\*-attract.json            |
| Preservation release claims, evidence references and limits               | config/source_reconstruction_1_0.json    |

Snapshots and reports repeat derived values only as evidence; validators compare
them with their authoritative owners. Make delegates to Python and does not own
a second set of hashes, defines, offsets or revision names.

scripts/build/ owns extraction and the AS/p2bin/post-patch pipeline.
scripts/validation/ owns repository, pointer, style and aggregate checks.
scripts/runtime/ owns serialized emulator execution through Kit. The authentic
Saxman implementation under scripts/authoring/ is a codec; preservation builds
include stored song bytes rather than recreating music from source.
