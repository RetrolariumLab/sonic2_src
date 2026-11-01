"""Pinned compression backends with project-owned temporary files and byte APIs."""

from pathlib import Path
import os
import subprocess
from scripts.build.project import ROOT, project_path
from scripts.build.temporary import temporary_directory
from scripts.build.core_tool import get
from scripts.authoring.enigma_s2 import decode as enigma_decode
from scripts.authoring.kosinski_s2 import decode as kosinski_decode, encode as kosinski_encode
from scripts.authoring.saxman import decode as saxman_decode, encode as saxman_encode


def native(codec, action, data, reference=None, root=ROOT):
    tool = get(root)
    parent = project_path("build/authoring/tmp", root)
    with temporary_directory(parent) as directory:
        directory = Path(directory)
        source = directory / "input.bin"
        output = directory / "output.bin"
        source.write_bytes(data)
        args = [str(tool), codec, action, str(source)]
        if reference is not None:
            ref = directory / "reference.bin"
            ref.write_bytes(reference)
            args.append(str(ref))
        args.append(str(output))
        env = dict(os.environ, TEMP=str(directory), TMP=str(directory), TMPDIR=str(directory))
        result = subprocess.run(args, cwd=root, env=env, stdout=subprocess.PIPE, stderr=subprocess.STDOUT, timeout=120)
        if result.returncode or not output.is_file():
            raise ValueError("Core " + codec + " " + action + " failed: " + result.stdout.decode(errors="replace"))
        return output.read_bytes()


def decode(kind, data, max_output=0x100000, driver_trailer=1, root=ROOT):
    if kind == "none":
        plain = bytes(data)
    elif kind == "nemesis":
        plain = native("nemesis", "decompress", data, root=root)
    elif kind == "enigma-s2":
        plain = enigma_decode(data, max_output=max_output)
    elif kind == "kosinski":
        plain = kosinski_decode(data, max_output=max_output)
    elif kind == "saxman":
        plain = saxman_decode(data, max_output=max_output)
    elif kind == "saxman-driver-trailer":
        if not 0 < driver_trailer < len(data):
            raise ValueError("Invalid driver trailer extent")
        plain = saxman_decode(data[:-driver_trailer], with_size=False, max_output=max_output)
    else:
        raise ValueError("Unknown compression container")
    if len(plain) > max_output:
        raise ValueError("Decoded payload exceeds its context capacity")
    return plain


def encode(kind, plain, reference=None, driver_trailer=b"", root=ROOT):
    if kind == "none":
        result = bytes(plain)
    elif kind == "nemesis":
        if reference is None:
            raise ValueError("Nemesis reference coding table is required")
        result = native("nemesis", "compress", plain, reference, root)
    elif kind == "enigma-s2":
        result = native("enigma", "compress", plain, root=root)
    elif kind == "kosinski":
        result = kosinski_encode(plain)
    elif kind == "saxman":
        result = saxman_encode(plain)
    elif kind == "saxman-driver-trailer":
        if not driver_trailer:
            raise ValueError("Original driver trailer is required")
        result = saxman_encode(plain, with_size=False) + driver_trailer
    else:
        raise ValueError("Unknown compression container")
    recovered = decode(
        kind, result, max_output=len(plain), driver_trailer=len(driver_trailer) if driver_trailer else 1, root=root
    )
    if recovered != plain:
        raise ValueError("Encoded content differs after decompression")
    return result
