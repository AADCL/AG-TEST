#!/usr/bin/env python3
"""MAVROS hardware backend with feedback-confirmed physical transitions."""

import math
import threading
import time


class Px4TransitionPolicy:
    VTOL_STATE = {"air": 3, "ground": 4}

    def __init__(
        self,
        command=183,
        selector_channel=8,
        ground_pwm=1300,
        air_pwm=1700,
        confirmations_required=3,
    ):
        self.command = int(command)
        self.selector_channel = float(selector_channel)
        self.ground_pwm = float(ground_pwm)
        self.air_pwm = float(air_pwm)
        self.confirmations_required = int(confirmations_required)
        if self.confirmations_required <= 0:
            raise ValueError("confirmations_required must be positive")
        self._expected_vtol_state = None
        self._observed_count = 0

    @staticmethod
    def response_accepted(response):
        return bool(getattr(response, "success", False))

    @staticmethod
    def flight_mode_response_accepted(response):
        return bool(getattr(response, "mode_sent", False))

    @staticmethod
    def ground_control_ready(snapshot):
        """Return whether the operator has prepared PX4 for ground control."""
        return (
            bool(snapshot.get("connected", False))
            and snapshot.get("physical_mode") == "ground"
            and bool(snapshot.get("armed", False))
            and str(snapshot.get("flight_mode", "")).upper() == "OFFBOARD"
        )

    def command_request(self, target_mode):
        if target_mode == "ground":
            pwm = self.ground_pwm
        elif target_mode == "air":
            pwm = self.air_pwm
        else:
            raise ValueError("target_mode must be ground or air")
        return self.command, self.selector_channel, pwm

    def begin_observation(self, target_mode):
        if target_mode not in self.VTOL_STATE:
            raise ValueError("target_mode must be ground or air")
        self._expected_vtol_state = self.VTOL_STATE[target_mode]
        self._observed_count = 0

    def observe_vtol_state(self, state):
        if self._expected_vtol_state is None:
            return False
        if int(state) == self._expected_vtol_state:
            self._observed_count += 1
        else:
            self._observed_count = 0
        return self._observed_count >= self.confirmations_required

    @staticmethod
    def takeoff_target(current_altitude, height):
        """Validate telemetry and return the requested absolute map z."""
        height = float(height)
        if not math.isfinite(height) or height <= 0.0:
            raise ValueError("takeoff map altitude must be positive and finite")
        current_altitude = float(current_altitude)
        if not math.isfinite(current_altitude):
            raise ValueError("current altitude must be finite")
        return height

    @staticmethod
    def local_target_from_map(
        current_local_altitude, current_map_altitude, target_map_altitude
    ):
        """Convert an absolute map-z target to the PX4 local-z setpoint."""
        values = tuple(
            float(value)
            for value in (
                current_local_altitude,
                current_map_altitude,
                target_map_altitude,
            )
        )
        if not all(math.isfinite(value) for value in values):
            raise ValueError("altitude conversion values must be finite")
        local_z, map_z, target_map_z = values
        return local_z + (target_map_z - map_z)


class Px4Backend:
    """ROS adapter. Construct this class only after rospy.init_node()."""

    def __init__(self):
        import rospy
        from geometry_msgs.msg import PoseStamped, TwistStamped
        from mavros_msgs.msg import ExtendedState, State
        from mavros_msgs.srv import CommandBool, CommandLong, CommandTOL, SetMode

        self.rospy = rospy
        self.PoseStamped = PoseStamped
        self.TwistStamped = TwistStamped
        self._lock = threading.RLock()
        self.state = State()
        self.extended_state = ExtendedState()
        self.pose = PoseStamped()
        self.pose_stamp = rospy.Time(0)
        self.map_pose = PoseStamped()
        self.map_pose_stamp = rospy.Time(0)

        self.policy = Px4TransitionPolicy(
            command=rospy.get_param("~transition_command", 183),
            selector_channel=rospy.get_param("~selector_channel", 8),
            ground_pwm=rospy.get_param("~ground_pwm", 1300),
            air_pwm=rospy.get_param("~air_pwm", 1700),
            confirmations_required=rospy.get_param("~transition_confirmations", 3),
        )

        self._arming = rospy.ServiceProxy("/mavros/cmd/arming", CommandBool)
        self._set_mode = rospy.ServiceProxy("/mavros/set_mode", SetMode)
        self._command = rospy.ServiceProxy("/mavros/cmd/command", CommandLong)
        self._land = rospy.ServiceProxy("/mavros/cmd/land", CommandTOL)
        self._position_pub = rospy.Publisher(
            "/mavros/setpoint_position/local", PoseStamped, queue_size=10
        )
        self._velocity_pub = rospy.Publisher(
            "/mavros/setpoint_velocity/cmd_vel", TwistStamped, queue_size=10
        )
        rospy.Subscriber("/mavros/state", State, self._state_cb, queue_size=10)
        rospy.Subscriber(
            "/mavros/extended_state", ExtendedState, self._extended_cb, queue_size=10
        )
        rospy.Subscriber(
            "/mavros/local_position/pose", PoseStamped, self._pose_cb, queue_size=10
        )
        rospy.Subscriber(
            "/ground_air/localization/pose",
            PoseStamped,
            self._map_pose_cb,
            queue_size=10,
        )

    def _state_cb(self, message):
        with self._lock:
            self.state = message

    def _extended_cb(self, message):
        with self._lock:
            self.extended_state = message

    def _pose_cb(self, message):
        with self._lock:
            self.pose = message
            self.pose_stamp = message.header.stamp

    def _map_pose_cb(self, message):
        if str(message.header.frame_id).lstrip("/") != "map":
            self.rospy.logerr_throttle(
                2.0,
                "Localization pose rejected: expected map frame, received %s",
                message.header.frame_id,
            )
            return
        with self._lock:
            self.map_pose = message
            self.map_pose_stamp = message.header.stamp

    def snapshot(self):
        with self._lock:
            physical = Px4TransitionPolicy.VTOL_STATE
            reverse = {value: key for key, value in physical.items()}
            return {
                "connected": bool(self.state.connected),
                "armed": bool(self.state.armed),
                "flight_mode": self.state.mode,
                "physical_mode": reverse.get(self.extended_state.vtol_state, "unknown"),
                "vtol_state": int(self.extended_state.vtol_state),
                "landed_state": int(self.extended_state.landed_state),
                # Public altitude semantics are absolute z in the relocalized map.
                "altitude": float(self.map_pose.pose.position.z),
                "local_altitude": float(self.pose.pose.position.z),
                "pose_stamp": self.map_pose_stamp.to_sec(),
            }

    def wait_for_services(self, timeout=10.0):
        for name in (
            "/mavros/cmd/arming",
            "/mavros/set_mode",
            "/mavros/cmd/command",
            "/mavros/cmd/land",
        ):
            self.rospy.wait_for_service(name, timeout=timeout)

    def switch_physical_mode(self, target_mode, timeout=15.0):
        snapshot = self.snapshot()
        if snapshot["armed"]:
            raise RuntimeError("physical mode transition requires disarmed vehicle")
        command, channel, pwm = self.policy.command_request(target_mode)
        self.policy.begin_observation(target_mode)
        response = self._command(
            broadcast=False,
            command=command,
            confirmation=0,
            param1=channel,
            param2=pwm,
            param3=0.0,
            param4=0.0,
            param5=0.0,
            param6=0.0,
            param7=0.0,
        )
        if not self.policy.response_accepted(response):
            return False
        deadline = time.monotonic() + float(timeout)
        rate = self.rospy.Rate(10)
        while not self.rospy.is_shutdown() and time.monotonic() < deadline:
            if self.policy.observe_vtol_state(self.snapshot()["vtol_state"]):
                return True
            rate.sleep()
        return False

    def switch_flight_mode(self, target_mode, timeout=2.0):
        target_mode = str(target_mode).upper()
        if self.snapshot()["flight_mode"] == target_mode:
            return True
        response = self._set_mode(base_mode=0, custom_mode=target_mode)
        if not self.policy.flight_mode_response_accepted(response):
            return False
        deadline = time.monotonic() + float(timeout)
        rate = self.rospy.Rate(20)
        while not self.rospy.is_shutdown() and time.monotonic() < deadline:
            if self.snapshot()["flight_mode"] == target_mode:
                return True
            rate.sleep()
        return False

    def _wait_armed(self, expected, timeout):
        deadline = time.monotonic() + float(timeout)
        rate = self.rospy.Rate(20)
        while not self.rospy.is_shutdown() and time.monotonic() < deadline:
            if self.snapshot()["armed"] is bool(expected):
                return True
            rate.sleep()
        return False

    def disarm(self, timeout=2.0):
        if not self.snapshot()["armed"]:
            return True
        response = self._arming(False)
        if not self.policy.response_accepted(response):
            return False
        return self._wait_armed(False, timeout)

    def prepare_ground(self, timeout=2.0):
        # Kept for API compatibility. Ground arming and flight-mode changes are
        # deliberately owned by the operator's transmitter.
        del timeout
        return self.policy.ground_control_ready(self.snapshot())

    def _position_target(self, x, y, z):
        target = self.PoseStamped()
        target.header.stamp = self.rospy.Time.now()
        target.header.frame_id = "map"
        target.pose.position.x = x
        target.pose.position.y = y
        target.pose.position.z = z
        with self._lock:
            target.pose.orientation = self.pose.pose.orientation
        if abs(target.pose.orientation.w) < 1e-9:
            target.pose.orientation.w = 1.0
        return target

    def _publish_position_for(self, target, duration):
        deadline = time.monotonic() + float(duration)
        rate = self.rospy.Rate(20)
        while not self.rospy.is_shutdown() and time.monotonic() < deadline:
            target.header.stamp = self.rospy.Time.now()
            self._position_pub.publish(target)
            rate.sleep()

    def takeoff(self, height=1.0, timeout=20.0):
        snapshot = self.snapshot()
        if snapshot["physical_mode"] != "air" or snapshot["armed"]:
            return False
        with self._lock:
            x = self.pose.pose.position.x
            y = self.pose.pose.position.y
        current_local_z = snapshot["local_altitude"]
        current_map_z = snapshot["altitude"]
        target_map_z = self.policy.takeoff_target(current_map_z, height)
        target_local_z = self.policy.local_target_from_map(
            current_local_z, current_map_z, target_map_z
        )
        target = self._position_target(x, y, current_local_z)
        self._publish_position_for(target, 2.0)
        mode_response = self._set_mode(base_mode=0, custom_mode="OFFBOARD")
        if not bool(getattr(mode_response, "mode_sent", False)):
            return False
        arm_response = self._arming(True)
        if not bool(getattr(arm_response, "success", False)):
            return False
        target.pose.position.z = target_local_z
        deadline = time.monotonic() + float(timeout)
        rate = self.rospy.Rate(20)
        while not self.rospy.is_shutdown() and time.monotonic() < deadline:
            target.header.stamp = self.rospy.Time.now()
            self._position_pub.publish(target)
            snapshot = self.snapshot()
            if snapshot["armed"] and snapshot["altitude"] >= target_map_z - 0.1:
                return True
            rate.sleep()
        return False

    def land(self, timeout=30.0):
        response = self._land(
            min_pitch=0.0, yaw=0.0, latitude=0.0, longitude=0.0, altitude=0.0
        )
        if not bool(getattr(response, "success", False)):
            return False
        deadline = time.monotonic() + float(timeout)
        rate = self.rospy.Rate(10)
        while not self.rospy.is_shutdown() and time.monotonic() < deadline:
            snapshot = self.snapshot()
            if not snapshot["armed"] and snapshot["landed_state"] == 1:
                return True
            rate.sleep()
        return False

    def hover(self):
        with self._lock:
            target = self._position_target(
                self.pose.pose.position.x,
                self.pose.pose.position.y,
                self.pose.pose.position.z,
            )
        self._position_pub.publish(target)

    def set_velocity(self, vx, vy, vz, yaw_rate):
        message = self.TwistStamped()
        message.header.stamp = self.rospy.Time.now()
        message.header.frame_id = "map"
        message.twist.linear.x = float(vx)
        message.twist.linear.y = float(vy)
        message.twist.linear.z = float(vz)
        message.twist.angular.z = float(yaw_rate)
        self._velocity_pub.publish(message)
