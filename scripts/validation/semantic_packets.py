"""Partition the canonical names and explicit unknowns by physical source owner."""


def validate(document, renames, unknowns):
    if document.get("schema_version") != 1 or not document.get("packets"):
        raise ValueError("Semantic review has no subsystem packets")
    known = {row["old"]: row for row in renames}
    pending = {row["symbol"]: row for row in unknowns}
    seen_known, seen_pending, ids = set(), set(), set()
    for packet in document["packets"]:
        identifier = packet["id"]
        if identifier in ids or not identifier or not packet.get("reason"):
            raise ValueError("Semantic packet needs a unique identity and review reason")
        ids.add(identifier)
        for names, records, seen in (
            (packet["renames"], known, seen_known),
            (packet["unknowns"], pending, seen_pending),
        ):
            if len(names) != len(set(names)) or seen & set(names) or not set(names) <= set(records):
                raise ValueError("Semantic packets duplicate or invent physical review owners")
            for name in names:
                definitions = records[name].get("definitions", [])
                if not definitions and records[name].get("kind") != "generated_trampoline":
                    raise ValueError("Semantic packet lacks physical declaration evidence")
                if any(
                    not any(row["source"].startswith(prefix) for prefix in packet["source_roots"])
                    for row in definitions
                ):
                    raise ValueError("Semantic packet claims another subsystem's declaration")
                seen.add(name)
    if seen_known != set(known) or seen_pending != set(pending):
        raise ValueError("Semantic packets omit reviewed names or explicit unknowns")
    return len(ids)
