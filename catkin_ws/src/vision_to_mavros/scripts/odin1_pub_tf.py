#!/usr/bin/env python3

import rospy
import tf2_ros
import tf2_geometry_msgs
from nav_msgs.msg import Odometry
from geometry_msgs.msg import TransformStamped
from threading import Lock

# 全局变量用于存储最新消息
latest_odom = None
odom_lock = Lock()

def handle_odom_pose(msg):
    global latest_odom
    with odom_lock:
        latest_odom = msg

def publish_tf():
    br = tf2_ros.TransformBroadcaster()
    t = TransformStamped()
    
    # 使用最新消息的时间戳
    t.header.stamp = rospy.Time.now()
    t.header.frame_id = "map"
    t.child_frame_id = "base_link"
    
    # 获取最新消息并复制数据
    with odom_lock:
        if latest_odom:
            t.transform.translation.x = latest_odom.pose.pose.position.x
            t.transform.translation.y = latest_odom.pose.pose.position.y
            t.transform.translation.z = latest_odom.pose.pose.position.z
            t.transform.rotation.x = latest_odom.pose.pose.orientation.x
            t.transform.rotation.y = latest_odom.pose.pose.orientation.y
            t.transform.rotation.z = latest_odom.pose.pose.orientation.z
            t.transform.rotation.w = latest_odom.pose.pose.orientation.w
            br.sendTransform(t)

if __name__ == '__main__':
    rospy.init_node('odometry_to_tf_publisher')
    rospy.Subscriber('/odin1/odometry_highfreq', Odometry, handle_odom_pose)

    rate = rospy.Rate(30)
    while not rospy.is_shutdown():
        publish_tf()
        rate.sleep()

