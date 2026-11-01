# Content formats

The machine-readable ownership registry is `config/authoring/data_formats.json`.
It covers 682 direct private inputs, 13 derived PSG envelopes, 210 ordinary
sprite/DPLC ledger roots, 15 inline/shared mapping tables, 104 animation roots,
three spin-tube path containers, eight indexed source tables, one palette-cycle
timing table, six demo runs and typed source-owned engine records. The two
accepted revisions share the record grammars; active input selection and
physical placement are resolved separately for each revision. The registry
includes the nested FM voice format and the `engine-records-s2` family with
explicit record discriminators. It contains no game payloads. Inline/shared
mappings and indexed source records have explicit typed owners. Inlined ordinary
ledgers retain reviewed source-region bounds, lexical scope and normalized code
fingerprints; physical filenames are not ledger boundaries. Release acceptance
still requires the complete predecessor and 2.0 gate.

Use the [content workflow](content_workflow.md) for commands and the export API.
The byte layout below is the retail S2 layout. Word-sized 68000 data is big
endian. Z80 SMPS pointers are little endian. Reserved bits, unreferenced bytes,
aliases and retail trailers survive a zero-edit cycle.

## Graphics and level geometry

| Registry codec            | Record layout and semantics                                                                      | Limits before export                                                      |
| ------------------------- | ------------------------------------------------------------------------------------------------ | ------------------------------------------------------------------------- |
| `tiles-4bpp`              | 8 by 8 pixels, high nibble first, 32 bytes per tile                                              | 64 four-bit pixels per tile; original decoded allocation                  |
| `tilemap`                 | Words: index bits 0..10, X/Y flip 11/12, palette 13..14, priority 15                             | Every field fits its VDP bit width; original stream slot                  |
| `blocks-16x16`            | Four tilemap words per block                                                                     | Eight bytes per block; source-owned block RAM; protected ARZ tail         |
| `chunks-128x128`          | 64 block words per chunk: index 0..9, flips 10/11, primary/secondary solidity 12..13/14..15      | 128 bytes per chunk; chunk RAM; block index below live block RAM capacity |
| `level-layout-s2`         | 16 rows; each row has 128 foreground then 128 background chunk bytes                             | Exactly 4096 bytes and byte-sized chunk selectors                         |
| `palette-md`              | Word with three-bit red at bit 1, green at 5, blue at 9; reserved bits remain explicit           | Channels 0..7; reserved mask `0xF111` is preserved                        |
| `special-stage-tile-rows` | Decoded special-stage art: word count, four bytes per repeated tile row, preserved two-byte tail | Count and rows agree; does not pretend to be an ordinary tile array       |

Block RAM is the source interval `Block_Table` to `Block_Table_End`, not the
largest decoded block stream. ARZ expands to 6400 bytes even though live block
RAM is 6144 bytes. The final 256 bytes overwrite the following original scratch
region. That tail contains empty patterns with palette flags; it is not all
zero. It is protected byte for byte and does not increase the number of usable
block indices beyond 768.

HTZ uses the EHZ block map, then patches 246 blocks at `Block_Table+$980`,
starting at block 304. It does not append the HTZ stream after the EHZ stream.
Consumers must use that overlay when presenting the combined level view.
Two-player rendering also transforms tile indices in block RAM; it does not
change the stored structural format.

## Placement and collision

| Registry codec         | Layout                                                                            | Limits before export                                                            |
| ---------------------- | --------------------------------------------------------------------------------- | ------------------------------------------------------------------------------- |
| `object-placement-s2`  | Six bytes: X word, packed Y/flags word, object ID byte, subtype byte              | Y 12 bits; packed flags preserved; nondecreasing X; canonical respawn RAM limit |
| `cnz-bumper-placement` | Six-byte kind/X/Y words, ending in a complete six-byte record whose X is `0xFFFF` | Nondecreasing X; no live X collides with terminator; kind and final Y preserved |
| `ring-groups-s2`       | X word plus Y/count/orientation word; two-byte `0xFFFF` terminator                | Live group X 0..0x7FFF; Y 12 bits; count 1..8; at most 255 expanded rings       |
| `start-position-s2`    | X/Y words                                                                         | Exactly four bytes; unsigned word coordinates                                   |
| `collision-heights-s2` | 256 shapes of 16 signed bytes                                                     | Exactly 4096 bytes; samples -128..127                                           |
| `collision-angles-s2`  | One byte per collision shape                                                      | Exactly 256 entries                                                             |
| `collision-index-s2`   | Byte shape selectors for live block mappings                                      | Exactly 768 entries                                                             |

The source defines shared buffers and capacities in `src/memory/`. Export
contracts derive their current values from symbols rather than duplicating RAM
addresses in the format registry. Placement streams are bounded by their
original encoded destination even when their record grammar allows more rows.

Object respawn indices start at one. The engine accesses
`Object_Respawn_Table+2+index`; index zero is reserved. The bound handler
derives its limit from `Obj_respawn_data_End-Obj_respawn_data-1` and the
byte-sized index. The accepted canonical RAM has 190 data bytes, so at most 189
records may carry the respawn flag. Both the RAM layout and capacity come from
fresh canonical symbols. Export without a bound capacity is rejected, including
the default object `Document` handler; callers must supply the context-bound
codec.

Edited objects and CNZ bumpers require nondecreasing X. Equal coordinates retain
their original order; export never sorts records or reassigns respawn indices.
Ring groups instead use any negative word X as the engine's end condition.
Decoding rejects negative X before the canonical final `0xFFFF`; encoding
rejects live group X at or above `0x8000`. Stored ring groups need no X sorting:
the engine sorts the expanded positions. These checks precede returned export
bytes and do not modify the retail engine or its RAM layout.

The original CNZ 2 bumper stream contains one inversion: zero-based records 19
and 20 have X 6336 and 6288. The registry records its exact SHA-256 and this
pair under `retail_bumper_order_exceptions`. The canonical context permits only
the exact original stream to retain this inversion; changing any field requires
a fully ordered list. The generic codec has no order exception. This preserves
retail bytes without silently normalizing the data or exempting later edits.

## Special-stage tables

| Registry codec              | Layout and model                                                                        | Limits before export                                                                                   |
| --------------------------- | --------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------ |
| `special-stage-track`       | Three tagged, sized MSB bitstreams: literal/run selectors, literal indices, run indices | Three sections, 28 rows, exactly 128 expanded cells per row, valid engine LUT indices                  |
| `special-stage-geometry`    | Seven word offsets followed by ordered stage segment arrays                             | Seven stages; segment IDs 0..4 with bit 7 flip; byte-sized segment cursor                              |
| `special-stage-objects`     | Seven word offsets; ring/bomb distance/angle pairs and group markers                    | Distance six bits; markers `0xFC`..`0xFF`; source-derived dynamic slot count; original three-byte tail |
| `special-stage-perspective` | 56 word references aliasing variable perspective records                                | Signed-word offsets; six-byte samples; visible depth cannot exceed available samples                   |
| `angle-lookup`              | 257 bytes plus one alignment byte                                                       | Fixed 258-byte original layout                                                                         |
| `sine-lookup`               | 256 signed words plus 64 cosine-extension words                                         | Fixed quarter-wave-derived symmetry; cosine extension follows the sine data                            |

A track selector of one reads a literal: a width bit selects six bits, or ten
bits plus the second LUT partition. A selector of zero reads a run: six bits, or
seven bits plus the second run partition. The wide run index 127 terminates a
row. Literal and run partitions begin at source-owned LUT labels. Rendering ORs
palette-line flags and, for runs, the priority flag. The encoder checks the
actual LUT expansion before producing a stream. Bit tails and trailing bytes
remain explicit, including original padding that a generic bitstream writer
might otherwise discard.

Perspective references may alias the same physical record. Each sample stores
unsigned center X, signed center Y, radii and occlusion limits. A zero visible
limit does not imply that the record has no stored samples.

## Audio

| Registry codec    | Layout and model                                                                      | Limits before export                                                              |
| ----------------- | ------------------------------------------------------------------------------------- | --------------------------------------------------------------------------------- |
| `smps-music-s2`   | Music header, FM/DAC/PSG channel descriptors, typed events and embedded voices        | Original bank/buffer base, header widths, fixed record layout and track workspace |
| `smps-sfx-s2`     | SFX header and channel descriptors, typed events and shared voice/stream references   | Same-bank external owners must resolve to typed record boundaries                 |
| `fm-voice-s2`     | Embedded 25-byte YM2612 voice: algorithm/feedback plus six groups of four operators   | Register field widths and reserved bits; driver register-write order              |
| `pcm-u8`          | Unsigned eight-bit samples                                                            | Byte range and original sample slot                                               |
| `dpcm-s2`         | Two delta codes per byte, high nibble first, initial accumulator `0x80`               | Even sample count; every transition must have an exact original delta code        |
| `psg-envelope-s2` | Signed attenuation offsets followed by hold marker `0x80` and explicit trailing bytes | Signed range excludes the hold marker; original driver allocation                 |
| `driver-program`  | Private compressed reference for the source-assembled Z80 driver                      | Decoded driver size; whole program protected against content edits                |

There are 31 music inputs and 81 SFX inputs. Twenty-seven songs use Saxman; four
are raw bank streams. Thirteen PSG envelopes are derived from the decoded driver
reference. Audio engine code remains assembly source; song, effect, voice and
envelope data never becomes tracked generated assembly.

DPCM uses modulo-256 deltas
`0,1,2,4,8,16,32,64,128,255,254,252,248,240,224,192`. Its encoder rejects
unrepresentable PCM transitions instead of quantizing them. FM voices expose
reserved register bits and keep operators in driver write order, so a round trip
does not normalize undocumented values.

SMPS follows reachable tracks through commands `0xE0`..`0xF9`. Branch, loop and
call operands remain absolute Z80 words. `0xE3` returns, `0xE4` restores and
terminates, `0xF2` stops, `0xF6` jumps, `0xF7` loops and `0xF8` calls. The
unused `0xED` command still consumes its following byte in this driver. These
are S2 semantics; command names from another engine are not sufficient.

The shared ten-byte loop-counter/call-stack workspace is checked on all
reachable control-flow paths. Calls cannot exceed five levels; loop counters
must stay disjoint from return addresses, including across calls. External
references are permitted only when another uncompressed input in the same bank
owns the requested complete voice or stream event. Compressed music has an
independent decode-buffer namespace. Unreachable original bytes remain owned
explicitly and are preserved.

## Assembly-owned tables

| Registry codec          | Layout and ownership                                                                          | Limits before export                                                                                   |
| ----------------------- | --------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------ |
| `sprite-s2`             | Relative word frame table; frame word count; eight-byte sprite pieces                         | Signed Y byte, signed X word, width/height 1..4, P1/P2 tile words, at most 80 pieces per frame         |
| `dplc-s2`               | Relative word frame table; frame word count; word tile-transfer runs                          | One through 16 tiles per run, 12-bit source index, preserved aliases and null references               |
| `animation-object-s2`   | Relative signed-word script table; timing byte and object frame/control bytes                 | Frames below `0x80`, explicit external script owners and original control hazards                      |
| `animation-player-s2`   | Player timing and animation bytecode with the same table ownership rules                      | Frames below `0xF0`; signed timing codes and shared scripts remain intact                              |
| `tube-path-s2`          | Relative word selectors with shared paths; each path has a byte-length word and XY word pairs | Four-bit path selector, word byte-length/cursor, signed-word container offsets and original allocation |
| `ring-sprite-s2`        | Signed relative frame table with one eight-byte sprite piece per frame and no count header    | Exactly one piece; original frame slot                                                                 |
| `special-stage-dplc-s2` | 36 counted character selectors followed by 21 headerless single-entry tail selectors          | Counted/single consumer ABI, one through 16 tiles per run, 12-bit source word offset                   |
| `demo-input-s2`         | Controller byte and duration-minus-one byte pairs                                             | Hold duration one through 256 frames, exact contiguous source run                                      |

These tables remain tracked source, using the original macro grammar. Their
compiled byte views are decoded and re-encoded for each revision. Source frame
boundaries distinguish unused sprite pieces from frame bodies. Pointer aliases,
null frame references, gaps and local-label scopes remain intact. Animation
scripts borrowed from another root must resolve uniquely at a declared script
start.

`Ani_obj52` contains an original backward-control argument that borrows the next
script's timing byte and wraps the byte cursor. Its exact hazard is declared in
the registry and preserved; an edited stream cannot introduce another hazard.
The unused older demo run remains an explicit source owner, even though the
retail demo dispatcher does not select it. Spin-tube entry paths in CPZ use
offsets relative to the tube object; CPZ main paths and MTZ paths use level
coordinate words. Their header stores the point payload length in bytes in a
word, and the consumer advances a word-sized remaining-length counter. The codec
therefore preserves 16-bit coordinates and does not impose an artificial
63-point byte-cursor limit. Original slot and signed-word container bounds still
apply.

## Compression and zero-edit policy

| Container               | Decode                                        | Encode and preservation policy                                                                                 |
| ----------------------- | --------------------------------------------- | -------------------------------------------------------------------------------------------------------------- |
| `none`                  | Structural codec consumes the input directly  | Exact bytes                                                                                                    |
| `nemesis`               | Pinned Core                                   | Core encoding with the original coding-table reference; semantic check, original stream retained without edits |
| `enigma-s2`             | Local S2 decoder                              | Pinned Core encoder; local decode of every result; original stream retained without edits                      |
| `kosinski`              | Local decoder with original descriptor timing | Local encoder; semantic check, original stream retained without edits                                          |
| `saxman`                | Authentic local LZSS implementation           | Exact original compressed songs required                                                                       |
| `saxman-driver-trailer` | Driver body decoded without a size prefix     | Exact encoded body plus retained retail trailer; source code owns the program                                  |

The pinned Core Enigma decoder does not match this game's engine for the retail
corpus. The repository therefore uses its S2 decoder with Core's encoder and
checks every result locally. Core itself is not modified. Original 68000 decoder
experiments validated the original and re-encoded compression streams during
format research; those private generated test images are not repository inputs.

Semantic recompression does not authorize silently replacing preservation bytes.
A `Document` returns the original stream only when structural encoding
reproduces the original decoded bytes. Any actual edit must use an encoder,
respect its revision ABI and fit its original destination and bank. The full
zero-edit command also rebuilds both complete ROMs and compares every byte with
the verified user images.

## Indexed source records and palette timing

These tables use frozen source record slots. Their relative selector words,
aliases, record boundaries and optional single trailing alignment byte are all
owned explicitly; padding is not used to conceal an unmodeled payload. Exports
also use the profile-qualified document target. A source-view document rejects
another profile ABI or a changed allocation before returning bytes.

| Codec                     | Typed record                                                                     | Capacity and dependency checks                                                                                   |
| ------------------------- | -------------------------------------------------------------------------------- | ---------------------------------------------------------------------------------------------------------------- |
| `track-frames-s2`         | Five source-defined sequences of track mapping-frame bytes                       | Frame IDs resolve within `Map_SpecialStageTrack`; source `_End` labels preserve sequence lengths                 |
| `background-scroll-s2`    | Eleven rows of five zero-extended byte increments                                | Five samples per row, values 0..255; direction is separate engine logic                                          |
| `phrase-words-s2`         | Even byte selectors into `SSMessage_TextFrames`, followed by a signed terminator | Eighteen word entries; only declared original invalid selector cells survive                                     |
| `message-glyphs-s2`       | Glyph mapping-frame bytes and a signed terminator                                | Every glyph index fits the source-owned message sprite table                                                     |
| `hud-layout-s2`           | Child-sprite count, initial X and mapping-frame bytes                            | Count fits the sub-sprite region of the object record; frame IDs fit HUD mappings                                |
| `pulley-path-s2`          | Byte-length word and signed XY point words                                       | This consumer stores cursor/length in separate bytes; at most 63 points, unlike the word-cursor spin-tube format |
| `pulley-children-s2`      | Count-minus-one word and signed XY/subtype-word child records                    | Dynamic object allocation capacity; ignored high subtype byte is explicit                                        |
| `ending-frames-s2`        | Three fixed 28-sample mapping-frame sequences                                    | Frame IDs fit the ending object's mappings and the 28-sample counter                                             |
| `palette-cycle-timing-s2` | Sixteen effective frame periods stored as countdown reload bytes                 | Periods 1..256 encode as reload 0..255; cycle index remains four bits                                            |

Palette color-cycle inputs use the same `palette-md` word grammar as base
palettes. The HTZ lava timing table stays assembler-owned but has its own pure
codec. `PalCycle_HTZ` decrements the timer before testing it, so a stored reload
of zero means one frame and 255 means 256 frames.

The background scroll reader clears its destination word before loading a byte;
the original `0xFF` sample therefore means 255, not -1. This distinction is
preserved instead of applying a signed-byte normalization.

The original final message phrase contains selectors `0x24` and `0x26` although
the word table has only eighteen entries. These two source cells are retained as
declared retail exceptions. The codec does not pretend that they resolve to
valid word owners. An edit cannot introduce, move or change an invalid selector
outside those exact declared cells; replacing one with a valid selector is
permitted by the record codec. Canonical builds still retain original bytes.

## Shared frame views

Inline mappings are not flattened into one private blob. They expose symbolic
selector references and one physical owner for each complete frame. Backward
signed offsets, cross-table aliases, an unused complete frame and the
zone-ordered title-card selector block are preserved. Unused frame bodies remain
modeled even when no current selector reaches them.

Ring frames omit the usual count word. Special-stage DPLC character frames have
a count word, while tail frames are single entries without a count. Their run
word contains a tile count in bits 12..15 and a source offset in *words* in bits
0..11; the engine doubles that offset when forming a byte address. This is a
different ABI from ordinary DPLC's unshifted source-tile index. Counted and
headerless selectors cannot be exchanged by an edit.

`frame_views.Document` freezes the profile ABI, table selectors and physical
frame slots. Encoding returns named patches without writing files. Shared
patches must agree before `frame_views.apply` returns a byte view; conflicting
writes fail before the input can change. Header changes, frame growth, pointers
into pieces and source-address overflows are rejected.

## Dynamic pattern transfer bounds

A legal twelve-bit DPLC offset can still read past its art input. Ordinary DPLC
exports therefore bind to the current private art consumer, check every source
tile run, and retain each original frame's total transfer size as its maximum
destination window. This conservative policy permits changing tile sources and
shortening transfers without claiming a larger dynamic allocation. It applies to
Sonic, Tails, dust/splash and the two-player signpost.

Adjacent art tile constants do not always mark independent dynamic windows:
Tails can use 28 tiles across its body/tail area, and the two-player signpost
can transfer 24 tiles despite another mode's neighboring allocation name. The
codec preserves the original per-frame transfer window rather than incorrectly
rejecting those original overlaps or inventing extra capacity.

Special-stage DPLC bounds differ by selector group. The current profile's source
pointer tables partition the shared decoded art RAM; destination tile
reservations bound Sonic, Tails and the separate tails. Each selector owns a
frozen source partition and destination budget. Every shared frame must fit all
consumers that reference it before the encoder returns any patches.

## Source-owned engine records

`engine_records.decode(kind, bytes)` and `encode(kind, model)` expose typed
records for source declarations that are not ordinary sprite or animation
tables. `source_records` independently discovers their macro calls, binds active
physical listing ranges and opens fixed-size documents for each revision. The
registry's `record_kinds` fields enumerate each owner's actual grammars.

| Record group                        | Representation and control                                                                                                                                                                                                                                                                                     |
| ----------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Credits and menus                   | Credits have a font/palette attribute, remapped glyph bytes and `FF` terminator. Menu text has a count-minus-one byte and glyph bytes. These are engine glyph IDs, not an assumed ASCII encoding.                                                                                                              |
| Credits page layouts                | Text pointer plus VRAM destination-word records end with a two-byte `FFFF`; the page index uses long pointers and a four-byte sentinel. Reference and layout topology remain protected.                                                                                                                        |
| Palette descriptors                 | Palette-load descriptors carry pointer, RAM destination and longword count. Transition descriptors carry callback, palette pointer, destination offset, count, timer and step fields. Pointer/count edits are protected; transition writes must fit the 128-byte palette and signed timer limits.              |
| Robot limb motion                   | A count-minus-one and duration precede child-pointer-slot/signed-delta triples. Programs contain an owned frame-table pointer and frame, mirrored-frame, sound and restart commands. Source frame indices, slot fields, signed widths and termination are checked. Program topology stays protected.           |
| Child and object initialization     | Typed spawn templates, object prototypes, bridge/platform/spike parameters, animal velocities/mappings and screen-object metadata preserve their exact field widths and original reference fields.                                                                                                             |
| Debug objects and pattern-load cues | Counted object/mapping/subtype/frame/art records and counted art-pointer/VRAM requests have explicit models, exact extents and protected selector/reference topology.                                                                                                                                          |
| UI positioning and sprite scaling   | Continue/title/result positions use signed words. Sprite scale regions contain source/destination addresses and dimensions; address fields are protected and dimensions cannot grow beyond the original transfer window.                                                                                       |
| Animated blocks and tiles           | Block patterns bind destination/count to the original block-table end. Tile scripts contain duration/art/VRAM/count descriptors and frame offsets, optionally with individual durations. Counts, references and destination windows are protected; frame sources cannot exceed the original per-script extent. |

`source_records.open_record(kind, data, target)` requires the canonical
protected reference policy and preserves the allocation's exact size. It returns
a `Document` and model without writing files. Numeric edits are allowed only
within the declared widths, original transfer windows and frozen revision ABI.
The low-level record codecs alone do not authorize changing pointers, counts,
dispatch selectors or placement. Those changes require a newly established
allocation and consumer contract. Several reference-only descriptors are
intentionally read-only through this bounded interface.

The credits renderer reads a long before testing its sign, although its source
layout terminator occupies only two bytes. The codec preserves this original
boundary and does not invent a four-byte terminator. Motion restart values `C0`
through `FF` are control codes, not out-of-range frame indices. Zero frame
duration advances after the first tick; signed motion deltas retain their raw
engine scaling rather than being rounded to whole pixels.

`config/authoring/source_macro_roles.json` separately reviews every macro that
directly emits 68000 or Z80 data. The structure gate detects an omitted or
changed emitter. Content macros point to their format owner; private input
wrappers, instruction/padding generators, mathematical constants and
source-owned driver ABI tables have explicit roles. Program coefficients and
executable instruction generation remain source, rather than becoming editable
music or level content.

Bound spawn templates retain their original parent link, object ID and subtype;
object prototypes also protect priority, render flags and collision selectors.
Changing these fields requires a separately established consumer contract,
rather than merely fitting another integer into the same byte.

Projectile bursts use six-byte records: signed position offsets, signed high
bytes of the fixed-point velocity words, mapping frame and flip flags. The
source-derived DBF count must equal the physical span. The bound document keeps
the entry count and frame/flag topology fixed while permitting signed numeric
edits within each byte.
