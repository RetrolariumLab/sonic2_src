"""Run a project command from any working directory."""
from pathlib import Path
import importlib
import sys

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT))

def main():
    if len(sys.argv) < 2:
        raise SystemExit("Usage: python scripts/run.py <category.module> [arguments]")
    module = sys.argv.pop(1)
    if not module.startswith(("build.", "validation.", "runtime.", "authoring.")):
        raise SystemExit("Unknown project command category")
    importlib.import_module("scripts." + module).main()

if __name__ == "__main__":
    main()
