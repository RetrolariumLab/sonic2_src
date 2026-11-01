"""Read AS listing symbols without interpreting source expressions."""

import re

SYMBOL = re.compile(r"\b([A-Za-z_][\w.]*)\s*:\s*([0-9A-F]+)\s+[C-](?:\s|\||$)")


def symbols(path):
    result = {}
    text = "\n".join(
        line for line in path.read_text(errors="replace").splitlines() if not re.match(r"^(?:\(\d+\))?\s*\d+/", line)
    )
    for match in SYMBOL.finditer(text):
        name, value = match[1], int(match[2], 16)
        if name in result and result[name] != value:
            raise ValueError("Conflicting AS symbol: " + name)
        result[name] = value
    if not result:
        raise ValueError("AS listing contains no symbols")
    return result
