;; Auto-generated. Do not edit!


(when (boundp 'ground_air_msgs::MissionStatus)
  (if (not (find-package "GROUND_AIR_MSGS"))
    (make-package "GROUND_AIR_MSGS"))
  (shadow 'MissionStatus (find-package "GROUND_AIR_MSGS")))
(unless (find-package "GROUND_AIR_MSGS::MISSIONSTATUS")
  (make-package "GROUND_AIR_MSGS::MISSIONSTATUS"))

(in-package "ROS")
;;//! \htmlinclude MissionStatus.msg.html
(if (not (find-package "STD_MSGS"))
  (ros::roseus-add-msgs "std_msgs"))


(intern "*IDLE*" (find-package "GROUND_AIR_MSGS::MISSIONSTATUS"))
(shadow '*IDLE* (find-package "GROUND_AIR_MSGS::MISSIONSTATUS"))
(defconstant ground_air_msgs::MissionStatus::*IDLE* 0)
(intern "*RUNNING*" (find-package "GROUND_AIR_MSGS::MISSIONSTATUS"))
(shadow '*RUNNING* (find-package "GROUND_AIR_MSGS::MISSIONSTATUS"))
(defconstant ground_air_msgs::MissionStatus::*RUNNING* 1)
(intern "*DWELLING*" (find-package "GROUND_AIR_MSGS::MISSIONSTATUS"))
(shadow '*DWELLING* (find-package "GROUND_AIR_MSGS::MISSIONSTATUS"))
(defconstant ground_air_msgs::MissionStatus::*DWELLING* 2)
(intern "*PAUSED*" (find-package "GROUND_AIR_MSGS::MISSIONSTATUS"))
(shadow '*PAUSED* (find-package "GROUND_AIR_MSGS::MISSIONSTATUS"))
(defconstant ground_air_msgs::MissionStatus::*PAUSED* 3)
(intern "*SUCCEEDED*" (find-package "GROUND_AIR_MSGS::MISSIONSTATUS"))
(shadow '*SUCCEEDED* (find-package "GROUND_AIR_MSGS::MISSIONSTATUS"))
(defconstant ground_air_msgs::MissionStatus::*SUCCEEDED* 4)
(intern "*FAILED*" (find-package "GROUND_AIR_MSGS::MISSIONSTATUS"))
(shadow '*FAILED* (find-package "GROUND_AIR_MSGS::MISSIONSTATUS"))
(defconstant ground_air_msgs::MissionStatus::*FAILED* 5)
(intern "*CANCELED*" (find-package "GROUND_AIR_MSGS::MISSIONSTATUS"))
(shadow '*CANCELED* (find-package "GROUND_AIR_MSGS::MISSIONSTATUS"))
(defconstant ground_air_msgs::MissionStatus::*CANCELED* 6)
(intern "*WAITING_FOR_LAND*" (find-package "GROUND_AIR_MSGS::MISSIONSTATUS"))
(shadow '*WAITING_FOR_LAND* (find-package "GROUND_AIR_MSGS::MISSIONSTATUS"))
(defconstant ground_air_msgs::MissionStatus::*WAITING_FOR_LAND* 7)

(defun ground_air_msgs::MissionStatus-to-symbol (const)
  (cond
        ((= const 0) 'ground_air_msgs::MissionStatus::*IDLE*)
        ((= const 1) 'ground_air_msgs::MissionStatus::*RUNNING*)
        ((= const 2) 'ground_air_msgs::MissionStatus::*DWELLING*)
        ((= const 3) 'ground_air_msgs::MissionStatus::*PAUSED*)
        ((= const 4) 'ground_air_msgs::MissionStatus::*SUCCEEDED*)
        ((= const 5) 'ground_air_msgs::MissionStatus::*FAILED*)
        ((= const 6) 'ground_air_msgs::MissionStatus::*CANCELED*)
        ((= const 7) 'ground_air_msgs::MissionStatus::*WAITING_FOR_LAND*)
        (t nil)))

(defclass ground_air_msgs::MissionStatus
  :super ros::object
  :slots (_header _state _current_index _total_goals _mission_id _detail ))

(defmethod ground_air_msgs::MissionStatus
  (:init
   (&key
    ((:header __header) (instance std_msgs::Header :init))
    ((:state __state) 0)
    ((:current_index __current_index) 0)
    ((:total_goals __total_goals) 0)
    ((:mission_id __mission_id) "")
    ((:detail __detail) "")
    )
   (send-super :init)
   (setq _header __header)
   (setq _state (round __state))
   (setq _current_index (round __current_index))
   (setq _total_goals (round __total_goals))
   (setq _mission_id (string __mission_id))
   (setq _detail (string __detail))
   self)
  (:header
   (&rest __header)
   (if (keywordp (car __header))
       (send* _header __header)
     (progn
       (if __header (setq _header (car __header)))
       _header)))
  (:state
   (&optional __state)
   (if __state (setq _state __state)) _state)
  (:current_index
   (&optional __current_index)
   (if __current_index (setq _current_index __current_index)) _current_index)
  (:total_goals
   (&optional __total_goals)
   (if __total_goals (setq _total_goals __total_goals)) _total_goals)
  (:mission_id
   (&optional __mission_id)
   (if __mission_id (setq _mission_id __mission_id)) _mission_id)
  (:detail
   (&optional __detail)
   (if __detail (setq _detail __detail)) _detail)
  (:serialization-length
   ()
   (+
    ;; std_msgs/Header _header
    (send _header :serialization-length)
    ;; uint8 _state
    1
    ;; uint32 _current_index
    4
    ;; uint32 _total_goals
    4
    ;; string _mission_id
    4 (length _mission_id)
    ;; string _detail
    4 (length _detail)
    ))
  (:serialize
   (&optional strm)
   (let ((s (if strm strm
              (make-string-output-stream (send self :serialization-length)))))
     ;; std_msgs/Header _header
       (send _header :serialize s)
     ;; uint8 _state
       (write-byte _state s)
     ;; uint32 _current_index
       (write-long _current_index s)
     ;; uint32 _total_goals
       (write-long _total_goals s)
     ;; string _mission_id
       (write-long (length _mission_id) s) (princ _mission_id s)
     ;; string _detail
       (write-long (length _detail) s) (princ _detail s)
     ;;
     (if (null strm) (get-output-stream-string s))))
  (:deserialize
   (buf &optional (ptr- 0))
   ;; std_msgs/Header _header
     (send _header :deserialize buf ptr-) (incf ptr- (send _header :serialization-length))
   ;; uint8 _state
     (setq _state (sys::peek buf ptr- :char)) (incf ptr- 1)
   ;; uint32 _current_index
     (setq _current_index (sys::peek buf ptr- :integer)) (incf ptr- 4)
   ;; uint32 _total_goals
     (setq _total_goals (sys::peek buf ptr- :integer)) (incf ptr- 4)
   ;; string _mission_id
     (let (n) (setq n (sys::peek buf ptr- :integer)) (incf ptr- 4) (setq _mission_id (subseq buf ptr- (+ ptr- n))) (incf ptr- n))
   ;; string _detail
     (let (n) (setq n (sys::peek buf ptr- :integer)) (incf ptr- 4) (setq _detail (subseq buf ptr- (+ ptr- n))) (incf ptr- n))
   ;;
   self)
  )

(setf (get ground_air_msgs::MissionStatus :md5sum-) "23946ede182678d2d602626aab96cd05")
(setf (get ground_air_msgs::MissionStatus :datatype-) "ground_air_msgs/MissionStatus")
(setf (get ground_air_msgs::MissionStatus :definition-)
      "std_msgs/Header header

uint8 IDLE=0
uint8 RUNNING=1
uint8 DWELLING=2
uint8 PAUSED=3
uint8 SUCCEEDED=4
uint8 FAILED=5
uint8 CANCELED=6
uint8 WAITING_FOR_LAND=7

uint8 state
uint32 current_index
uint32 total_goals
string mission_id
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



(provide :ground_air_msgs/MissionStatus "23946ede182678d2d602626aab96cd05")


