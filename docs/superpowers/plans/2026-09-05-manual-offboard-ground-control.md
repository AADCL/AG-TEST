# Manual OFFBOARD Ground Control Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Make ground navigation validate operator-selected OFFBOARD state without controlling PX4 modes, while publishing navigation and bundled wheel control commands at 20 Hz.

**Architecture:** Keep the ROS interfaces intact and change only ground-task readiness and emergency-stop behavior. `Px4Backend.prepare_ground()` becomes a read-only state check, `ModeManagerNode` no longer changes flight mode in either emergency-stop path, and the existing single `ActuatorControl` packet remains the synchronization boundary for forward/yaw inputs consumed by the PX4 wheel mixer.

**Tech Stack:** ROS Noetic, rospy, MAVROS, move_base, TEB Local Planner, Python unittest/nosetests, roslaunch XML.

## Global Constraints

- The authoritative implementation source is remote `/home/bitcq/catkin_ws`.
- Ground task code must not arm, disarm, or switch PX4 flight mode.
- The operator manually selects `OFFBOARD` before ground navigation and manually returns to `POSCTL` after emergency stop.
- Existing ROS service names and message types remain unchanged.
- Navigation control, velocity routing, and actuator output run at `20 Hz`.
- Forward and yaw components are published together in one `mavros_msgs/ActuatorControl` message.
- Air-task takeoff, landing, altitude, and physical-mode transition behavior remains unchanged.

---

### Task 1: Make ground readiness a read-only policy

**Files:**
- Modify: `catkin_ws/src/ground_air_control/scripts/px4_backend.py`
- Modify: `catkin_ws/src/ground_air_control/src/ground_air_control/px4_backend.py`
- Test: `catkin_ws/src/ground_air_control/tests/test_px4_backend.py`

**Interfaces:**
- Consumes: snapshot dictionary containing `connected`, `physical_mode`, `armed`, and `flight_mode`.
- Produces: `Px4TransitionPolicy.ground_control_ready(snapshot) -> bool`; compatible `Px4Backend.prepare_ground(timeout=2.0) -> bool`.

- [ ] **Step 1: Write the failing policy and contract tests**

```python
def test_ground_control_ready_requires_manual_armed_offboard_state(self):
    ready = {"connected": True, "physical_mode": "ground", "armed": True,
             "flight_mode": "OFFBOARD"}
    self.assertTrue(self.policy.ground_control_ready(ready))
    for key, value in (("connected", False), ("physical_mode", "air"),
                       ("armed", False), ("flight_mode", "POSCTL")):
        candidate = dict(ready)
        candidate[key] = value
        self.assertFalse(self.policy.ground_control_ready(candidate))

def test_ground_prepare_does_not_command_arming_or_flight_mode(self):
    source = (SCRIPTS / "px4_backend.py").read_text(encoding="utf-8")
    tree = ast.parse(source)
    method = find_method(tree, "Px4Backend", "prepare_ground")
    calls = {getattr(node.func, "attr", "") for node in ast.walk(method)
             if isinstance(node, ast.Call)}
    self.assertFalse({"_arming", "_set_mode", "switch_flight_mode", "disarm"} & calls)
```

- [ ] **Step 2: Run the focused test and verify failure**

Run: `cd /home/bitcq/catkin_ws && python3 -m unittest src/ground_air_control/tests/test_px4_backend.py -v`

Expected: failure because `ground_control_ready` is absent and `prepare_ground` still commands arming/mode changes.

- [ ] **Step 3: Implement minimal read-only readiness logic**

```python
@staticmethod
def ground_control_ready(snapshot):
    return (
        bool(snapshot.get("connected", False))
        and snapshot.get("physical_mode") == "ground"
        and bool(snapshot.get("armed", False))
        and str(snapshot.get("flight_mode", "")).upper() == "OFFBOARD"
    )

def prepare_ground(self, timeout=2.0):
    del timeout
    return self.policy.ground_control_ready(self.snapshot())
```

Copy the identical module into `src/ground_air_control/px4_backend.py` because catkin installs that package implementation.

- [ ] **Step 4: Run the focused test and verify pass**

Run: `cd /home/bitcq/catkin_ws && python3 -m unittest src/ground_air_control/tests/test_px4_backend.py -v`

Expected: all backend policy tests pass.

### Task 2: Remove flight-mode control from ground emergency-stop paths

**Files:**
- Modify: `catkin_ws/src/ground_air_control/scripts/mode_manager_node.py`
- Test: `catkin_ws/src/ground_air_control/tests/test_mode_manager_node_contract.py`

**Interfaces:**
- Consumes: `/ground_air/emergency_stop` requests and `/ground_air/prepare_ground` requests.
- Produces: unchanged `SetEmergencyStop` and `Trigger` responses with operator-facing status details.

- [ ] **Step 1: Write failing AST contract tests**

```python
def _method_calls(name):
    tree = ast.parse(NODE.read_text(encoding="utf-8"))
    cls = next(node for node in tree.body if isinstance(node, ast.ClassDef))
    method = next(node for node in cls.body
                  if isinstance(node, ast.FunctionDef) and node.name == name)
    return {getattr(node.func, "attr", "") for node in ast.walk(method)
            if isinstance(node, ast.Call)}

def test_ground_estop_paths_do_not_switch_flight_mode(self):
    self.assertNotIn("switch_flight_mode", _method_calls("_engage_emergency_stop"))
    self.assertNotIn("switch_flight_mode", _method_calls("_reset_emergency_stop"))
```

- [ ] **Step 2: Run the focused test and verify failure**

Run: `cd /home/bitcq/catkin_ws && python3 -m unittest src/ground_air_control/tests/test_mode_manager_node_contract.py -v`

Expected: failure because both methods currently call `switch_flight_mode`.

- [ ] **Step 3: Implement manual-mode emergency-stop behavior**

Replace the ground POSCTL restore branch with a direct successful response whose detail is `operator emergency stop latched; switch RC to POSCTL manually`. Replace reset-time OFFBOARD switching with `operator reset; switch RC to OFFBOARD before ground preparation`. Retain air-mode `hover()` behavior and retain `_prepare_ground_sequence()` calling the now read-only backend check.

- [ ] **Step 4: Run node/core tests**

Run: `cd /home/bitcq/catkin_ws && python3 -m unittest src/ground_air_control/tests/test_mode_manager_node_contract.py src/ground_air_control/tests/test_mode_manager_core.py -v`

Expected: all tests pass and air-task lifecycle assertions remain intact.

### Task 3: Fix the complete ground control chain at 20 Hz

**Files:**
- Modify: `catkin_ws/src/teb_local_planner_tutorials/launch/bz_navigation.launch`
- Modify: `catkin_ws/src/car_bringup/launch/task_system.launch`
- Modify: `catkin_ws/src/ground_air_control/tests/test_ground_actuator_policy.py`
- Create: `catkin_ws/src/ground_air_control/tests/test_ground_control_launch_contract.py`

**Interfaces:**
- Consumes: `/navigation/cmd_vel` and `/ground/cmd_vel`.
- Produces: `/mavros/actuator_control` at 20 Hz with `controls[2]` and `controls[3]` set before one publish call.

- [ ] **Step 1: Add failing launch and actuator contract tests**

```python
def test_actuator_bundles_forward_and_yaw_in_one_publish(self):
    source = (SCRIPTS / "ground_actuator_node.py").read_text(encoding="utf-8")
    timer = find_method(ast.parse(source), "GroundActuatorNode", "_timer")
    text = ast.unparse(timer)
    self.assertLess(text.index("message.controls[2]"), text.index("self.publisher.publish"))
    self.assertLess(text.index("message.controls[3]"), text.index("self.publisher.publish"))
    self.assertEqual(text.count("self.publisher.publish"), 1)

def test_navigation_and_actuator_rates_are_20_hz(self):
    nav = ET.parse(BZ_LAUNCH).getroot()
    controller = nav.find(".//param[@name='controller_frequency']")
    self.assertEqual(controller.attrib["value"], "20.0")
    control = CONTROL_LAUNCH.read_text(encoding="utf-8")
    self.assertIn('<arg name="control_rate" default="20.0" />', control)
```

- [ ] **Step 2: Run tests and verify controller-frequency failure**

Run: `cd /home/bitcq/catkin_ws && python3 -m unittest src/ground_air_control/tests/test_ground_actuator_policy.py src/ground_air_control/tests/test_ground_control_launch_contract.py -v`

Expected: actuator bundling passes; launch contract fails because move_base is still `5.0 Hz`.

- [ ] **Step 3: Set active move_base controller frequency to 20 Hz and document prerequisites**

Change the active `controller_frequency` in `bz_navigation.launch` from `5.0` to `20.0`. Add comments to `task_system.launch` stating that the operator must manually arm and select OFFBOARD before `/ground_air/prepare_ground`, and must manually select POSCTL after emergency stop.

- [ ] **Step 4: Run launch contract tests and XML checks**

Run: `cd /home/bitcq/catkin_ws && python3 -m unittest src/ground_air_control/tests/test_ground_actuator_policy.py src/ground_air_control/tests/test_ground_control_launch_contract.py -v && xmllint --noout src/teb_local_planner_tutorials/launch/bz_navigation.launch src/car_bringup/launch/task_system.launch src/ground_air_control/launch/control.launch`

Expected: all tests pass; `xmllint` exits 0.

### Task 3A: Suppress ground commands when the operator leaves OFFBOARD

**Files:**
- Modify: `catkin_ws/src/ground_air_control/scripts/cmd_vel_router_core.py`
- Modify: `catkin_ws/src/ground_air_control/src/ground_air_control/cmd_vel_router_core.py`
- Modify: `catkin_ws/src/ground_air_control/scripts/cmd_vel_router_node.py`
- Test: `catkin_ws/src/ground_air_control/tests/test_cmd_vel_router_core.py`

**Interfaces:**
- Consumes: `VehicleStatus.mode` and `VehicleStatus.flight_mode`.
- Produces: ground routing only when logical mode is ground and PX4 reports `OFFBOARD`.

- [ ] **Step 1: Add a failing policy test**

```python
def test_ground_routing_requires_operator_selected_offboard(self):
    core = CmdVelRouterCore(timeout=0.5)
    core.set_vehicle_state("ground", "POSCTL")
    self.assertEqual(core.accept((0.2, 0.0, 0.0), 1.0).channel, "stop")
    core.set_vehicle_state("ground", "OFFBOARD")
    self.assertEqual(core.accept((0.2, 0.0, 0.0), 1.1).channel, "ground")
```

- [ ] **Step 2: Run the test and verify failure**

Run: `cd /home/bitcq/catkin_ws && python3 -m unittest src/ground_air_control/tests/test_cmd_vel_router_core.py -v`

Expected: failure because `set_vehicle_state` does not exist.

- [ ] **Step 3: Implement flight-mode gating**

```python
def set_vehicle_state(self, mode, flight_mode):
    mode = str(mode)
    if mode == "ground" and str(flight_mode).upper() != "OFFBOARD":
        mode = "unknown"
    self.set_mode(mode)
```

Change `CmdVelRouterNode._status_callback()` to call `set_vehicle_state(MODE_NAMES.get(message.mode, "unknown"), message.flight_mode)` before applying the emergency-stop state.

- [ ] **Step 4: Run router tests**

Run: `cd /home/bitcq/catkin_ws && python3 -m unittest src/ground_air_control/tests/test_cmd_vel_router_core.py -v`

Expected: all router tests pass and POSCTL ground status routes only zero commands.

### Task 4: Update the operator manual and verify the workspace

**Files:**
- Modify: `docs/空地两用机器人_地面模态自主导航使用手册_V1.0.md`
- Modify: remote copy of the same manual if present under `/home/bitcq/catkin_ws`.

**Interfaces:**
- Documents: manual OFFBOARD/POSCTL sequence, 20 Hz chain, readiness checks, emergency-stop recovery, and map-frame mission goals.

- [ ] **Step 1: Update manual commands and state checks**

Document `/ground_air/emergency_stop`, `/ground_air/prepare_ground`, `/ground_air/vehicle_status`, `/mavros/state`, the requirement for `armed: true`, `mode: OFFBOARD`, `localized: true`, and the manual POSCTL recovery sequence. State that mission goals use the `map` frame.

- [ ] **Step 2: Run the full non-actuating verification set**

Run: `cd /home/bitcq/catkin_ws && python3 -m unittest discover -s src/ground_air_control/tests -p 'test_*.py' -v && catkin_make -j1`

Expected: all control tests pass and catkin build completes without errors. Do not launch ROS nodes, unlock the vehicle, or send a navigation goal.

- [ ] **Step 3: Synchronize authoritative remote source into a clean GitHub checkout**

Copy only source, tests, launch files, the manual, this plan, and the approved design. Exclude `build/`, `devel/`, maps, PCD files, ROS logs, and caches.

- [ ] **Step 4: Commit and push**

```bash
git add catkin_ws/src/ground_air_control catkin_ws/src/car_bringup/launch/task_system.launch \
  catkin_ws/src/teb_local_planner_tutorials/launch/bz_navigation.launch docs
git commit -m "feat: require manual OFFBOARD for ground navigation"
git push origin main
```

Expected: `origin/main` advances to the new commit and the GitHub manual contains the updated workflow.
