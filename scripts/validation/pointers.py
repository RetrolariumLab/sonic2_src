"""Audit literal ROM pointers and declared fixed hardware/header locations."""

import argparse
import json
import re
from scripts.build.listing import symbols
from scripts.build.project import ROOT, atomic_write, load, profile, profiles
from scripts.validation.asm_style import source_files
from scripts.validation.pointer_expressions import Resolver, constant_definitions, merge_constants, qualify

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


def physical(value, width="l"):
    if width == "w":
        value &= 0xFFFF
        if value & 0x8000:
            value -= 0x10000
    return value & 0xFFFFFF


def compact(value):
    return re.sub(r"\s+", "", value).casefold()


def operands(value):
    """Split assembler operands without cutting function arguments."""
    result, first, depth = [], 0, 0
    for index, character in enumerate(value):
        if character == "(":
            depth += 1
        elif character == ")":
            depth -= 1
        elif character == "," and depth == 0:
            result.append(value[first:index].strip())
            first = index + 1
    result.append(value[first:].strip())
    return result


def scan(text, rom_size, scalar_tables=None, aliases=None, scalar_loads=None, fixed_symbols=None):
    problems = []
    scalar_tables = scalar_tables or {}
    scalar_loads = scalar_loads or []
    fixed_symbols = {key.casefold(): value for key, value in (fixed_symbols or {}).items()}
    resolver = Resolver(merge_constants(aliases or {}, constant_definitions(text)))
    reviewed = {}
    for record in scalar_loads:
        key = (record["owner"], record["operation"].lower(), compact(record["expression"]), record["register"].lower())
        if (
            key in reviewed
            or type(record.get("value")) is not int
            or type(record.get("count")) is not int
            or record["count"] < 1
            or len(record.get("reason", "")) < 40
        ):
            raise ValueError("Invalid reviewed scalar address-register load")
        reviewed[key] = [record, 0]
    scalar_values, scalar_lines = {}, {}
    owner, scope = None, None

    def numeric_address(expression, width="l", first=0):
        result = resolver.resolve(qualify(expression, scope))
        plain = compact(re.sub(r"\.[wl]$", "", expression.strip(), flags=re.I)).strip("()")
        if plain in fixed_symbols and result.values == {fixed_symbols[plain]} and not result.unresolved:
            return False
        return any(first <= physical(value, width) < rom_size for value in result.values) or (
            result.unresolved
            and not result.symbolic
            and (
                re.search(r"\$[0-9a-f]+|\b[0-9]+", expression, re.I)
                or any(name.casefold() in resolver.constants for name in re.findall(r"[A-Za-z_][\w.]*", expression))
            )
        )

    for line_number, line in enumerate(text.splitlines(), 1):
        body = bare_code(line)
        label = re.match(r"^([A-Za-z_][\w.]*|\.[\w.]+)(?::|\s|$)", body)
        if label:
            name = label[1]
            if name.startswith("."):
                owner = (scope or "") + name
            else:
                owner = scope = name
            if owner in scalar_tables:
                scalar_values.setdefault(owner, [])
                scalar_lines[owner] = line_number
        reasons = []
        for match in re.finditer(r"\(([^)]+)\)\.([wl])\b", body, re.I):
            if literal_expression(match[1]) or numeric_address(match[1], match[2].lower()):
                reasons.append("absolute numeric memory operand needs a named region or label")
        typed = re.search(r"\b(?:lea|pea|jmp|jsr)(?:\.([wl]))?\s+(.+)", body, re.I)
        if typed and (
            literal_expression(operands(typed[2])[0])
            or numeric_address(operands(typed[2])[0], (typed[1] or "l").lower())
        ):
            reasons.append("numeric address or constant alias in a pointer instruction")
        immediate = re.search(r"\b(movea?\.([wl]))\s+#(.+),\s*(a[0-7]|sp)\s*$", body, re.I)
        if immediate:
            operation, width, expression, register = immediate.groups()
            key = (owner, operation.lower(), compact(expression), register.lower())
            result = resolver.resolve(qualify(expression, scope))
            values = {physical(value, width.lower()) for value in result.values}
            if key in reviewed:
                record, seen = reviewed[key]
                if values != {record["value"]} or result.symbolic or result.unresolved:
                    reasons.append("Reviewed scalar address-register load changed value")
                reviewed[key][1] += 1
            elif numeric_address(expression, width.lower()):
                reasons.append("numeric ROM address or constant alias loaded into an address register")
        longs = re.search(r"\bdc\.l\s+(.+)", body, re.I)
        if longs:
            for value in operands(longs[1]):
                value = value.strip()
                if owner in scalar_tables:
                    if not NUMBER.fullmatch(value):
                        reasons.append("Scalar longword table contains a non-scalar expression")
                    else:
                        scalar_values[owner].append(int(value[1:], 16) if value.startswith("$") else int(value))
                elif numeric_address(value, first=0x200):
                    reasons.append("numeric longword expression lies within the accepted ROM range")
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
    for record, seen in reviewed.values():
        if seen != record["count"]:
            problems.append(
                {
                    "line": 0,
                    "owner": record["owner"],
                    "reason": "Reviewed scalar address-register load count changed",
                    "code": record["operation"] + " #" + record["expression"] + "," + record["register"],
                }
            )
    return problems


def audit(root=ROOT, static=False):
    destination = root / "build/pointer-audit.json"
    destination.unlink(missing_ok=True)
    manifest = load("assets/manifest.json", root)
    rom_size = max(item["size"] for item in manifest["images"])
    config = load("config/reconstruction/fixed_regions.json", root)
    scalar_tables = {
        item["owner"]: [item["radix"] ** power for power in reversed(range(item["digits"]))]
        for item in config["scalar_longword_tables"]
    }
    all_sources = {path.relative_to(root).as_posix(): path.read_text() for path in source_files(root)}
    constants = merge_constants(*(constant_definitions(text) for text in all_sources.values()))
    for selected in profiles(root)["profiles"]:
        for name, value in selected.get("defines", {}).items():
            constants = merge_constants(constants, {name.casefold(): [str(value)]})
    scalar_loads = config.get("scalar_address_register_loads", [])
    if any(item.get("source") not in all_sources for item in scalar_loads):
        raise ValueError("Scalar address-register load has no source owner")
    problems, count = [], 0
    scalar_owners = {name: 0 for name in scalar_tables}
    for name, text in all_sources.items():
        count += 1
        for scalar_name in scalar_owners:
            scalar_owners[scalar_name] += len(re.findall(r"(?m)^" + re.escape(scalar_name) + r":", text))
        problems.extend(
            {"path": name, **item}
            for item in scan(
                text,
                rom_size,
                scalar_tables,
                aliases=constants,
                scalar_loads=[item for item in scalar_loads if item["source"] == name],
                fixed_symbols={config["deliberate_exception"]["symbol"]: 1},
            )
        )
    if any(count != 1 for count in scalar_owners.values()):
        raise ValueError("Scalar longword table owners are missing or ambiguous")
    if problems:
        raise ValueError("Literal pointer audit failed:\n" + json.dumps(problems[:30], indent=2))
    report = {
        "source_files": count,
        "literal_pointer_candidates": 0,
        "scalar_table_owners": list(scalar_tables),
        "constant_aliases": len(constants),
        "reviewed_scalar_address_loads": len(scalar_loads),
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
    atomic_write(destination, (json.dumps(report, indent=2) + "\n").encode())
    print(f"[OK] Pointer audit: {count} source files, no unowned numeric addresses in checked pointer positions")
    return report


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--static", action="store_true")
    args = parser.parse_args()
    audit(static=args.static)
