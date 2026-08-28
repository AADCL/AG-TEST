# Navigation Safety Configuration Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Make the existing ROS1 ground navigation configuration conservative and internally complete for low-speed hardware validation.

**Architecture:** Keep move_base, GlobalPlanner, costmap_2d, and TEB unchanged. Modify only their launch/YAML configuration and add a read-only contract test that verifies the selected safety policy.

**Tech Stack:** ROS1 Noetic, roslaunch XML, YAML, Python 3 unittest.

## Global Constraints

- Modify only `/home/bitcq/catkin_ws/src/teb_local_planner_tutorials`.
- Do not start navigation or publish control commands during verification.
- Keep the obstacle source `/cloud_registered_body_1`.
- Keep the existing 0.6 m square footprint until physical measurement.

---

### Task 1: Add the failing navigation configuration contract

**Files:**
- Create: `src/teb_local_planner_tutorials/tests/test_navigation_safety_config.py`

**Interfaces:**
- Consumes: launch XML and YAML configuration files.
- Produces: a zero/nonzero test result for the approved safety policy.

- [ ] Write assertions for global planner loading, unknown-space rejection, positive angular acceleration, stopping at goals, tightened tolerances, low obstacle detection, and disabled predictive dynamic obstacles.
- [ ] Run `python3 src/teb_local_planner_tutorials/tests/test_navigation_safety_config.py` and confirm it fails because the existing configuration violates the policy.

### Task 2: Apply the conservative configuration

**Files:**
- Modify: `src/teb_local_planner_tutorials/launch/bz_navigation.launch`
- Modify: `src/teb_local_planner_tutorials/cfg/diff_drive/global_planner_params.yaml`
- Modify: `src/teb_local_planner_tutorials/cfg/diff_drive/teb_local_planner_params.yaml`
- Modify: `src/teb_local_planner_tutorials/cfg/diff_drive/costmap_common_params_global.yaml`
- Modify: `src/teb_local_planner_tutorials/cfg/diff_drive/costmap_common_params_local.yaml`

**Interfaces:**
- Consumes: `/map`, `/cloud_registered_body_1`, `/Odometry_loc`, and the `world -> base_link` TF chain.
- Produces: GlobalPlanner paths and TEB commands on `/navigation/cmd_vel` when navigation is later started by an operator.

- [ ] Load `global_planner_params.yaml` inside the move_base node.
- [ ] Set `allow_unknown: false` and `default_tolerance: 0.25`.
- [ ] Set `acc_lim_theta: 0.2`, `xy_goal_tolerance: 0.25`, `yaw_goal_tolerance: 0.35`, `free_goal_vel: False`, and `include_dynamic_obstacles: False`.
- [ ] Set both obstacle-layer `min_obstacle_height` values to `0.15`.
- [ ] Re-run the contract test and confirm all assertions pass.

### Task 3: Verify without moving hardware

**Files:**
- Test: `src/teb_local_planner_tutorials/tests/test_navigation_safety_config.py`

**Interfaces:**
- Consumes: the completed remote workspace.
- Produces: build and test evidence only; no running navigation stack.

- [ ] Run the package tests.
- [ ] Run `catkin_make` with the system clock corrected to the current date if required.
- [ ] Inspect `roslaunch ... --nodes` or XML parsing without starting nodes.
- [ ] Display the final remote `global_planner_params.yaml` and explain each parameter group.
