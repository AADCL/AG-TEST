from px4_drone import PX4Drone
import time
import rospy

rospy.init_node("demo_car_control")
drone = PX4Drone()
drone.switch_mode("car")

drone.switch_mode("car")
rospy.loginfo("Switched to car mode")
drone.set_car_velocity(linear=0.5, angular=0.0, duration=2.0)
