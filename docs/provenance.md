# Provenance and licensing

## Imported baseline

The reconstructed source text was imported from
https://github.com/sonicretro/s2disasm at commit
4ef457c18fc4902396c43ab06fabc119ac6ecb64 on its master branch. That HEAD is
dated 2026-10-16. Its 1142 commits and 44 public contributor names were
collapsed into a new repository; none of the upstream Git objects were imported.
The imported baseline is identified by the upstream commit above.

The upstream disclaimer is preserved in
[the notice below](#upstream-disclaimer). Upstream provides that disclaimer
rather than a source license: the annotation license status is
license_not_granted. Reconstructing the game grants no license to Sega's game
code, music, graphics, or other data. User ROMs and extracted payloads are
private_user_supplied and must never enter Git.

All original binary game assets, WAV files, editor projects, fixed-file
modifications, Lua build tools and unused platform executables were excluded.
Music, effects, FM voices and PSG envelopes are private inputs rather than
redistributed assembler content. The driver code and engine lookup tables remain
source. SMPS2ASM content macros are excluded from the preservation build. The
complete unmodified community build and its optional fixes can be recovered from
the upstream commit above; it is a reference, never this project's Git base.

## Build tools and compression

AS 1.42 Beta build 313 comes from the two x86-64 tool paths in that same
upstream commit. Their sizes and SHA-256 are pinned in config/toolchain.json.
The resolver obtains and verifies the executables and GPL text together in the
ignored build/tools/as-313 cache; no executable is shipped in this repository.
The upstream update commit is 15e9fd52a65318bec3d5e746ce48dba6db6910db. Its
source repository is https://github.com/flamewing/asl-releases. The donor does
not record a separate exact AS source commit.

The external build-313 dependency is necessary because Kit's AS build 212
truncates the imported long jump-trampoline macro lists. Both accepted main
images failed that probe with undefined/truncated trampoline symbols. The
build-313 AS plus Kit p2bin produced both original images byte for byte. The
public dependency pins are in config/toolchain.json; Kit and Core were not
modified. p2bin is obtained and hash-checked through Kit rather than bundled.

The Python authentic Saxman encoder follows upstream
build_tools/source_code/lz_comp2/LZSS.c, not clownlzss. The original encoder is
by Haruhiko Okumura (1989), with Clownacy's Saxman adaptation (2020). The
implementation header preserves the complete permission notice and provenance.
Synthetic regression vectors are generated from synthetic strings, never music.

Licensing of the newly written project tools and documentation is not yet
assigned; this is separate from the explicitly licensed external components and
from the unlicensed reconstructed game content. Nothing here grants game content
redistribution rights.

## Public contributor names at the imported HEAD

Counts reflect git shortlog -sn HEAD and retain upstream aliases. They are not a
claim that aliases are distinct people. No contributor email is copied.

```text
   792	Clownacy
    74	flamewing
    60	MainMemory
    50	unknown
    36	AlexField442
    23	MoDule
    16	Alex Field
     9	Flamewing
     7	Francis Gagné
     6	Brainulator9
     6	IntelOrca
     5	Gabriel Ravier
     4	GabrielRavier
     4	Ralakimus
     4	RobiWanKenobi
     4	rocketsailor
     3	DeltaWooloo
     3	MineRobber9000
     3	Natsumi
     3	Selbi182
     2	Christopher Trumbour
     2	Marzo Sette Torres Junior
     2	OrionNavattan
     2	Sonic Hachelle-Bee
     2	devon-artmeier
     2	marzojr
     1	Caverns4
     1	Devon
     1	DevonArtmeier
     1	Filter
     1	FourHawk
     1	Geeovanni
     1	GeminiCrafterMan
     1	MDTravis
     1	MoDule88
     1	Nasina7
     1	Nintorch
     1	Pokepunch
     1	Sean Brackeen
     1	Tristan Penman
     1	kirisamemofo
     1	kirjavascript
     1	ollie-ollie-tech-deck
     1	oo1o1o12
```

## Accepted and excluded revisions

REV00 and REV01 were supplied by the user and the stock upstream build matched
each byte. Their input contracts are in assets/manifest.json and their shared
source build profiles are in config/revision_profiles.json. No real image
matching the theoretical REV02 hash was found in the supplied Sonic 2 folder.
REV02, prototypes, compilations, modifications and lock-on builds are outside
this reconstruction's preservation scope.

## Preservation option folding

Community bug fixes, optional optimizations, checksum bypass, expanded water
tables, driver fixes, and theoretical REV02 branches have been removed from the
buildable source. Their conditions were folded to the shared original
REV00/REV01 values in a separate source-only preservation change, checked
against both complete original images. Only official revision selection remains.
Power-of-two padding is an original container property, not a user option. The
removed switches can be recovered from the imported upstream commit above.

## Upstream disclaimer

Preserved verbatim from the imported upstream snapshot, including its spelling.

### DISCLAIMER

Any and all content presented in this repository is presented for informational
and educational purposes only. Commercial usage is expressly prohibited. Sonic
Retro claims no ownership of any code in these repositories. You assume any and
all responsibility for using this content responsibly. Sonic Retro claims no
responsibiliy or warranty.
