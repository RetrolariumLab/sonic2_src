"""Build an unreachable-return relocation probe without editing canonical sources."""

import argparse
import hashlib
import json
import re
from scripts.build.build_rom import assemble_image, prepare_audio, verify
from scripts.build.listing import symbols
from scripts.build.project import ROOT, atomic_write, load, profile, profiles, reference, toolchain
from scripts.validation.asm_style import source_files

RETURN = re.compile(r"^\s*(?:(?:[A-Za-z_][\w.]*:?|\.[\w.]+:|[+-]+)\s+)?(rts|rte)\s*$", re.I)
GLOBAL = re.compile(r"^([A-Za-z_][\w.]*)\b")


def code(line):
    return line.split(";", 1)[0].rstrip()


def terminal(lines, index):
    for following in lines[index + 1 :]:
        body = code(following)
        if not body.strip():
            continue
        if re.match(r"^\s*(?:even|align\b|endif\b)", body, re.I):
            continue
        return bool(GLOBAL.match(body))
    return True


def duplicate_epilogues(text, anchors=()):
    lines = text.splitlines()
    output, records, used = [], [], []
    owner = None
    for index, line in enumerate(lines):
        body = code(line)
        label = GLOBAL.match(body)
        if label:
            owner = label[1].rstrip(":")
        output.append(line)
        match = RETURN.fullmatch(body)
        if match and terminal(lines, index):
            output.append("                " + match[1].lower() + " ; unreachable relocation probe word")
            records.append({"line": index + 1, "owner": owner, "opcode": match[1].lower()})
            for anchor in anchors:
                if owner == anchor["anchor_owner"]:
                    output.extend([anchor["alias"] + ":", "                jmp (" + anchor["target"] + ").l"])
                    used.append(anchor["symbol"])
    return "\n".join(output) + "\n", records, used


class Sources:
    def __init__(self, root):
        self.files = {p.relative_to(root).as_posix(): p.read_text() for p in source_files(root)}

    def locate(self, label):
        matches = []
        for name, text in self.files.items():
            for match in re.finditer(r"(?m)^" + re.escape(label) + r":(?=\s|$)", text):
                matches.append((name, match.start()))
        if len(matches) != 1:
            raise ValueError("Expected exactly one source owner for " + label)
        return matches[0]

    def before(self, label, addition):
        name, position = self.locate(label)
        text = self.files[name]
        self.files[name] = text[:position] + addition + text[position:]

    def move_block(self, item):
        name, start = self.locate(item["start"])
        end_name, end = self.locate(item["end"])
        if name != end_name or end <= start:
            raise ValueError("Move range must be contiguous in its semantic module: " + item["start"])
        text = self.files[name]
        block = text[start:end]
        self.files[name] = text[:start] + text[end:]
        self.before(item["before"], block + "\n")

    def take_table(self, label, inline=False):
        name, start = self.locate(label)
        text = self.files[name]
        pattern = re.escape(label) + (r":[^\n]*\n" if inline else r":\n(?:[ \t]+dc\.b[^\n]*\n)+")
        match = re.match(pattern, text[start:])
        if not match:
            raise ValueError("Unsupported complete table owner: " + label)
        self.files[name] = text[:start] + text[start + match.end() :]
        return match[0]

    def replace_once(self, pattern, replacement):
        count = 0
        for name, text in self.files.items():
            self.files[name], found = re.subn(pattern, replacement, text, flags=re.M)
            count += found
        if count != 1:
            raise ValueError("Expected one relocation control owner, found " + str(count))


def generate(root, revision, canonical_symbols, original):
    config = load("config/reconstruction/relocation.json", root)
    destination = root / "build/relocated" / revision
    copied = destination / "source"
    source = Sources(root)
    before_hashes = {name: hashlib.sha256((root / name).read_bytes()).hexdigest() for name in source.files}
    insertions, anchor_uses = [], []
    for name, text in source.files.items():
        transformed, records, used = duplicate_epilogues(text, config["trampolines"])
        source.files[name] = transformed
        insertions.extend({"path": name, **record} for record in records)
        anchor_uses.extend(used)
    wanted = [item["symbol"] for item in config["trampolines"]]
    if sorted(anchor_uses) != sorted(wanted):
        raise ValueError("Near trampoline owners are missing or ambiguous")
    for item in config["trampolines"]:
        at, target = canonical_symbols[item["symbol"]], canonical_symbols[item["target"]]
        if original[at : at + 6] != bytes.fromhex("4ef9") + target.to_bytes(4, "big"):
            raise ValueError("Original trampoline is not the declared absolute JMP: " + item["symbol"])
        count = 0
        for name, text in source.files.items():
            rows = []
            for line in text.splitlines():
                body, separator, comment = line.partition(";")
                if not re.search(r"\bjmpTos0?\b", body):
                    body, found = re.subn(r"\b" + re.escape(item["symbol"]) + r"\b", item["alias"], body)
                    count += found
                rows.append(body + (separator + comment if separator else ""))
            source.files[name] = "\n".join(rows) + "\n"
        if count != item["call_count"]:
            raise ValueError("Unexpected trampoline caller set: " + item["symbol"])
    for item in config["procedure_moves"] + config["table_moves"]:
        source.move_block(item)
    audio = config["audio_layout"]
    asset = source.take_table(audio["moved_asset"], inline=True)
    if not re.search(r'\bBINCLUDE\s+"[^"\n]+"', asset, re.I):
        raise ValueError("Relocated art owner must be one complete asset include")
    source.replace_once(
        r"^[ \t]*align[ \t]+" + re.escape(audio["alignment"]) + r"[ \t]*$",
        "                org Relocation_SoundHostStart",
    )
    source.before(audio["driver"], "                org Relocation_DriverStart\n")
    host_path, host_at = source.locate(audio["host"])
    driver_path, driver_at = source.locate(audio["driver"])
    if host_path != driver_path:
        raise ValueError("Sound host and compressed driver must share their layout owner")
    host_padding = source.files[host_path][host_at:driver_at].count("; unreachable relocation probe word") * 2
    append = "                org Relocation_OriginalSize\n" + asset + "                even\n"
    append += "                org Relocation_OriginalSize+" + str(audio["asset_capacity"]) + "\n"
    preserved = []
    for item in config["legacy_reads"]["slopes"]:
        table = source.take_table(item["label"])
        at = canonical_symbols[item["label"]]
        if at + item["index"] >= len(original):
            raise ValueError("Legacy slope read leaves the original image")
        sentinel = original[at + item["index"]]
        append += (
            table + f"                ds.b {item['index']}-(*-{item['label']})\n                dc.b ${sentinel:02X}\n"
        )
        preserved.append(
            {
                "label": item["label"],
                "kind": "slope_sentinel",
                "index": item["index"],
                "byte": sentinel,
                "source_offset": at + item["index"],
            }
        )
    window = config["legacy_reads"]["slot_window"]
    source.take_table(window["label"], inline=True)
    at = canonical_symbols[window["label"]]
    data = original[at : at + window["size"]]
    if len(data) != window["size"]:
        raise ValueError("Legacy slot lookup leaves the original image")
    path = destination / "legacy-slot-window.bin"
    atomic_write(path, data)
    append += window["label"] + ':\n                binclude "' + path.relative_to(root).as_posix() + '"\n'
    preserved.append(
        {
            "label": window["label"],
            "kind": "source_as_lookup_data",
            "size": len(data),
            "sha256": hashlib.sha256(data).hexdigest(),
            "source_offset": at,
        }
    )
    padding = r"^[ \t]*if[ \t]+\(\*-StartOfRom\)&\(\*-StartOfRom-1\)[ \t]*$"
    source.replace_once(padding, lambda match: append + match[0])
    for name, text in source.files.items():

        def include(match):
            target = match[2]
            if target not in source.files:
                return match[0]
            return match[1] + (copied / target).relative_to(root).as_posix() + match[3]

        text = re.sub(r'(\binclude\s+")([^"\n]+)(")', include, text, flags=re.I)
        atomic_write(copied / name, text.encode())
    if any(hashlib.sha256((root / name).read_bytes()).hexdigest() != value for name, value in before_hashes.items()):
        raise ValueError("Canonical source changed while preparing the probe")
    defines = {
        "Relocation_OriginalSize": len(original),
        "Relocation_SoundHostStart": canonical_symbols[audio["host"]] - host_padding,
        "Relocation_DriverStart": canonical_symbols[audio["driver"]],
    }
    return (
        copied,
        defines,
        {
            "source_hashes": before_hashes,
            "insertions": insertions,
            "terminal_return_words": len(insertions),
            "near_trampolines": len(anchor_uses),
            "legacy_reads": preserved,
            "sound_host_padding_bytes": host_padding,
        },
    )


def build(revision=None, root=ROOT):
    selected = profile(revision, root)
    revision = selected["id"]
    verify(revision, root)
    canonical_folder = (root / selected["output"]).parent
    canonical = symbols(canonical_folder / "main.lst")
    original = reference(revision, root)
    copied, extra, report = generate(root, revision, canonical, original)
    assembler, p2bin = toolchain(root)
    prepare_audio(root=root)
    directory = root / "build/relocated" / revision
    entry = directory / "main.asm"
    defines = {**selected["defines"], **extra}
    wrapper = "".join(name + " = " + str(value) + "\n" for name, value in defines.items())
    wrapper += '\tinclude "' + (copied / profiles(root)["entry"]).relative_to(root).as_posix() + '"\n'
    atomic_write(entry, wrapper.encode())
    output = directory / "sonic2.bin"
    assemble_image(entry, output, assembler, p2bin, root, logical_size=len(original))
    relocated = symbols(entry.with_suffix(".lst"))
    data = output.read_bytes()
    config = load("config/reconstruction/relocation.json", root)
    audio = config["audio_layout"]
    for label in [audio["driver"], *audio["bank_labels"]]:
        if relocated[label] != canonical[label]:
            raise ValueError("Original audio layout changed: " + label)
    manifest = load("assets/manifest.json", root)
    driver = next(
        item for item in manifest["assets"] if item["path"] == load("config/audio.json", root)["driver_data"]["asset"]
    )
    at = relocated[audio["driver"]]
    if data[at : at + driver["size"]] != original[driver["offset"] : driver["offset"] + driver["size"]]:
        raise ValueError("Original compressed driver stream changed")
    if relocated["StartOfRom"] != 0:
        raise ValueError("Fixed vector origin moved")
    missing = sorted(name for name in canonical if not name.startswith("__") and name not in relocated)
    if missing:
        raise ValueError("Original symbols disappeared: " + ", ".join(missing[:12]))
    for item in report["legacy_reads"]:
        at = relocated[item["label"]]
        if item["kind"] == "slope_sentinel":
            expected = original[
                canonical[item["label"]] : canonical[item["label"]]
                + next(v["size"] for v in config["legacy_reads"]["slopes"] if v["label"] == item["label"])
            ]
            if data[at : at + len(expected)] != expected or data[at + item["index"]] != item["byte"]:
                raise ValueError("Legacy slope lookup differs from the original")
        elif hashlib.sha256(data[at : at + item["size"]]).hexdigest() != item["sha256"]:
            raise ValueError("Legacy slot lookup window differs from the original")
    report.update(
        config_sha256=hashlib.sha256((root / "config/reconstruction/relocation.json").read_bytes()).hexdigest(),
        profile=revision,
        physical_size=len(data),
        logical_size=len(original),
        sha256=hashlib.sha256(data).hexdigest(),
        header_policy=config["header_policy"],
        source_unchanged=True,
        shifted_symbol_values=sum(canonical[name] != relocated[name] for name in canonical if name in relocated),
    )
    atomic_write(directory / "report.json", (json.dumps(report, indent=2) + "\n").encode())
    print(
        f"[OK] {revision}: {report['terminal_return_words']} unreachable return words, {report['shifted_symbol_values']} shifted symbol values"
    )
    return output


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--revision")
    parser.add_argument("--all", action="store_true")
    args = parser.parse_args()
    for item in profiles()["profiles"] if args.all else [profile(args.revision)]:
        build(item["id"])


if __name__ == "__main__":
    main()
