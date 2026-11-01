"""Reject incomplete goldens, input changes and moved RAM watches without ROMs."""

import copy
from pathlib import Path
import tempfile
import unittest
from scripts.build.project import ROOT, load
from scripts.runtime.movies import validate_check


class RuntimeContractTests(unittest.TestCase):
    def setUp(self):
        self.config = load("config/runtime.json")
        self.path = ROOT / self.config["scenarios"][0]["check"]
        self.spec = load(self.path.relative_to(ROOT))
        self.symbols = {"x_pos": 8, "y_pos": 12}
        for cell in self.spec["cells"].values():
            parts = cell["symbol"].split("+")
            self.symbols[parts[0]] = int(cell["address"], 0) - sum(self.symbols[part] for part in parts[1:])
        self.symbols.update(emerald_hill_zone=0, casino_night_zone=12, chemical_plant_zone=13, aquatic_ruin_zone=15)

    def validate(self, spec=None, path=None):
        return validate_check(spec or self.spec, self.config, self.symbols, path or self.path)

    def test_both_complete_goldens_require_full_2p_attract_coverage(self):
        for scenario in self.config["scenarios"]:
            path = ROOT / scenario["check"]
            result = self.validate(load(scenario["check"]), path)
            self.assertEqual(result["comparisons"], 3582)
            self.assertIn(("00", "0001"), result["zone_two_player_pairs"])

    def test_missing_checkpoint_or_cell_cannot_produce_a_green_check(self):
        for kind in ["frame", "value", "watch"]:
            spec = copy.deepcopy(self.spec)
            if kind == "frame":
                spec["expected"].pop("600")
            elif kind == "value":
                spec["expected"]["600"].pop("score")
            else:
                spec["cells"].pop("score")
            with self.subTest(kind=kind), self.assertRaises(ValueError):
                self.validate(spec)

    def test_tolerances_alignment_offsets_and_changed_ram_addresses_are_rejected(self):
        for kind in ["tolerance", "offset", "address"]:
            spec = copy.deepcopy(self.spec)
            if kind == "tolerance":
                spec["cells"]["player_x"]["tolerance"] = 1
            elif kind == "offset":
                spec["offset"] = 1
            else:
                spec["cells"]["player_x"]["address"] = "0xffb00a"
            with self.subTest(kind=kind), self.assertRaises(ValueError):
                self.validate(spec)

    def test_two_player_coverage_is_mandatory(self):
        spec = copy.deepcopy(self.spec)
        for values in spec["expected"].values():
            values["two_player"] = "0000"
        with self.assertRaisesRegex(ValueError, "two-player"):
            self.validate(spec)

    def test_nonzero_input_or_ram_initialization_is_rejected(self):
        parent = ROOT / "build/tests"
        parent.mkdir(parents=True, exist_ok=True)
        with tempfile.TemporaryDirectory(dir=parent) as directory:
            folder = Path(directory)
            text = (self.path.parent / self.spec["movie"]).read_text()
            for altered in [text.replace("60000 00 00", "60000 01 00"), text.replace("---", "power_on ff\n---")]:
                (folder / "bad.rlmovie").write_text(altered)
                spec = copy.deepcopy(self.spec)
                spec["movie"] = "bad.rlmovie"
                with self.assertRaises(ValueError):
                    self.validate(spec, folder / "check.json")
