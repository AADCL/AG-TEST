#!/usr/bin/env python3
# -*- coding: utf-8 -*-
import rospy
import threading
import time
import numpy as np
from geometry_msgs.msg import PoseStamped, TwistStamped
from mavros_msgs.msg import (
    State,
    AttitudeTarget,
    ExtendedState,
    ActuatorControl,
)
from mavros_msgs.srv import (
    CommandBool,
    SetMode,
    CommandTOL,
    CommandLong,
    CommandLongRequest,
)
from mavros_msgs.srv import VehicleInfoGet, VehicleInfoGetRequest
from sensor_msgs.msg import BatteryState, NavSatFix


class PX4Drone:
    def __init__(self):
        self._px4_version = None

        # 线程控制标志
        self._thread_run = True
        self._shutdown_hook_set = False
        self._is_active = False  # 是否处于需要发送指令的状态
        self.is_hovering = False  # 是否处于悬停状态

        # 状态变量
        self.current_state = State()
        self.current_pose = PoseStamped()
        self.current_battery = BatteryState()
        self.home_position = None
        self.extended_state = ExtendedState()

        # 控制变量
        self.target_position = [0, 0, 0]
        self.velocity = [0, 0, 0]
        self.yaw_rate = 0.0
        self.control_mode = "POSITION"  # POSITION or VELOCITY

        # 当前模式 (drone/car)
        # 使用vtol_state判断：
        #   vtol_state = 3 -> 无人机模式
        #   vtol_state = 4 -> 车辆模式
        self.current_vehicle_mode = "unknown"  # 初始未知，等待状态更新

        # 初始化服务
        rospy.wait_for_service("/mavros/cmd/arming")
        rospy.wait_for_service("/mavros/set_mode")
        rospy.wait_for_service("/mavros/cmd/command")
        rospy.wait_for_service("/mavros/vehicle_info_get")
        self.arming_client = rospy.ServiceProxy(
            "/mavros/cmd/arming", CommandBool
        )
        self.set_mode_client = rospy.ServiceProxy("/mavros/set_mode", SetMode)
        self.land_client = rospy.ServiceProxy("/mavros/cmd/land", CommandTOL)
        self.command_client = rospy.ServiceProxy(
            "/mavros/cmd/command", CommandLong
        )
        self.vehicle_info_get_client = rospy.ServiceProxy(
            "/mavros/vehicle_info_get", VehicleInfoGet
        )

        # 初始化发布器
        self.local_pos_pub = rospy.Publisher(
            "/mavros/setpoint_position/local", PoseStamped, queue_size=10
        )
        self.vel_pub = rospy.Publisher(
            "/mavros/setpoint_velocity/cmd_vel", TwistStamped, queue_size=10
        )
        self.car_vel_pub = rospy.Publisher(
            "/mavros/setpoint_raw/attitude", AttitudeTarget, queue_size=10
        )
        self.actuator_control_pub = rospy.Publisher(
            "/mavros/actuator_control", ActuatorControl, queue_size=10
        )

        # 初始化订阅器
        rospy.Subscriber("/mavros/state", State, self.state_cb)
        rospy.Subscriber(
            "/mavros/local_position/pose", PoseStamped, self.pose_cb
        )
        rospy.Subscriber("/mavros/battery", BatteryState, self.battery_cb)
        rospy.Subscriber(
            "/mavros/global_position/global", NavSatFix, self.global_position_cb
        )
        rospy.Subscriber(
            "/mavros/extended_state", ExtendedState, self.extended_state_cb
        )

        # 后台线程
        self.control_thread = threading.Thread(target=self._control_loop)
        self.control_thread.daemon = True
        self.control_thread.start()

        # 等待连接
        self._wait_for_connection()

        # 设置ROS关闭钩子
        rospy.on_shutdown(self._shutdown_hook)
        self._shutdown_hook_set = True

        # 确保车辆版本正确
        self._update_vehicle_info_get()
        # 确保车辆模式被正确识别
        self._update_vehicle_mode()

    # ---------- 核心API ----------

    def get_vehicle_state(self):
        return {
            "connected": self.current_state.connected,
            "px4_version": self._px4_version,
            "vehicle_mode": self.current_vehicle_mode,
            "arm_state": self.current_state.armed,
            "mode_state": self.current_state.mode,
        }

    def takeoff(self, height=2.0, timeout=15.0):
        """阻塞式起飞到指定高度"""
        # 确保无人机模式
        if self.current_vehicle_mode != "drone":
            rospy.logerr("Takeoff only allowed in drone mode")
            return False

        # 确保vtol状态为无人机模式
        if self.extended_state.vtol_state != 3:
            rospy.logerr("VTOL state must be MC (3) for takeoff")
            return False

        rospy.loginfo(f"Taking off to {height}m using OFFBOARD mode")

        # 发送初始位置指令（当前位置）
        self.hover()
        # 解锁无人机并设置OFFBOARD模式
        if not self._set_mode("OFFBOARD"):
            rospy.logerr("Failed to set OFFBOARD mode")
            return False

        # time.sleep(1)  # 确保发送了位置指令
        if not self._arm(True):
            rospy.logerr("Arming failed")
            return False

        # 发送初始位置指令（当前位置）
        self.hover()
        time.sleep(1)  # 确保发送了位置指令

        # 获取当前水平位置
        current_x = self.current_pose.pose.position.x
        current_y = self.current_pose.pose.position.y

        # 设置目标高度（水平位置保持不变）
        target_height = height

        rospy.loginfo(f"Initiating takeoff to {height}m")
        rospy.loginfo(
            f"Horizontal position locked at ({current_x:.2f}, {current_y:.2f})"
        )

        # 持续发送目标位置直到达到高度
        start_time = time.time()
        last_log_time = start_time
        success = False

        while not rospy.is_shutdown():
            # 检查超时
            if time.time() - start_time > timeout:
                rospy.logerr(f"Takeoff timed out after {timeout} seconds")
                break

            # 发送目标位置
            self.set_target_position(current_x, current_y, target_height)

            # 获取当前高度
            current_z = self.current_pose.pose.position.z

            # 记录进度
            if time.time() - last_log_time > 1.0:
                progress = min(100, 100 * current_z / target_height)
                rospy.loginfo(
                    f"Takeoff height: {current_z:.2f}/{target_height:.2f}m ({progress:.1f}%)"
                )
                last_log_time = time.time()

            # 检查是否达到目标高度（90%即认为成功）
            if current_z >= target_height * 0.9:
                rospy.loginfo(f"Takeoff successful! Reached {current_z:.2f}m")
                self.hover()
                success = True
                break

            time.sleep(0.1)
        self.is_hovering = success
        return success

    def land(self, timeout=30.0):
        """阻塞式降落"""
        # 确保无人机模式
        if self.current_vehicle_mode != "drone":
            rospy.logerr("Landing only allowed in drone mode")
            return False
        # 检查悬停状态
        if not self.is_hovering:
            rospy.logerr("Landing requires drone to be in hovering state")
            return False
        rospy.loginfo("Landing")

        # 暂停发送setpoint
        self._is_active = False

        # 调用降落服务
        try:
            # 使用当前GPS位置作为降落点
            if self.home_position:
                land_response = self.land_client(
                    min_pitch=0.0,
                    yaw=0.0,
                    latitude=self.home_position.latitude,
                    longitude=self.home_position.longitude,
                    altitude=0,
                )
            else:
                # 如果没有GPS信息，直接降落
                land_response = self.land_client(
                    min_pitch=0.0, yaw=0.0, latitude=0, longitude=0, altitude=0
                )

            if not land_response.success:
                rospy.logerr("Land command rejected by FCU")
                return False

        except rospy.ServiceException as e:
            rospy.logerr(f"Land service call failed: {e}")
            return False

        # 检查是否进入LAND模式
        start_time = time.time()
        land_mode_activated = False
        while self._thread_run and not rospy.is_shutdown():
            if time.time() - start_time > timeout:
                rospy.logerr("AUTO.LAND switch timeout")
                return False

            if self.current_state.mode == "AUTO.LAND":
                rospy.loginfo("Land mode activated")
                land_mode_activated = True
                break

            time.sleep(0.1)

        if not land_mode_activated:
            return False

        # 等待高度下降
        success = False

        while self._thread_run and not rospy.is_shutdown():
            current_time = time.time()
            if current_time - start_time > timeout:
                rospy.logerr("Landing timeout")
                break

            if not self.current_state.armed:
                rospy.loginfo("Landed successfully")
                self.hover()
                success = True
                break
            time.sleep(0.1)
        self.is_hovering = False
        return success

    def move_to(self, x, y, z, relative=True, timeout=20.0):
        """阻塞式移动到指定位置"""
        if self.current_vehicle_mode != "drone":
            rospy.logerr("Move to only allowed in drone mode")
            return False
        # 检查悬停状态
        if not self.is_hovering:
            rospy.logerr("Landing requires drone to be in hovering state")
            return False
        rospy.loginfo(
            f"Moving to position ({x}, {y}, {z}) {'relative' if relative else 'absolute'}"
        )

        # 确保在OFFBOARD模式
        if self.current_state.mode != "OFFBOARD":
            rospy.logwarn("Not in OFFBOARD mode, switching...")
            if not self._set_mode("OFFBOARD"):
                rospy.logerr("Failed to set OFFBOARD mode")
                return False

        # 激活控制线程
        self._is_active = True
        self.control_mode = "POSITION"

        # 计算目标位置
        if relative:
            current_x, current_y, current_z = self.get_position()
            x += current_x
            y += current_y
            z += current_z

        self.set_target_position(x, y, z)

        # 等待到达
        start_time = time.time()
        success = False

        while self._thread_run and not rospy.is_shutdown():
            position = self.current_pose.pose.position
            distance = np.sqrt(
                (position.x - x) ** 2
                + (position.y - y) ** 2
                + (position.z - z) ** 2
            )

            if distance < 0.3:
                rospy.loginfo("Position reached")
                self.hover()  # 到达后自动悬停
                success = True
                break

            if time.time() - start_time > timeout:
                rospy.logwarn("Position timeout")
                self.hover()  # 超时后悬停保证安全
                break

            time.sleep(0.1)

        return success

    def set_velocity_target(self, vx, vy, vz, yaw_rate=0.0):
        """设置连续速度目标，由调用方负责持续更新或切换回悬停。"""
        if self.current_vehicle_mode != "drone":
            rospy.logerr("Velocity target only allowed in drone mode")
            return False
        if not self.is_hovering:
            rospy.logerr("Velocity target requires an airborne hovering state")
            return False
        if self.current_state.mode != "OFFBOARD":
            rospy.logwarn("Velocity target requires OFFBOARD mode")
            return False

        self._is_active = True
        self.control_mode = "VELOCITY"
        self.velocity = [float(vx), float(vy), float(vz)]
        self.yaw_rate = float(yaw_rate)
        return True

    def set_velocity(self, vx, vy, vz, duration=3.0):
        """设置无人机速度（阻塞式）"""
        if self.current_vehicle_mode != "drone":
            rospy.logerr("Set velocity only allowed in drone mode")
            return False
        # 检查悬停状态
        if not self.is_hovering:
            rospy.logerr("Landing requires drone to be in hovering state")
            return False
        rospy.loginfo(
            f"Setting velocity ({vx}, {vy}, {vz}) for {'duration' if duration else 'continuous'}"
        )

        # 确保在OFFBOARD模式
        if self.current_state.mode != "OFFBOARD":
            rospy.logwarn("Not in OFFBOARD mode, switching...")
            if not self._set_mode("OFFBOARD"):
                rospy.logerr("Failed to set OFFBOARD mode")
                return False

        if not self.set_velocity_target(vx, vy, vz):
            return False

        if duration:
            # 如果是临时速度命令
            start_time = time.time()
            while (
                time.time() - start_time
            ) < duration and not rospy.is_shutdown():
                time.sleep(0.1)
            self.hover()  # 结束后悬停
            return True
        else:
            # 持续速度控制，需要外部调用hover停止
            return True

    def return_to_home(self, height=None, timeout=60.0):
        """返回起飞点并降落"""
        # 确保无人机模式
        if self.current_vehicle_mode != "drone":
            rospy.logerr("return_to_home to home only allowed in drone mode")
            return False
        # 检查悬停状态
        if not self.is_hovering:
            rospy.logerr(
                "return_to_home requires drone to be in hovering state"
            )
            return False
        rospy.loginfo("Returning to home")

        if self.home_position is None:
            rospy.logwarn("No home position set, returning to launch point")
            home_x, home_y, home_z = 0, 0, height if height else 0
        else:
            # 使用本地位置系统的原点作为返回点
            home_x, home_y, home_z = 0, 0, height if height else 0

        # 如果指定了高度，先上升到该高度
        current_z = self.current_pose.pose.position.z
        if height is not None and current_z < height - 0.5:
            if not self.move_to(home_x, home_y, height, timeout=timeout / 3):
                rospy.logwarn("Failed to ascend to safe height")
                return False

        # 移动到返回点上方
        if not self.move_to(
            home_x, home_y, height if height else current_z, timeout=timeout / 3
        ):
            rospy.logwarn("Failed to move to home position")
            return False

        # 下降到地面
        if height is None or height > 0.5:
            if not self.move_to(home_x, home_y, 0.5, timeout=timeout / 3):
                rospy.logwarn("Failed to descend to landing height")

        # 降落
        return self.land(timeout=timeout / 3)

    def switch_mode(self, target_mode, timeout=15.0):
        """阻塞式切换模式"""
        rospy.loginfo(f"Requesting switch to {target_mode} mode")

        # 检查当前模式
        self._update_vehicle_mode()
        if self.current_vehicle_mode == target_mode:
            rospy.logwarn(f"Already in {target_mode} mode")
            return True

        try:
            # 准备切换服务请求
            req = CommandLongRequest()
            if self._px4_version == 11:
                req.command = 183  # 旧版本PX4
                req.confirmation = 1
                req.param1 = 8

                if target_mode == "car":
                    vtol_state = 4  # 车辆模式
                    # 切换到车模式: param1=1300
                    rospy.loginfo("Preparing to switch to car mode")

                    # 如果当前是飞行模式，先降落并上锁
                    if (
                        self.current_vehicle_mode == "drone"
                        and self.current_state.armed
                    ):
                        self.land(timeout=10)
                        rospy.loginfo("Waiting for disarm...")
                        start_time = time.time()
                        while self.current_state.armed and (
                            time.time() - start_time < 10
                        ):
                            time.sleep(0.5)

                        if self.current_state.armed:
                            rospy.logerr(
                                "Disarm failed, cannot switch to car mode"
                            )
                            return False

                    req.param2 = 1300  # 切换到车模式

                else:  # target_mode == "drone"
                    # 切换到飞机模式: param1=1700
                    vtol_state = 3  # 无人机模式
                    rospy.loginfo("Preparing to switch to drone mode")
                    # 如果当前是车模式，先停止车辆上锁
                    if (
                        self.current_vehicle_mode == "car"
                        and self.current_state.armed
                    ):
                        self.stop_car()
                        # 上锁
                        if self._arm(False):
                            self.current_state.armed = False
                        else:
                            rospy.logwarn("Failed to disarm vehicle after control")

                    req.param2 = 1700  # 切换到无人机模式
            elif self._px4_version == 14:
                pass  # 新版本PX4待补充
            else:
                rospy.logerr(
                    f"px4_version error, px4_version = {self._px4_version}"
                )
                return False
            # 发送切换命令
            resp = self.command_client(req)

            # 等待模式切换完成
            start_time = time.time()
            while (
                time.time() - start_time
            ) < timeout and not rospy.is_shutdown():
                self._update_vehicle_mode()
                if self.current_vehicle_mode == target_mode or resp:
                    self.current_vehicle_mode = target_mode
                    self.extended_state.vtol_state = vtol_state
                    rospy.loginfo(
                        f"Switched to {target_mode} mode successfully"
                    )
                    self.is_hovering = False
                    return True
                time.sleep(0.1)

            rospy.logerr(f"Mode switch timeout after {timeout} seconds")
            return False

        except rospy.ServiceException as e:
            rospy.logerr(f"Mode switch service call failed: {e}")
            return False
        except Exception as e:
            rospy.logerr(f"Unexpected error during mode switch: {str(e)}")
            return False

    def set_car_velocity(self, linear=0.0, angular=0.0, duration=0.0):
        """
        阻塞式车辆控制（解锁->执行->上锁）
        :param linear: 线速度（m/s），范围-2.0~2.0
        :param angular: 角速度（rad/s），范围-2.0~2.0
        :param duration: 持续时间（秒），必须大于0
        :return: 成功返回True，失败返回False
        """
        if duration <= 0:
            rospy.logerr("Duration must be positive")
            return False

        # 确保当前处于车辆模式
        if self.current_vehicle_mode != "car":
            rospy.logerr("Cannot control car when not in car mode")
            return False
        # 设置OFFBOARD模式
        # if not self._set_mode("OFFBOARD"):
        #     rospy.logerr("Failed to set OFFBOARD mode")
        #     return False
        self.set_mode_client(custom_mode="OFFBOARD")
        self._send_car_velocity(0, 0)
        # 解锁车辆
        if not self._arm(True):
            rospy.logerr("Failed to arm vehicle")
            return False

        # 限制速度范围
        linear = max(min(linear, 2.0), -2.0)
        angular = max(min(angular, 2.0), -2.0)

        rospy.loginfo(
            f"Starting car control: linear={linear}, angular={angular}, duration={duration}"
        )

        # 持续发送控制指令直到达到持续时间
        start_time = time.time()
        rate = rospy.Rate(20)  # 20Hz

        while (time.time() - start_time) < duration and not rospy.is_shutdown():
            # 发送速度指令
            self._send_car_velocity(linear, angular)
            rate.sleep()

        # 控制结束，停止车辆
        self._send_car_velocity(0, 0)
        rospy.loginfo("Car control completed, stopping")

        # 上锁
        if self._arm(False):
            self.current_state.armed = False
        else:
            rospy.logwarn("Failed to disarm vehicle after control")

        return True

    # ---------- 辅助API ----------

    def _send_car_velocity(self, linear, angular):
        """发送车辆速度指令"""
        MaxAngular = 5.0
        MaxLinear = 3.2
        # 线速度归一化处理，取值范围-1.0到1.0
        # 中位0为停止，归一化处理，最大设置为3m/s时，发送-1和1就会3m/s
        linear_normalized = linear / MaxLinear
        # 角速度归一化处理，取值范围-1.0到1.0
        # 中位0为停止，归一化处理，最大设置为3rad/s时，发送-1和1就会3rad/s
        angular_normalized = angular / MaxAngular
        actuator = ActuatorControl()
        actuator.group_mix = 1
        actuator.controls = [
            0.0,
            0.0,
            angular_normalized,
            linear_normalized,
            0.0,
            0.0,
            0.0,
            0.0,
        ]
        self.actuator_control_pub.publish(actuator)

    def stop_car(self):
        """立即停止车辆并上锁"""
        if self.current_vehicle_mode != "car":
            return False

        # 发送停止指令
        self._send_car_velocity(0, 0)

        # 上锁
        if self._arm(False):
            self.current_state.armed = False
        else:
            rospy.logwarn("Failed to disarm vehicle after control")
        return True

    def hover(self):
        """悬停在当前位置（飞机模式）"""
        if self.current_vehicle_mode != "drone":
            rospy.logwarn("Hover only effective in drone mode")
            return False

        rospy.loginfo("Hovering at current position")
        self._is_active = True
        self.control_mode = "POSITION"
        self.yaw_rate = 0.0
        if self.current_pose.header.stamp != rospy.Time(
            0
        ):  # 确保有有效的位置数据
            self.target_position = [
                self.current_pose.pose.position.x,
                self.current_pose.pose.position.y,
                self.current_pose.pose.position.z,
            ]
        self.is_hovering = True
        return True

    def get_position(self):
        """获取当前位置"""
        pose = self.current_pose.pose.position
        return pose.x, pose.y, pose.z

    def get_battery(self):
        """获取电池状态"""
        return (
            self.current_battery.voltage,
            self.current_battery.percentage * 100,
        )

    # ---------- 内部方法 ----------
    def set_target_position(self, x, y, z):
        """设置目标位置（内部使用）"""
        self.target_position = [x, y, z]

    def _arm(self, arm):
        """内部解锁/锁定方法"""
        try:
            return self.arming_client(arm).success
        except rospy.ServiceException as e:
            rospy.logerr(f"Arming failed: {e}")
            return False

    def _set_mode(self, mode):
        """内部设置飞行模式方法"""
        try:
            resp = self.set_mode_client(custom_mode=mode)
            if resp.mode_sent:
                # 等待模式切换确认
                start_time = time.time()
                while self._thread_run and not rospy.is_shutdown():
                    if time.time() - start_time > 5.0:
                        rospy.logerr("Mode change confirmation timeout")
                        return False
                    if self.current_state.mode == mode:
                        return True
                    time.sleep(0.1)
            return resp.mode_sent
        except rospy.ServiceException as e:
            rospy.logerr(f"Mode change failed: {e}")
            return False

    def _update_vehicle_info_get(self):
        req = VehicleInfoGetRequest()
        # req.sysid
        resp = self.vehicle_info_get_client(req)
        vehicle_info = resp.vehicles[0]
        rospy.loginfo(f"Vehicle Info sys_id: {vehicle_info.sysid}")
        self._px4_version = self.get_px4_version(vehicle_info)
        rospy.loginfo(f"PX4 Version: {self._px4_version}")

    def get_px4_version(self, vehicle_info):
        version_uint = vehicle_info.flight_sw_version
        major = (version_uint >> 24) & 0xFF
        minor = (version_uint >> 16) & 0xFF
        patch = (version_uint >> 8) & 0xFF
        vtype = version_uint & 0xFF

        # 映射版本类型代码到可读字符串
        version_types = {0: "dev", 1: "alpha", 2: "beta", 3: "rc", 4: "release"}
        rospy.loginfo(
            f"{major}.{minor}.{patch} ({version_types.get(vtype, 'unknown')})"
        )
        return minor

    def _update_vehicle_mode(self):
        """根据vtol_state更新当前车辆模式"""
        # vtol_state:
        #   3 = MAV_VTOL_STATE_MC (多旋翼/无人机模式)
        #   4 = MAV_VTOL_STATE_FW (固定翼/车辆模式)
        if self.extended_state.vtol_state == 3:
            new_mode = "drone"
        elif self.extended_state.vtol_state == 4:
            new_mode = "car"
        else:
            new_mode = self.current_vehicle_mode  # 保持当前模式不变

        if new_mode != self.current_vehicle_mode:
            rospy.loginfo(
                f"Vehicle mode changed: {self.current_vehicle_mode} -> {new_mode}"
            )
            self.current_vehicle_mode = new_mode

    def _wait_for_connection(self):
        """等待飞控连接"""
        rospy.loginfo("Waiting for FCU connection")
        while (
            self._thread_run
            and not rospy.is_shutdown()
            and not self.current_state.connected
        ):
            time.sleep(0.1)
        if not self._thread_run:
            return
        rospy.loginfo("FCU connected")

        # 获取初始状态
        self._update_vehicle_mode()

        # # 发送初始位置
        # for i in range(50):
        #     if not self._thread_run:
        #         return
        #     self.local_pos_pub.publish(self._create_pose())
        #     time.sleep(0.1)
        self._create_pose()

    def _create_pose(self):
        """创建位置指令"""
        pose = PoseStamped()
        pose.header.stamp = rospy.Time.now()
        pose.header.frame_id = "map"
        pose.pose.position.x = self.target_position[0]
        pose.pose.position.y = self.target_position[1]
        pose.pose.position.z = self.target_position[2]
        # 保持当前朝向 (四元数)
        if self.current_pose.header.stamp != rospy.Time(0):
            pose.pose.orientation = self.current_pose.pose.orientation
        else:
            pose.pose.orientation.w = 1.0
        return pose

    def _create_velocity(self):
        """创建速度指令"""
        twist = TwistStamped()
        twist.header.stamp = rospy.Time.now()
        twist.header.frame_id = "map"
        twist.twist.linear.x = self.velocity[0]
        twist.twist.linear.y = self.velocity[1]
        twist.twist.linear.z = self.velocity[2]
        twist.twist.angular.z = self.yaw_rate
        return twist

    def _control_loop(self):
        """后台控制线程"""
        rate = rospy.Rate(20)  # 20Hz

        while self._thread_run and not rospy.is_shutdown():
            try:
                if not self._thread_run or not self._is_active:
                    rate.sleep()
                    continue

                # 根据当前模式发送不同的控制命令
                if self.current_vehicle_mode == "drone":
                    if self.control_mode == "POSITION":
                        self.local_pos_pub.publish(self._create_pose())
                    elif self.control_mode == "VELOCITY":
                        self.vel_pub.publish(self._create_velocity())
                # 在车辆模式时不发送任何无人机控制命令

                rate.sleep()
            except rospy.exceptions.ROSException:
                # ROS已关闭，退出线程
                break
        rospy.loginfo("Control thread stopped")

    def _shutdown_hook(self):
        """ROS关闭时的回调函数"""
        rospy.loginfo("Shutting down vehicle controller")
        self._thread_run = False
        self._is_active = False

        # 停止车辆控制
        if self.current_vehicle_mode == "car":
            self.stop_car()

        # 尝试安全降落
        if self.current_vehicle_mode == "drone" and self.current_state.armed:
            rospy.logwarn("Drone still armed, attempting to land...")
            try:
                self.land(timeout=10)
            except:
                pass

    # ---------- 回调函数 ----------

    def state_cb(self, msg):
        self.current_state = msg

    def pose_cb(self, msg):
        self.current_pose = msg

    def battery_cb(self, msg):
        self.current_battery = msg

    def global_position_cb(self, msg):
        """保存GPS位置作为home position"""
        if self.home_position is None:
            self.home_position = msg
            rospy.loginfo(
                f"Home position set: ({msg.latitude}, {msg.longitude})"
            )

    def extended_state_cb(self, msg):
        """处理扩展状态消息，更新vtol状态"""
        self.extended_state = msg
        self._update_vehicle_mode()

    def __del__(self):
        """析构函数确保线程关闭"""
        if hasattr(self, "_shutdown_hook_set") and not self._shutdown_hook_set:
            self._shutdown_hook()
