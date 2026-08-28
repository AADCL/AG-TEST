#!/usr/bin/env python3
"""ROS adapter for ordered, pauseable move_base missions."""

import threading

import actionlib
from actionlib_msgs.msg import GoalStatus
from geometry_msgs.msg import Twist
from ground_air_msgs.msg import MissionStatus, VehicleStatus
from ground_air_msgs.srv import SubmitMission, SubmitMissionResponse
from move_base_msgs.msg import MoveBaseAction, MoveBaseGoal
import rospy
from std_srvs.srv import Trigger, TriggerResponse

from mission_executor_core import MissionError, MissionExecutorCore, MissionState


class MissionExecutorNode:
    def __init__(self):
        self._lock = threading.RLock()
        self._core = MissionExecutorCore(rospy.get_param("~dwell_seconds", 2.0))
        self._localized = False
        self._emergency_stop = True
        self._vehicle_mode = VehicleStatus.UNKNOWN
        self._armed = False
        self._altitude = 0.0

        action_name = rospy.get_param("~move_base_action", "/move_base")
        self._move_base = actionlib.SimpleActionClient(action_name, MoveBaseAction)
        self._zero_pub = rospy.Publisher("/navigation/cmd_vel", Twist, queue_size=1)
        self._status_pub = rospy.Publisher(
            "/ground_air/mission/status", MissionStatus, queue_size=1, latch=True
        )
        rospy.Subscriber(
            "/ground_air/vehicle_status", VehicleStatus, self._vehicle_status_cb, queue_size=1
        )

        rospy.Service("/ground_air/mission/submit", SubmitMission, self._submit_cb)
        rospy.Service("/ground_air/mission/start", Trigger, self._start_cb)
        rospy.Service("/ground_air/mission/pause", Trigger, self._pause_cb)
        rospy.Service("/ground_air/mission/resume", Trigger, self._resume_cb)
        rospy.Service("/ground_air/mission/cancel", Trigger, self._cancel_cb)
        rospy.Timer(rospy.Duration(0.05), self._timer_cb)
        self._publish_status()

    def _vehicle_status_cb(self, msg):
        with self._lock:
            self._localized = bool(msg.localized)
            self._emergency_stop = bool(msg.emergency_stop)
            self._vehicle_mode = msg.mode
            self._armed = bool(msg.armed)
            self._altitude = float(msg.altitude)

    def _is_airborne(self):
        return self._vehicle_mode == VehicleStatus.AIR or (
            self._armed and self._altitude > 0.2
        )

    def _submit_cb(self, req):
        with self._lock:
            try:
                self._core.submit(
                    req.mission_id,
                    req.goals,
                    localized=self._localized,
                    emergency_stop=self._emergency_stop,
                )
            except MissionError as exc:
                return SubmitMissionResponse(False, str(exc), 0)
            self._publish_status()
            return SubmitMissionResponse(True, "mission accepted", len(req.goals))

    def _start_cb(self, _req):
        return self._run_service_operation(self._core.start)

    def _pause_cb(self, _req):
        return self._run_service_operation(lambda: self._core.pause(rospy.get_time()))

    def _resume_cb(self, _req):
        return self._run_service_operation(
            lambda: self._core.resume(
                rospy.get_time(), self._localized, self._emergency_stop
            )
        )

    def _cancel_cb(self, _req):
        return self._run_service_operation(self._core.cancel)

    def _run_service_operation(self, operation):
        with self._lock:
            try:
                action = operation()
                self._apply_action(action)
            except MissionError as exc:
                return TriggerResponse(False, str(exc))
            self._publish_status()
            return TriggerResponse(True, self._core.detail)

    def _send_goal(self, pose):
        goal = MoveBaseGoal()
        goal.target_pose = pose
        if not goal.target_pose.header.frame_id:
            goal.target_pose.header.frame_id = rospy.get_param("~default_goal_frame", "world")
        goal.target_pose.header.stamp = rospy.Time.now()
        self._move_base.send_goal(goal, done_cb=self._move_base_done_cb)

    def _move_base_done_cb(self, status, _result):
        with self._lock:
            if self._core.state != MissionState.RUNNING:
                return
            try:
                if status == GoalStatus.SUCCEEDED:
                    action = self._core.on_goal_succeeded(
                        rospy.get_time(), airborne=self._is_airborne()
                    )
                else:
                    action = self._core.on_goal_failed(
                        "move_base finished with status {}".format(status)
                    )
                self._apply_action(action)
            except MissionError as exc:
                rospy.logerr("mission result rejected: %s", exc)
            self._publish_status()

    def _apply_action(self, action):
        if action is None:
            return
        name, payload = action
        if name == "send_goal":
            self._send_goal(payload)
        elif name == "cancel_goal":
            self._move_base.cancel_goal()
        elif name == "cancel_and_stop":
            self._move_base.cancel_all_goals()
            self._zero_pub.publish(Twist())
        elif name in ("stop", "hover"):
            self._zero_pub.publish(Twist())
        else:
            raise RuntimeError("unknown mission action: {}".format(name))

    def _timer_cb(self, _event):
        with self._lock:
            action = self._core.tick(
                rospy.get_time(), self._localized, self._emergency_stop
            )
            self._apply_action(action)
            self._publish_status()

    def _publish_status(self):
        msg = MissionStatus()
        msg.header.stamp = rospy.Time.now()
        msg.state = int(self._core.state)
        msg.current_index = self._core.current_index
        msg.total_goals = self._core.total_goals
        msg.mission_id = self._core.mission_id
        msg.detail = self._core.detail
        self._status_pub.publish(msg)


if __name__ == "__main__":
    rospy.init_node("mission_executor")
    MissionExecutorNode()
    rospy.spin()
