#!/usr/bin/env python3
"""Invoke one typed ground-air service workflow from a roslaunch entry point."""

import os
import sys

import rospy
from geometry_msgs.msg import Pose
from ground_air_msgs.srv import LoadMap, Relocalize, SaveMapping, StartMapping

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from ground_air_operation_core import OperationError, execute


class RosOperationApi:
    def __init__(self, wait_timeout):
        self._wait_timeout = wait_timeout

    def _proxy(self, service_name, service_type):
        rospy.loginfo("waiting for %s", service_name)
        rospy.wait_for_service(service_name, timeout=self._wait_timeout)
        return rospy.ServiceProxy(service_name, service_type)

    def start_mapping(self, map_id):
        return self._proxy("/ground_air/mapping/start", StartMapping)(map_id=map_id)

    def save_mapping(self):
        return self._proxy("/ground_air/mapping/save", SaveMapping)()

    def load_map(self, map_id):
        return self._proxy("/ground_air/load_map", LoadMap)(
            map_id=map_id, source_uri=""
        )

    def relocalize(self, timeout):
        return self._proxy("/ground_air/relocalize", Relocalize)(
            use_initial_guess=False,
            initial_guess=Pose(),
            timeout=timeout,
        )


def main():
    rospy.init_node("ground_air_operation")
    operation = rospy.get_param("~operation")
    map_id = rospy.get_param("~map_id", "")
    timeout = float(rospy.get_param("~relocalize_timeout", 60.0))
    wait_timeout = float(rospy.get_param("~service_wait_timeout", 90.0))
    keep_alive = bool(rospy.get_param("~keep_alive", False))

    try:
        response = execute(
            operation,
            RosOperationApi(wait_timeout),
            map_id=map_id,
            timeout=timeout,
        )
    except (OperationError, rospy.ROSException, rospy.ServiceException) as error:
        rospy.logfatal("ground-air operation '%s' failed: %s", operation, error)
        return 1

    rospy.loginfo("ground-air operation '%s' succeeded: %s", operation, response.message)
    if operation == "save_mapping":
        rospy.loginfo(
            "map_directory=%s point_count=%d map_area=%.3f",
            response.map_directory,
            response.point_count,
            response.map_area,
        )
    elif operation == "relocalize":
        rospy.loginfo(
            "fitness=%.6f rmse=%.6f pose=(%.3f, %.3f, %.3f)",
            response.fitness,
            response.rmse,
            response.pose.pose.position.x,
            response.pose.pose.position.y,
            response.pose.pose.position.z,
        )

    if keep_alive:
        rospy.loginfo("operation complete; keeping the included stack alive")
        rospy.spin()
    return 0


if __name__ == "__main__":
    sys.exit(main())
