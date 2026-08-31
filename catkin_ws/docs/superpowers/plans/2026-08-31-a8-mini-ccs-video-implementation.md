# A8 Mini CCS Video Integration Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Publish the SIYI A8 Mini RTSP stream as a ROS image topic and expose it to CCS_dev through the official H.264/MPEG-TS SRT Listener from `base_system.launch`.

**Architecture:** A focused Python ROS node decodes `rtsp://192.168.144.25:8554/main.264`, publishes `/a8_cam/image_raw`, and reconnects without replaying stale frames. The unmodified CCS `epgeneral_video_srt v0.1.0` subscribes to that topic and listens on robot UDP 9000 for the CCS_dev FFmpeg Caller.

**Tech Stack:** ROS1 Noetic, Python 3, rospy, OpenCV/FFmpeg, cv_bridge, sensor_msgs, GStreamer 1.0, SRT, catkin.

## Global Constraints

- Work only in `/home/bitcq/catkin_ws`; do not depend on sourcing `/home/bitcq/ccs_edge_ws`.
- A8 Mini is `192.168.144.25`; RTSP source is `rtsp://192.168.144.25:8554/main.264`.
- Publish `sensor_msgs/Image` on `/a8_cam/image_raw`, frame `a8_cam`.
- Device identity is `AGV_001`, robot address is `192.168.50.130`.
- SRT is H.264 baseline in MPEG-TS, Listener on UDP 9000, 120 ms latency, 2000 kbit/s.
- Camera/video failures must not terminate the remaining `base_system.launch` processes.
- No camera extrinsics or CameraInfo are published without calibration.
- No arming, mode change, movement, takeoff, landing, TF, mapping, localization, or mission behavior changes.
- `/home/bitcq/catkin_ws` has no `.git`; commit steps are replaced by explicit file backups, diffs, and verification hashes.

---

### Task 1: A8 Mini ROS image bridge

**Files:**
- Create: `src/a8_mini_camera/package.xml`
- Create: `src/a8_mini_camera/CMakeLists.txt`
- Create: `src/a8_mini_camera/scripts/a8_mini_camera_core.py`
- Create: `src/a8_mini_camera/scripts/a8_mini_camera_node.py`
- Create: `src/a8_mini_camera/launch/a8_mini_camera.launch`
- Create: `src/a8_mini_camera/tests/test_a8_mini_camera_core.py`

**Interfaces:**
- Consumes: RTSP URL string and OpenCV `VideoCapture` frames.
- Produces: `/a8_cam/image_raw` (`sensor_msgs/Image`) and pure helpers `CameraConfig`, `validate_config`, `build_rtsp_url`, `ReconnectPolicy`.

- [ ] **Step 1: Write failing core tests**

Test exact defaults, rejection of non-absolute topics/invalid rates, IP-to-RTSP URL construction, and reconnect delay reset/increment behavior.

- [ ] **Step 2: Verify RED**

Run:

```bash
cd /home/bitcq/catkin_ws/src/a8_mini_camera
python3 -m unittest discover -s tests -v
```

Expected: import failure because `a8_mini_camera_core.py` does not exist.

- [ ] **Step 3: Implement the pure core**

Implement immutable validated configuration and a bounded reconnect policy. `build_rtsp_url("192.168.144.25")` must return exactly `rtsp://192.168.144.25:8554/main.264`.

- [ ] **Step 4: Verify core GREEN**

Run the same unittest command. Expected: all tests pass.

- [ ] **Step 5: Implement the ROS node and package metadata**

The node must:

```python
capture = cv2.VideoCapture(config.rtsp_url, cv2.CAP_FFMPEG)
capture.set(cv2.CAP_PROP_BUFFERSIZE, 1)
ok, frame = capture.read()
message = bridge.cv2_to_imgmsg(frame, encoding="bgr8")
message.header.stamp = rospy.Time.now()
message.header.frame_id = config.frame_id
publisher.publish(message)
```

On open/read failure, release the capture, sleep using `ReconnectPolicy`, and reconnect. Never publish when `read()` returns false. Publisher queue size is 1.

- [ ] **Step 6: Verify syntax and tests**

```bash
python3 -m py_compile scripts/a8_mini_camera_core.py scripts/a8_mini_camera_node.py
python3 -m unittest discover -s tests -v
```

Expected: exit 0.

### Task 2: Official CCS SRT package and robot video profile

**Files:**
- Copy unchanged: `/home/bitcq/ccs_edge_ws/src/EPGeneral_video_srt` to `src/EPGeneral_video_srt`
- Create: `src/car_bringup/config/a8_video.yaml`
- Modify: `src/EPGeneral_device_config/config/device.yaml`
- Create: `src/car_bringup/tests/test_a8_ccs_video_contract.py`

**Interfaces:**
- Consumes: `/a8_cam/image_raw` and `/edge_device/device/{id,ip}`.
- Produces: SRT Listener `0.0.0.0:9000/udp` carrying H.264 baseline/MPEG-TS.

- [ ] **Step 1: Write failing contract tests**

Parse YAML/XML/source and assert:

```python
assert video["image_topic"] == "/a8_cam/image_raw"
assert video["image_message_type"] == "sensor_msgs/Image"
assert video["srt_port"] == 9000
assert video["srt_bind_address"] == "0.0.0.0"
assert device["device"]["id"] == "AGV_001"
assert device["device"]["ip"] == "192.168.50.130"
```

Also assert the SRT source contains `mode=listener`, `x264enc`, `h264parse`, `mpegtsmux`, and `srtsink`.

- [ ] **Step 2: Verify RED**

Run:

```bash
cd /home/bitcq/catkin_ws/src/car_bringup
python3 -m unittest tests.test_a8_ccs_video_contract -v
```

Expected: failure because the current workspace lacks the package/profile and has the wrong identity.

- [ ] **Step 3: Copy the official package and create the profile**

Use the already audited `v0.1.0` package without protocol changes. Configure 640×480, 30 fps, 2000 kbit/s, 120 ms, frame timeout 5 s, and UDP 9000.

- [ ] **Step 4: Correct robot identity**

Write exactly:

```yaml
schema_version: 1
device:
  id: "AGV_001"
  ip: "192.168.50.130"
```

- [ ] **Step 5: Verify GREEN and official package identity**

Run the contract test and check `package.xml` version/name. Expected: all tests pass; package is `epgeneral_video_srt` version `0.1.0`.

### Task 3: Integrate both nodes into `base_system.launch`

**Files:**
- Modify: `src/car_bringup/launch/base_system.launch`
- Modify: `src/car_bringup/package.xml`
- Test: `src/car_bringup/tests/test_a8_ccs_video_contract.py`

**Interfaces:**
- Consumes: launch arguments `start_a8_camera`, `start_video_srt`, `a8_camera_ip`, `a8_image_topic`, `srt_port`.
- Produces: optional camera and SRT processes in the base layer.

- [ ] **Step 1: Extend the contract test and verify RED**

Assert default values, conditional includes, argument forwarding, and that neither camera nor SRT node/include is marked `required="true"`.

- [ ] **Step 2: Add launch arguments and commented includes**

Add defaults:

```xml
<arg name="start_a8_camera" default="true" />
<arg name="start_video_srt" default="true" />
<arg name="a8_camera_ip" default="192.168.144.25" />
<arg name="a8_image_topic" default="/a8_cam/image_raw" />
<arg name="srt_port" default="9000" />
```

Include `a8_mini_camera.launch` and `epgeneral_video_srt.launch` conditionally, passing the current device YAML and A8 video YAML. Add runtime dependencies to `car_bringup/package.xml`.

- [ ] **Step 3: Verify GREEN and launch expansion**

```bash
python3 -m unittest tests.test_a8_ccs_video_contract -v
roslaunch --files car_bringup base_system.launch start_mavros:=false start_livox:=false
```

Expected: test exit 0 and files resolve entirely under `/home/bitcq/catkin_ws`.

### Task 4: Build and isolated hardware verification

**Files:**
- No production file changes unless a failing test exposes a defect; any defect first receives a failing regression test.

**Interfaces:**
- Consumes: live A8 RTSP and robot UDP 9000.
- Produces: build/test evidence and a decoded SRT stream.

- [ ] **Step 1: Verify dependencies**

```bash
python3 -c 'import cv2, cv_bridge, rospy; print(cv2.__version__)'
gst-inspect-1.0 srtsink
ping -c 2 192.168.144.25
```

Expected: imports succeed, `srtsink` is present, and ping has 0% loss.

- [ ] **Step 2: Build the complete workspace**

```bash
cd /home/bitcq/catkin_ws
source /opt/ros/noetic/setup.bash
catkin_make --force-cmake -DPYTHON_EXECUTABLE=/usr/bin/python3
```

Expected: exit 0.

- [ ] **Step 3: Run all focused tests**

Run A8 core and CCS contract suites. Expected: zero failures.

- [ ] **Step 4: Start only the video chain**

```bash
source /home/bitcq/catkin_ws/devel/setup.bash
roslaunch car_bringup base_system.launch start_mavros:=false start_livox:=false
```

Expected: A8 connects, first ROS image arrives, SRT Listener binds UDP 9000; no vehicle-control nodes are started.

- [ ] **Step 5: Inspect ROS and SRT health**

```bash
rostopic hz /a8_cam/image_raw
rostopic echo -n1 /a8_cam/image_raw/header
ss -lunp | grep ':9000'
```

Expected: sustained image rate, frame `a8_cam`, and one UDP 9000 owner.

- [ ] **Step 6: Decode through a Caller**

Use a bounded non-display FFmpeg probe from a separate host or after confirming the installed FFmpeg supports SRT:

```bash
ffprobe -v error -rw_timeout 5000000 -show_streams \
  'srt://192.168.50.130:9000?mode=caller&transtype=live&latency=120000'
```

Expected: one H.264 video stream in MPEG-TS.

- [ ] **Step 7: CCS_dev acceptance**

Set the CCS device `AGV_001` to `192.168.50.130`, SRT port 9000 and latency 120 ms. Open its video switch and confirm live frames; closing the page must disconnect the Caller without stopping the robot Listener.
