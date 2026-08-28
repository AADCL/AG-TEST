# Ground-Air Full Flow Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Consolidate the verified HZBZ hardware chain and new production orchestration packages into `/home/bitcq/catkin_ws` so mapping, global relocalization, ordered navigation, ground/air mode switching, fixed-height flight, emergency stop, platform communication, and video can be exercised end to end.

**Architecture:** Preserve the four HZBZ packages and import only the verified sensor/LIO/platform packages. Put production state machines behind new ROS services, route navigation velocity through one exclusive mux, and make the platform bridge an adapter rather than a hardware controller. Use Open3D 0.14.1 FPFH/RANSAC plus ICP for unknown-pose relocalization.

**Tech Stack:** ROS1 Noetic, catkin, Python 3.8, C++14, MAVROS, move_base/actionlib, TEB, PCL, Open3D 0.14.1, libhv, yaml-cpp, GStreamer/FFmpeg.

## Global Constraints

- Canonical local workspace: `C:/Users/BM/Desktop/重点研发/ground-air/catkin_ws`.
- Canonical remote workspace: `/home/bitcq/catkin_ws`.
- Ignore archive contents.
- Flight altitude is exactly `1.0 m` relative to takeoff position.
- Takeoff, landing, mode switching, emergency stop, and reset use ROS services.
- A flight goal never causes automatic landing.
- Every successful task point dwells for `2.0 s`.
- Do not arm or move hardware during automated verification.
- New behavior follows test-driven development.

---

### Task 1: Import and audit the verified hardware packages

**Files:**
- Create: `src/livox_ros_driver2/**`
- Create: `src/fast_lio_open3d/**`
- Create: `src/vision_to_mavros/**`
- Create: `src/spiritwing_web/**`
- Create: `src/lukong_fusion_client/**`
- Modify: `src/fast_lio_open3d/launch/mapping_mid360.launch`

**Interfaces:**
- Consumes: MID360 raw packets and `/mavros/*`.
- Produces: `/Odometry_loc`, `/cloud_registered_1`, `/cloud_registered_body_1`, `/mavros/vision_pose/pose`, platform WebSocket transport.

- [ ] Copy only source-controlled/runtime files; exclude `build`, `devel`, `.git`, diagnostic captures, caches, models, and virtual environments.
- [ ] Replace `/home/bitcq/ifc_plus/...` parameter paths with `$(find fast_lio_open3d)`.
- [ ] Run `catkin_lint` where available and record unresolved system dependencies.
- [ ] Compare imported files with the remote runtime versions using SHA256 manifests.

### Task 2: Add stable messages and service contracts

**Files:**
- Create: `src/ground_air_msgs/package.xml`
- Create: `src/ground_air_msgs/CMakeLists.txt`
- Create: `src/ground_air_msgs/msg/VehicleStatus.msg`
- Create: `src/ground_air_msgs/msg/MissionStatus.msg`
- Create: `src/ground_air_msgs/srv/SetVehicleMode.srv`
- Create: `src/ground_air_msgs/srv/SetEmergencyStop.srv`
- Create: `src/ground_air_msgs/srv/SubmitMission.srv`
- Create: `src/ground_air_msgs/srv/LoadMap.srv`
- Create: `src/ground_air_msgs/srv/Relocalize.srv`

**Interfaces:**
- Produces: typed contracts consumed by control, mission, localization, and platform bridge.

- [ ] Write a package-structure test that asserts every message/service is generated and contains the required fields.
- [ ] Run the test and verify it fails because the package is absent.
- [ ] Add the minimal package and definitions.
- [ ] Re-run the test and verify it passes.

### Task 3: Implement the mode and emergency-stop state machine

**Files:**
- Create: `src/ground_air_control/package.xml`
- Create: `src/ground_air_control/CMakeLists.txt`
- Create: `src/ground_air_control/scripts/mode_manager_core.py`
- Create: `src/ground_air_control/scripts/mode_manager_node.py`
- Create: `src/ground_air_control/tests/test_mode_manager_core.py`

**Interfaces:**
- Consumes: `SetVehicleMode`, `SetEmergencyStop`, MAVROS state, extended state, local pose.
- Produces: `VehicleStatus`, calls hardware backend only after guard checks.

- [ ] Test valid and invalid transitions, stale telemetry rejection, 1.0 m takeoff target, flight-goal hover, latched emergency stop, and explicit reset.
- [ ] Run tests and verify expected failures.
- [ ] Implement a dependency-injected pure Python state machine.
- [ ] Run tests until all state-machine cases pass.

### Task 4: Repair and isolate the PX4 hardware backend

**Files:**
- Create: `src/ground_air_control/scripts/px4_backend.py`
- Create: `src/ground_air_control/tests/test_px4_backend.py`
- Modify: `src/teb_local_planner_tutorials/launch/bz_navigation.launch`

**Interfaces:**
- Consumes: MAVROS service responses and observed state transitions.
- Produces: `switch_to_ground()`, `switch_to_air()`, `takeoff(1.0)`, `land()`, `hover()`, `set_velocity()`.

- [ ] Add regression tests showing that a truthy service response without `success` does not confirm a transition.
- [ ] Add tests for PX4 minor-version dispatch and timeout behavior.
- [ ] Implement the backend without mutating cached MAVROS messages.
- [ ] Remove production startup of the old `drone_mode_node`; preserve it only as legacy reference.

### Task 5: Add exclusive velocity routing

**Files:**
- Create: `src/ground_air_control/scripts/cmd_vel_router_core.py`
- Create: `src/ground_air_control/scripts/cmd_vel_router_node.py`
- Create: `src/ground_air_control/tests/test_cmd_vel_router_core.py`

**Interfaces:**
- Consumes: `/navigation/cmd_vel`, vehicle mode, emergency state.
- Produces: `/ground/cmd_vel` or `/air/cmd_vel`, never both; publishes repeated zero on stop/timeout.

- [ ] Test ground routing, air routing, timeout, transition suppression, and emergency latching.
- [ ] Verify tests fail before implementation.
- [ ] Implement minimal routing core and ROS adapter.
- [ ] Remap move_base output to `/navigation/cmd_vel` and ground/air backends to their private inputs.

### Task 6: Implement ordered mission execution

**Files:**
- Create: `src/ground_air_mission/package.xml`
- Create: `src/ground_air_mission/CMakeLists.txt`
- Create: `src/ground_air_mission/scripts/mission_core.py`
- Create: `src/ground_air_mission/scripts/mission_node.py`
- Create: `src/ground_air_mission/tests/test_mission_core.py`

**Interfaces:**
- Consumes: `SubmitMission`, move_base action results, `VehicleStatus`, localization status.
- Produces: ordered move_base goals and `MissionStatus`.

- [ ] Test ordered goals, exactly 2.0-second dwell, pause/resume from current index, cancel/failure, localization guard, emergency guard, and no automatic landing.
- [ ] Verify tests fail because the mission core is absent.
- [ ] Implement the pure mission core and actionlib ROS adapter.
- [ ] Run all mission tests and existing drone tests.

### Task 7: Implement map lifecycle and global relocalization

**Files:**
- Create: `src/ground_air_localization/package.xml`
- Create: `src/ground_air_localization/CMakeLists.txt`
- Create: `src/ground_air_localization/include/ground_air_localization/global_relocalizer.hpp`
- Create: `src/ground_air_localization/src/global_relocalizer.cpp`
- Create: `src/ground_air_localization/scripts/map_manager.py`
- Create: `src/ground_air_localization/launch/localization.launch`
- Create: `src/ground_air_localization/tests/test_map_manager.py`

**Interfaces:**
- Consumes: saved PCD, optional map YAML/PGM, `/cloud_registered_body_1`, `/Odometry_loc`.
- Produces: `/ground_air/localization/pose`, confidence/status, and `map -> odom`.

- [ ] Test URL/path validation, staging-directory extraction, manifest validation, atomic activation, and failure preservation.
- [ ] Verify map-manager tests fail before implementation.
- [ ] Implement map manager with configurable platform URL and local-path fallback.
- [ ] Port reusable Open3D conversion/registration code, add FPFH/RANSAC coarse registration before multi-scale ICP, and remove all hard-coded paths.
- [ ] Add deterministic registration tests using generated asymmetric point clouds.

### Task 8: Convert the platform bridge into an adapter

**Files:**
- Modify: `src/spiritwing_web/src/spiritwing_web_node.cpp`
- Modify: `src/spiritwing_web/config/params.yaml`
- Modify: `src/spiritwing_web/package.xml`
- Create: `src/spiritwing_web/tests/test_protocol_contract.py`

**Interfaces:**
- Consumes: platform WebSocket JSON.
- Produces: calls to ground-air services and status responses derived from ROS state.

- [ ] Add protocol-contract tests for mission submission, mode services, map loading, relocalization, emergency stop/reset, and no direct `/cmd_vel` or MAVROS control.
- [ ] Verify tests expose the current direct-control implementation.
- [ ] Replace direct control/goal sequencing with service clients.
- [ ] Keep map/point-cloud upload and RTSP URL reporting configurable.

### Task 9: Add video supervision and unified bringup

**Files:**
- Create: `src/ground_air_bringup/package.xml`
- Create: `src/ground_air_bringup/CMakeLists.txt`
- Create: `src/ground_air_bringup/launch/sensors.launch`
- Create: `src/ground_air_bringup/launch/mapping.launch`
- Create: `src/ground_air_bringup/launch/mission.launch`
- Create: `src/ground_air_bringup/launch/full.launch`
- Create: `src/ground_air_bringup/scripts/video_supervisor.py`
- Create: `src/ground_air_bringup/tests/test_launch_contracts.py`
- Modify: `src/car_bringup/launch/bringup.launch`

**Interfaces:**
- Produces: one supported startup surface with mapping/mission profiles and supervised RTSP process.

- [ ] Test launch arguments, mutually exclusive map publishers, required nodes, 1.0 m altitude, and command-topic remaps.
- [ ] Verify launch tests fail before implementation.
- [ ] Implement the four launch files and process supervisor.
- [ ] Make legacy `car_bringup` include the new mission profile for compatibility.

### Task 10: Install Open3D 0.14.1 and verify on the remote Jetson

**Files:**
- Create remote: `/home/bitcq/opt/open3d-0.14.1/`
- Create: `scripts/install_open3d_0_14_1.sh`
- Create: `scripts/deploy_remote.ps1`

**Interfaces:**
- Produces: `Open3DConfig.cmake`, shared libraries, headers, and repeatable deployment scripts.

- [ ] Confirm architecture, disk, RAM, compiler and CMake requirements.
- [ ] Build official tag `v0.14.1` for aarch64 with GUI/CUDA/Python/ML/examples disabled and shared libraries enabled.
- [ ] Install under the user-owned prefix and verify a minimal C++ link/run test.
- [ ] Sync reviewed source into `/home/bitcq/catkin_ws/src` without deleting unrelated user data.
- [ ] Run `catkin_make`, Python unit tests, package discovery, launch XML checks, and duplicate publisher/subscriber checks.
- [ ] Run only disarmed ROS graph verification; document the remaining staged real-flight checklist.

## Self-review

- Spec coverage: mapping/upload, unknown-pose relocalization, ordered mission/dwell, mode switching, fixed altitude, explicit landing, video, emergency stop, unified workspace, dependency installation, and staged verification are each assigned to a task.
- Placeholder scan: no implementation step delegates unspecified behavior; thresholds and field contracts will be encoded in package tests and configs.
- Type consistency: control and platform modules share only `ground_air_msgs`; navigation velocity is `/navigation/cmd_vel`; map localization publishes the status consumed by mission gating.
