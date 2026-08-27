"""Registration quality policy shared by tests and ROS adapters."""

import math


class LocalizationQualityGate:
    def __init__(self, min_fitness=0.55, max_rmse=0.30, required_confirmations=2):
        if not 0.0 <= min_fitness <= 1.0:
            raise ValueError("min_fitness must be in [0, 1]")
        if max_rmse <= 0.0:
            raise ValueError("max_rmse must be positive")
        if required_confirmations < 1:
            raise ValueError("required_confirmations must be positive")
        self.min_fitness = float(min_fitness)
        self.max_rmse = float(max_rmse)
        self.required_confirmations = int(required_confirmations)
        self.confirmations = 0

    def reset(self):
        self.confirmations = 0

    def observe(self, fitness, rmse):
        good = (
            math.isfinite(fitness)
            and math.isfinite(rmse)
            and fitness >= self.min_fitness
            and rmse <= self.max_rmse
        )
        self.confirmations = self.confirmations + 1 if good else 0
        return self.confirmations >= self.required_confirmations
