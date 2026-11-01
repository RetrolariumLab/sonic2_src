"""Remove only manifest-owned canonical and relocation profile outputs."""

from scripts.validation.source1 import clean_profile_outputs


def main():
    clean_profile_outputs()
    print("[OK] Removed canonical and relocated profile outputs; inputs and other build workspaces remain")
