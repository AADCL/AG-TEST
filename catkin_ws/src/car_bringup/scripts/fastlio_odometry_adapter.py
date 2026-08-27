#!/usr/bin/env python3
"""Adapt FAST-LIO odometry frame semantics for the MAVROS odometry plugin."""

import copy

import rospy
from nav_msgs.msg import Odometry


class FrameContractError(ValueError):
    pass


def _normalized_frame(frame_id):
    return frame_id.lstrip("/")


def adapt_odometry(
    message,
    expected_frame_id="camera_init",
    expected_child_frame_id="body",
    output_frame_id="odom",
    output_child_frame_id="base_link",
):
    """Return a copy using MAVROS ENU/FLU semantic frame names.

    MAVROS owns the numeric ENU/FLU -> NED/FRD conversion through its standard
    odom<->odom_ned and base_link<->base_link_frd transforms.  Rewriting these
    semantic aliases connects FAST-LIO to that conversion without rotating the
    measurement twice.
    """
    actual_frame = _normalized_frame(message.header.frame_id)
    actual_child = _normalized_frame(message.child_frame_id)
    expected_frame = _normalized_frame(expected_frame_id)
    expected_child = _normalized_frame(expected_child_frame_id)

    if actual_frame != expected_frame:
        raise FrameContractError(
            "expected parent frame '{}', received '{}'".format(
                expected_frame, actual_frame
            )
        )
    if actual_child != expected_child:
        raise FrameContractError(
            "expected child frame '{}', received '{}'".format(
                expected_child, actual_child
            )
        )

    adapted = copy.deepcopy(message)
    adapted.header.frame_id = _normalized_frame(output_frame_id)
    adapted.child_frame_id = _normalized_frame(output_child_frame_id)
    return adapted


class FastlioOdometryAdapterNode:
    def __init__(self):
        input_topic = rospy.get_param("~input_topic", "/Odometry_loc")
        output_topic = rospy.get_param("~output_topic", "/mavros/odometry/out")
        self.expected_frame_id = rospy.get_param(
            "~expected_frame_id", "camera_init"
        )
        self.expected_child_frame_id = rospy.get_param(
            "~expected_child_frame_id", "body"
        )
        self.output_frame_id = rospy.get_param("~output_frame_id", "odom")
        self.output_child_frame_id = rospy.get_param(
            "~output_child_frame_id", "base_link"
        )

        self.publisher = rospy.Publisher(output_topic, Odometry, queue_size=10)
        self.subscriber = rospy.Subscriber(
            input_topic, Odometry, self._callback, queue_size=10
        )
        rospy.loginfo(
            "FAST-LIO odometry adapter: %s (%s/%s) -> %s (%s/%s)",
            input_topic,
            self.expected_frame_id,
            self.expected_child_frame_id,
            output_topic,
            self.output_frame_id,
            self.output_child_frame_id,
        )

    def _callback(self, message):
        try:
            adapted = adapt_odometry(
                message,
                expected_frame_id=self.expected_frame_id,
                expected_child_frame_id=self.expected_child_frame_id,
                output_frame_id=self.output_frame_id,
                output_child_frame_id=self.output_child_frame_id,
            )
        except FrameContractError as error:
            rospy.logerr_throttle(2.0, "FAST-LIO odometry rejected: %s", error)
            return
        self.publisher.publish(adapted)


def main():
    rospy.init_node("fastlio_odometry_to_px4")
    FastlioOdometryAdapterNode()
    rospy.spin()


if __name__ == "__main__":
    main()
