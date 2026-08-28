#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import rospy
from geometry_msgs.msg import Twist
from mavros_msgs.msg import ActuatorControl
from std_msgs.msg import Header

class CmdVelToActuatorControl:
    def __init__(self):
        rospy.init_node('cmd_vel_to_actuator_control', anonymous=True)
        
        # 订阅cmd_vel话题
        rospy.Subscriber('/cmd_vel', Twist, self.cmd_vel_callback)
        
        # 发布到mavros/actuator_control话题
        self.actuator_pub = rospy.Publisher('/mavros/actuator_control', ActuatorControl, queue_size=10)
        
        # 当前控制值
        self.linear_x = 0.0
        self.angular_z = 0.0
        
        # 发布频率20Hz
        self.rate = rospy.Rate(20)
        
        # 主循环
        self.run()
    
    def cmd_vel_callback(self, msg):
        """
        处理cmd_vel消息的回调函数
        """
        self.linear_x = msg.linear.x
        self.angular_z = -msg.angular.z
    
    def run(self):
        """
        主循环，以20Hz频率发布控制消息
        """
        while not rospy.is_shutdown():
            # 创建ActuatorControl消息
            actuator_msg = ActuatorControl()
            
            # 设置消息头
            actuator_msg.header = Header()
            actuator_msg.header.stamp = rospy.Time.now()
            actuator_msg.header.frame_id = "base_link"  # 根据实际情况调整帧ID
            
            # 设置组混合为1（飞行控制）
            actuator_msg.group_mix = 1
            
            # 初始化controls数组，所有8个值设为0
            actuator_msg.controls = [0.0] * 8
            
            # 将线速度和角速度映射到controls数组
            # 索引2对应角速度，索引3对应线速度
            # 注意：可能需要根据实际需求调整正负号
            actuator_msg.controls[2] = self.angular_z  # 角速度
            actuator_msg.controls[3] = self.linear_x   # 线速度
            
            # 发布消息
            self.actuator_pub.publish(actuator_msg)
            # actuator_msg.controls[2] = 0.0  # 角速度
            # actuator_msg.controls[3] = 0.0   # 线速度

            #self.linear_x = 0.0
            #self.angular_z = 0.0
            # 控制发布频率
            self.rate.sleep()

if __name__ == '__main__':
    try:
        converter = CmdVelToActuatorControl()
    except rospy.ROSInterruptException:
        pass