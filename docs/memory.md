# Memory and hardware interfaces

s2.constants.asm is the owner of addresses and object-field offsets. The table
below summarizes the current original layout; runtime watches resolve those
symbols from each canonical AS listing instead of trusting this prose.

| Symbol/area                      | 68000 address               | Role                                            |
| -------------------------------- | --------------------------- | ----------------------------------------------- |
| Vectors                          | $000000                     | 64 exception/interrupt longwords                |
| Header                           | $000100                     | Cartridge header through EndOfHeader at $000200 |
| Z80_RAM                          | $A00000                     | Z80 work RAM through $A01FFF                    |
| Z80_Bus_Request / Z80_Reset      | $A11100 / $A11200           | Sound CPU bus and reset control                 |
| HW_Port_1_Data / HW_Port_2_Data  | $A10003 / $A10005           | Controller interfaces                           |
| VDP_data_port / VDP_control_port | $C00000 / $C00004           | VDP data and command interfaces                 |
| PSG_input                        | $C00011                     | PSG write interface                             |
| RAM_Start / Chunk_Table          | $FF0000                     | Main RAM and level chunk storage                |
| Level_Layout                     | $FF8000                     | Level layout data                               |
| Object_RAM / MainCharacter       | $FFB000                     | Object slots; Sonic is the first slot           |
| Sidekick                         | $FFB040                     | Tails/player-two object slot                    |
| Camera_RAM                       | $FFEE00                     | Camera state through Camera_RAM_End at $FFEF00  |
| Game_Mode                        | $FFF600                     | Current engine mode                             |
| Normal_palette                   | $FFFB00                     | Normal palette buffer                           |
| Vint_runcount                    | $FFFE0C                     | VBlank frame counter                            |
| Life_count / Ring_count / Score  | $FFFE12 / $FFFE20 / $FFFE26 | Main player counters                            |
| SlotMachineVariables             | $FFFF4E                     | CNZ slot state and its temporary values         |

RAM_Mirror_Start names the original lower RAM mirror used by layout and demo
recording routines. Intentional_Crash_OddAddress names the deliberate odd word
access in the original crash path; it is an explicitly preserved exception, not
an unidentified ROM pointer.

Z80 code is assembled in its own address space inside the compressed driver. The
driver uses a $8000-byte ROM bank window. Four stored uncompressed songs and all
effects retain their original within-bank positions, because embedded SMPS
pointers address that window. Compressed songs decode at the music buffer
address and capacity owned by config/audio.json. DAC sample payloads and rates
are declared there too. Generated include guards reject uncompressed placement
changes; pointer checks and byte identity protect the canonical regions.

The vector/header origins and selected hardware locations are asserted by
config/reconstruction/fixed_regions.json. Pointer audit also distinguishes the
2P menu's decimal place-value table from numeric ROM addresses using an explicit
radix/count contract. Relocation's original sound-bank positions and
source-as-data lookup windows have additional controls described in runtime.md.
