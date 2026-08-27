#!/usr/bin/env python3
import rospy
from geometry_msgs.msg import Twist
from ground_air_msgs.msg import VehicleStatus

from ground_air_control.cmd_vel_router_core import CmdVelRouterCore


MODE_NAMES = {
    VehicleStatus.GROUND: "ground",
    VehicleStatus.AIR: "airborne",
    VehicleStatus.TAKEOFF: "takeoff",
    VehicleStatus.LANDING: "landing",
    VehicleStatus.ESTOP: "estop",
    VehicleStatus.FAULT: "fault",
}


class CmdVelRouterNode:
    def __init__(self):
        timeout = rospy.get_param("~timeout", 0.5)
        rate_hz = float(rospy.get_param("~rate", 20.0))
        self.core = CmdVelRouterCore(timeout)
        self.ground_pub = rospy.Publisher("/ground/cmd_vel", Twist, queue_size=1)
        self.air_pub = rospy.Publisher("/air/cmd_vel", Twist, queue_size=1)
        rospy.Subscriber(
            "/navigation/cmd_vel", Twist, self._command_callback, queue_size=1
        )
        rospy.Subscriber(
            "/ground_air/vehicle_status",
            VehicleStatus,
            self._status_callback,
            queue_size=10,
        )
        self.timer = rospy.Timer(rospy.Duration(1.0 / rate_hz), self._timer_callback)

    def _status_callback(self, message):
        self.core.set_mode(MODE_NAMES.get(message.mode, "unknown"))
        self.core.set_emergency_stop(message.emergency_stop)
        if message.emergency_stop or message.mode not in (
            VehicleStatus.GROUND,
            VehicleStatus.AIR,
        ):
            self._publish_stop()

    def _command_callback(self, message):
        decision = self.core.accept(
            (message.linear.x, message.linear.y, message.angular.z),
            rospy.get_time(),
        )
        self._publish(decision)

    def _timer_callback(self, _event):
        self._publish(self.core.tick(rospy.get_time()))

    @staticmethod
    def _twist(command):
        message = Twist()
        message.linear.x = command[0]
        message.linear.y = command[1]
        message.angular.z = command[2]
        return message

    def _publish(self, decision):
        if decision.channel == "ground":
            self.ground_pub.publish(self._twist(decision.command))
        elif decision.channel == "air":
            self.air_pub.publish(self._twist(decision.command))
        else:
            self._publish_stop()

    def _publish_stop(self):
        zero = Twist()
        self.ground_pub.publish(zero)
        self.air_pub.publish(zero)


if __name__ == "__main__":
    rospy.init_node("cmd_vel_router")
    CmdVelRouterNode()
    rospy.spin()
