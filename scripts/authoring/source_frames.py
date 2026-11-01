"""Resolve inline/shared mapping frames to one canonical typed physical owner."""

from collections import Counter, defaultdict
import hashlib
from scripts.build.project import ROOT, profile
from scripts.build.source_asm import statements
from scripts.authoring import frame_views, dplc_contexts
from scripts.authoring.source_indexed import tables


class Owners:
    def __init__(self, context, artifacts, parents):
        self.context = context
        self.by_address = {}
        self.sources = {}
        ring_sources = {row["source"] for row in artifacts if row["codec"] == "ring-sprite-s2"}
        ss_sources = {row["source"] for row in artifacts if row["codec"] == "special-stage-dplc-s2"}
        symbols = context["symbols"]
        for name, lines in context["listing"].source_lines.items():
            if not name.startswith("src/"):
                continue
            pending = []
            for number, label, scope, operation, arguments in statements("\n".join(lines), parents.get(name)):
                if label and not label.startswith("@") and not label.endswith("_End"):
                    if label in symbols and (name, number) in context["listing"].addresses:
                        pending.append(label)
                if not operation:
                    continue
                kind = None
                if operation == "spriteheader":
                    kind = "sprite-counted"
                elif operation == "dplcheader" and name in ss_sources:
                    kind = "ss-dplc-counted"
                elif operation == "spritepiece" and name in ring_sources:
                    kind = "sprite-single"
                elif operation == "dplcentry" and name in ss_sources:
                    kind = "ss-dplc-single"
                if kind and pending:
                    addresses = {symbols[label] for label in pending}
                    if len(addresses) != 1:
                        raise ValueError("Source frame aliases have different addresses")
                    at = next(iter(addresses))
                    if not 0 <= at <= len(context["rom"]) - 2:
                        raise ValueError("Source frame leaves the canonical ROM")
                    count = int.from_bytes(context["rom"][at : at + 2], "big") if kind.endswith("-counted") else 1
                    size = (2 if kind.endswith("-counted") else 0) + count * (8 if kind.startswith("sprite-") else 2)
                    if at + size > len(context["rom"]):
                        raise ValueError("Source frame body leaves its ROM")
                    endings = {symbols[label + "_End"] for label in pending if label + "_End" in symbols}
                    if endings and endings != {at + size}:
                        raise ValueError("Frame byte grammar differs from source-defined ends: " + pending[0])
                    frame = frame_views.Frame(sorted(pending)[0], at, size, kind)
                    previous = self.by_address.get(at)
                    if previous and (previous.size != size or previous.kind != kind):
                        raise ValueError("Conflicting source frame definitions")
                    if previous is None:
                        self.by_address[at] = frame
                        self.sources[at] = name
                pending = []


def roundtrip(artifacts, context, parents, root=ROOT):
    if not artifacts:
        return {"records": [], "frames": [], "dependencies": []}
    source = tables(context, root)
    owners = Owners(context, artifacts, parents)
    table_specs = []
    selected = set()
    inline_sources = {row["source"] for row in artifacts}
    by_symbol = {row["root_symbol"]: row for row in artifacts}
    for artifact in artifacts:
        symbol = artifact["root_symbol"]
        name, rows, index, targets = source.header(symbol, "mappingstableentry.w")
        if name != artifact["source"]:
            raise ValueError("Inline mapping table has the wrong registered source")
        address = context["symbols"][symbol]
        kind = artifact["codec"]
        if kind == "special-stage-dplc-s2":
            counted = artifact["counted_selectors"]
            if not 0 < counted < len(targets):
                raise ValueError("Special-stage DPLC counted/single split is invalid")
            kinds = ("ss-dplc-counted",) * counted + ("ss-dplc-single",) * (len(targets) - counted)
        else:
            kinds = (("sprite-single" if kind == "ring-sprite-s2" else "sprite-counted"),) * len(targets)
        first_word = int.from_bytes(context["rom"][address : address + 2], "big")
        budgets = dplc_contexts.special(artifact, context) if kind == "special-stage-dplc-s2" else ()
        table_specs.append(frame_views.Table(symbol, address, kinds, first_word == 0, budgets))
        for number, target in enumerate(targets):
            word = int.from_bytes(context["rom"][address + number * 2 : address + number * 2 + 2], "big")
            if word == 0 and first_word == 0:
                continue
            offset = word if word < 0x8000 else word - 0x10000
            at = address + offset
            symbol_name = symbol + target if target.startswith(".") else target
            if context["symbols"].get(symbol_name) != at:
                raise ValueError("Mapping word differs from its symbolic source reference")
            frame = owners.by_address.get(at)
            if frame is None or frame.kind != kinds[number]:
                raise ValueError("Inline mapping reaches no typed consumer frame: " + symbol_name)
            selected.add(at)
    # Keep unused complete frames in each inline source ledger as explicit owners.
    selected.update(at for at, name in owners.sources.items() if name in inline_sources)
    frames = tuple(owners.by_address[at] for at in sorted(selected))
    spec = frame_views.Spec(
        profile(context["revision"], root)["content_abi"], len(context["rom"]), tuple(table_specs), frames
    )
    document, model = frame_views.Document.open(context["rom"], spec)
    patches = document.encode(model, spec)
    if frame_views.apply(context["rom"], patches) != context["rom"]:
        raise ValueError("Shared source views change original bytes during zero edit")
    frame_by_name = {row.name: row for row in frames}
    users = defaultdict(set)
    for table in model["tables"]:
        for reference in table["references"]:
            if reference is not None:
                users[reference].add(table["name"])
    records = []
    dependencies = []
    for table in model["tables"]:
        artifact = by_symbol[table["name"]]
        definition = next(row for row in table_specs if row.name == table["name"])
        references = table["references"]
        data = context["rom"][definition.address : definition.address + len(references) * 2]
        records.append(
            {
                "source": artifact["source"],
                "codec": artifact["codec"],
                "root_symbol": table["name"],
                "revision": context["revision"],
                "start": definition.address,
                "end_exclusive": definition.address + len(data),
                "frame_references": len(references),
                "distinct_frames": len(set(references) - {None}),
                "null_frames": references.count(None),
                "shared_frames": sum(len(users[value]) > 1 for value in set(references) - {None}),
                "size": len(data),
                "sha256": hashlib.sha256(data).hexdigest(),
                "zero_edit": True,
                "transfer_bounds": [
                    {"source_bytes": row.source_bytes, "max_tiles": row.max_tiles, "offset_scale": row.offset_scale}
                    for row in definition.transfer_budgets
                ],
            }
        )
        for reference in sorted(set(references) - {None}):
            frame = frame_by_name[reference]
            dependencies.append(
                {
                    "revision": context["revision"],
                    "source_table": table["name"],
                    "frame_owner": reference,
                    "frame_source": owners.sources[frame.address],
                    "address": frame.address,
                    "external_to_table_source": owners.sources[frame.address] != artifact["source"],
                }
            )
    frame_rows = []
    for definition, model_frame in zip(frames, model["frames"]):
        data = context["rom"][definition.address : definition.address + definition.size]
        frame_rows.append(
            {
                "owner": definition.name,
                "source": owners.sources[definition.address],
                "revision": context["revision"],
                "kind": definition.kind,
                "start": definition.address,
                "size": definition.size,
                "entries": len(model_frame["entries"]),
                "used_by_tables": sorted(users[definition.name]),
                "sha256": hashlib.sha256(data).hexdigest(),
                "zero_edit": True,
            }
        )
    return {"records": records, "frames": frame_rows, "dependencies": dependencies}
