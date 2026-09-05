#!/usr/bin/env python3
"""Pure safety state machine for the ground-air vehicle."""

from enum import Enum
import math


class TransitionError(RuntimeError):
    pass


class Mode(Enum):
    UNKNOWN = "unknown"
    GROUND = "ground"
    SWITCHING_TO_AIR = "switching_to_air"
    AIR_READY = "air_ready"
    TAKEOFF = "takeoff"
    AIRBORNE = "airborne"
    LANDING = "landing"
    SWITCHING_TO_GROUND = "switching_to_ground"
    ESTOP = "estop"
    FAULT = "fault"


class ModeManagerCore:
    def __init__(
        self,
        takeoff_height=1.0,
        telemetry_timeout=0.5,
        min_flight_altitude=0.5,
        max_flight_altitude=3.0,
    ):
        telemetry_timeout = float(telemetry_timeout)
        self.min_flight_altitude = float(min_flight_altitude)
        self.max_flight_altitude = float(max_flight_altitude)
        if (
            not math.isfinite(self.min_flight_altitude)
            or not math.isfinite(self.max_flight_altitude)
            or self.min_flight_altitude <= 0.0
            or self.max_flight_altitude <= self.min_flight_altitude
        ):
            raise ValueError("flight altitude limits are invalid")
        if not math.isfinite(telemetry_timeout) or telemetry_timeout <= 0.0:
            raise ValueError("telemetry_timeout must be positive")
        self.takeoff_height = 0.0
        self.set_takeoff_height(takeoff_height)
        self.telemetry_timeout = telemetry_timeout
        self.state = Mode.UNKNOWN
        self.emergency_stop = False
        self.detail = "waiting for telemetry"
        self.connected = False
        self.armed = False
        self.physical_mode = "unknown"
        self.altitude = 0.0
        self.telemetry_stamp = float("-inf")
        self.pose_stamp = float("-inf")

    def validate_flight_altitude(self, altitude):
        altitude = float(altitude)
        if not math.isfinite(altitude):
            raise ValueError("flight altitude must be finite")
        if not self.min_flight_altitude <= altitude <= self.max_flight_altitude:
            raise ValueError(
                "flight altitude must be within [{:.2f}, {:.2f}] m".format(
                    self.min_flight_altitude, self.max_flight_altitude
                )
            )
        return altitude

    def set_takeoff_height(self, altitude):
        self.takeoff_height = self.validate_flight_altitude(altitude)
        return self.takeoff_height

    def set_flight_target(self, now, altitude):
        self._require_not_estopped()
        self._require_fresh(now)
        if self.state is not Mode.AIRBORNE or self.physical_mode != "air":
            raise TransitionError("altitude change requires airborne state")
        altitude = self.validate_flight_altitude(altitude)
        self.detail = "tracking flight altitude {:.2f} m".format(altitude)
        return altitude

    def update_telemetry(
        self, now, connected, armed, physical_mode, altitude, pose_stamp
    ):
        if physical_mode not in ("unknown", "ground", "air"):
            raise ValueError("physical_mode must be unknown, ground, or air")
        self.connected = bool(connected)
        self.armed = bool(armed)
        self.physical_mode = physical_mode
        self.altitude = float(altitude)
        self.telemetry_stamp = float(now)
        self.pose_stamp = float(pose_stamp)
        if self.state is Mode.UNKNOWN and self.connected:
            self.synchronize_from_telemetry()

    def synchronize_from_telemetry(self):
        if self.emergency_stop:
            self.state = Mode.ESTOP
        elif not self.connected:
            self.state = Mode.UNKNOWN
        elif self.physical_mode == "ground":
            self.state = Mode.GROUND
        elif self.physical_mode == "air" and self.armed:
            self.state = Mode.AIRBORNE
        elif self.physical_mode == "air":
            self.state = Mode.AIR_READY
        else:
            self.state = Mode.UNKNOWN
        self.detail = "synchronized from telemetry"

    def _require_fresh(self, now):
        now = float(now)
        if not self.connected:
            raise TransitionError("FCU is not connected")
        if now - self.telemetry_stamp > self.telemetry_timeout:
            raise TransitionError("vehicle telemetry is stale")
        if now - self.pose_stamp > self.telemetry_timeout:
            raise TransitionError("local pose is stale")

    def _require_not_estopped(self):
        if self.emergency_stop or self.state is Mode.ESTOP:
            raise TransitionError("emergency stop is latched")

    def begin_switch_to_air(self, now):
        self._require_not_estopped()
        self._require_fresh(now)
        if self.state is not Mode.GROUND or self.armed:
            raise TransitionError("air switch requires disarmed ground mode")
        self.state = Mode.SWITCHING_TO_AIR
        self.detail = "switching to air configuration"

    def finish_switch_to_air(self, success):
        if self.state is not Mode.SWITCHING_TO_AIR:
            raise TransitionError("air switch is not active")
        if not success or self.physical_mode != "air":
            self.state = Mode.FAULT
            self.detail = "air configuration was not observed"
            raise TransitionError(self.detail)
        self.state = Mode.AIR_READY
        self.detail = "air configuration ready"

    def begin_takeoff(self, now):
        self._require_not_estopped()
        self._require_fresh(now)
        if self.state is not Mode.AIR_READY or self.physical_mode != "air":
            raise TransitionError("takeoff requires confirmed air configuration")
        if self.armed:
            raise TransitionError("takeoff requires a disarmed vehicle")
        self.state = Mode.TAKEOFF
        self.detail = "taking off to {:.2f} m".format(self.takeoff_height)

    def takeoff_requires_air_switch(self, now):
        """Return whether takeoff must first change the physical configuration."""
        self._require_not_estopped()
        self._require_fresh(now)
        if self.armed:
            raise TransitionError("takeoff requires a disarmed vehicle")
        if self.state is Mode.GROUND and self.physical_mode == "ground":
            return True
        if self.state is Mode.AIR_READY and self.physical_mode == "air":
            return False
        raise TransitionError("takeoff requires ground or confirmed air-ready state")

    def ground_disarm_required_for_takeoff(self, now):
        """Validate the pre-transition state and report whether ground is armed."""
        self._require_not_estopped()
        self._require_fresh(now)
        if self.state is Mode.GROUND and self.physical_mode == "ground":
            return self.armed
        if self.state is Mode.AIR_READY and self.physical_mode == "air":
            return False
        raise TransitionError(
            "takeoff preparation requires ground or confirmed air-ready state"
        )

    def begin_ground_navigation(self, now):
        self._require_not_estopped()
        self._require_fresh(now)
        if self.state is not Mode.GROUND or self.physical_mode != "ground":
            raise TransitionError("ground navigation requires ground configuration")
        self.detail = "preparing ground navigation"

    def finish_ground_navigation(self, success, flight_mode):
        if (
            not success
            or not self.armed
            or self.physical_mode != "ground"
            or str(flight_mode).upper() != "OFFBOARD"
        ):
            self.state = Mode.FAULT
            self.detail = "ground navigation readiness was not confirmed"
            raise TransitionError(self.detail)
        self.state = Mode.GROUND
        self.detail = "ground navigation ready"

    def finish_takeoff(self, success):
        if self.state is not Mode.TAKEOFF:
            raise TransitionError("takeoff is not active")
        reached = self.altitude >= self.takeoff_height * 0.9
        if not success or not self.armed or self.physical_mode != "air" or not reached:
            self.state = Mode.FAULT
            self.detail = "takeoff completion was not confirmed"
            raise TransitionError(self.detail)
        self.state = Mode.AIRBORNE
        self.detail = "airborne at {:.2f} m".format(self.altitude)

    def begin_landing(self, now):
        self._require_not_estopped()
        self._require_fresh(now)
        if self.state is not Mode.AIRBORNE or self.physical_mode != "air":
            raise TransitionError("landing requires airborne state")
        self.state = Mode.LANDING
        self.detail = "landing"

    def finish_landing(self, success):
        if self.state is not Mode.LANDING:
            raise TransitionError("landing is not active")
        if not success or self.armed:
            self.state = Mode.FAULT
            self.detail = "landing completion was not confirmed"
            raise TransitionError(self.detail)
        self.state = Mode.AIR_READY
        self.detail = "landed; air configuration remains active"

    def begin_switch_to_ground(self, now):
        self._require_not_estopped()
        self._require_fresh(now)
        if self.state is not Mode.AIR_READY or self.armed:
            raise TransitionError("ground switch requires landed and disarmed state")
        self.state = Mode.SWITCHING_TO_GROUND
        self.detail = "switching to ground configuration"

    def finish_switch_to_ground(self, success):
        if self.state is not Mode.SWITCHING_TO_GROUND:
            raise TransitionError("ground switch is not active")
        if not success or self.physical_mode != "ground":
            self.state = Mode.FAULT
            self.detail = "ground configuration was not observed"
            raise TransitionError(self.detail)
        self.state = Mode.GROUND
        self.detail = "ground configuration ready"

    def set_emergency_stop(self, active, reason):
        active = bool(active)
        if active:
            self.emergency_stop = True
            self.state = Mode.ESTOP
            self.detail = reason or "emergency stop"
            return
        if not self.emergency_stop:
            return
        if not self.connected:
            raise TransitionError("cannot reset emergency stop without FCU telemetry")
        self.emergency_stop = False
        self.synchronize_from_telemetry()
        self.detail = reason or "emergency stop reset"

    def on_navigation_goal_reached(self):
        if self.state is Mode.AIRBORNE:
            self.detail = "flight goal reached; waiting for explicit land command"
            return "hover"
        return "stop"

    def fail(self, reason):
        if self.state is not Mode.ESTOP:
            self.state = Mode.FAULT
        self.detail = str(reason)
