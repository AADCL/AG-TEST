#!/usr/bin/env python3
"""Bridge CCS task command/feedback topics to supervised ground-air services."""

import math
import threading
import time
from types import SimpleNamespace

from epgeneral_task_control.msg import TaskExecutionCommand, TaskExecutionFeedback
from geometry_msgs.msg import PoseStamped
from ground_air_msgs.msg import MissionStatus
from ground_air_msgs.srv import SubmitMission, SubmitMissionRequest
import rospy
from std_srvs.srv import Trigger, TriggerRequest

from epaguav_ground_air_task_adapter.controller import BackendError, TaskAdapterController


COMMAND_TOPIC = "/epgeneral_task_control/execution_command"
FEEDBACK_TOPIC = "/epgeneral_task_control/execution_feedback"
SUBMIT_SERVICE = "/ground_air/mission/submit"
START_SERVICE = "/ground_air/mission/start"
CANCEL_SERVICE = "/ground_air/mission/cancel"
MISSION_STATUS_TOPIC = "/ground_air/mission/status"
LOCALIZATION_POSE_TOPIC = "/ground_air/localization/pose"


class RosMissionBackend:
    def __init__(self, wait_timeout):
        self.wait_timeout = float(wait_timeout)
        self.submit_proxy = rospy.ServiceProxy(SUBMIT_SERVICE, SubmitMission)
        self.start_proxy = rospy.ServiceProxy(START_SERVICE, Trigger)
        self.cancel_proxy = rospy.ServiceProxy(CANCEL_SERVICE, Trigger)

    @staticmethod
    def _error_code(message):
        lowered = str(message).lower()
        if "localiz" in lowered:
            return "LOCALIZATION_UNAVAILABLE"
        if "emergency" in lowered:
            return "EMERGENCY_STOP"
        if "already active" in lowered or "current state" in lowered:
            return "EXECUTION_CONFLICT"
        return "INTERNAL_ERROR"

    def _wait(self, name):
        try:
            rospy.wait_for_service(name, timeout=self.wait_timeout)
        except rospy.ROSException as exc:
            raise BackendError(
                "service {} unavailable: {}".format(name, exc), "SERVICE_UNAVAILABLE"
            )

    def submit(self, mission):
        self._wait(SUBMIT_SERVICE)
        request = SubmitMissionRequest()
        request.mission_id = mission.mission_id
        for waypoint in mission.waypoints:
            goal = PoseStamped()
            goal.header.frame_id = mission.frame_id
            goal.pose.position.x = waypoint.x
            goal.pose.position.y = waypoint.y
            goal.pose.position.z = waypoint.z
            goal.pose.orientation.z = math.sin(waypoint.yaw * 0.5)
            goal.pose.orientation.w = math.cos(waypoint.yaw * 0.5)
            request.goals.append(goal)
        try:
            response = self.submit_proxy(request)
        except rospy.ServiceException as exc:
            raise BackendError(str(exc), "SERVICE_UNAVAILABLE")
        if not response.accepted:
            raise BackendError(response.message, self._error_code(response.message))
        return response.message

    def start(self):
        return self._trigger(START_SERVICE, self.start_proxy)

    def cancel(self):
        return self._trigger(CANCEL_SERVICE, self.cancel_proxy)

    def _trigger(self, name, proxy):
        self._wait(name)
        try:
            response = proxy(TriggerRequest())
        except rospy.ServiceException as exc:
            raise BackendError(str(exc), "SERVICE_UNAVAILABLE")
        if not response.success:
            raise BackendError(response.message, self._error_code(response.message))
        return response.message


class TaskAdapterNode:
    def __init__(self):
        self.lock = threading.RLock()
        self.pose_timeout = float(rospy.get_param("~pose_timeout", 2.0))
        self.feedback_period = float(rospy.get_param("~feedback_period", 1.0))
        if self.pose_timeout <= 0.0 or self.feedback_period <= 0.0:
            raise rospy.ROSInitException("pose_timeout and feedback_period must be positive")
        mission_root = rospy.get_param("~mission_root", "/home/bitcq/ccs_edge_ws/mission")
        wait_timeout = float(rospy.get_param("~service_wait_timeout", 2.0))
        if wait_timeout <= 0.0:
            raise rospy.ROSInitException("service_wait_timeout must be positive")

        self.backend = RosMissionBackend(wait_timeout)
        self.controller = TaskAdapterController(mission_root, self.backend)
        self.latest_pose = None
        self.latest_pose_at = None
        self.latest_status = None
        self.last_feedback_at = 0.0
        self.last_terminal_key = None

        self.feedback_pub = rospy.Publisher(
            FEEDBACK_TOPIC, TaskExecutionFeedback, queue_size=10
        )
        rospy.Subscriber(
            COMMAND_TOPIC, TaskExecutionCommand, self._command_callback, queue_size=10
        )
        rospy.Subscriber(
            MISSION_STATUS_TOPIC, MissionStatus, self._mission_status_callback, queue_size=10
        )
        rospy.Subscriber(
            LOCALIZATION_POSE_TOPIC, PoseStamped, self._pose_callback, queue_size=10
        )
        self.timer = rospy.Timer(rospy.Duration(0.1), self._timer_callback)
        rospy.on_shutdown(self._shutdown)

    def _pose_callback(self, message):
        with self.lock:
            self.latest_pose = message
            self.latest_pose_at = time.monotonic()

    def _fresh_position(self):
        if (
            self.latest_pose is None
            or self.latest_pose_at is None
            or time.monotonic() - self.latest_pose_at > self.pose_timeout
        ):
            return (0.0, 0.0, 0.0), False
        point = self.latest_pose.pose.position
        return (float(point.x), float(point.y), float(point.z)), True

    @staticmethod
    def _command_data(message):
        return SimpleNamespace(
            action=int(message.action),
            request_id=str(message.request_id),
            task_id=str(message.task_id),
            subtask_id=str(message.subtask_id),
            device_id=str(message.device_id),
            execution_id=str(message.execution_id),
            revision=int(message.revision),
            xml_path=str(message.xml_path),
            frame_id=str(message.frame_id),
            map_id=str(message.map_id),
            scheduled_at=float(message.scheduled_at.to_sec()),
        )

    def _command_callback(self, message):
        with self.lock:
            command = self._command_data(message)
            position, fresh = self._fresh_position()
            current_xy = position[:2] if fresh else None
            feedback = self.controller.handle(
                command, current_xy=current_xy, now=rospy.Time.now().to_sec()
            )
            self._publish(feedback)

    def _mission_status_callback(self, message):
        with self.lock:
            self.latest_status = message
            if int(message.state) not in (
                MissionStatus.SUCCEEDED,
                MissionStatus.FAILED,
                MissionStatus.CANCELED,
            ):
                return
            key = (int(message.state), str(message.mission_id), str(message.detail))
            if key == self.last_terminal_key:
                return
            self.last_terminal_key = key
            feedback = self._status_feedback(message)
            if feedback is not None:
                self._publish(feedback)

    def _status_feedback(self, status):
        position, fresh = self._fresh_position()
        detail = str(status.detail)
        if not fresh:
            detail = "{}; localization pose unavailable or stale".format(detail)
        return self.controller.update_mission_status(
            state=status.state,
            current_index=status.current_index,
            total_goals=status.total_goals,
            detail=detail,
            position=position,
        )

    def _timer_callback(self, _event):
        with self.lock:
            transition = self.controller.tick(rospy.Time.now().to_sec())
            if transition is not None:
                self._publish(transition)
            now = time.monotonic()
            if (
                self.latest_status is not None
                and self.controller.core.state == "running"
                and now - self.last_feedback_at >= self.feedback_period
            ):
                feedback = self._status_feedback(self.latest_status)
                if feedback is not None:
                    self._publish(feedback)

    def _publish(self, feedback):
        if feedback is None:
            return
        message = TaskExecutionFeedback()
        for key in (
            "request_id",
            "task_id",
            "subtask_id",
            "device_id",
            "execution_id",
            "revision",
            "state",
            "waypoint_index",
            "waypoint_count",
            "progress",
            "error_code",
            "message",
        ):
            setattr(message, key, getattr(feedback, key))
        message.position.x, message.position.y, message.position.z = feedback.position
        self.feedback_pub.publish(message)
        self.last_feedback_at = time.monotonic()

    def _shutdown(self):
        with self.lock:
            if self.controller.core.state not in ("scheduled", "running"):
                return
            try:
                self.backend.cancel()
            except BackendError as exc:
                rospy.logerr("task adapter shutdown cancel failed: %s", exc)


if __name__ == "__main__":
    rospy.init_node("epaguav_ground_air_task_adapter")
    TaskAdapterNode()
    rospy.loginfo("EPAGUAV ground-air CCS task adapter started")
    rospy.spin()
