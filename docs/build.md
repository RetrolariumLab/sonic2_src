# Building the original revisions

This checkout builds the accepted retail REV00 and REV01 images. It distributes
no ROM or extracted game data. Obtain the original images yourself.

## Prerequisites

Use Python 3.10 or newer, GNU Make, Git, an importable Retrolarium Core Python
package for history audit, and Retrolarium Kit with build-tool release
2026.10.11. The exact executable hashes and public dependency commits are in
config/toolchain.json. Use the pinned Kit source commit (or a compatible newer
version) for `make lint`; the build-tool release alone does not identify the
label-aware CLI. The binary allowlist is empty.

The original source needs AS 1.42 Beta build 313 because build 212 truncates its
long trampoline macro argument lists. Only the Windows x86-64 and Linux x86-64
upstream executables are obtained with their GPL text into ignored
build/tools/as-313/. Windows is the current validation host. Linux remains
unverified. p2bin comes from the pinned Kit. The first build downloads these
exact files from the pinned upstream snapshot, checks their size and SHA-256
before writing the cache, and rechecks every cached file on every use. Changed
cache entries fail without being silently replaced. An offline checkout can
provision the same files at the manifest-owned paths; it receives the same
checks. An arbitrary PATH assembler is never used.

## Private inputs and extraction

Run:

```sh
make split ROM_DIR="/path/to/your/rom/folder"
make verify-all
```

The import scans that folder for images matching the sizes, SHA-1 and SHA-256 in
assets/manifest.json. It copies only the two verified images into data/roms/.
Alternatively, put the images at the exact relative paths listed in that
manifest and run make split without ROM_DIR.

Retrolarium Kit extracts every manifest range into the single ignored data/ root
and checks its hash. Four empty original object lists contain no bytes; their
labels and following source-defined boundaries remain in the assembly. Use make
check-assets to reject missing or changed preservation inputs.

## Build commands

Bare make prints help. make build builds the default profile from
config/revision_profiles.json. Select the other profile with REV=rev00. make
verify builds one profile, compares its size and every byte with the verified
user input, then checks both output hashes. make verify-all does that for all
accepted profiles in order.

Music and sound effects are private ROM assets, including the 27 stored Saxman
streams, four uncompressed songs, and 81 effects. Preservation builds include
the stored bytes directly. Uncompressed SMPS pointers address their original Z80
bank offsets; generated wrappers reject placement changes within that bank. The
13 PSG envelopes are sliced from the decoded private driver during split. Their
offsets, lengths and hashes live in config/audio.json. DAC DPCM and SEGA PCM are
extracted in their stored forms; WAV converters are absent. All generated source
wrappers, AS objects, headers, listings, logs and ROMs stay in build/. Removing
that directory does not change the preservation build.

The 68000 source and Z80 driver assemble together. Kit p2bin applies the
original saxman-bugged driver compression; Python patches its compressed size,
the ROM-end header and the Mega Drive checksum, matching the original build.
REV00 deliberately contains an odd-address crash instruction. Its known AS
warning 180 is accepted only when AS produced an object and reported no errors;
stale objects are deleted before each assembly.

## Checks without private inputs

make test runs the full test suite. Without extracted original songs, only the
test that decodes and authentically recompresses every song is skipped with an
explanation. Synthetic authentic-codec vectors, malformed stream and capacity
checks, patch bounds, stale-output rejection, manifest contracts, the real Make
help command, and a deleted-private-payload history regression still run.

make check-private-data checks the current source tree and every unique blob
reachable from every Git ref. It rejects any complete private asset or ROM
payload and every tracked binary, including compiler executables. Music/SFX
source files, SMPS2ASM content macros and inline PSG envelopes are also
rejected. Deleting private content in a later commit does not make that history
valid.

The preservation build is one part of the reconstruction workflow. Lint,
relocation, MAME and semantic-layout commands are implemented and have separate
evidence. Complete release acceptance is checked by the appropriate full
clean-clone aggregate; preservation has passed and the integrated 2.0 gate
follows. See [validation](validation.md) for the complete sequence.

## Direct aggregate from original ROMs

After placing the two verified ROMs at the paths owned by the asset manifest,
`make release-check` extracts its required inputs itself. The complete 2.0
command is `make source-2-check CORE_SOURCE="path/to/retrolarium-core"`; it also
prepares the pinned public Core CLI if needed. A prior split command or saved
build directory is not required. Existing direct assets and derived envelopes
are checked first; changed preservation content is rejected before any write.
Undeclared private files remain outside extraction ownership.
