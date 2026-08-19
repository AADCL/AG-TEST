#!/usr/bin/env python3
import math
from collections import namedtuple


VelocityCommand = namedtuple("VelocityCommand", "vx vy vz yaw_rate")


def clamp(value, lower, upper):
    return max(lower, min(upper, value))


def quaternion_to_yaw(x, y, z, w):
    sin_yaw = 2.0 * (w * z + x * y)
    cos_yaw = 1.0 - 2.0 * (y * y + z * z)
    return math.atan2(sin_yaw, cos_yaw)


def body_to_world(vx_body, vy_body, yaw):
    cos_yaw = math.cos(yaw)
    sin_yaw = math.sin(yaw)
    return (
        cos_yaw * vx_body - sin_yaw * vy_body,
        sin_yaw * vx_body + cos_yaw * vy_body,
    )


class DroneModeController:
    STANDBY = "standby"
    TAKING_OFF = "taking_off"
    AIRBORNE = "airborne"
    LANDING = "landing"

    def __init__(
        self,
        max_horizontal_speed,
        max_yaw_rate,
        altitude_kp,
        max_vertical_speed,
        cmd_vel_timeout,
    ):
        self.max_horizontal_speed = float(max_horizontal_speed)
        self.max_yaw_rate = float(max_yaw_rate)
        self.altitude_kp = float(altitude_kp)
        self.max_vertical_speed = float(max_vertical_speed)
        self.cmd_vel_timeout = float(cmd_vel_timeout)

        self.state = self.STANDBY
        self.target_altitude = None
        self._vx_body = 0.0
        self._vy_body = 0.0
        self._yaw_rate = 0.0
        self._last_cmd_stamp = None

    def begin_takeoff(self):
        if self.state != self.STANDBY:
            return False
        self.state = self.TAKING_OFF
        return True

    def finish_takeoff(self, success, altitude):
        if self.state != self.TAKING_OFF:
            return False
        if success:
            self.state = self.AIRBORNE
            self.target_altitude = float(altitude)
            self._clear_navigation_command()
        else:
            self._reset_to_standby()
        return bool(success)

    def begin_landing(self):
        if self.state != self.AIRBORNE:
            return False
        self.state = self.LANDING
        self._clear_navigation_command()
        return True

    def finish_landing(self, success):
        if self.state != self.LANDING:
            return False
        if success:
            self._reset_to_standby()
        else:
            self.state = self.AIRBORNE
            self._clear_navigation_command()
        return bool(success)

    def accept_cmd_vel(self, vx_body, vy_body, yaw_rate, stamp):
        if self.state != self.AIRBORNE:
            return False
        self._vx_body = float(vx_body)
        self._vy_body = float(vy_body)
        self._yaw_rate = float(yaw_rate)
        self._last_cmd_stamp = float(stamp)
        return True

    def compute_command(self, now, yaw, altitude):
        if self.state != self.AIRBORNE:
            return None

        command_is_fresh = (
            self._last_cmd_stamp is not None
            and float(now) - self._last_cmd_stamp <= self.cmd_vel_timeout
        )
        if command_is_fresh:
            vx_body, vy_body = self._limit_horizontal_velocity(
                self._vx_body, self._vy_body
            )
            yaw_rate = clamp(
                self._yaw_rate, -self.max_yaw_rate, self.max_yaw_rate
            )
        else:
            vx_body, vy_body, yaw_rate = 0.0, 0.0, 0.0

        vx_world, vy_world = body_to_world(vx_body, vy_body, float(yaw))
        altitude_error = self.target_altitude - float(altitude)
        vz = clamp(
            self.altitude_kp * altitude_error,
            -self.max_vertical_speed,
            self.max_vertical_speed,
        )
        return VelocityCommand(vx_world, vy_world, vz, yaw_rate)

    def _limit_horizontal_velocity(self, vx, vy):
        speed = math.hypot(vx, vy)
        if speed <= self.max_horizontal_speed or speed == 0.0:
            return vx, vy
        scale = self.max_horizontal_speed / speed
        return vx * scale, vy * scale

    def _clear_navigation_command(self):
        self._vx_body = 0.0
        self._vy_body = 0.0
        self._yaw_rate = 0.0
        self._last_cmd_stamp = None

    def _reset_to_standby(self):
        self.state = self.STANDBY
        self.target_altitude = None
        self._clear_navigation_command()
