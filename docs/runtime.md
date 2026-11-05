# Relocation and runtime checks

The canonical build reproduces REV00 and REV01 from the user's own images. The
relocation build is an experimental proof image. It keeps canonical source files
unchanged and is not an additional retail revision or an authoring target.

```sh
make build-relocated
make runtime-check
```

Both commands cover all accepted profiles; REV=rev00 selects one. Each
relocation build first rebuilds and compares the original profile byte for byte.
Reports and copied sources go under build/relocated/<profile>/. Runtime logs,
temporary files, staged MAME and reports go under build/runtime/.

## Relocation method and fixed regions

The scanner duplicates terminal 68000 RTS/RTE words before the next global
owner. Conditional exits within procedures and instruction slots inside
fixed-stride jump tables are not padded. The current layout inserts 1453
unreachable return words per profile. Synthetic tests protect conditional exits,
return instruction slots and the AS listing parser. The report records every
insertion with its source file, owner and line; the exact coverage is
inspectable.

The vector origin and header stay fixed. Branch operands and data references
follow their source labels. Ten near trampolines preserve the original absolute
JMP target and caller instruction width when word displacements approach their
limit. Two complete source blocks move within the copied source: the slot target
helper and the level-select order table. These moves avoid widening short
branches. Canonical sources and retail bytes are unchanged.

The original compressed Z80 driver stream, its placement, and the two music bank
origins are checked exactly. The probe moves Sonic's raw artwork to the appended
region to leave room for the inserted words before the original sound area.
Named dependencies remain resolvable; reviewed renames preserve their original
profile values. The [symbol registry](symbols.md) records their provenance.

The probe is physically 2 MiB. Its header ROM end and checksum range retain the
original logical 1 MiB extent. This is explicit experimental metadata: the game
uses that extent for its power-on checksum loop. Extending the loop changes cold
boot timing and therefore the frame-based attract comparison. The complete
physical probe is identified separately by SHA-256 in its report. Added lookup
data is checked against the verified original input. This policy does not change
canonical header/checksum behavior and does not claim a general ROM expansion
feature or hardware validation.

## Original code bytes also used as lookup data

Two original CNZ bugs make relocation more than address substitution:

- SlopedSolid can index a flipped flipper's height table at $7FFF. That reads
  unrelated instruction bytes. The probe moves the three height tables to
  explicit lookup regions and preserves each original sentinel byte at that
  index. The valid 36-byte tables are checked against the original too.
- SlotMachine_Routine3 masks d1 but indexes SlotSequence1 with d0. The resulting
  lookup extends past the eight sequence bytes into neighboring sequences,
  trampolines and instructions. The probe preserves the original 256-byte read
  window as private derived lookup data, while executable procedures relocate.

These dependencies are declared by source labels in
config/reconstruction/relocation.json. The bytes come from the verified original
image, remain ignored under build/, and are never committed. They preserve the
original bugs rather than repairing game behavior. No RAM is patched, no golden
is generated from the probe, and no comparison tolerance is used.

## Original RAM goldens

Each revision has its own tests/runtime/<profile>-attract.json. A shared movie
runs from power-on for 60000 frames with no controller input, reset command,
initial RAM fill or alignment offset. The goldens contain 199 checkpoints at
300-frame intervals starting at frame 600, with 18 RAM watches each: game mode,
zone/act, both cameras, Sonic/Tails positions, rings, score, lives, VBlank
count, two-player mode and player-two counters. Each revision requires 3582
exact comparisons. The validator rejects missing checkpoints, missing cells,
changed addresses, nonzero tolerances, alignment offsets and absent two-player
coverage before launching MAME. RAM addresses must match the canonical AS
symbols.

The observed attract composition includes EHZ in two-player mode and the CPZ,
ARZ and CNZ demos. The tentative CNZ-two-player description is not used as
coverage evidence: the captured CNZ portion has the two-player flag clear.
Reports list the observed zone/flag pairs rather than assuming the composition.
Screenshots are not used as runtime evidence.

```sh
make runtime-golden
```

This command deliberately updates tracked goldens. It always uses the accepted
original profile image after checking its full input identity. It offers no
arbitrary ROM override. Review regenerated RAM values before committing them.
The normal runtime-check command never updates expected values.

## Emulator identity and execution

config/runtime.json pins the observed standalone MAME 0.289 executable by
SHA-256 and records the public source checkout commit associated with it. The
public upstream is https://github.com/mamedev/mame. This is an observed binary
identity, not a claim that the executable was independently rebuilt from source.
The registered executable is checked and copied into the ignored project build
area; MAME configuration and temporary writes stay there. The accepted runtime
host is Windows x86-64. Linux runtime is unverified.

The project takes an OS file lock for its runtime sequence and checks globally
for consoles.exe before every run. A foreign active emulator makes the run wait;
it is never terminated. Different projects still need to honor the same global
process convention. On timeout, the owned launcher process tree and processes
using this project's exact staged executable path are stopped, then the launcher
is reaped. A leftover owned emulator makes the check fail. Full runtime jobs
must not be launched in parallel.

## Controller-driven routes

`make runtime-extended-check` runs four power-on controller movies for both
revisions against the canonical and relocated ROMs. The routes select Sonic
alone and pause/resume, Tails alone, an Emerald Hill versus race with both
controllers, and the special stage reached through the versus selection menu.
Each run compares eleven RAM cells at sixteen checkpoints. Required states must
occur in order and the selected player coordinates must change after play
starts. Identical idle menus cannot satisfy the declared gameplay coverage.

`config/runtime_extended.json` owns the movies, exact input hashes, state
requirements and watches. Goldens below `tests/runtime/extended/` retain the
original ROM, emulator and movie hashes. `make runtime-extended-golden` always
uses hash-verified original ROMs. Normal checks use the accepted values and
never derive them from a candidate. Movie headers allow only power-on execution
and controller input; RAM writes, initial-state overrides and alignment offsets
are rejected. The complete 2.0 gate executes all sixteen comparisons.

Coverage remains limited to the recorded routes and watched RAM fields. Ending
sequences, all stages, exhaustive special-stage play and every instruction
remain outside the reached-state contract.
