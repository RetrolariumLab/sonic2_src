# Architecture decisions

These decisions describe the integrated source, content and validation design.
Complete 2.0 acceptance still requires its full predecessor and delta gates in a
clean clone.

## Preserve original inputs and behavior

The source builds two verified retail revisions. Only official revision defines
select behavior. Community fixes and optimization switches were removed from the
reconstruction engine; their provenance remains documented separately. Canonical
identity is a byte comparison with user inputs, not a checksum-only claim. The
current source contains no ROM or tracked private audio/data payload. Privacy is
checked separately for the current tree and every reachable ref.

## Keep one semantic owner per module and fact

Entry wrappers preserve original include order while source directories group
responsibilities. Data ledgers live beside their code owners. One ownership
registry records source ranges and justified size exceptions. Profile and input
facts have one JSON owner. Content records refer to those owners and derive
placements and RAM boundaries from canonical assembly symbols and listings.

## Separate structural editing from compression and placement

Pure codecs expose records and preserve reserved bits, aliases, gaps and tails.
Context-bound codecs additionally check bank namespaces, live engine capacities
and LUTs. Frozen document targets prevent exports into a different revision ABI
or a widened slot. Filesystem writes occur only after serialization succeeds.
The code is reusable by a separate authoring application; no GUI is included.

## Retain original compression without edits

Equivalent decoded bytes do not imply equivalent compressed bytes. Nemesis,
Enigma and Kosinski recompression is checked semantically. A document retains
its original stream only when structural encoding reproduces its original plain
bytes. Edited content must be encoded and fit the original destination. Saxman
additionally reproduces original compressed bytes exactly. The driver has a
retail trailing byte outside the decoded compressed body; it is retained
explicitly. The compressed driver remains a source-code reference.

## Use Core without changing its source

Core is a pinned public dependency built outside its clean checkout. It supplies
Nemesis and the Enigma encoder. Its pinned Enigma decoder disagrees with the S2
engine on the retail corpus, so this repository supplies an S2 decoder and
checks every Core-encoded stream with it. No dependency patch is hidden in a
project build directory. Original 68000 decoder experiments provide additional
format evidence, and private experimental ROM/RAM outputs stay untracked.

## Preserve unusual original data accesses explicitly

ARZ's block stream writes beyond live block RAM into original scratch space.
That exact tail is protected rather than treated as authorable extra capacity.
HTZ patches the EHZ block map at its original offset. The existing object
animation cursor-wrap hazard is declared and preserved. SMPS calls and loop
counters share ten bytes of track state; control-flow validation prevents edits
from overlapping them. Such quirks do not justify weakening capacity checks.

## Keep relocation a separate preservation experiment

The probe inserts unreachable return words and adjusts branches while retaining
fixed hardware and audio windows. It preserves original accidental read windows
and uses the original logical checksum extent so boot-loop timing stays
comparable. Probe behavior is checked against original-ROM MAME goldens for each
revision, including two-player gameplay. It is not a new retail profile or an
authoring allocator. See [runtime](runtime.md) for the complete contract.
