#!/usr/bin/env python3
import math
import threading

import rospy
from geometry_msgs.msg import Twist
from ground_air_msgs.msg import VehicleStatus
from ground_air_msgs.srv import (
    SetEmergencyStop,
    SetEmergencyStopResponse,
    SetFlightAltitude,
    SetFlightAltitudeResponse,
    SetVehicleMode,
    SetVehicleModeResponse,
)
from std_srvs.srv import Trigger, TriggerResponse

from ground_air_control.mode_manager_core import Mode, ModeManagerCore, TransitionError
from ground_air_control.px4_backend import Px4Backend


STATUS_MODE = {
    Mode.UNKNOWN: VehicleStatus.UNKNOWN,
    Mode.GROUND: VehicleStatus.GROUND,
    Mode.SWITCHING_TO_AIR: VehicleStatus.TAKEOFF,
    Mode.AIR_READY: VehicleStatus.AIR,
    Mode.TAKEOFF: VehicleStatus.TAKEOFF,
    Mode.AIRBORNE: VehicleStatus.AIR,
    Mode.LANDING: VehicleStatus.LANDING,
    Mode.SWITCHING_TO_GROUND: VehicleStatus.LANDING,
    Mode.ESTOP: VehicleStatus.ESTOP,
    Mode.FAULT: VehicleStatus.FAULT,
}


class ModeManagerNode:
    def __init__(self, backend=None):
        self.backend = backend or Px4Backend()
        self.backend.wait_for_services(rospy.get_param("~service_timeout", 10.0))
        self.core = ModeManagerCore(
            takeoff_height=rospy.get_param("~takeoff_height", 1.0),
            telemetry_timeout=rospy.get_param("~telemetry_timeout", 0.5),
            min_flight_altitude=rospy.get_param("~min_flight_altitude", 0.5),
            max_flight_altitude=rospy.get_param("~max_flight_altitude", 3.0),
        )
        self.core.set_emergency_stop(True, "startup safety interlock")
        self.transition_timeout = float(rospy.get_param("~transition_timeout", 15.0))
        self.ground_mode_timeout = float(rospy.get_param("~ground_mode_timeout", 2.0))
        self.ground_stop_settle_time = float(
            rospy.get_param("~ground_stop_settle_time", 0.2)
        )
        self.takeoff_timeout = float(rospy.get_param("~takeoff_timeout", 20.0))
        self.land_timeout = float(rospy.get_param("~land_timeout", 30.0))
        self.altitude_kp = float(rospy.get_param("~altitude_kp", 1.0))
        self.max_vertical_speed = float(rospy.get_param("~max_vertical_speed", 0.5))
        self.target_altitude = None
        self._transition_lock = threading.Lock()
        self._state_lock = threading.RLock()

        self.status_pub = rospy.Publisher(
            "/ground_air/vehicle_status", VehicleStatus, queue_size=10, latch=True
        )
        rospy.Subscriber("/air/cmd_vel", Twist, self._air_cmd_callback, queue_size=1)
        self.takeoff_service = rospy.Service(
            "/ground_air/takeoff", Trigger, self._takeoff_service
        )
        self.takeoff_to_altitude_service = rospy.Service(
            "/ground_air/takeoff_to_altitude",
            SetFlightAltitude,
            self._takeoff_to_altitude_service,
        )
        self.set_flight_altitude_service = rospy.Service(
            "/ground_air/set_flight_altitude",
            SetFlightAltitude,
            self._set_flight_altitude_service,
        )
        self.land_service = rospy.Service(
            "/ground_air/land", Trigger, self._land_service
        )
        self.prepare_ground_service = rospy.Service(
            "/ground_air/prepare_ground", Trigger, self._prepare_ground_service
        )
        self.mode_service = rospy.Service(
            "/ground_air/set_mode", SetVehicleMode, self._set_mode_service
        )
        self.estop_service = rospy.Service(
            "/ground_air/emergency_stop",
            SetEmergencyStop,
            self._emergency_stop_service,
        )
        self.timer = rospy.Timer(rospy.Duration(0.1), self._status_timer)

    def _refresh_telemetry(self):
        snapshot = self.backend.snapshot()
        now = rospy.get_time()
        self.core.update_telemetry(
            now=now,
            connected=snapshot["connected"],
            armed=snapshot["armed"],
            physical_mode=snapshot["physical_mode"],
            altitude=snapshot["altitude"],
            pose_stamp=snapshot["pose_stamp"],
        )
        return snapshot

    def _status_message(self):
        snapshot = self.backend.snapshot()
        message = VehicleStatus()
        message.header.stamp = rospy.Time.now()
        message.mode = STATUS_MODE[self.core.state]
        message.connected = snapshot["connected"]
        message.armed = snapshot["armed"]
        message.localized = bool(rospy.get_param("/ground_air/localized", False))
        message.emergency_stop = self.core.emergency_stop
        message.altitude = snapshot["altitude"]
        message.flight_mode = snapshot["flight_mode"]
        message.detail = self.core.detail
        return message

    def _status_timer(self, _event):
        with self._state_lock:
            self._refresh_telemetry()
            self.status_pub.publish(self._status_message())

    def _run_transition(self, callback):
        if not self._transition_lock.acquire(False):
            return False, "another transition is already running"
        try:
            with self._state_lock:
                self._refresh_telemetry()
            callback()
            with self._state_lock:
                self.status_pub.publish(self._status_message())
            return True, self.core.detail
        except (TransitionError, RuntimeError, ValueError, rospy.ServiceException) as error:
            with self._state_lock:
                self.core.fail(str(error))
                self.status_pub.publish(self._status_message())
            rospy.logerr("Ground-air transition failed: %s", error)
            return False, str(error)
        finally:
            self._transition_lock.release()

    def _switch_to_air(self):
        with self._state_lock:
            self.core.begin_switch_to_air(rospy.get_time())
        success = self.backend.switch_physical_mode("air", self.transition_timeout)
        with self._state_lock:
            self._refresh_telemetry()
            self.core.finish_switch_to_air(success)

    def _switch_to_ground(self):
        with self._state_lock:
            self.core.begin_switch_to_ground(rospy.get_time())
        success = self.backend.switch_physical_mode("ground", self.transition_timeout)
        with self._state_lock:
            self._refresh_telemetry()
            self.core.finish_switch_to_ground(success)

    def _takeoff_sequence(self, requested_height=None):
        with self._state_lock:
            self._refresh_telemetry()
            if requested_height is not None:
                self.core.set_takeoff_height(requested_height)
            disarm_required = self.core.ground_disarm_required_for_takeoff(
                rospy.get_time()
            )
        if disarm_required:
            rospy.sleep(self.ground_stop_settle_time)
            if not self.backend.switch_flight_mode(
                "POSCTL", self.ground_mode_timeout
            ):
                raise RuntimeError("POSCTL confirmation failed before takeoff")
            if not self.backend.disarm(self.ground_mode_timeout):
                raise RuntimeError("ground vehicle disarm failed before takeoff")
        with self._state_lock:
            self._refresh_telemetry()
            requires_switch = self.core.takeoff_requires_air_switch(rospy.get_time())
        if requires_switch:
            self._switch_to_air()
        with self._state_lock:
            self.core.begin_takeoff(rospy.get_time())
        success = self.backend.takeoff(self.core.takeoff_height, self.takeoff_timeout)
        with self._state_lock:
            self._refresh_telemetry()
            self.core.finish_takeoff(success)
            self.target_altitude = self.core.altitude

    def _landing_sequence(self):
        with self._state_lock:
            self.core.begin_landing(rospy.get_time())
        success = self.backend.land(self.land_timeout)
        with self._state_lock:
            self._refresh_telemetry()
            self.core.finish_landing(success)
            self.target_altitude = None
        self._switch_to_ground()

    def _prepare_ground_sequence(self):
        if not bool(rospy.get_param("/ground_air/localized", False)):
            raise TransitionError("ground navigation requires valid localization")
        with self._state_lock:
            snapshot = self._refresh_telemetry()
            self.core.begin_ground_navigation(rospy.get_time())
            if not snapshot["armed"]:
                raise TransitionError(
                    "ground navigation requires manual RC arming"
                )
            if str(snapshot["flight_mode"]).upper() != "OFFBOARD":
                raise TransitionError(
                    "ground navigation requires manual RC OFFBOARD selection"
                )
        success = self.backend.prepare_ground(self.ground_mode_timeout)
        with self._state_lock:
            snapshot = self._refresh_telemetry()
            self.core.finish_ground_navigation(success, snapshot["flight_mode"])

    def _takeoff_service(self, _request):
        success, message = self._run_transition(self._takeoff_sequence)
        return TriggerResponse(success=success, message=message)

    def _takeoff_to_altitude_service(self, request):
        success, message = self._run_transition(
            lambda: self._takeoff_sequence(request.altitude)
        )
        return SetFlightAltitudeResponse(
            success=success, message=message, status=self._status_message()
        )

    def _set_flight_altitude_service(self, request):
        def set_target():
            with self._state_lock:
                self._refresh_telemetry()
                self.target_altitude = self.core.set_flight_target(
                    rospy.get_time(), request.altitude
                )

        success, message = self._run_transition(set_target)
        return SetFlightAltitudeResponse(
            success=success, message=message, status=self._status_message()
        )

    def _land_service(self, _request):
        success, message = self._run_transition(self._landing_sequence)
        return TriggerResponse(success=success, message=message)

    def _prepare_ground_service(self, _request):
        success, message = self._run_transition(self._prepare_ground_sequence)
        return TriggerResponse(success=success, message=message)

    def _set_mode_service(self, request):
        if request.target_mode == SetVehicleModeRequestMode.AIR:
            callback = self._switch_to_air
        elif request.target_mode == SetVehicleModeRequestMode.GROUND:
            callback = self._switch_to_ground
        else:
            return SetVehicleModeResponse(
                success=False,
                message="target_mode must be GROUND or AIR",
                status=self._status_message(),
            )
        success, message = self._run_transition(callback)
        return SetVehicleModeResponse(
            success=success, message=message, status=self._status_message()
        )

    def _emergency_stop_service(self, request):
        if request.active:
            return self._engage_emergency_stop()
        return self._reset_emergency_stop()

    def _engage_emergency_stop(self):
        try:
            with self._state_lock:
                snapshot = self._refresh_telemetry()
                self.core.set_emergency_stop(True, "operator emergency stop")
                if self.core.physical_mode == "air" and self.core.armed:
                    self.backend.hover()
                elif snapshot["physical_mode"] == "ground":
                    self.core.detail = (
                        "operator emergency stop latched; "
                        "switch RC to POSCTL manually"
                    )
                status = self._status_message()
                self.status_pub.publish(status)
            return SetEmergencyStopResponse(
                success=True, message=self.core.detail, status=status
            )
        except (TransitionError, RuntimeError, rospy.ServiceException) as error:
            with self._state_lock:
                self.core.set_emergency_stop(True, "emergency stop after mode error")
                status = self._status_message()
                self.status_pub.publish(status)
            return SetEmergencyStopResponse(
                success=False, message=str(error), status=status
            )

    def _reset_emergency_stop(self):
        if not self._transition_lock.acquire(False):
            return SetEmergencyStopResponse(
                success=False,
                message="another transition is already running",
                status=self._status_message(),
            )
        try:
            with self._state_lock:
                snapshot = self._refresh_telemetry()
                self.core.set_emergency_stop(False, "operator reset")
                if snapshot["physical_mode"] == "ground":
                    self.core.detail = (
                        "operator reset; manually arm and select OFFBOARD "
                        "before ground preparation"
                    )
                status = self._status_message()
                self.status_pub.publish(status)
            return SetEmergencyStopResponse(
                success=True, message=self.core.detail, status=status
            )
        except (TransitionError, RuntimeError, rospy.ServiceException) as error:
            with self._state_lock:
                self.core.set_emergency_stop(True, "emergency stop reset failed")
                status = self._status_message()
                self.status_pub.publish(status)
            return SetEmergencyStopResponse(
                success=False, message=str(error), status=status
            )
        finally:
            self._transition_lock.release()

    def _air_cmd_callback(self, command):
        with self._state_lock:
            if self.core.state is not Mode.AIRBORNE or self.core.emergency_stop:
                return
            snapshot = self.backend.snapshot()
            if self.target_altitude is None:
                self.target_altitude = snapshot["altitude"]
            vertical = self.altitude_kp * (self.target_altitude - snapshot["altitude"])
            vertical = max(-self.max_vertical_speed, min(self.max_vertical_speed, vertical))
            orientation = self.backend.pose.pose.orientation
            yaw = math.atan2(
                2.0 * (orientation.w * orientation.z + orientation.x * orientation.y),
                1.0 - 2.0 * (orientation.y ** 2 + orientation.z ** 2),
            )
            vx_world = command.linear.x * math.cos(yaw) - command.linear.y * math.sin(yaw)
            vy_world = command.linear.x * math.sin(yaw) + command.linear.y * math.cos(yaw)
            self.backend.set_velocity(vx_world, vy_world, vertical, command.angular.z)


class SetVehicleModeRequestMode:
    GROUND = 1
    AIR = 3


if __name__ == "__main__":
    rospy.init_node("ground_air_mode_manager")
    ModeManagerNode()
    rospy.spin()
