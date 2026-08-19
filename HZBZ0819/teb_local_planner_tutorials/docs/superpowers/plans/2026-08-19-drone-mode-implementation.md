# 无人机模态启动与控制桥 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 为 `bz_navigation.launch` 增加可选无人机模态节点，通过 ROS 服务起降，并把 TEB 机体系 `/cmd_vel` 转换为带高度保持的 MAVROS 速度指令。

**Architecture:** 新建无 ROS 依赖的 `DroneModeController` 管理状态、坐标转换、限幅和命令超时；新建 ROS 包装节点连接服务、订阅器与现有 `PX4Drone`。底层 `PX4Drone` 只增加非阻塞速度目标和偏航角速度支持，启动文件负责条件启用。

**Tech Stack:** ROS1/catkin、Python 3、rospy、geometry_msgs、std_srvs、MAVROS、Python unittest、XML ElementTree。

## Global Constraints

- `enable_drone_mode` 默认 `false`，启动导航不得自动解锁或起飞。
- 节点启动后只自动切换到 `drone` 模态。
- 起飞和降落接口分别为 `/drone_mode/takeoff` 与 `/drone_mode/land`，类型均为 `std_srvs/Trigger`。
- `/cmd_vel` 按机体坐标解释，`linear.z` 被忽略。
- 默认参数：起飞高度 `1.0 m`、命令超时 `0.5 s`、最大水平速度 `1.0 m/s`、最大偏航速度 `1.0 rad/s`、高度比例增益 `1.0`、最大垂直速度 `0.5 m/s`、控制频率 `20 Hz`。
- 目录不是 Git 仓库，因此每个任务用测试结果和文件 diff 作为检查点，不执行 commit。

---

## File Structure

- Create `scripts/drone_mode_control.py`: 纯 Python 状态机和速度计算。
- Create `scripts/drone_mode_node.py`: ROS 服务、订阅、定时控制及 `PX4Drone` 适配。
- Modify `scripts/px4_drone.py`: 增加连续速度目标 API 和 yaw-rate setpoint。
- Modify `launch/bz_navigation.launch`: 条件启动无人机节点并传递参数。
- Modify `package.xml`: 声明新增运行依赖。
- Modify `CMakeLists.txt`: 安装三个 Python 文件。
- Create `tests/test_drone_mode_control.py`: 纯逻辑单元测试。
- Create `tests/test_drone_mode_package.py`: 启动文件、依赖、安装和 Python 语法测试。

### Task 1: 无 ROS 依赖的控制核心

**Files:**
- Create: `tests/test_drone_mode_control.py`
- Create: `scripts/drone_mode_control.py`

**Interfaces:**
- Produces: `clamp(value, lower, upper) -> float`
- Produces: `quaternion_to_yaw(x, y, z, w) -> float`
- Produces: `body_to_world(vx_body, vy_body, yaw) -> (vx_world, vy_world)`
- Produces: `DroneModeController` with `begin_takeoff()`, `finish_takeoff(success, altitude)`, `begin_landing()`, `finish_landing(success)`, `accept_cmd_vel(vx, vy, yaw_rate, stamp)`, and `compute_command(now, yaw, altitude)`.

- [ ] **Step 1: Write the failing control tests**

Create tests for 90-degree body/world conversion, vector-magnitude limiting, state gating, altitude correction, and timeout:

```python
import math
import os
import sys
import unittest

SCRIPTS = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", "scripts"))
sys.path.insert(0, SCRIPTS)

from drone_mode_control import DroneModeController, body_to_world


class DroneModeControlTest(unittest.TestCase):
    def test_body_velocity_rotates_into_world_frame(self):
        vx, vy = body_to_world(1.0, 0.0, math.pi / 2.0)
        self.assertAlmostEqual(vx, 0.0, places=6)
        self.assertAlmostEqual(vy, 1.0, places=6)

    def test_command_is_ignored_before_takeoff(self):
        core = DroneModeController(1.0, 1.0, 1.0, 0.5, 0.5)
        self.assertFalse(core.accept_cmd_vel(0.5, 0.0, 0.2, 1.0))
        self.assertIsNone(core.compute_command(1.0, 0.0, 0.0))

    def test_airborne_command_is_limited_and_holds_altitude(self):
        core = DroneModeController(1.0, 0.4, 1.0, 0.5, 0.5)
        self.assertTrue(core.begin_takeoff())
        core.finish_takeoff(True, 2.0)
        self.assertTrue(core.accept_cmd_vel(3.0, 4.0, 1.0, 10.0))
        command = core.compute_command(10.1, 0.0, 1.0)
        self.assertAlmostEqual(math.hypot(command.vx, command.vy), 1.0)
        self.assertAlmostEqual(command.yaw_rate, 0.4)
        self.assertAlmostEqual(command.vz, 0.5)

    def test_timeout_stops_horizontal_and_yaw_but_keeps_altitude(self):
        core = DroneModeController(1.0, 1.0, 1.0, 0.5, 0.5)
        core.begin_takeoff()
        core.finish_takeoff(True, 2.0)
        core.accept_cmd_vel(0.5, 0.2, 0.3, 10.0)
        command = core.compute_command(10.6, 0.0, 1.8)
        self.assertEqual((command.vx, command.vy, command.yaw_rate), (0.0, 0.0, 0.0))
        self.assertAlmostEqual(command.vz, 0.2)

    def test_failed_landing_returns_to_airborne_state(self):
        core = DroneModeController(1.0, 1.0, 1.0, 0.5, 0.5)
        core.begin_takeoff()
        core.finish_takeoff(True, 2.0)
        self.assertTrue(core.begin_landing())
        core.finish_landing(False)
        self.assertEqual(core.state, core.AIRBORNE)


if __name__ == "__main__":
    unittest.main()
```

- [ ] **Step 2: Run the tests and verify RED**

Run: `python -m unittest tests.test_drone_mode_control -v`

Expected: import failure for missing `drone_mode_control`.

- [ ] **Step 3: Implement the minimal control core**

Implement immutable `VelocityCommand(vx, vy, vz, yaw_rate)`, the three math helpers, explicit states `STANDBY`, `TAKING_OFF`, `AIRBORNE`, `LANDING`, transition validation, magnitude limiting, altitude P-control, and timeout zeroing. `finish_takeoff(False, ...)` must return to `STANDBY`; `finish_landing(False)` must return to `AIRBORNE`.

- [ ] **Step 4: Run the tests and verify GREEN**

Run: `python -m unittest tests.test_drone_mode_control -v`

Expected: 5 tests pass.

### Task 2: PX4 连续速度目标与偏航控制

**Files:**
- Modify: `scripts/px4_drone.py`
- Modify: `tests/test_drone_mode_package.py`

**Interfaces:**
- Consumes: `VelocityCommand` fields from Task 1.
- Produces: `PX4Drone.set_velocity_target(vx, vy, vz, yaw_rate=0.0) -> bool`.

- [ ] **Step 1: Write failing source-contract tests**

Use `ast` to verify `PX4Drone` exposes `set_velocity_target`, `_create_velocity` assigns `twist.twist.angular.z`, and `hover` resets `yaw_rate`:

```python
import ast
import os
import unittest

ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))


class DroneModePackageTest(unittest.TestCase):
    def test_px4_driver_exposes_yaw_rate_velocity_target(self):
        path = os.path.join(ROOT, "scripts", "px4_drone.py")
        source = open(path, encoding="utf-8").read()
        tree = ast.parse(source)
        methods = {
            node.name: node
            for cls in tree.body if isinstance(cls, ast.ClassDef) and cls.name == "PX4Drone"
            for node in cls.body if isinstance(node, ast.FunctionDef)
        }
        self.assertIn("set_velocity_target", methods)
        self.assertIn("yaw_rate", [arg.arg for arg in methods["set_velocity_target"].args.args])
        self.assertIn("twist.twist.angular.z", source)
        self.assertIn("self.yaw_rate = 0.0", source)
```

- [ ] **Step 2: Run the contract test and verify RED**

Run: `python -m unittest tests.test_drone_mode_package.DroneModePackageTest.test_px4_driver_exposes_yaw_rate_velocity_target -v`

Expected: failure because `set_velocity_target` does not exist.

- [ ] **Step 3: Implement the PX4 extension**

Initialize `self.yaw_rate = 0.0`. Add a non-blocking `set_velocity_target` that requires drone mode and hovering state, selects velocity control, stores `[vx, vy, vz]` plus yaw rate, and activates the existing 20 Hz publisher. Make `set_velocity` delegate to it. Add `twist.twist.angular.z = self.yaw_rate` in `_create_velocity`, and reset yaw rate in `hover`.

- [ ] **Step 4: Run control and contract tests**

Run: `python -m unittest discover -s tests -v`

Expected: all Task 1 and Task 2 tests pass.

### Task 3: ROS 无人机模态节点

**Files:**
- Create: `scripts/drone_mode_node.py`
- Modify: `tests/test_drone_mode_package.py`

**Interfaces:**
- Consumes: `DroneModeController` and `PX4Drone.set_velocity_target`.
- Produces: node `drone_mode`, services `~takeoff` and `~land`, subscriber configured by `~cmd_vel_topic`.

- [ ] **Step 1: Add failing AST contract tests for the ROS node**

Check that the node imports `Trigger`/`TriggerResponse`, advertises private services `~takeoff` and `~land`, subscribes to the configured command topic, creates a timer, calls `switch_mode("drone")`, and never calls `takeoff` from initialization.

- [ ] **Step 2: Run the node contract test and verify RED**

Run: `python -m unittest tests.test_drone_mode_package.DroneModePackageTest.test_drone_node_contract -v`

Expected: file-not-found failure for `scripts/drone_mode_node.py`.

- [ ] **Step 3: Implement the ROS wrapper**

Implement `DroneModeNode` with:

- parameter validation requiring positive height, timeout, limits, gain and control rate;
- `PX4Drone()` initialization followed by `switch_mode("drone")`;
- non-blocking mutex acquisition in both service callbacks;
- takeoff transition, `driver.takeoff(height)`, and `finish_takeoff`;
- landing transition, `driver.land()`, and `finish_landing`;
- `/cmd_vel` callback that records only accepted airborne commands;
- timer callback that reads pose quaternion/altitude, computes a command, and calls `set_velocity_target`;
- `main()` that initializes `rospy`, catches startup errors, logs fatal, and exits nonzero.

- [ ] **Step 4: Run all Python tests**

Run: `python -m unittest discover -s tests -v`

Expected: all tests pass.

### Task 4: Launch、依赖与安装接入

**Files:**
- Modify: `launch/bz_navigation.launch`
- Modify: `package.xml`
- Modify: `CMakeLists.txt`
- Modify: `tests/test_drone_mode_package.py`

**Interfaces:**
- Consumes: executable `drone_mode_node.py` and its eight private parameters.
- Produces: `enable_drone_mode:=true` launch option.

- [ ] **Step 1: Add failing XML/build metadata tests**

Parse `bz_navigation.launch` and assert:

- `enable_drone_mode` exists with default `false`;
- a `drone_mode_node.py` node has `if="$(arg enable_drone_mode)"`;
- all eight private parameters are present with exact defaults;
- `package.xml` declares `rospy`, `geometry_msgs`, `std_srvs`, `sensor_msgs`, and `mavros_msgs` runtime dependencies;
- `CMakeLists.txt` installs `drone_mode_node.py`, `drone_mode_control.py`, and `px4_drone.py`.

- [ ] **Step 2: Run metadata tests and verify RED**

Run: `python -m unittest tests.test_drone_mode_package -v`

Expected: failures for missing launch argument, node, dependencies, and install entries.

- [ ] **Step 3: Modify launch and metadata**

Add launch arguments with the approved defaults, then conditionally start:

```xml
<node if="$(arg enable_drone_mode)"
      pkg="teb_local_planner_tutorials"
      type="drone_mode_node.py"
      name="drone_mode"
      output="screen"
      required="true">
  <param name="cmd_vel_topic" value="$(arg drone_cmd_vel_topic)" />
  <param name="takeoff_height" value="$(arg takeoff_height)" />
  <param name="cmd_vel_timeout" value="$(arg cmd_vel_timeout)" />
  <param name="max_horizontal_speed" value="$(arg max_horizontal_speed)" />
  <param name="max_yaw_rate" value="$(arg max_yaw_rate)" />
  <param name="altitude_kp" value="$(arg altitude_kp)" />
  <param name="max_vertical_speed" value="$(arg max_vertical_speed)" />
  <param name="control_rate" value="$(arg control_rate)" />
</node>
```

Add runtime dependencies to `package.xml`. Add `catkin_install_python(PROGRAMS ...)` for the three Python files.

- [ ] **Step 4: Run metadata and unit tests**

Run: `python -m unittest discover -s tests -v`

Expected: all tests pass.

### Task 5: Full local verification

**Files:**
- Verify all modified and created files.

- [ ] **Step 1: Compile Python source in memory without writing bytecode into source folders**

Run: `python -c "import pathlib; files=list(pathlib.Path('scripts').glob('*.py'))+list(pathlib.Path('tests').glob('*.py')); [compile(p.read_text(encoding='utf-8'), str(p), 'exec') for p in files]; print(f'Python syntax OK ({len(files)} files)')"`

Expected: `Python syntax OK` and exit code 0.

- [ ] **Step 2: Parse ROS XML files**

Run:

```powershell
python -c "import xml.etree.ElementTree as ET; ET.parse('launch/bz_navigation.launch'); ET.parse('package.xml'); print('XML OK')"
```

Expected: `XML OK` and exit code 0.

- [ ] **Step 3: Run the complete test suite**

Run: `python -m unittest discover -s tests -v`

Expected: all tests pass with zero failures and zero errors.

- [ ] **Step 4: Inspect the final change set**

Run: `Get-ChildItem scripts,launch,tests,docs/superpowers -Recurse -File | Select-Object FullName,Length,LastWriteTime`

Expected: new controller, node, tests, design and plan are present; only scoped package files have changed.

- [ ] **Step 5: Record hardware verification commands for the ROS/PX4 host**

Run on the ROS host after sourcing the catkin workspace:

```bash
roslaunch teb_local_planner_tutorials bz_navigation.launch enable_drone_mode:=true
rosservice call /drone_mode/takeoff
rosservice call /drone_mode/land
```

Expected: launch switches to drone mode without automatic takeoff; the two service calls explicitly take off and land. Hardware execution is not performed on this Windows workspace.
