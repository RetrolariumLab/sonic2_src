"""Preserve AS label syntax while using the shared Kit ASL formatter.

Kit currently discovers .s/.inc and its label lexer does not cover several
original AS forms. A disposable .s mirror presents every source label as a
plain named colon label. Kit owns all formatting. We restore only the original
label token after formatting; no instruction, operand or string is substituted.
"""

from pathlib import Path
import re
import subprocess
import tempfile
from scripts.build.project import ROOT, atomic_write, load

SUFFIXES = {".asm", ".s", ".inc"}
HEAD = re.compile(r"^(\s*)([^\s;]+)(.*)$")
NAME = re.compile(r"^[A-Za-z_][A-Za-z0-9_]*:$")


def encode_source(text):
    output, records = [], []
    for line in text.splitlines():
        if not line.strip():
            output.append(line)
            continue
        record = None
        match = HEAD.match(line)
        if match:
            indent, token, tail = match.groups()
            is_label = not indent or token.endswith(":") or bool(re.fullmatch(r"[+-]+", token))
            if is_label:
                original = token
                name = token[:-1] if token.endswith(":") else token
                safe = re.sub(r"[^A-Za-z0-9_]", "_", name)
                if not safe or not re.match(r"[A-Za-z_]", safe):
                    safe = "L" + safe[1:]
                encoded = safe + ":"
                if not NAME.fullmatch(encoded):
                    raise ValueError("Cannot protect AS label: " + original)
                line = encoded + tail
                record = (original, encoded)
        output.append(line)
        records.append(record)
    return "\n".join(output) + ("\n" if output else ""), records


def restore_source(text, records):
    output, cursor = [], 0
    for line in text.splitlines():
        if not line.strip():
            output.append(line)
            continue
        if cursor >= len(records):
            raise ValueError("Kit changed the number of nonblank source lines")
        record = records[cursor]
        cursor += 1
        if record is not None:
            original, encoded = record
            if not line.startswith(encoded) or (len(line) > len(encoded) and not line[len(encoded)].isspace()):
                raise ValueError("Kit changed a protected source label")
            padding = " " * max(0, len(encoded) - len(original))
            line = (original + padding + line[len(encoded) :]).rstrip()
        output.append(line)
    if cursor != len(records):
        raise ValueError("Kit removed a nonblank source line")
    return "\n".join(output) + ("\n" if output else "")


def code_signature(text):
    """Keep every non-whitespace code byte, including whitespace in strings."""
    result = []
    for line in text.splitlines():
        code, quote = [], None
        for index, char in enumerate(line):
            if quote:
                code.append(char)
                if char == quote and (index == 0 or line[index - 1] != "\\"):
                    quote = None
            elif char == '"' or (
                char == "'" and (index == 0 or not (line[index - 1].isalnum() or line[index - 1] == "_"))
            ):
                quote = char
                code.append(char)
            elif char == ";":
                break
            elif not char.isspace():
                code.append(char)
        if code:
            result.append("".join(code))
    return result


def source_files(root=ROOT):
    files = set()
    for name in load("config/lint.json", root)["assembly"]["paths"]:
        path = root / name
        if not path.resolve().is_relative_to(root.resolve()):
            raise ValueError("Assembly lint path leaves the repository")
        if path.is_dir():
            files.update(p for p in path.rglob("*") if p.is_file() and p.suffix in SUFFIXES)
        elif path.is_file() and path.suffix in SUFFIXES:
            files.add(path)
        else:
            raise ValueError("Missing configured assembly source: " + name)
    return sorted(files)


def normalize(root=ROOT, fix=False):
    config = load("config/lint.json", root)
    config = {
        "schema": config["schema"],
        "schema_version": config["schema_version"],
        "assembly": {**config["assembly"], "paths": ["sources"]},
        "code": False,
    }
    import json

    parent = root / "build/lint-sessions"
    parent.mkdir(parents=True, exist_ok=True)
    if not parent.resolve().is_relative_to((root / "build").resolve()):
        raise ValueError("Style scratch folder leaves build/")
    changed = []
    with tempfile.TemporaryDirectory(dir=parent) as directory:
        scratch = Path(directory)
        if not scratch.resolve().is_relative_to(parent.resolve()):
            raise ValueError("Style scratch folder leaves its allowed root")
        atomic_write(scratch / "config/lint.json", (json.dumps(config, indent=2) + "\n").encode())
        copies = []
        for index, source in enumerate(source_files(root)):
            original = source.read_bytes().decode("utf-8")
            encoded, records = encode_source(original)
            copy = scratch / "sources" / f"{index:04d}.s"
            atomic_write(copy, encoded.encode())
            copies.append((source, copy, original, records))
        command = ["rltool", "lint", "--fix", "--only", "assembly", "--project", str(scratch)]
        # A comment ending in a space plus a period can need a second Kit pass.
        # The mirror must pass Kit's own complete lint before restoration.
        for attempt in range(3):
            result = subprocess.run(command, cwd=root, text=True, capture_output=True, timeout=120)
            if result.returncode == 0:
                break
        if result.returncode:
            message = result.stdout + result.stderr
            for source, copy, _, _ in copies:
                message = (
                    message.replace(str(copy), str(source))
                    .replace(copy.as_posix(), source.as_posix())
                    .replace(copy.relative_to(scratch).as_posix(), source.relative_to(root).as_posix())
                )
            raise ValueError("Shared ASL formatter failed:\n" + message)
        for source, copy, original, records in copies:
            formatted = restore_source(copy.read_text(), records)
            if code_signature(formatted) != code_signature(original):
                before, after = code_signature(original), code_signature(formatted)
                mismatch = next(
                    (i for i, pair in enumerate(zip(before, after)) if pair[0] != pair[1]), min(len(before), len(after))
                )
                detail = (
                    f"\nCode line {mismatch}: {before[mismatch : mismatch + 1]!r} -> {after[mismatch : mismatch + 1]!r}"
                )
                raise ValueError("Kit changed code or quoted data: " + source.relative_to(root).as_posix() + detail)
            if formatted != original:
                changed.append(source.relative_to(root).as_posix())
                if fix:
                    atomic_write(source, formatted.encode())
    label = "formatted" if fix else "would format"
    print(
        f"[{'OK' if fix or not changed else 'FAIL'}] Kit ASL adapter: {label} {len(changed)} of {len(copies)} source(s)"
    )
    return changed
