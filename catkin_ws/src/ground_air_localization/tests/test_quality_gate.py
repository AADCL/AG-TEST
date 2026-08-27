#!/usr/bin/env python3
import math
import sys
from pathlib import Path
import unittest


SOURCE = Path(__file__).resolve().parents[1] / "src"
sys.path.insert(0, str(SOURCE))

from ground_air_localization.localization_quality import LocalizationQualityGate  # noqa: E402


class LocalizationQualityGateTests(unittest.TestCase):
    def setUp(self):
        self.gate = LocalizationQualityGate(
            min_fitness=0.55, max_rmse=0.30, required_confirmations=2
        )

    def test_requires_two_consecutive_good_results(self):
        self.assertFalse(self.gate.observe(0.75, 0.12))
        self.assertTrue(self.gate.observe(0.72, 0.14))

    def test_bad_result_resets_confirmation_count(self):
        self.gate.observe(0.8, 0.1)
        self.assertFalse(self.gate.observe(0.2, 0.1))
        self.assertFalse(self.gate.observe(0.8, 0.1))
        self.assertTrue(self.gate.observe(0.8, 0.1))

    def test_rejects_high_rmse_and_non_finite_values(self):
        for fitness, rmse in ((0.9, 0.31), (math.nan, 0.1), (0.9, math.inf)):
            self.assertFalse(self.gate.observe(fitness, rmse))


if __name__ == "__main__":
    unittest.main()
