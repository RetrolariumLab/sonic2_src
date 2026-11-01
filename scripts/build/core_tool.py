"""Build and verify the pinned public Core CLI without modifying its source."""

import argparse
import hashlib
import json
import os
from pathlib import Path
import subprocess
from scripts.build.project import ROOT, atomic_write, load, project_path

RECEIPT = "build/tools/core-tool.json"


def sha(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def get(root=ROOT):
    path = root / RECEIPT
    if not path.is_file():
        raise ValueError("Core CLI is not prepared; run make prepare-core CORE_SOURCE=path/to/retrolarium-core")
    receipt = json.loads(path.read_text())
    expected = load("config/toolchain.json", root)["core"]
    if receipt["source_commit"] != expected["commit"] or receipt["source_url"] != expected["source"]:
        raise ValueError("Prepared Core tool differs from the pinned source")
    tool = project_path(receipt["path"], root)
    if not tool.is_file() or sha(tool) != receipt["sha256"]:
        raise ValueError("Prepared Core executable differs from its receipt")
    return tool


def prepare(source=None, generator=None, root=ROOT):
    try:
        return get(root)
    except ValueError:
        if not source:
            raise
    source = Path(source).resolve()
    expected = load("config/toolchain.json", root)["core"]

    def state():
        commit = subprocess.check_output(["git", "-C", str(source), "rev-parse", "HEAD"], text=True).strip()
        changed = subprocess.check_output(
            ["git", "-C", str(source), "status", "--porcelain", "--untracked-files=no"], text=True
        ).strip()
        if commit != expected["commit"] or changed:
            raise ValueError("CORE_SOURCE must be a clean checkout of the pinned public Core commit")

    state()
    folder = root / "build/tools/core"
    temporary = root / "build/tools/tmp"
    temporary.mkdir(parents=True, exist_ok=True)
    env = dict(os.environ, TEMP=str(temporary), TMP=str(temporary), TMPDIR=str(temporary))
    command = [
        "cmake",
        "-S",
        str(source),
        "-B",
        str(folder),
        "-DRETROLARIUM_CORE_BUILD_CLI=ON",
        "-DRETROLARIUM_CORE_BUILD_TESTS=OFF",
    ]
    if generator:
        command += ["-G", generator]
    if os.name == "nt" and (generator or env.get("CMAKE_GENERATOR", "")).startswith("Visual Studio"):
        command += ["-A", "x64"]
    subprocess.run(command, cwd=root, env=env, check=True, timeout=300)
    subprocess.run(
        ["cmake", "--build", str(folder), "--config", "Release", "--parallel", "1"],
        cwd=root,
        env=env,
        check=True,
        timeout=900,
    )
    state()
    candidates = [folder / "Release/rlcore.exe", folder / "rlcore.exe", folder / "rlcore"]
    existing = [path for path in candidates if path.is_file()]
    if len(existing) != 1:
        raise ValueError("Core build did not produce exactly one expected CLI executable")
    tool = existing[0]
    version = subprocess.check_output([str(tool), "version"], text=True, env=env).strip()
    receipt = {
        "schema_version": 1,
        "path": tool.relative_to(root).as_posix(),
        "sha256": sha(tool),
        "version": version,
        "source_url": expected["source"],
        "source_commit": expected["commit"],
        "source_tracked_clean": True,
        "build_configuration": "Release",
        "build_parallelism": 1,
    }
    atomic_write(root / RECEIPT, (json.dumps(receipt, indent=2) + "\n").encode())
    return get(root)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--source", default=os.environ.get("CORE_SOURCE"))
    parser.add_argument("--generator", default=os.environ.get("CMAKE_GENERATOR"))
    args = parser.parse_args()
    print("[OK] Core CLI: " + prepare(args.source, args.generator).relative_to(ROOT).as_posix())
