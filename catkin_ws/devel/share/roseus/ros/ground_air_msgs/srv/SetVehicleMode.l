;; Auto-generated. Do not edit!


(when (boundp 'ground_air_msgs::SetVehicleMode)
  (if (not (find-package "GROUND_AIR_MSGS"))
    (make-package "GROUND_AIR_MSGS"))
  (shadow 'SetVehicleMode (find-package "GROUND_AIR_MSGS")))
(unless (find-package "GROUND_AIR_MSGS::SETVEHICLEMODE")
  (make-package "GROUND_AIR_MSGS::SETVEHICLEMODE"))
(unless (find-package "GROUND_AIR_MSGS::SETVEHICLEMODEREQUEST")
  (make-package "GROUND_AIR_MSGS::SETVEHICLEMODEREQUEST"))
(unless (find-package "GROUND_AIR_MSGS::SETVEHICLEMODERESPONSE")
  (make-package "GROUND_AIR_MSGS::SETVEHICLEMODERESPONSE"))

(in-package "ROS")





(intern "*GROUND*" (find-package "GROUND_AIR_MSGS::SETVEHICLEMODEREQUEST"))
(shadow '*GROUND* (find-package "GROUND_AIR_MSGS::SETVEHICLEMODEREQUEST"))
(defconstant ground_air_msgs::SetVehicleModeRequest::*GROUND* 1)
(intern "*AIR*" (find-package "GROUND_AIR_MSGS::SETVEHICLEMODEREQUEST"))
(shadow '*AIR* (find-package "GROUND_AIR_MSGS::SETVEHICLEMODEREQUEST"))
(defconstant ground_air_msgs::SetVehicleModeRequest::*AIR* 3)

(defun ground_air_msgs::SetVehicleModeRequest-to-symbol (const)
  (cond
        ((= const 1) 'ground_air_msgs::SetVehicleModeRequest::*GROUND*)
        ((= const 3) 'ground_air_msgs::SetVehicleModeRequest::*AIR*)
        (t nil)))

(defclass ground_air_msgs::SetVehicleModeRequest
  :super ros::object
  :slots (_target_mode ))

(defmethod ground_air_msgs::SetVehicleModeRequest
  (:init
   (&key
    ((:target_mode __target_mode) 0)
    )
   (send-super :init)
   (setq _target_mode (round __target_mode))
   self)
  (:target_mode
   (&optional __target_mode)
   (if __target_mode (setq _target_mode __target_mode)) _target_mode)
  (:serialization-length
   ()
   (+
    ;; uint8 _target_mode
    1
    ))
  (:serialize
   (&optional strm)
   (let ((s (if strm strm
              (make-string-output-stream (send self :serialization-length)))))
     ;; uint8 _target_mode
       (write-byte _target_mode s)
     ;;
     (if (null strm) (get-output-stream-string s))))
  (:deserialize
   (buf &optional (ptr- 0))
   ;; uint8 _target_mode
     (setq _target_mode (sys::peek buf ptr- :char)) (incf ptr- 1)
   ;;
   self)
  )

(defclass ground_air_msgs::SetVehicleModeResponse
  :super ros::object
  :slots (_success _message _status ))

(defmethod ground_air_msgs::SetVehicleModeResponse
  (:init
   (&key
    ((:success __success) nil)
    ((:message __message) "")
    ((:status __status) (instance ground_air_msgs::VehicleStatus :init))
    )
   (send-super :init)
   (setq _success __success)
   (setq _message (string __message))
   (setq _status __status)
   self)
  (:success
   (&optional (__success :null))
   (if (not (eq __success :null)) (setq _success __success)) _success)
  (:message
   (&optional __message)
   (if __message (setq _message __message)) _message)
  (:status
   (&rest __status)
   (if (keywordp (car __status))
       (send* _status __status)
     (progn
       (if __status (setq _status (car __status)))
       _status)))
  (:serialization-length
   ()
   (+
    ;; bool _success
    1
    ;; string _message
    4 (length _message)
    ;; ground_air_msgs/VehicleStatus _status
    (send _status :serialization-length)
    ))
  (:serialize
   (&optional strm)
   (let ((s (if strm strm
              (make-string-output-stream (send self :serialization-length)))))
     ;; bool _success
       (if _success (write-byte -1 s) (write-byte 0 s))
     ;; string _message
       (write-long (length _message) s) (princ _message s)
     ;; ground_air_msgs/VehicleStatus _status
       (send _status :serialize s)
     ;;
     (if (null strm) (get-output-stream-string s))))
  (:deserialize
   (buf &optional (ptr- 0))
   ;; bool _success
     (setq _success (not (= 0 (sys::peek buf ptr- :char)))) (incf ptr- 1)
   ;; string _message
     (let (n) (setq n (sys::peek buf ptr- :integer)) (incf ptr- 4) (setq _message (subseq buf ptr- (+ ptr- n))) (incf ptr- n))
   ;; ground_air_msgs/VehicleStatus _status
     (send _status :deserialize buf ptr-) (incf ptr- (send _status :serialization-length))
   ;;
   self)
  )

(defclass ground_air_msgs::SetVehicleMode
  :super ros::object
  :slots ())

(setf (get ground_air_msgs::SetVehicleMode :md5sum-) "ec2c78fe35d8769d286703fa442499f8")
(setf (get ground_air_msgs::SetVehicleMode :datatype-) "ground_air_msgs/SetVehicleMode")
(setf (get ground_air_msgs::SetVehicleMode :request) ground_air_msgs::SetVehicleModeRequest)
(setf (get ground_air_msgs::SetVehicleMode :response) ground_air_msgs::SetVehicleModeResponse)

(defmethod ground_air_msgs::SetVehicleModeRequest
  (:response () (instance ground_air_msgs::SetVehicleModeResponse :init)))

(setf (get ground_air_msgs::SetVehicleModeRequest :md5sum-) "ec2c78fe35d8769d286703fa442499f8")
(setf (get ground_air_msgs::SetVehicleModeRequest :datatype-) "ground_air_msgs/SetVehicleModeRequest")
(setf (get ground_air_msgs::SetVehicleModeRequest :definition-)
      "uint8 GROUND=1
uint8 AIR=3
uint8 target_mode
---
bool success
string message
ground_air_msgs/VehicleStatus status


================================================================================
MSG: ground_air_msgs/VehicleStatus
std_msgs/Header header

uint8 UNKNOWN=0
uint8 GROUND=1
uint8 TAKEOFF=2
uint8 AIR=3
uint8 LANDING=4
uint8 ESTOP=5
uint8 FAULT=6

uint8 mode
bool connected
bool armed
bool localized
bool emergency_stop
float32 altitude
string flight_mode
string detail

================================================================================
MSG: std_msgs/Header
# Standard metadata for higher-level stamped data types.
# This is generally used to communicate timestamped data 
# in a particular coordinate frame.
# 
# sequence ID: consecutively increasing ID 
uint32 seq
#Two-integer timestamp that is expressed as:
# * stamp.sec: seconds (stamp_secs) since epoch (in Python the variable is called 'secs')
# * stamp.nsec: nanoseconds since stamp_secs (in Python the variable is called 'nsecs')
# time-handling sugar is provided by the client library
time stamp
#Frame this data is associated with
string frame_id
")

(setf (get ground_air_msgs::SetVehicleModeResponse :md5sum-) "ec2c78fe35d8769d286703fa442499f8")
(setf (get ground_air_msgs::SetVehicleModeResponse :datatype-) "ground_air_msgs/SetVehicleModeResponse")
(setf (get ground_air_msgs::SetVehicleModeResponse :definition-)
      "uint8 GROUND=1
uint8 AIR=3
uint8 target_mode
---
bool success
string message
ground_air_msgs/VehicleStatus status


================================================================================
MSG: ground_air_msgs/VehicleStatus
std_msgs/Header header

uint8 UNKNOWN=0
uint8 GROUND=1
uint8 TAKEOFF=2
uint8 AIR=3
uint8 LANDING=4
uint8 ESTOP=5
uint8 FAULT=6

uint8 mode
bool connected
bool armed
bool localized
bool emergency_stop
float32 altitude
string flight_mode
string detail

================================================================================
MSG: std_msgs/Header
# Standard metadata for higher-level stamped data types.
# This is generally used to communicate timestamped data 
# in a particular coordinate frame.
# 
# sequence ID: consecutively increasing ID 
uint32 seq
#Two-integer timestamp that is expressed as:
# * stamp.sec: seconds (stamp_secs) since epoch (in Python the variable is called 'secs')
# * stamp.nsec: nanoseconds since stamp_secs (in Python the variable is called 'nsecs')
# time-handling sugar is provided by the client library
time stamp
#Frame this data is associated with
string frame_id
")



(provide :ground_air_msgs/SetVehicleMode "ec2c78fe35d8769d286703fa442499f8")


