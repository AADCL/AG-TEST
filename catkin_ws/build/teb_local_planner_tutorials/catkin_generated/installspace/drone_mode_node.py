#!/usr/bin/env python3
import math
import threading

import rospy
from geometry_msgs.msg import Twist
from std_srvs.srv import Trigger, TriggerResponse

from drone_mode_control import DroneModeController, quaternion_to_yaw
from px4_drone import PX4Drone


class DroneModeNode:
    def __init__(self):
        self.cmd_vel_topic = rospy.get_param("~cmd_vel_topic", "/cmd_vel")
        if not isinstance(self.cmd_vel_topic, str) or not self.cmd_vel_topic:
            raise ValueError("~cmd_vel_topic must be a non-empty string")

        self.takeoff_height = self._positive_param("takeoff_height", 1.0)
        cmd_vel_timeout = self._positive_param("cmd_vel_timeout", 0.5)
        max_horizontal_speed = self._positive_param(
            "max_horizontal_speed", 1.0
        )
        max_yaw_rate = self._positive_param("max_yaw_rate", 1.0)
        altitude_kp = self._positive_param("altitude_kp", 1.0)
        max_vertical_speed = self._positive_param("max_vertical_speed", 0.5)
        self.control_rate = self._positive_param("control_rate", 20.0)

        self.controller = DroneModeController(
            max_horizontal_speed,
            max_yaw_rate,
            altitude_kp,
            max_vertical_speed,
            cmd_vel_timeout,
        )
        self._service_lock = threading.Lock()
        self._state_lock = threading.Lock()

        self.driver = PX4Drone()
        if not self.driver.switch_mode("drone"):
            raise RuntimeError("failed to switch the vehicle to drone mode")

        self.cmd_vel_subscriber = rospy.Subscriber(
            self.cmd_vel_topic,
            Twist,
            self._cmd_vel_callback,
            queue_size=1,
        )
        self.takeoff_service = rospy.Service(
            "~takeoff", Trigger, self._takeoff_service
        )
        self.land_service = rospy.Service("~land", Trigger, self._land_service)
        self.control_timer = rospy.Timer(
            rospy.Duration(1.0 / self.control_rate), self._control_timer
        )

        rospy.loginfo(
            "Drone mode ready. Call %s/takeoff to arm and take off.",
            rospy.get_name(),
        )

    @staticmethod
    def _positive_param(name, default):
        value = float(rospy.get_param("~" + name, default))
        if not math.isfinite(value) or value <= 0.0:
            raise ValueError("~{} must be a finite positive number".format(name))
        return value

    def _takeoff_service(self, _request):
        if not self._service_lock.acquire(False):
            return TriggerResponse(success=False, message="another transition is running")
        try:
            with self._state_lock:
                if not self.controller.begin_takeoff():
                    return TriggerResponse(
                        success=False,
                        message="takeoff is only allowed from standby",
                    )

            try:
                success = bool(self.driver.takeoff(self.takeoff_height))
            except Exception as exc:
                rospy.logerr("Takeoff failed: %s", exc)
                success = False

            with self._state_lock:
                self.controller.finish_takeoff(success, self.takeoff_height)
            if success:
                return TriggerResponse(
                    success=True,
                    message="takeoff completed at {:.2f} m".format(
                        self.takeoff_height
                    ),
                )
            return TriggerResponse(success=False, message="takeoff failed")
        finally:
            self._service_lock.release()

    def _land_service(self, _request):
        if not self._service_lock.acquire(False):
            return TriggerResponse(success=False, message="another transition is running")
        try:
            with self._state_lock:
                if not self.controller.begin_landing():
                    return TriggerResponse(
                        success=False,
                        message="landing is only allowed while airborne",
                    )

            try:
                success = bool(self.driver.land())
            except Exception as exc:
                rospy.logerr("Landing failed: %s", exc)
                success = False

            with self._state_lock:
                self.controller.finish_landing(success)
            if success:
                return TriggerResponse(success=True, message="landing completed")

            if self.driver.current_state.mode == "OFFBOARD":
                self.driver.hover()
            return TriggerResponse(success=False, message="landing failed")
        finally:
            self._service_lock.release()

    def _cmd_vel_callback(self, message):
        with self._state_lock:
            accepted = self.controller.accept_cmd_vel(
                message.linear.x,
                message.linear.y,
                message.angular.z,
                rospy.get_time(),
            )
        if not accepted:
            rospy.logwarn_throttle(5.0, "Ignoring cmd_vel while drone is not airborne")

    def _control_timer(self, _event):
        with self._state_lock:
            pose = self.driver.current_pose.pose
            orientation = pose.orientation
            yaw = quaternion_to_yaw(
                orientation.x,
                orientation.y,
                orientation.z,
                orientation.w,
            )
            command = self.controller.compute_command(
                rospy.get_time(), yaw, pose.position.z
            )
            if command is None:
                return

            if self.driver.current_state.mode != "OFFBOARD":
                rospy.logwarn_throttle(
                    2.0,
                    "Airborne control paused because FCU is not in OFFBOARD mode",
                )
                return

            if not self.driver.set_velocity_target(
                command.vx,
                command.vy,
                command.vz,
                command.yaw_rate,
            ):
                rospy.logwarn_throttle(2.0, "PX4 rejected the velocity target")


def main():
    rospy.init_node("drone_mode")
    try:
        DroneModeNode()
    except Exception as exc:
        rospy.logfatal("Unable to start drone mode: %s", exc)
        raise
    rospy.spin()


if __name__ == "__main__":
    main()
