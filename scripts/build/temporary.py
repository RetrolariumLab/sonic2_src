"""Own short-lived build directories and retry transient Windows cleanup locks."""

from contextlib import contextmanager
from pathlib import Path
import shutil
import tempfile
import time


def remove_owned(directory, parent):
    directory = Path(directory)
    parent = Path(parent).resolve()
    for delay in (0, 0.05, 0.1, 0.2, 0.4, 0.8):
        if delay:
            time.sleep(delay)
        resolved = directory.resolve()
        if resolved == parent or not resolved.is_relative_to(parent):
            raise ValueError("Refusing to remove a temporary directory outside its owner")
        try:
            shutil.rmtree(directory)
            return
        except FileNotFoundError:
            if not directory.exists():
                return
            raise
        except OSError as error:
            transient = isinstance(error, PermissionError) or getattr(error, "winerror", None) in {5, 32, 145}
            if not transient or delay == 0.8:
                raise


@contextmanager
def temporary_directory(parent):
    parent = Path(parent)
    parent.mkdir(parents=True, exist_ok=True)
    directory = Path(tempfile.mkdtemp(prefix="codec-", dir=parent))
    try:
        yield directory
    finally:
        remove_owned(directory, parent)
