;; Auto-generated. Do not edit!


(when (boundp 'ground_air_msgs::VehicleStatus)
  (if (not (find-package "GROUND_AIR_MSGS"))
    (make-package "GROUND_AIR_MSGS"))
  (shadow 'VehicleStatus (find-package "GROUND_AIR_MSGS")))
(unless (find-package "GROUND_AIR_MSGS::VEHICLESTATUS")
  (make-package "GROUND_AIR_MSGS::VEHICLESTATUS"))

(in-package "ROS")
;;//! \htmlinclude VehicleStatus.msg.html
(if (not (find-package "STD_MSGS"))
  (ros::roseus-add-msgs "std_msgs"))


(intern "*UNKNOWN*" (find-package "GROUND_AIR_MSGS::VEHICLESTATUS"))
(shadow '*UNKNOWN* (find-package "GROUND_AIR_MSGS::VEHICLESTATUS"))
(defconstant ground_air_msgs::VehicleStatus::*UNKNOWN* 0)
(intern "*GROUND*" (find-package "GROUND_AIR_MSGS::VEHICLESTATUS"))
(shadow '*GROUND* (find-package "GROUND_AIR_MSGS::VEHICLESTATUS"))
(defconstant ground_air_msgs::VehicleStatus::*GROUND* 1)
(intern "*TAKEOFF*" (find-package "GROUND_AIR_MSGS::VEHICLESTATUS"))
(shadow '*TAKEOFF* (find-package "GROUND_AIR_MSGS::VEHICLESTATUS"))
(defconstant ground_air_msgs::VehicleStatus::*TAKEOFF* 2)
(intern "*AIR*" (find-package "GROUND_AIR_MSGS::VEHICLESTATUS"))
(shadow '*AIR* (find-package "GROUND_AIR_MSGS::VEHICLESTATUS"))
(defconstant ground_air_msgs::VehicleStatus::*AIR* 3)
(intern "*LANDING*" (find-package "GROUND_AIR_MSGS::VEHICLESTATUS"))
(shadow '*LANDING* (find-package "GROUND_AIR_MSGS::VEHICLESTATUS"))
(defconstant ground_air_msgs::VehicleStatus::*LANDING* 4)
(intern "*ESTOP*" (find-package "GROUND_AIR_MSGS::VEHICLESTATUS"))
(shadow '*ESTOP* (find-package "GROUND_AIR_MSGS::VEHICLESTATUS"))
(defconstant ground_air_msgs::VehicleStatus::*ESTOP* 5)
(intern "*FAULT*" (find-package "GROUND_AIR_MSGS::VEHICLESTATUS"))
(shadow '*FAULT* (find-package "GROUND_AIR_MSGS::VEHICLESTATUS"))
(defconstant ground_air_msgs::VehicleStatus::*FAULT* 6)

(defun ground_air_msgs::VehicleStatus-to-symbol (const)
  (cond
        ((= const 0) 'ground_air_msgs::VehicleStatus::*UNKNOWN*)
        ((= const 1) 'ground_air_msgs::VehicleStatus::*GROUND*)
        ((= const 2) 'ground_air_msgs::VehicleStatus::*TAKEOFF*)
        ((= const 3) 'ground_air_msgs::VehicleStatus::*AIR*)
        ((= const 4) 'ground_air_msgs::VehicleStatus::*LANDING*)
        ((= const 5) 'ground_air_msgs::VehicleStatus::*ESTOP*)
        ((= const 6) 'ground_air_msgs::VehicleStatus::*FAULT*)
        (t nil)))

(defclass ground_air_msgs::VehicleStatus
  :super ros::object
  :slots (_header _mode _connected _armed _localized _emergency_stop _altitude _flight_mode _detail ))

(defmethod ground_air_msgs::VehicleStatus
  (:init
   (&key
    ((:header __header) (instance std_msgs::Header :init))
    ((:mode __mode) 0)
    ((:connected __connected) nil)
    ((:armed __armed) nil)
    ((:localized __localized) nil)
    ((:emergency_stop __emergency_stop) nil)
    ((:altitude __altitude) 0.0)
    ((:flight_mode __flight_mode) "")
    ((:detail __detail) "")
    )
   (send-super :init)
   (setq _header __header)
   (setq _mode (round __mode))
   (setq _connected __connected)
   (setq _armed __armed)
   (setq _localized __localized)
   (setq _emergency_stop __emergency_stop)
   (setq _altitude (float __altitude))
   (setq _flight_mode (string __flight_mode))
   (setq _detail (string __detail))
   self)
  (:header
   (&rest __header)
   (if (keywordp (car __header))
       (send* _header __header)
     (progn
       (if __header (setq _header (car __header)))
       _header)))
  (:mode
   (&optional __mode)
   (if __mode (setq _mode __mode)) _mode)
  (:connected
   (&optional (__connected :null))
   (if (not (eq __connected :null)) (setq _connected __connected)) _connected)
  (:armed
   (&optional (__armed :null))
   (if (not (eq __armed :null)) (setq _armed __armed)) _armed)
  (:localized
   (&optional (__localized :null))
   (if (not (eq __localized :null)) (setq _localized __localized)) _localized)
  (:emergency_stop
   (&optional (__emergency_stop :null))
   (if (not (eq __emergency_stop :null)) (setq _emergency_stop __emergency_stop)) _emergency_stop)
  (:altitude
   (&optional __altitude)
   (if __altitude (setq _altitude __altitude)) _altitude)
  (:flight_mode
   (&optional __flight_mode)
   (if __flight_mode (setq _flight_mode __flight_mode)) _flight_mode)
  (:detail
   (&optional __detail)
   (if __detail (setq _detail __detail)) _detail)
  (:serialization-length
   ()
   (+
    ;; std_msgs/Header _header
    (send _header :serialization-length)
    ;; uint8 _mode
    1
    ;; bool _connected
    1
    ;; bool _armed
    1
    ;; bool _localized
    1
    ;; bool _emergency_stop
    1
    ;; float32 _altitude
    4
    ;; string _flight_mode
    4 (length _flight_mode)
    ;; string _detail
    4 (length _detail)
    ))
  (:serialize
   (&optional strm)
   (let ((s (if strm strm
              (make-string-output-stream (send self :serialization-length)))))
     ;; std_msgs/Header _header
       (send _header :serialize s)
     ;; uint8 _mode
       (write-byte _mode s)
     ;; bool _connected
       (if _connected (write-byte -1 s) (write-byte 0 s))
     ;; bool _armed
       (if _armed (write-byte -1 s) (write-byte 0 s))
     ;; bool _localized
       (if _localized (write-byte -1 s) (write-byte 0 s))
     ;; bool _emergency_stop
       (if _emergency_stop (write-byte -1 s) (write-byte 0 s))
     ;; float32 _altitude
       (sys::poke _altitude (send s :buffer) (send s :count) :float) (incf (stream-count s) 4)
     ;; string _flight_mode
       (write-long (length _flight_mode) s) (princ _flight_mode s)
     ;; string _detail
       (write-long (length _detail) s) (princ _detail s)
     ;;
     (if (null strm) (get-output-stream-string s))))
  (:deserialize
   (buf &optional (ptr- 0))
   ;; std_msgs/Header _header
     (send _header :deserialize buf ptr-) (incf ptr- (send _header :serialization-length))
   ;; uint8 _mode
     (setq _mode (sys::peek buf ptr- :char)) (incf ptr- 1)
   ;; bool _connected
     (setq _connected (not (= 0 (sys::peek buf ptr- :char)))) (incf ptr- 1)
   ;; bool _armed
     (setq _armed (not (= 0 (sys::peek buf ptr- :char)))) (incf ptr- 1)
   ;; bool _localized
     (setq _localized (not (= 0 (sys::peek buf ptr- :char)))) (incf ptr- 1)
   ;; bool _emergency_stop
     (setq _emergency_stop (not (= 0 (sys::peek buf ptr- :char)))) (incf ptr- 1)
   ;; float32 _altitude
     (setq _altitude (sys::peek buf ptr- :float)) (incf ptr- 4)
   ;; string _flight_mode
     (let (n) (setq n (sys::peek buf ptr- :integer)) (incf ptr- 4) (setq _flight_mode (subseq buf ptr- (+ ptr- n))) (incf ptr- n))
   ;; string _detail
     (let (n) (setq n (sys::peek buf ptr- :integer)) (incf ptr- 4) (setq _detail (subseq buf ptr- (+ ptr- n))) (incf ptr- n))
   ;;
   self)
  )

(setf (get ground_air_msgs::VehicleStatus :md5sum-) "95fa82c3b8b77ebda59f5cb1adfd1b65")
(setf (get ground_air_msgs::VehicleStatus :datatype-) "ground_air_msgs/VehicleStatus")
(setf (get ground_air_msgs::VehicleStatus :definition-)
      "std_msgs/Header header

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



(provide :ground_air_msgs/VehicleStatus "95fa82c3b8b77ebda59f5cb1adfd1b65")


