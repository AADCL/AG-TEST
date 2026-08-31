"""Pure configuration and reconnect policy for the A8 Mini ROS bridge."""

from dataclasses import dataclass, field
import ipaddress
import math


def build_rtsp_url(camera_ip: str) -> str:
    """Return the SIYI A8 Mini main-stream URL for a validated IPv4 address."""
    try:
        address = ipaddress.ip_address(camera_ip)
    except ValueError as error:
        raise ValueError("camera_ip must be a valid IPv4 address") from error
    if address.version != 4:
        raise ValueError("camera_ip must be a valid IPv4 address")
    return f"rtsp://{address}:8554/main.264"


@dataclass(frozen=True)
class CameraConfig:
    camera_ip: str = "192.168.144.25"
    image_topic: str = "/a8_cam/image_raw"
    frame_id: str = "a8_cam"
    publish_rate: float = 30.0
    reconnect_initial_delay: float = 1.0
    reconnect_maximum_delay: float = 8.0
    rtsp_url: str = field(init=False)

    def __post_init__(self) -> None:
        object.__setattr__(self, "rtsp_url", build_rtsp_url(self.camera_ip))
        if not self.image_topic.startswith("/"):
            raise ValueError("image_topic must be an absolute ROS topic")
        if not self.frame_id or self.frame_id.startswith("/"):
            raise ValueError("frame_id must be non-empty and must not start with '/'")
        if not math.isfinite(self.publish_rate) or self.publish_rate <= 0.0:
            raise ValueError("publish_rate must be finite and greater than zero")
        ReconnectPolicy(self.reconnect_initial_delay, self.reconnect_maximum_delay)


class ReconnectPolicy:
    """Bounded exponential backoff used after RTSP open/read failures."""

    def __init__(self, initial_delay: float = 1.0, maximum_delay: float = 8.0) -> None:
        if not math.isfinite(initial_delay) or initial_delay <= 0.0:
            raise ValueError("initial_delay must be finite and greater than zero")
        if not math.isfinite(maximum_delay) or maximum_delay < initial_delay:
            raise ValueError("maximum_delay must be finite and at least initial_delay")
        self._initial_delay = float(initial_delay)
        self._maximum_delay = float(maximum_delay)
        self._current_delay = self._initial_delay

    def next_delay(self) -> float:
        delay = self._current_delay
        self._current_delay = min(self._maximum_delay, self._current_delay * 2.0)
        return delay

    def reset(self) -> None:
        self._current_delay = self._initial_delay
