#!/usr/bin/env python3
"""Ground command adapter with an independent watchdog."""

import math


class GroundActuatorPolicy:
    def __init__(self, max_linear=3.2, max_angular=5.0, timeout=0.5):
        self.max_linear = float(max_linear)
        self.max_angular = float(max_angular)
        self.timeout = float(timeout)
        if min(self.max_linear, self.max_angular, self.timeout) <= 0.0:
            raise ValueError("limits and timeout must be positive")
        self.linear = 0.0
        self.angular = 0.0
        self.stamp = float("-inf")

    def accept(self, linear, angular, now):
        values = (float(linear), float(angular), float(now))
        if not all(math.isfinite(value) for value in values):
            self.linear = self.angular = 0.0
            return
        self.linear = max(-self.max_linear, min(self.max_linear, values[0]))
        self.angular = max(-self.max_angular, min(self.max_angular, values[1]))
        self.stamp = values[2]

    def controls(self, now):
        if float(now) - self.stamp > self.timeout:
            return 0.0, 0.0
        # The vehicle's PX4 mixer expects the same normalized values used by
        # the original field bridge: cmd_vel values are copied directly into
        # controls[3] (forward) and controls[2] (inverted yaw).
        linear = max(-1.0, min(1.0, self.linear))
        angular = max(-1.0, min(1.0, -self.angular))
        return linear, angular


class GroundActuatorNode:
    def __init__(self):
        import rospy
        from geometry_msgs.msg import Twist
        from mavros_msgs.msg import ActuatorControl

        self.rospy = rospy
        self.ActuatorControl = ActuatorControl
        self.policy = GroundActuatorPolicy(
            rospy.get_param("~max_linear", 3.2),
            rospy.get_param("~max_angular", 5.0),
            rospy.get_param("~timeout", 0.5),
        )
        self.publisher = rospy.Publisher(
            "/mavros/actuator_control", ActuatorControl, queue_size=10
        )
        rospy.Subscriber("/ground/cmd_vel", Twist, self._callback, queue_size=1)
        rate = float(rospy.get_param("~rate", 20.0))
        self.timer = rospy.Timer(rospy.Duration(1.0 / rate), self._timer)

    def _callback(self, message):
        self.policy.accept(message.linear.x, message.angular.z, self.rospy.get_time())

    def _timer(self, _event):
        linear, angular = self.policy.controls(self.rospy.get_time())
        message = self.ActuatorControl()
        message.header.stamp = self.rospy.Time.now()
        message.header.frame_id = "base_link"
        message.group_mix = 1
        message.controls = [0.0] * 8
        message.controls[2] = angular
        message.controls[3] = linear
        self.publisher.publish(message)


if __name__ == "__main__":
    import rospy

    rospy.init_node("ground_actuator")
    GroundActuatorNode()
    rospy.spin()
