;; Auto-generated. Do not edit!


(when (boundp 'ground_air_msgs::SubmitMission)
  (if (not (find-package "GROUND_AIR_MSGS"))
    (make-package "GROUND_AIR_MSGS"))
  (shadow 'SubmitMission (find-package "GROUND_AIR_MSGS")))
(unless (find-package "GROUND_AIR_MSGS::SUBMITMISSION")
  (make-package "GROUND_AIR_MSGS::SUBMITMISSION"))
(unless (find-package "GROUND_AIR_MSGS::SUBMITMISSIONREQUEST")
  (make-package "GROUND_AIR_MSGS::SUBMITMISSIONREQUEST"))
(unless (find-package "GROUND_AIR_MSGS::SUBMITMISSIONRESPONSE")
  (make-package "GROUND_AIR_MSGS::SUBMITMISSIONRESPONSE"))

(in-package "ROS")

(if (not (find-package "GEOMETRY_MSGS"))
  (ros::roseus-add-msgs "geometry_msgs"))




(defclass ground_air_msgs::SubmitMissionRequest
  :super ros::object
  :slots (_mission_id _goals ))

(defmethod ground_air_msgs::SubmitMissionRequest
  (:init
   (&key
    ((:mission_id __mission_id) "")
    ((:goals __goals) ())
    )
   (send-super :init)
   (setq _mission_id (string __mission_id))
   (setq _goals __goals)
   self)
  (:mission_id
   (&optional __mission_id)
   (if __mission_id (setq _mission_id __mission_id)) _mission_id)
  (:goals
   (&rest __goals)
   (if (keywordp (car __goals))
       (send* _goals __goals)
     (progn
       (if __goals (setq _goals (car __goals)))
       _goals)))
  (:serialization-length
   ()
   (+
    ;; string _mission_id
    4 (length _mission_id)
    ;; geometry_msgs/PoseStamped[] _goals
    (apply #'+ (send-all _goals :serialization-length)) 4
    ))
  (:serialize
   (&optional strm)
   (let ((s (if strm strm
              (make-string-output-stream (send self :serialization-length)))))
     ;; string _mission_id
       (write-long (length _mission_id) s) (princ _mission_id s)
     ;; geometry_msgs/PoseStamped[] _goals
     (write-long (length _goals) s)
     (dolist (elem _goals)
       (send elem :serialize s)
       )
     ;;
     (if (null strm) (get-output-stream-string s))))
  (:deserialize
   (buf &optional (ptr- 0))
   ;; string _mission_id
     (let (n) (setq n (sys::peek buf ptr- :integer)) (incf ptr- 4) (setq _mission_id (subseq buf ptr- (+ ptr- n))) (incf ptr- n))
   ;; geometry_msgs/PoseStamped[] _goals
   (let (n)
     (setq n (sys::peek buf ptr- :integer)) (incf ptr- 4)
     (setq _goals (let (r) (dotimes (i n) (push (instance geometry_msgs::PoseStamped :init) r)) r))
     (dolist (elem- _goals)
     (send elem- :deserialize buf ptr-) (incf ptr- (send elem- :serialization-length))
     ))
   ;;
   self)
  )

(defclass ground_air_msgs::SubmitMissionResponse
  :super ros::object
  :slots (_accepted _message _goal_count ))

(defmethod ground_air_msgs::SubmitMissionResponse
  (:init
   (&key
    ((:accepted __accepted) nil)
    ((:message __message) "")
    ((:goal_count __goal_count) 0)
    )
   (send-super :init)
   (setq _accepted __accepted)
   (setq _message (string __message))
   (setq _goal_count (round __goal_count))
   self)
  (:accepted
   (&optional (__accepted :null))
   (if (not (eq __accepted :null)) (setq _accepted __accepted)) _accepted)
  (:message
   (&optional __message)
   (if __message (setq _message __message)) _message)
  (:goal_count
   (&optional __goal_count)
   (if __goal_count (setq _goal_count __goal_count)) _goal_count)
  (:serialization-length
   ()
   (+
    ;; bool _accepted
    1
    ;; string _message
    4 (length _message)
    ;; uint32 _goal_count
    4
    ))
  (:serialize
   (&optional strm)
   (let ((s (if strm strm
              (make-string-output-stream (send self :serialization-length)))))
     ;; bool _accepted
       (if _accepted (write-byte -1 s) (write-byte 0 s))
     ;; string _message
       (write-long (length _message) s) (princ _message s)
     ;; uint32 _goal_count
       (write-long _goal_count s)
     ;;
     (if (null strm) (get-output-stream-string s))))
  (:deserialize
   (buf &optional (ptr- 0))
   ;; bool _accepted
     (setq _accepted (not (= 0 (sys::peek buf ptr- :char)))) (incf ptr- 1)
   ;; string _message
     (let (n) (setq n (sys::peek buf ptr- :integer)) (incf ptr- 4) (setq _message (subseq buf ptr- (+ ptr- n))) (incf ptr- n))
   ;; uint32 _goal_count
     (setq _goal_count (sys::peek buf ptr- :integer)) (incf ptr- 4)
   ;;
   self)
  )

(defclass ground_air_msgs::SubmitMission
  :super ros::object
  :slots ())

(setf (get ground_air_msgs::SubmitMission :md5sum-) "0b7be7b794768c0b19086f237b7f7bf0")
(setf (get ground_air_msgs::SubmitMission :datatype-) "ground_air_msgs/SubmitMission")
(setf (get ground_air_msgs::SubmitMission :request) ground_air_msgs::SubmitMissionRequest)
(setf (get ground_air_msgs::SubmitMission :response) ground_air_msgs::SubmitMissionResponse)

(defmethod ground_air_msgs::SubmitMissionRequest
  (:response () (instance ground_air_msgs::SubmitMissionResponse :init)))

(setf (get ground_air_msgs::SubmitMissionRequest :md5sum-) "0b7be7b794768c0b19086f237b7f7bf0")
(setf (get ground_air_msgs::SubmitMissionRequest :datatype-) "ground_air_msgs/SubmitMissionRequest")
(setf (get ground_air_msgs::SubmitMissionRequest :definition-)
      "string mission_id
geometry_msgs/PoseStamped[] goals

================================================================================
MSG: geometry_msgs/PoseStamped
# A Pose with reference coordinate frame and timestamp
Header header
Pose pose

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

================================================================================
MSG: geometry_msgs/Pose
# A representation of pose in free space, composed of position and orientation. 
Point position
Quaternion orientation

================================================================================
MSG: geometry_msgs/Point
# This contains the position of a point in free space
float64 x
float64 y
float64 z

================================================================================
MSG: geometry_msgs/Quaternion
# This represents an orientation in free space in quaternion form.

float64 x
float64 y
float64 z
float64 w
---
bool accepted
string message
uint32 goal_count

")

(setf (get ground_air_msgs::SubmitMissionResponse :md5sum-) "0b7be7b794768c0b19086f237b7f7bf0")
(setf (get ground_air_msgs::SubmitMissionResponse :datatype-) "ground_air_msgs/SubmitMissionResponse")
(setf (get ground_air_msgs::SubmitMissionResponse :definition-)
      "string mission_id
geometry_msgs/PoseStamped[] goals

================================================================================
MSG: geometry_msgs/PoseStamped
# A Pose with reference coordinate frame and timestamp
Header header
Pose pose

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

================================================================================
MSG: geometry_msgs/Pose
# A representation of pose in free space, composed of position and orientation. 
Point position
Quaternion orientation

================================================================================
MSG: geometry_msgs/Point
# This contains the position of a point in free space
float64 x
float64 y
float64 z

================================================================================
MSG: geometry_msgs/Quaternion
# This represents an orientation in free space in quaternion form.

float64 x
float64 y
float64 z
float64 w
---
bool accepted
string message
uint32 goal_count

")



(provide :ground_air_msgs/SubmitMission "0b7be7b794768c0b19086f237b7f7bf0")


