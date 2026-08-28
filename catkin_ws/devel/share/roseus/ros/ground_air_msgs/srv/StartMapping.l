;; Auto-generated. Do not edit!


(when (boundp 'ground_air_msgs::StartMapping)
  (if (not (find-package "GROUND_AIR_MSGS"))
    (make-package "GROUND_AIR_MSGS"))
  (shadow 'StartMapping (find-package "GROUND_AIR_MSGS")))
(unless (find-package "GROUND_AIR_MSGS::STARTMAPPING")
  (make-package "GROUND_AIR_MSGS::STARTMAPPING"))
(unless (find-package "GROUND_AIR_MSGS::STARTMAPPINGREQUEST")
  (make-package "GROUND_AIR_MSGS::STARTMAPPINGREQUEST"))
(unless (find-package "GROUND_AIR_MSGS::STARTMAPPINGRESPONSE")
  (make-package "GROUND_AIR_MSGS::STARTMAPPINGRESPONSE"))

(in-package "ROS")





(defclass ground_air_msgs::StartMappingRequest
  :super ros::object
  :slots (_map_id ))

(defmethod ground_air_msgs::StartMappingRequest
  (:init
   (&key
    ((:map_id __map_id) "")
    )
   (send-super :init)
   (setq _map_id (string __map_id))
   self)
  (:map_id
   (&optional __map_id)
   (if __map_id (setq _map_id __map_id)) _map_id)
  (:serialization-length
   ()
   (+
    ;; string _map_id
    4 (length _map_id)
    ))
  (:serialize
   (&optional strm)
   (let ((s (if strm strm
              (make-string-output-stream (send self :serialization-length)))))
     ;; string _map_id
       (write-long (length _map_id) s) (princ _map_id s)
     ;;
     (if (null strm) (get-output-stream-string s))))
  (:deserialize
   (buf &optional (ptr- 0))
   ;; string _map_id
     (let (n) (setq n (sys::peek buf ptr- :integer)) (incf ptr- 4) (setq _map_id (subseq buf ptr- (+ ptr- n))) (incf ptr- n))
   ;;
   self)
  )

(defclass ground_air_msgs::StartMappingResponse
  :super ros::object
  :slots (_success _message _status ))

(defmethod ground_air_msgs::StartMappingResponse
  (:init
   (&key
    ((:success __success) nil)
    ((:message __message) "")
    ((:status __status) (instance ground_air_msgs::MappingStatus :init))
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
    ;; ground_air_msgs/MappingStatus _status
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
     ;; ground_air_msgs/MappingStatus _status
       (send _status :serialize s)
     ;;
     (if (null strm) (get-output-stream-string s))))
  (:deserialize
   (buf &optional (ptr- 0))
   ;; bool _success
     (setq _success (not (= 0 (sys::peek buf ptr- :char)))) (incf ptr- 1)
   ;; string _message
     (let (n) (setq n (sys::peek buf ptr- :integer)) (incf ptr- 4) (setq _message (subseq buf ptr- (+ ptr- n))) (incf ptr- n))
   ;; ground_air_msgs/MappingStatus _status
     (send _status :deserialize buf ptr-) (incf ptr- (send _status :serialization-length))
   ;;
   self)
  )

(defclass ground_air_msgs::StartMapping
  :super ros::object
  :slots ())

(setf (get ground_air_msgs::StartMapping :md5sum-) "7109d91bb5e43bd6cea8265829bbdff6")
(setf (get ground_air_msgs::StartMapping :datatype-) "ground_air_msgs/StartMapping")
(setf (get ground_air_msgs::StartMapping :request) ground_air_msgs::StartMappingRequest)
(setf (get ground_air_msgs::StartMapping :response) ground_air_msgs::StartMappingResponse)

(defmethod ground_air_msgs::StartMappingRequest
  (:response () (instance ground_air_msgs::StartMappingResponse :init)))

(setf (get ground_air_msgs::StartMappingRequest :md5sum-) "7109d91bb5e43bd6cea8265829bbdff6")
(setf (get ground_air_msgs::StartMappingRequest :datatype-) "ground_air_msgs/StartMappingRequest")
(setf (get ground_air_msgs::StartMappingRequest :definition-)
      "string map_id
---
bool success
string message
ground_air_msgs/MappingStatus status


================================================================================
MSG: ground_air_msgs/MappingStatus
std_msgs/Header header

uint8 IDLE=0
uint8 RECORDING=1
uint8 SAVING=2
uint8 COMPLETE=3
uint8 ERROR=4

uint8 state
string map_id
uint64 point_count
float64 map_area
string message

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

(setf (get ground_air_msgs::StartMappingResponse :md5sum-) "7109d91bb5e43bd6cea8265829bbdff6")
(setf (get ground_air_msgs::StartMappingResponse :datatype-) "ground_air_msgs/StartMappingResponse")
(setf (get ground_air_msgs::StartMappingResponse :definition-)
      "string map_id
---
bool success
string message
ground_air_msgs/MappingStatus status


================================================================================
MSG: ground_air_msgs/MappingStatus
std_msgs/Header header

uint8 IDLE=0
uint8 RECORDING=1
uint8 SAVING=2
uint8 COMPLETE=3
uint8 ERROR=4

uint8 state
string map_id
uint64 point_count
float64 map_area
string message

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



(provide :ground_air_msgs/StartMapping "7109d91bb5e43bd6cea8265829bbdff6")


