"""Resolve DPLC bounds from the current profile's art inputs and reservations."""

from scripts.build.project import ROOT, load, project_path
from scripts.authoring.dplc_capacity import Budget


def ordinary(artifact, context, max_tiles, root=ROOT):
    contract = artifact["transfer_contract"]
    manifest = load("assets/manifest.json", root)
    assets = [row for row in manifest["assets"] if row["path"] == contract["source_asset"]]
    if len(assets) != 1:
        raise ValueError("DPLC source art has no unique private input")
    data = project_path(manifest["output"] + "/" + assets[0]["path"], root).read_bytes()
    at = context["symbols"][contract["source_symbol"]]
    if len(data) != assets[0]["size"] or context["rom"][at : at + len(data)] != data:
        raise ValueError("DPLC source art differs from its current consumer")
    if contract["destination_policy"] != "original_per_frame_transfer":
        raise ValueError("Unknown ordinary DPLC destination policy")
    budget = Budget(len(data), max_tiles, 32)
    budget.validate()
    return budget


def special(artifact, context):
    contract = artifact["transfer_contract"]
    symbols, rom = context["symbols"], context["rom"]
    first, end = (symbols[contract[key]] & 0xFFFFFF for key in ["source_start", "source_end"])
    bases = []
    for group in contract["groups"]:
        address = symbols[group["pointer_table"]]
        count = len(group["selector_counts"])
        bases.extend(
            int.from_bytes(rom[address + index * 4 : address + index * 4 + 4], "big") for index in range(count)
        )
    if not bases or bases[0] != first or not all(first <= a < b <= end for a, b in zip(bases, bases[1:] + [end])):
        raise ValueError("Special-stage DPLC art partitions leave their source RAM")
    budgets = []
    partition = 0
    for group in contract["groups"]:
        capacity = symbols[group["destination_end"]] - symbols[group["destination_start"]]
        for count in group["selector_counts"]:
            if type(count) is not int or count < 1:
                raise ValueError("Invalid DPLC selector partition")
            limit = bases[partition + 1] if partition + 1 < len(bases) else end
            budget = Budget(limit - bases[partition], capacity, 2)
            budget.validate()
            budgets.extend([budget] * count)
            partition += 1
    return tuple(budgets)
