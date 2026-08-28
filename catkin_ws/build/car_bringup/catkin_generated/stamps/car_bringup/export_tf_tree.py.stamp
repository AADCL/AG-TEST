#!/usr/bin/env python3
"""Validate the live TF topology, then export frames.gv and frames.pdf."""

import argparse
import os
from pathlib import Path
import subprocess
import sys
import threading
import time

import rospy
from tf2_msgs.msg import TFMessage

sys.path.insert(0, str(Path(__file__).resolve().parent))
from tf_tree_validation import normalize_frame, validate_tf_tree


class TfCollector:
    def __init__(self):
        self.parents = {}
        self._lock = threading.Lock()
        self._sub_tf = rospy.Subscriber("/tf", TFMessage, self._callback, queue_size=100)
        self._sub_static = rospy.Subscriber(
            "/tf_static", TFMessage, self._callback, queue_size=100
        )

    def _callback(self, message):
        with self._lock:
            for transform in message.transforms:
                parent = normalize_frame(transform.header.frame_id)
                child = normalize_frame(transform.child_frame_id)
                if parent and child:
                    self.parents.setdefault(child, set()).add(parent)

    def snapshot(self):
        with self._lock:
            return {child: set(values) for child, values in self.parents.items()}


def parse_args():
    parser = argparse.ArgumentParser()
    parser.add_argument("--listen-seconds", type=float, default=5.0)
    parser.add_argument(
        "--workspace",
        default=os.environ.get("GROUND_AIR_WS", "/home/bitcq/catkin_ws"),
    )
    return parser.parse_args(rospy.myargv(argv=sys.argv)[1:])


def main():
    rospy.init_node("ground_air_tf_tree_exporter", anonymous=True, disable_signals=True)
    args = parse_args()
    collector = TfCollector()
    end_time = time.monotonic() + max(0.5, args.listen_seconds)
    while not rospy.is_shutdown() and time.monotonic() < end_time:
        rospy.sleep(0.05)

    errors = validate_tf_tree(collector.snapshot())
    if errors:
        for error in errors:
            rospy.logerr("TF validation: %s", error)
        return 2

    timestamp = time.strftime("%Y%m%d_%H%M%S")
    output = Path(args.workspace) / "artifacts" / "tf" / timestamp
    output.mkdir(parents=True, exist_ok=False)
    result = subprocess.run(["rosrun", "tf", "view_frames"], cwd=str(output), timeout=30)
    if result.returncode != 0:
        rospy.logerr("view_frames exited with code %d", result.returncode)
        return result.returncode

    expected = (output / "frames.gv", output / "frames.pdf")
    missing = [str(path) for path in expected if not path.is_file()]
    if missing:
        rospy.logerr("TF export did not create: %s", ", ".join(missing))
        return 3
    print(str(output))
    return 0


if __name__ == "__main__":
    sys.exit(main())
