"""Safe parsing helpers for CCS trajectory XML."""

from dataclasses import dataclass
import math
import os
import stat
from xml.etree import ElementTree


@dataclass(frozen=True)
class Waypoint:
    index: int
    waypoint_id: str
    x: float
    y: float
    z: float
    yaw: float


@dataclass(frozen=True)
class Trajectory:
    mission_id: str
    task_id: str
    subtask_id: str
    device_id: str
    revision: int
    map_id: str
    frame_id: str
    waypoints: tuple


class AdapterError(ValueError):
    def __init__(self, message, error_code="INVALID_TRAJECTORY"):
        super().__init__(str(message))
        self.error_code = str(error_code)


def _fail(message):
    raise AdapterError(message)


def _safe_regular_file(xml_path, mission_root):
    root = os.path.realpath(os.path.abspath(os.path.expanduser(mission_root)))
    path = os.path.abspath(os.path.expanduser(xml_path))
    resolved = os.path.realpath(path)
    try:
        if os.path.commonpath((root, resolved)) != root:
            _fail("trajectory path is outside the configured mission root")
        if os.path.islink(path):
            _fail("trajectory path must not be a symbolic link")
        if not stat.S_ISREG(os.stat(path, follow_symlinks=False).st_mode):
            _fail("trajectory path is not a regular file")
    except (OSError, ValueError) as exc:
        _fail("trajectory path is invalid: {}".format(exc))
    return path


def _finite(value, name):
    try:
        result = float(value)
    except (TypeError, ValueError):
        _fail("{} must be numeric".format(name))
    if not math.isfinite(result):
        _fail("{} must be finite".format(name))
    return result


def _positive_int(value, name, minimum=0):
    try:
        result = int(value)
    except (TypeError, ValueError):
        _fail("{} must be an integer".format(name))
    if str(result) != str(value) or result < minimum:
        _fail("{} is out of range".format(name))
    return result


def load_trajectory(
    xml_path,
    mission_root,
    task_id,
    subtask_id,
    device_id,
    revision,
    map_id,
    frame_id,
    current_xy=None,
):
    path = _safe_regular_file(xml_path, mission_root)
    try:
        root = ElementTree.parse(path).getroot()
    except (ElementTree.ParseError, OSError) as exc:
        _fail("trajectory XML cannot be read: {}".format(exc))
    if root.tag != "trajectory" or root.get("schema_version") != "2":
        _fail("trajectory XML schema is invalid")
    expected = {
        "task_id": str(task_id),
        "subtask_id": str(subtask_id),
        "device_id": str(device_id),
    }
    for key, value in expected.items():
        if root.get(key) != value:
            _fail("trajectory {} does not match command".format(key))
    parsed_revision = _positive_int(root.get("revision"), "revision", 1)
    if parsed_revision != int(revision):
        _fail("trajectory revision does not match command")
    metadata = root.find("metadata")
    waypoint_container = root.find("waypoints")
    if metadata is None or waypoint_container is None:
        _fail("trajectory XML is missing metadata or waypoints")
    if metadata.get("map_id") != str(map_id):
        _fail("trajectory map_id does not match command")
    if metadata.get("frame_id") != str(frame_id) or str(frame_id) != "map":
        _fail("trajectory frame_id must be map")
    speed = _finite(metadata.get("cruise_speed_mps"), "cruise_speed_mps")
    delay = _finite(metadata.get("start_delay_seconds"), "start_delay_seconds")
    if speed <= 0.0 or delay < 0.0:
        _fail("trajectory speed or start delay is out of range")
    items = waypoint_container.findall("waypoint")
    declared_count = _positive_int(waypoint_container.get("count"), "waypoint count", 2)
    if declared_count != len(items) or not 2 <= len(items) <= 500:
        _fail("trajectory must contain 2 to 500 waypoints")
    points = []
    waypoint_ids = set()
    previous_xy = current_xy
    previous_yaw = 0.0
    for expected_index, item in enumerate(items):
        index = _positive_int(item.get("index"), "waypoint index")
        if index != expected_index:
            _fail("waypoint indices must be contiguous")
        waypoint_id = item.get("waypoint_id")
        if (
            not waypoint_id
            or len(waypoint_id) > 128
            or waypoint_id in waypoint_ids
        ):
            _fail("waypoint ID is invalid or duplicated")
        waypoint_ids.add(waypoint_id)
        x = _finite(item.get("x"), "waypoint.x")
        y = _finite(item.get("y"), "waypoint.y")
        z = _finite(item.get("z"), "waypoint.z")
        if previous_xy is not None and math.hypot(x - previous_xy[0], y - previous_xy[1]) > 1e-9:
            previous_yaw = math.atan2(y - previous_xy[1], x - previous_xy[0])
        points.append(
            Waypoint(
                index,
                waypoint_id,
                x,
                y,
                z,
                previous_yaw,
            )
        )
        previous_xy = (x, y)
    return Trajectory(
        "{}:{}:r{}".format(root.get("task_id"), root.get("subtask_id"), root.get("revision")),
        root.get("task_id"),
        root.get("subtask_id"),
        root.get("device_id"),
        parsed_revision,
        metadata.get("map_id"),
        metadata.get("frame_id"),
        tuple(points),
    )
