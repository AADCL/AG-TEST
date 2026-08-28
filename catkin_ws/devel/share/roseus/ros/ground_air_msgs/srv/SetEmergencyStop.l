;; Auto-generated. Do not edit!


(when (boundp 'ground_air_msgs::SetEmergencyStop)
  (if (not (find-package "GROUND_AIR_MSGS"))
    (make-package "GROUND_AIR_MSGS"))
  (shadow 'SetEmergencyStop (find-package "GROUND_AIR_MSGS")))
(unless (find-package "GROUND_AIR_MSGS::SETEMERGENCYSTOP")
  (make-package "GROUND_AIR_MSGS::SETEMERGENCYSTOP"))
(unless (find-package "GROUND_AIR_MSGS::SETEMERGENCYSTOPREQUEST")
  (make-package "GROUND_AIR_MSGS::SETEMERGENCYSTOPREQUEST"))
(unless (find-package "GROUND_AIR_MSGS::SETEMERGENCYSTOPRESPONSE")
  (make-package "GROUND_AIR_MSGS::SETEMERGENCYSTOPRESPONSE"))

(in-package "ROS")





(defclass ground_air_msgs::SetEmergencyStopRequest
  :super ros::object
  :slots (_active ))

(defmethod ground_air_msgs::SetEmergencyStopRequest
  (:init
   (&key
    ((:active __active) nil)
    )
   (send-super :init)
   (setq _active __active)
   self)
  (:active
   (&optional (__active :null))
   (if (not (eq __active :null)) (setq _active __active)) _active)
  (:serialization-length
   ()
   (+
    ;; bool _active
    1
    ))
  (:serialize
   (&optional strm)
   (let ((s (if strm strm
              (make-string-output-stream (send self :serialization-length)))))
     ;; bool _active
       (if _active (write-byte -1 s) (write-byte 0 s))
     ;;
     (if (null strm) (get-output-stream-string s))))
  (:deserialize
   (buf &optional (ptr- 0))
   ;; bool _active
     (setq _active (not (= 0 (sys::peek buf ptr- :char)))) (incf ptr- 1)
   ;;
   self)
  )

(defclass ground_air_msgs::SetEmergencyStopResponse
  :super ros::object
  :slots (_success _message _status ))

(defmethod ground_air_msgs::SetEmergencyStopResponse
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

(defclass ground_air_msgs::SetEmergencyStop
  :super ros::object
  :slots ())

(setf (get ground_air_msgs::SetEmergencyStop :md5sum-) "6adfca563192fe56ca02041330bd55c8")
(setf (get ground_air_msgs::SetEmergencyStop :datatype-) "ground_air_msgs/SetEmergencyStop")
(setf (get ground_air_msgs::SetEmergencyStop :request) ground_air_msgs::SetEmergencyStopRequest)
(setf (get ground_air_msgs::SetEmergencyStop :response) ground_air_msgs::SetEmergencyStopResponse)

(defmethod ground_air_msgs::SetEmergencyStopRequest
  (:response () (instance ground_air_msgs::SetEmergencyStopResponse :init)))

(setf (get ground_air_msgs::SetEmergencyStopRequest :md5sum-) "6adfca563192fe56ca02041330bd55c8")
(setf (get ground_air_msgs::SetEmergencyStopRequest :datatype-) "ground_air_msgs/SetEmergencyStopRequest")
(setf (get ground_air_msgs::SetEmergencyStopRequest :definition-)
      "bool active
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

(setf (get ground_air_msgs::SetEmergencyStopResponse :md5sum-) "6adfca563192fe56ca02041330bd55c8")
(setf (get ground_air_msgs::SetEmergencyStopResponse :datatype-) "ground_air_msgs/SetEmergencyStopResponse")
(setf (get ground_air_msgs::SetEmergencyStopResponse :definition-)
      "bool active
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



(provide :ground_air_msgs/SetEmergencyStop "6adfca563192fe56ca02041330bd55c8")


