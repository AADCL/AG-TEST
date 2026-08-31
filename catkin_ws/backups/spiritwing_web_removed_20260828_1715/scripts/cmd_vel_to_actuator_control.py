#!/usr/bin/env python3
# -*- coding: utf-8 -*-

"""Convert /cmd_vel into /mavros/actuator_control for Lukong field testing.

This mirrors the script provided from the UAV. Keep it as a separate bridge so
the Web node can publish standard Twist commands while actuator mapping stays
easy to tune on the vehicle.
"""

import rospy
from geometry_msgs.msg import Twist
from mavros_msgs.msg import ActuatorControl
from std_msgs.msg import Header


class CmdVelToActuatorControl:
    def __init__(self):
        rospy.init_node("cmd_vel_to_actuator_control", anonymous=False)

        self.cmd_vel_topic = rospy.get_param("~cmd_vel_topic", "/cmd_vel")
        self.actuator_topic = rospy.get_param("~actuator_topic", "/mavros/actuator_control")
        self.frame_id = rospy.get_param("~frame_id", "base_link")
        self.publish_hz = float(rospy.get_param("~publish_hz", 20.0))
        self.group_mix = int(rospy.get_param("~group_mix", 1))
        self.yaw_index = int(rospy.get_param("~yaw_index", 2))
        self.forward_index = int(rospy.get_param("~forward_index", 3))
        self.invert_yaw = bool(rospy.get_param("~invert_yaw", True))
        self.timeout_s = float(rospy.get_param("~timeout_s", 0.5))

        self.linear_x = 0.0
        self.angular_z = 0.0
        self.last_cmd_time = rospy.Time(0)

        rospy.Subscriber(self.cmd_vel_topic, Twist, self.cmd_vel_callback, queue_size=10)
        self.actuator_pub = rospy.Publisher(self.actuator_topic, ActuatorControl, queue_size=10)

    def cmd_vel_callback(self, msg):
        self.linear_x = msg.linear.x
        self.angular_z = -msg.angular.z if self.invert_yaw else msg.angular.z
        self.last_cmd_time = rospy.Time.now()

    def spin(self):
        rate = rospy.Rate(self.publish_hz)
        while not rospy.is_shutdown():
            now = rospy.Time.now()
            linear_x = self.linear_x
            angular_z = self.angular_z
            if self.timeout_s > 0.0 and not self.last_cmd_time.is_zero():
                if (now - self.last_cmd_time).to_sec() > self.timeout_s:
                    linear_x = 0.0
                    angular_z = 0.0

            msg = ActuatorControl()
            msg.header = Header(stamp=now, frame_id=self.frame_id)
            msg.group_mix = self.group_mix
            msg.controls = [0.0] * 8
            if 0 <= self.yaw_index < len(msg.controls):
                msg.controls[self.yaw_index] = angular_z
            if 0 <= self.forward_index < len(msg.controls):
                msg.controls[self.forward_index] = linear_x
            self.actuator_pub.publish(msg)
            rate.sleep()


if __name__ == "__main__":
    try:
        CmdVelToActuatorControl().spin()
    except rospy.ROSInterruptException:
        pass
