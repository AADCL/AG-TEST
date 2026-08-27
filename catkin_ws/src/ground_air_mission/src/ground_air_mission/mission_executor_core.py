#!/usr/bin/env python3
"""ROS-independent ordered mission state machine."""

from enum import IntEnum


class MissionError(RuntimeError):
    pass


class MissionState(IntEnum):
    IDLE = 0
    RUNNING = 1
    DWELLING = 2
    PAUSED = 3
    SUCCEEDED = 4
    FAILED = 5
    CANCELED = 6
    WAITING_FOR_LAND = 7


class MissionExecutorCore:
    ACTIVE_STATES = {
        MissionState.RUNNING,
        MissionState.DWELLING,
        MissionState.PAUSED,
        MissionState.WAITING_FOR_LAND,
    }

    def __init__(self, dwell_seconds=2.0):
        if dwell_seconds < 0.0:
            raise ValueError("dwell_seconds must be non-negative")
        self.dwell_seconds = float(dwell_seconds)
        self.state = MissionState.IDLE
        self.mission_id = ""
        self.goals = []
        self.current_index = 0
        self.detail = "idle"
        self._dwell_until = None
        self._paused_from = None
        self._remaining_dwell = None
        self._final_goal_airborne = False

    @property
    def total_goals(self):
        return len(self.goals)

    def submit(self, mission_id, goals, localized, emergency_stop):
        if self.state in self.ACTIVE_STATES:
            raise MissionError("a mission is already active")
        if emergency_stop:
            raise MissionError("emergency stop is active")
        if not localized:
            raise MissionError("vehicle is not localized")
        if not goals:
            raise MissionError("mission contains no goals")
        self.mission_id = str(mission_id)
        self.goals = list(goals)
        self.current_index = 0
        self.state = MissionState.IDLE
        self.detail = "mission accepted"
        self._dwell_until = None
        self._paused_from = None
        self._remaining_dwell = None
        self._final_goal_airborne = False

    def start(self):
        if not self.goals:
            raise MissionError("no mission has been submitted")
        if self.state != MissionState.IDLE:
            raise MissionError("mission cannot be started from current state")
        self.state = MissionState.RUNNING
        self.detail = "navigating to goal {}".format(self.current_index)
        return "send_goal", self.goals[self.current_index]

    def on_goal_succeeded(self, now, airborne):
        if self.state != MissionState.RUNNING:
            raise MissionError("goal result received while not navigating")
        self.state = MissionState.DWELLING
        self._dwell_until = float(now) + self.dwell_seconds
        self._final_goal_airborne = bool(airborne)
        self.detail = "dwelling at goal {}".format(self.current_index)
        return "stop", None

    def on_goal_failed(self, detail):
        if self.state != MissionState.RUNNING:
            raise MissionError("goal failure received while not navigating")
        self.state = MissionState.FAILED
        self.detail = str(detail)
        return "stop", None

    def tick(self, now, localized, emergency_stop):
        if self.state in self.ACTIVE_STATES and (emergency_stop or not localized):
            self.state = MissionState.FAILED
            self.detail = "emergency stop" if emergency_stop else "localization lost"
            return "cancel_and_stop", None

        if self.state != MissionState.DWELLING:
            return None
        if float(now) < self._dwell_until:
            return None

        if self.current_index + 1 < len(self.goals):
            self.current_index += 1
            self.state = MissionState.RUNNING
            self._dwell_until = None
            self.detail = "navigating to goal {}".format(self.current_index)
            return "send_goal", self.goals[self.current_index]

        self._dwell_until = None
        if self._final_goal_airborne:
            self.state = MissionState.WAITING_FOR_LAND
            self.detail = "final goal reached; waiting for explicit land command"
            return "hover", None
        self.state = MissionState.SUCCEEDED
        self.detail = "mission completed"
        return "stop", None

    def pause(self, now):
        if self.state not in (MissionState.RUNNING, MissionState.DWELLING):
            raise MissionError("mission is not running")
        self._paused_from = self.state
        if self.state == MissionState.DWELLING:
            self._remaining_dwell = max(0.0, self._dwell_until - float(now))
            action = ("stop", None)
        else:
            action = ("cancel_goal", None)
        self.state = MissionState.PAUSED
        self.detail = "mission paused"
        return action

    def resume(self, now, localized, emergency_stop):
        if self.state != MissionState.PAUSED:
            raise MissionError("mission is not paused")
        if emergency_stop:
            raise MissionError("emergency stop is active")
        if not localized:
            raise MissionError("vehicle is not localized")
        if self._paused_from == MissionState.DWELLING:
            self.state = MissionState.DWELLING
            self._dwell_until = float(now) + self._remaining_dwell
            self.detail = "dwelling at goal {}".format(self.current_index)
            return "stop", None
        self.state = MissionState.RUNNING
        self.detail = "navigating to goal {}".format(self.current_index)
        return "send_goal", self.goals[self.current_index]

    def cancel(self):
        if self.state not in self.ACTIVE_STATES and self.state != MissionState.IDLE:
            raise MissionError("mission is not active")
        self.state = MissionState.CANCELED
        self.detail = "mission canceled"
        return "cancel_and_stop", None
