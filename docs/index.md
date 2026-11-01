# Documentation

Start with [building and private inputs](build.md) and the
[validation commands](validation.md). The current source organization and fact
owners are described in [architecture](architecture.md); the engine's RAM and
hardware interfaces are summarized in [memory](memory.md).

[Relocation and runtime](runtime.md) explains the exact MAME evidence, the two
CNZ source-as-data dependencies and the experimental probe header policy.
[Style](style.md) explains the shared Kit ASL adapter and mechanical formatting.
[Unknowns](unknowns.md) records limitations and acceptance blockers without
turning them into unsupported claims.

[Provenance and licensing](provenance.md) records the upstream baseline, public
contributors, excluded community modes and tool origins. The original
[upstream disclaimer](provenance.md#upstream-disclaimer) is preserved
separately.

The preservation boundary is machine-readable in
config/source_reconstruction_1_0.json. The complete preservation gate has passed
from a clean clone with only the verified ROMs supplied. Semantic layout and
complete content contracts belong to the later 2.0 milestone.

[Symbol meanings and uncertainty](symbols.md) describes confirmed renames,
per-profile evidence and the explicit unknown work queue. For legal private
content work, read [content workflow](content_workflow.md) and the consolidated
[format reference](data_formats.md). Their byte APIs and zero-edit rebuild are
separate from final 2.0 aggregate acceptance.
