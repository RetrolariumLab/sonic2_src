"""Resolve the exact external AS build in an ignored, verified project cache."""

import hashlib
from pathlib import Path
from urllib.parse import urlsplit
from urllib.request import urlopen
from scripts.build.project import atomic_write, host_id, project_path


def checked_bytes(data, record):
    if len(data) != record["size"] or hashlib.sha256(data).hexdigest() != record["sha256"]:
        raise ValueError("External AS dependency hash or size mismatch")
    return data


def cached_file(record, root):
    name = record["path"]
    if not isinstance(name, str) or not name.startswith("build/tools/as-313/") or "\\" in name:
        raise ValueError("External AS cache path is outside its owner")
    target = project_path(name, root)
    cache = project_path("build/tools/as-313", root).resolve()
    if target.resolve() == cache or not target.resolve().is_relative_to(cache):
        raise ValueError("External AS cache path is outside its owner")
    if target.exists():
        checked_bytes(target.read_bytes(), record)
    else:
        parsed = urlsplit(record["url"])
        if parsed.scheme != "https" or parsed.hostname != "raw.githubusercontent.com":
            raise ValueError("External AS dependency must use its pinned HTTPS source")
        with urlopen(record["url"], timeout=60) as response:
            data = response.read(record["size"] + 1)
        atomic_write(target, checked_bytes(data, record))
    return target


def assembler(config, root):
    host = host_id()
    if host not in config["hosts"]:
        raise ValueError("This host has no pinned external AS dependency")
    cached_file(config["license"], root)
    target = cached_file(config["hosts"][host], root)
    if host.startswith("linux-"):
        target.chmod(target.stat().st_mode | 0o111)
    return target
