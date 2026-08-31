#!/usr/bin/env python3
"""Activates a validated historical map bundle and supervises map_server."""

import os
import signal
import subprocess
import threading
import time
from pathlib import Path

from ground_air_msgs.srv import LoadMap, LoadMapResponse
import rospy
from std_msgs.msg import String

from ground_air_localization.map_registry import MapRegistry, MapRegistryError


class MapManagerNode:
    def __init__(self):
        root = rospy.get_param("~maps_root", "/home/bitcq/catkin_ws/maps")
        self._map_frame = rospy.get_param("~map_frame", "map")
        self._registry = MapRegistry(root)
        self._lock = threading.RLock()
        self._map_server = None
        self._map_changed_pub = rospy.Publisher(
            "/ground_air/localization/map_changed", String, queue_size=1, latch=True
        )
        rospy.Service("/ground_air/load_map", LoadMap, self._load_map_cb)
        rospy.on_shutdown(self._stop_map_server)

    def _stop_map_server(self):
        process = self._map_server
        self._map_server = None
        if process is None or process.poll() is not None:
            return
        try:
            os.killpg(os.getpgid(process.pid), signal.SIGINT)
            process.wait(timeout=5.0)
        except (OSError, subprocess.TimeoutExpired):
            process.terminate()

    def _start_map_server(self, yaml_path):
        self._stop_map_server()
        command = [
            "rosrun",
            "map_server",
            "map_server",
            str(yaml_path),
            "__name:=ground_air_map_server",
            "_frame_id:={}".format(self._map_frame),
        ]
        self._map_server = subprocess.Popen(command, start_new_session=True)
        time.sleep(0.5)
        if self._map_server.poll() is not None:
            code = self._map_server.returncode
            self._map_server = None
            raise RuntimeError("map_server exited with code {}".format(code))

    def _load_map_cb(self, request):
        with self._lock:
            source = request.source_uri
            if not source:
                source = str(self._registry.root / request.map_id)
            try:
                bundle = self._registry.install(request.map_id, source)
                self._start_map_server(bundle.yaml)
            except (MapRegistryError, OSError, RuntimeError) as exc:
                rospy.logerr("map activation failed: %s", exc)
                return LoadMapResponse(False, str(exc), "")

            rospy.set_param("/ground_air/active_map_id", bundle.map_id)
            rospy.set_param("/ground_air/active_map_directory", str(bundle.directory))
            rospy.set_param("/ground_air/active_map_pcd", str(bundle.pcd))
            rospy.set_param("/ground_air/active_map_yaml", str(bundle.yaml))
            self._map_changed_pub.publish(String(data=str(bundle.pcd)))
            return LoadMapResponse(True, "map activated; relocalization required", str(bundle.directory))


if __name__ == "__main__":
    rospy.init_node("ground_air_map_manager")
    MapManagerNode()
    rospy.spin()
