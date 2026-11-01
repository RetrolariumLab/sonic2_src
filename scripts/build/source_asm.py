"""Read AS source declarations outside macro templates and retain lexical labels."""

import re
from scripts.build.listing_source import ListingIndex

LABEL = re.compile(r"^([A-Za-z_.][\w.]*)(?::|\s|$)")


def statements(text, initial_scope=None):
    """Yield physical declarations outside macro templates, with lexical scopes."""
    lines = text.splitlines()
    templates = ListingIndex({}, [], {"source": lines}, {}).macro_definition_lines("source")
    scope = initial_scope
    for number, raw in enumerate(lines, 1):
        if number in templates:
            continue
        body = raw.split(";", 1)[0].rstrip()
        label = None
        match = LABEL.match(body)
        if match:
            label = match[1]
            if label.startswith("."):
                label = (scope or "") + label
            else:
                scope = label
            body = body[match.end() :]
        anonymous = re.match(r"^([+\-/]+)(?=\s|$)", body)
        if anonymous:
            label = "@" + str(number) + ":" + anonymous[1]
            body = body[anonymous.end() :]
        if not body.strip():
            yield number, label, scope, "", ""
            continue
        operation, *rest = body.strip().split(None, 1)
        yield number, label, scope, operation.lower(), rest[0].strip() if rest else ""
