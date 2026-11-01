"""Bind inlined data ledgers to reviewed physical source regions."""

import hashlib
import json
import re
from scripts.validation.asm_style import code_signature


def region_lines(artifact, lines):
    region = artifact.get("source_region")
    if region is None:
        return lines
    if not isinstance(region, dict):
        raise ValueError("Invalid source data region: " + artifact["source"])
    first, last = region.get("first_line"), region.get("last_line")
    scope = region.get("initial_scope")
    if (
        type(first) is not int
        or type(last) is not int
        or not 1 <= first <= last <= len(lines)
        or (scope is not None and (not isinstance(scope, str) or not re.fullmatch(r"[A-Za-z_][\w.]*", scope)))
    ):
        raise ValueError("Source data region has invalid bounds or scope: " + artifact["source"])
    selected = lines[first - 1 : last]
    fingerprint = hashlib.sha256(
        json.dumps(code_signature("\n".join(selected)), separators=(",", ":")).encode()
    ).hexdigest()
    if region.get("code_sha256") != fingerprint:
        raise ValueError("Source data region changed after review: " + artifact["source"])
    return selected
