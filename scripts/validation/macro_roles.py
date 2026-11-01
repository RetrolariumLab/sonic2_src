"""Inventory data-emitting macro definitions independently of content names."""

import hashlib
import json
import re
from scripts.build.project import ROOT, load
from scripts.build.source_asm import source_files
from scripts.validation.asm_style import code_signature

HEADER = re.compile(r"^([A-Za-z_][\w.]*)\s+macro\b", re.I)
EMITS = re.compile(r"\b(?:dc\.[bwl]|binclude|db|dw|dl)\b", re.I)


def inventory(root=ROOT):
    result = []
    for path in source_files(root):
        active, depth, body = None, 0, []
        for raw in path.read_text().splitlines():
            code = raw.split(";", 1)[0]
            match = HEADER.match(code)
            if match and active is None:
                active, depth, body = match[1], 1, [raw]
                continue
            if active is None:
                continue
            body.append(raw)
            if re.match(r"^\s*(?:rept|irp|irpc)\b", code, re.I) or HEADER.match(code):
                depth += 1
            if re.match(r"^\s*endm\b", code, re.I):
                depth -= 1
            if depth == 0:
                text = "\n".join(body)
                if any(EMITS.search(line.split(";", 1)[0]) for line in body):
                    result.append(
                        {
                            "source": path.relative_to(root).as_posix(),
                            "macro": active,
                            "code_sha256": hashlib.sha256(
                                json.dumps(code_signature(text), separators=(",", ":")).encode()
                            ).hexdigest(),
                        }
                    )
                active = None
    return result


def audit(root=ROOT):
    actual = inventory(root)
    ledger = load("config/authoring/source_macro_roles.json", root)
    formats = set(load("config/authoring/data_formats.json", root)["format_ids"])
    expected = ledger["definitions"]
    if ledger.get("review_status") != "reviewed" or len(expected) != len(actual):
        raise ValueError("Source-emitting macro review is incomplete")
    keyed = {(row["source"], row["macro"]): row for row in expected}
    if len(keyed) != len(expected):
        raise ValueError("Duplicate emitting macro owner")
    for row in actual:
        evidence = keyed.get((row["source"], row["macro"]), {})
        if evidence.get("code_sha256") != row["code_sha256"]:
            raise ValueError("Data-emitting macro is missing or changed after review: " + row["macro"])
        if (
            evidence.get("role")
            not in {"content_record", "private_input_bridge", "program_constant", "pointer_structure"}
            or len(evidence.get("reason", "")) < 40
        ):
            raise ValueError("Data-emitting macro has no explicit content/program role")
        if evidence["role"] == "content_record" and evidence.get("format_owner") not in formats:
            raise ValueError("Content macro has no structural format owner")
    return {"reviewed_emitting_macros": len(actual)}
