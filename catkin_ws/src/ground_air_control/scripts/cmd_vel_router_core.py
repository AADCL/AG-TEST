#!/usr/bin/env python3
"""Pure exclusive velocity routing policy."""

from dataclasses import dataclass
import math


@dataclass(frozen=True)
class RouteDecision:
    channel: str
    command: tuple


class CmdVelRouterCore:
    GROUND_MODES = {"ground"}
    AIR_MODES = {"airborne"}

    def __init__(self, timeout=0.5):
        self.timeout = float(timeout)
        if not math.isfinite(self.timeout) or self.timeout <= 0.0:
            raise ValueError("timeout must be positive")
        self.mode = "unknown"
        self.emergency_stop = False
        self.last_command = (0.0, 0.0, 0.0)
        self.last_command_stamp = float("-inf")
        self.last_channel = "stop"

    def set_mode(self, mode):
        self.mode = str(mode)
        if self.mode not in self.GROUND_MODES | self.AIR_MODES:
            self.last_channel = "stop"

    def set_emergency_stop(self, active):
        self.emergency_stop = bool(active)
        if self.emergency_stop:
            self.last_channel = "stop"
            self.last_command = (0.0, 0.0, 0.0)

    def accept(self, command, now):
        vx, vy, yaw_rate = (float(value) for value in command)
        if not all(math.isfinite(value) for value in (vx, vy, yaw_rate)):
            return self._stop()
        if self.emergency_stop:
            return self._stop()
        if self.mode in self.GROUND_MODES:
            routed = (vx, 0.0, yaw_rate)
            channel = "ground"
        elif self.mode in self.AIR_MODES:
            routed = (vx, vy, yaw_rate)
            channel = "air"
        else:
            return self._stop()
        self.last_command = routed
        self.last_command_stamp = float(now)
        self.last_channel = channel
        return RouteDecision(channel, routed)

    def tick(self, now):
        if self.emergency_stop:
            return self._stop()
        if float(now) - self.last_command_stamp > self.timeout:
            return self._stop()
        return RouteDecision(self.last_channel, self.last_command)

    def _stop(self):
        self.last_channel = "stop"
        self.last_command = (0.0, 0.0, 0.0)
        return RouteDecision("stop", self.last_command)
