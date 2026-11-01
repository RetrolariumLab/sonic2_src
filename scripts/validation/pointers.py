"""Audit literal ROM pointers and declared fixed hardware/header locations."""

import argparse
import json
import re
from scripts.build.listing import symbols
from scripts.build.project import ROOT, atomic_write, load, profile, profiles
from scripts.validation.asm_style import source_files

NUMBER = re.compile(r"^(?:\$[0-9a-f]+|[0-9]+)$", re.I)
REGISTER = re.compile(r"\b(?:[ad][0-7]|pc|sp)\b", re.I)


def bare_code(line):
    result, quote = [], None
    for index, char in enumerate(line):
        if quote:
            result.append(" ")
            if char == quote:
                quote = None
        elif char == '"' or (char == "'" and (index == 0 or not (line[index - 1].isalnum() or line[index - 1] == "_"))):
            quote = char
            result.append(" ")
        elif char == ";":
            break
        else:
            result.append(char)
    return "".join(result).rstrip()


def literal_expression(value):
    value = re.sub(r"\.[wl]$", "", value.strip(), flags=re.I).strip("() ")
    return bool(
        value
        and (value.startswith("$") or value[0].isdigit())
        and not REGISTER.search(value)
        and re.fullmatch(r"[\s$0-9a-f+*/()\-]+", value, re.I)
    )


def scan(text, rom_size, scalar_tables=None):
    problems = []
    scalar_tables = scalar_tables or {}
    scalar_values = {}
    scalar_lines = {}
    owner = None
    for line_number, line in enumerate(text.splitlines(), 1):
        body = bare_code(line)
        label = re.match(r"^([A-Za-z_][\w.]*)\b", body)
        if label:
            owner = label[1]
            if owner in scalar_tables:
                scalar_values.setdefault(owner, [])
                scalar_lines[owner] = line_number
        reasons = []
        for match in re.finditer(r"\(([^)]+)\)\.[wl]\b", body, re.I):
            if literal_expression(match[1]):
                reasons.append("absolute numeric memory operand needs a named region or label")
        typed = re.search(r"\b(?:lea|pea|jmp|jsr)(?:\.[wl])?\s+([^,]+)", body, re.I)
        if typed and literal_expression(typed[1]):
            reasons.append("numeric address in a pointer instruction")
        longs = re.search(r"\bdc\.l\s+(.+)", body, re.I)
        if longs:
            for value in longs[1].split(","):
                value = value.strip()
                if owner in scalar_tables and not NUMBER.fullmatch(value):
                    reasons.append("Scalar longword table contains a non-scalar expression")
                if NUMBER.fullmatch(value):
                    number = int(value[1:], 16) if value.startswith("$") else int(value)
                    if owner in scalar_tables:
                        scalar_values[owner].append(number)
                    elif 0x200 <= number < rom_size:
                        reasons.append("longword literal lies within the accepted ROM range")
        for reason in dict.fromkeys(reasons):
            problems.append({"line": line_number, "owner": owner, "reason": reason, "code": body.strip()})
    for name, values in scalar_values.items():
        if values != scalar_tables[name]:
            problems.append(
                {
                    "line": scalar_lines[name],
                    "owner": name,
                    "reason": "Declared scalar table no longer matches its radix contract",
                    "code": "",
                }
            )
    return problems


def audit(root=ROOT, static=False):
    manifest = load("assets/manifest.json", root)
    rom_size = max(item["size"] for item in manifest["images"])
    config = load("config/reconstruction/fixed_regions.json", root)
    scalar_tables = {
        item["owner"]: [item["radix"] ** power for power in reversed(range(item["digits"]))]
        for item in config["scalar_longword_tables"]
    }
    problems, count = [], 0
    scalar_owners = {name: 0 for name in scalar_tables}
    for path in source_files(root):
        count += 1
        text = path.read_text()
        for name in scalar_owners:
            scalar_owners[name] += len(re.findall(r"(?m)^" + re.escape(name) + r":", text))
        problems.extend(
            {"path": path.relative_to(root).as_posix(), **item} for item in scan(text, rom_size, scalar_tables)
        )
    if any(count != 1 for count in scalar_owners.values()):
        raise ValueError("Scalar longword table owners are missing or ambiguous")
    if problems:
        raise ValueError("Literal pointer audit failed:\n" + json.dumps(problems[:30], indent=2))
    report = {
        "source_files": count,
        "literal_pointer_candidates": 0,
        "scalar_table_owners": list(scalar_tables),
        "profiles": [],
    }
    if not static:
        config = load("config/reconstruction/fixed_regions.json", root)
        relocation = load("config/reconstruction/relocation.json", root)
        for selected in profiles(root)["profiles"]:
            table = symbols((root / selected["output"]).parent / "main.lst")
            for item in config["locations"]:
                actual = table[item["symbol"]]
                if item.get("mask"):
                    actual &= int(item["mask"], 0)
                if actual != int(item["address"], 0):
                    raise ValueError("Fixed region moved: " + item["symbol"])
            bank = config["bank_window"]
            if table[bank["base_symbol"]] != bank["size"]:
                raise ValueError("Z80 bank-window size changed")
            if table[config["deliberate_exception"]["symbol"]] != 1:
                raise ValueError("Original deliberate crash address changed")
            required = [item["label"] for item in relocation["legacy_reads"]["slopes"]]
            required.append(relocation["legacy_reads"]["slot_window"]["label"])
            if any(name not in table for name in required):
                raise ValueError("A source-as-data lookup dependency lost its named owner")
            report["profiles"].append(
                {
                    "profile": selected["id"],
                    "fixed_locations": len(config["locations"]),
                    "legacy_lookup_owners": required,
                }
            )
    atomic_write(root / "build/pointer-audit.json", (json.dumps(report, indent=2) + "\n").encode())
    print(f"[OK] Pointer audit: {count} source files, no unresolved numeric address operands")
    return report


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--static", action="store_true")
    args = parser.parse_args()
    audit(static=args.static)
