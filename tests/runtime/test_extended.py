"""Require real reached states, motion and exact original controller routes."""

from copy import deepcopy
from pathlib import Path
import hashlib
import tempfile
import unittest
from scripts.build.project import ROOT
from scripts.runtime.extended import check_spec, movie_runs, reached


class ExtendedRuntimeTests(unittest.TestCase):
    def test_state_order_and_motion_are_required(self):
        case = {
            "id": "route",
            "required_states": [{"after": 1, "values": {"mode": "04"}}, {"after": 2, "values": {"mode": "0c"}}],
            "motion_after": 2,
            "motion_cells": ["x"],
        }
        expected = {"1": {"mode": "04", "x": "00"}, "2": {"mode": "0c", "x": "10"}, "3": {"mode": "0c", "x": "11"}}
        reached(expected, case)
        for altered in (
            {"2": expected["2"], "3": expected["3"]},
            {"1": expected["1"], "2": expected["2"], "3": expected["2"]},
        ):
            with self.assertRaises(ValueError):
                reached(altered, case)

    def test_exact_movie_ram_addresses_and_checkpoint_matrix(self):
        parent = ROOT / "build/tests/extended"
        parent.mkdir(parents=True, exist_ok=True)
        with tempfile.TemporaryDirectory(dir=parent) as folder:
            root = Path(folder)
            movie = (
                "# retrolarium movie 1\nplatform megadrive\nsource mame\nframes 3\noffset 0\n---\n1 00 00\n2 08 00\n"
            )
            (root / "route.rlmovie").write_bytes(movie.encode())
            case = {
                "id": "route",
                "frames": 3,
                "checkpoints": [1, 2, 3],
                "movie_sha256": hashlib.sha256(movie.encode()).hexdigest(),
                "required_states": [{"after": 1, "values": {"x": "10"}}],
                "motion_after": 1,
                "motion_cells": ["x"],
            }
            config = {"machine": "genesis", "watches": {"x": {"symbol": "Player", "length": 1}}}
            spec = {
                "schema": "retrolarium.movie-check",
                "schema_version": 1,
                "source_profile": "rev00",
                "machine": "genesis",
                "frames": [1, 2, 3],
                "movie": "route.rlmovie",
                "cells": {"x": {"symbol": "Player", "address": "0xff0000", "length": 1}},
                "expected": {"1": {"x": "10"}, "2": {"x": "11"}, "3": {"x": "12"}},
            }

            def check(value):
                check_spec(value, case, config, {"Player": 0xFF0000}, root / "check.json", "rev00", root)

            check(spec)
            for kind in ("address", "tolerance", "checkpoint", "profile"):
                changed = deepcopy(spec)
                if kind == "address":
                    changed["cells"]["x"]["address"] = "0xff0010"
                elif kind == "tolerance":
                    changed["cells"]["x"]["tolerance"] = 1
                elif kind == "checkpoint":
                    changed["expected"].pop("2")
                else:
                    changed["source_profile"] = "rev01"
                with self.subTest(kind=kind), self.assertRaises(ValueError):
                    check(changed)
            (root / "route.rlmovie").write_bytes(movie.replace("08", "04").encode())
            with self.assertRaisesRegex(ValueError, "changed"):
                check(spec)
            with self.assertRaises(ValueError):
                movie_runs(movie.replace("---", "power_on unsafe\n---"), 3)
