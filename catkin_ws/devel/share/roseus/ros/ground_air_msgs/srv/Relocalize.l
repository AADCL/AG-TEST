;; Auto-generated. Do not edit!


(when (boundp 'ground_air_msgs::Relocalize)
  (if (not (find-package "GROUND_AIR_MSGS"))
    (make-package "GROUND_AIR_MSGS"))
  (shadow 'Relocalize (find-package "GROUND_AIR_MSGS")))
(unless (find-package "GROUND_AIR_MSGS::RELOCALIZE")
  (make-package "GROUND_AIR_MSGS::RELOCALIZE"))
(unless (find-package "GROUND_AIR_MSGS::RELOCALIZEREQUEST")
  (make-package "GROUND_AIR_MSGS::RELOCALIZEREQUEST"))
(unless (find-package "GROUND_AIR_MSGS::RELOCALIZERESPONSE")
  (make-package "GROUND_AIR_MSGS::RELOCALIZERESPONSE"))

(in-package "ROS")

(if (not (find-package "GEOMETRY_MSGS"))
  (ros::roseus-add-msgs "geometry_msgs"))


(if (not (find-package "GEOMETRY_MSGS"))
  (ros::roseus-add-msgs "geometry_msgs"))


(defclass ground_air_msgs::RelocalizeRequest
  :super ros::object
  :slots (_use_initial_guess _initial_guess _timeout ))

(defmethod ground_air_msgs::RelocalizeRequest
  (:init
   (&key
    ((:use_initial_guess __use_initial_guess) nil)
    ((:initial_guess __initial_guess) (instance geometry_msgs::PoseWithCovarianceStamped :init))
    ((:timeout __timeout) 0.0)
    )
   (send-super :init)
   (setq _use_initial_guess __use_initial_guess)
   (setq _initial_guess __initial_guess)
   (setq _timeout (float __timeout))
   self)
  (:use_initial_guess
   (&optional (__use_initial_guess :null))
   (if (not (eq __use_initial_guess :null)) (setq _use_initial_guess __use_initial_guess)) _use_initial_guess)
  (:initial_guess
   (&rest __initial_guess)
   (if (keywordp (car __initial_guess))
       (send* _initial_guess __initial_guess)
     (progn
       (if __initial_guess (setq _initial_guess (car __initial_guess)))
       _initial_guess)))
  (:timeout
   (&optional __timeout)
   (if __timeout (setq _timeout __timeout)) _timeout)
  (:serialization-length
   ()
   (+
    ;; bool _use_initial_guess
    1
    ;; geometry_msgs/PoseWithCovarianceStamped _initial_guess
    (send _initial_guess :serialization-length)
    ;; float64 _timeout
    8
    ))
  (:serialize
   (&optional strm)
   (let ((s (if strm strm
              (make-string-output-stream (send self :serialization-length)))))
     ;; bool _use_initial_guess
       (if _use_initial_guess (write-byte -1 s) (write-byte 0 s))
     ;; geometry_msgs/PoseWithCovarianceStamped _initial_guess
       (send _initial_guess :serialize s)
     ;; float64 _timeout
       (sys::poke _timeout (send s :buffer) (send s :count) :double) (incf (stream-count s) 8)
     ;;
     (if (null strm) (get-output-stream-string s))))
  (:deserialize
   (buf &optional (ptr- 0))
   ;; bool _use_initial_guess
     (setq _use_initial_guess (not (= 0 (sys::peek buf ptr- :char)))) (incf ptr- 1)
   ;; geometry_msgs/PoseWithCovarianceStamped _initial_guess
     (send _initial_guess :deserialize buf ptr-) (incf ptr- (send _initial_guess :serialization-length))
   ;; float64 _timeout
     (setq _timeout (sys::peek buf ptr- :double)) (incf ptr- 8)
   ;;
   self)
  )

(defclass ground_air_msgs::RelocalizeResponse
  :super ros::object
  :slots (_success _message _pose _fitness _rmse ))

(defmethod ground_air_msgs::RelocalizeResponse
  (:init
   (&key
    ((:success __success) nil)
    ((:message __message) "")
    ((:pose __pose) (instance geometry_msgs::PoseStamped :init))
    ((:fitness __fitness) 0.0)
    ((:rmse __rmse) 0.0)
    )
   (send-super :init)
   (setq _success __success)
   (setq _message (string __message))
   (setq _pose __pose)
   (setq _fitness (float __fitness))
   (setq _rmse (float __rmse))
   self)
  (:success
   (&optional (__success :null))
   (if (not (eq __success :null)) (setq _success __success)) _success)
  (:message
   (&optional __message)
   (if __message (setq _message __message)) _message)
  (:pose
   (&rest __pose)
   (if (keywordp (car __pose))
       (send* _pose __pose)
     (progn
       (if __pose (setq _pose (car __pose)))
       _pose)))
  (:fitness
   (&optional __fitness)
   (if __fitness (setq _fitness __fitness)) _fitness)
  (:rmse
   (&optional __rmse)
   (if __rmse (setq _rmse __rmse)) _rmse)
  (:serialization-length
   ()
   (+
    ;; bool _success
    1
    ;; string _message
    4 (length _message)
    ;; geometry_msgs/PoseStamped _pose
    (send _pose :serialization-length)
    ;; float64 _fitness
    8
    ;; float64 _rmse
    8
    ))
  (:serialize
   (&optional strm)
   (let ((s (if strm strm
              (make-string-output-stream (send self :serialization-length)))))
     ;; bool _success
       (if _success (write-byte -1 s) (write-byte 0 s))
     ;; string _message
       (write-long (length _message) s) (princ _message s)
     ;; geometry_msgs/PoseStamped _pose
       (send _pose :serialize s)
     ;; float64 _fitness
       (sys::poke _fitness (send s :buffer) (send s :count) :double) (incf (stream-count s) 8)
     ;; float64 _rmse
       (sys::poke _rmse (send s :buffer) (send s :count) :double) (incf (stream-count s) 8)
     ;;
     (if (null strm) (get-output-stream-string s))))
  (:deserialize
   (buf &optional (ptr- 0))
   ;; bool _success
     (setq _success (not (= 0 (sys::peek buf ptr- :char)))) (incf ptr- 1)
   ;; string _message
     (let (n) (setq n (sys::peek buf ptr- :integer)) (incf ptr- 4) (setq _message (subseq buf ptr- (+ ptr- n))) (incf ptr- n))
   ;; geometry_msgs/PoseStamped _pose
     (send _pose :deserialize buf ptr-) (incf ptr- (send _pose :serialization-length))
   ;; float64 _fitness
     (setq _fitness (sys::peek buf ptr- :double)) (incf ptr- 8)
   ;; float64 _rmse
     (setq _rmse (sys::peek buf ptr- :double)) (incf ptr- 8)
   ;;
   self)
  )

(defclass ground_air_msgs::Relocalize
  :super ros::object
  :slots ())

(setf (get ground_air_msgs::Relocalize :md5sum-) "c61b338cbffb25ec319cc4dabf79db05")
(setf (get ground_air_msgs::Relocalize :datatype-) "ground_air_msgs/Relocalize")
(setf (get ground_air_msgs::Relocalize :request) ground_air_msgs::RelocalizeRequest)
(setf (get ground_air_msgs::Relocalize :response) ground_air_msgs::RelocalizeResponse)

(defmethod ground_air_msgs::RelocalizeRequest
  (:response () (instance ground_air_msgs::RelocalizeResponse :init)))

(setf (get ground_air_msgs::RelocalizeRequest :md5sum-) "c61b338cbffb25ec319cc4dabf79db05")
(setf (get ground_air_msgs::RelocalizeRequest :datatype-) "ground_air_msgs/RelocalizeRequest")
(setf (get ground_air_msgs::RelocalizeRequest :definition-)
      "bool use_initial_guess
geometry_msgs/PoseWithCovarianceStamped initial_guess
float64 timeout

================================================================================
MSG: geometry_msgs/PoseWithCovarianceStamped
# This expresses an estimated pose with a reference coordinate frame and timestamp

Header header
PoseWithCovariance pose

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
MSG: geometry_msgs/PoseWithCovariance
# This represents a pose in free space with uncertainty.

Pose pose

# Row-major representation of the 6x6 covariance matrix
# The orientation parameters use a fixed-axis representation.
# In order, the parameters are:
# (x, y, z, rotation about X axis, rotation about Y axis, rotation about Z axis)
float64[36] covariance

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
bool success
string message
geometry_msgs/PoseStamped pose
float64 fitness
float64 rmse


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
")

(setf (get ground_air_msgs::RelocalizeResponse :md5sum-) "c61b338cbffb25ec319cc4dabf79db05")
(setf (get ground_air_msgs::RelocalizeResponse :datatype-) "ground_air_msgs/RelocalizeResponse")
(setf (get ground_air_msgs::RelocalizeResponse :definition-)
      "bool use_initial_guess
geometry_msgs/PoseWithCovarianceStamped initial_guess
float64 timeout

================================================================================
MSG: geometry_msgs/PoseWithCovarianceStamped
# This expresses an estimated pose with a reference coordinate frame and timestamp

Header header
PoseWithCovariance pose

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
MSG: geometry_msgs/PoseWithCovariance
# This represents a pose in free space with uncertainty.

Pose pose

# Row-major representation of the 6x6 covariance matrix
# The orientation parameters use a fixed-axis representation.
# In order, the parameters are:
# (x, y, z, rotation about X axis, rotation about Y axis, rotation about Z axis)
float64[36] covariance

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
bool success
string message
geometry_msgs/PoseStamped pose
float64 fitness
float64 rmse


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
")



(provide :ground_air_msgs/Relocalize "c61b338cbffb25ec319cc4dabf79db05")


