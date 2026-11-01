# Documentation

To build the retail images, start with [building and private inputs](build.md)
and [validation commands](validation.md). [Revision profiles](revisions.md)
explains the accepted inputs, shared engine and excluded variants. The complete
preservation and 2.0 gates have passed from clean clones; their scope and
retained limitations remain documented below.

To navigate or change source, read [architecture](architecture.md),
[source layout](source_layout.md) and [memory interfaces](memory.md).
[Style](style.md) describes shared formatting and the original AS syntax
adapter. [Contribution rules](../CONTRIBUTING.md) explain the verification and
history boundaries.

To inspect or edit legal private content, use
[content workflow](content_workflow.md) and [data formats](data_formats.md).
These describe the byte APIs, revision ABI, capacities, preservation streams and
complete zero-edit rebuild. There is no bundled GUI or external editor project.

To assess evidence and limitations, read [relocation and runtime](runtime.md),
[open and resolved unknowns](unknowns.md) and
[architecture decisions](architecture_decisions.md). Runtime and content reports
are generated independently and do not replace history or clean-tree checks. The
preservation manifest is `config/source_reconstruction_1_0.json`; its
requirements remain prerequisites of the final 2.0 milestone.

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
[upstream disclaimer](provenance.md#upstream-disclaimer) is preserved
separately. The [README](../README.md) provides project status and the shortest
build path.

[Reconstruction boundary](source_reconstruction_2_0.md) separates implemented
commands, unresolved development claims and final clean-clone acceptance.
