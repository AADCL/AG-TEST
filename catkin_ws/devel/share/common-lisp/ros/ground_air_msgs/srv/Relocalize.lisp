; Auto-generated. Do not edit!


(cl:in-package ground_air_msgs-srv)


;//! \htmlinclude Relocalize-request.msg.html

(cl:defclass <Relocalize-request> (roslisp-msg-protocol:ros-message)
  ((use_initial_guess
    :reader use_initial_guess
    :initarg :use_initial_guess
    :type cl:boolean
    :initform cl:nil)
   (initial_guess
    :reader initial_guess
    :initarg :initial_guess
    :type geometry_msgs-msg:PoseWithCovarianceStamped
    :initform (cl:make-instance 'geometry_msgs-msg:PoseWithCovarianceStamped))
   (timeout
    :reader timeout
    :initarg :timeout
    :type cl:float
    :initform 0.0))
)

(cl:defclass Relocalize-request (<Relocalize-request>)
  ())

(cl:defmethod cl:initialize-instance :after ((m <Relocalize-request>) cl:&rest args)
  (cl:declare (cl:ignorable args))
  (cl:unless (cl:typep m 'Relocalize-request)
    (roslisp-msg-protocol:msg-deprecation-warning "using old message class name ground_air_msgs-srv:<Relocalize-request> is deprecated: use ground_air_msgs-srv:Relocalize-request instead.")))

(cl:ensure-generic-function 'use_initial_guess-val :lambda-list '(m))
(cl:defmethod use_initial_guess-val ((m <Relocalize-request>))
  (roslisp-msg-protocol:msg-deprecation-warning "Using old-style slot reader ground_air_msgs-srv:use_initial_guess-val is deprecated.  Use ground_air_msgs-srv:use_initial_guess instead.")
  (use_initial_guess m))

(cl:ensure-generic-function 'initial_guess-val :lambda-list '(m))
(cl:defmethod initial_guess-val ((m <Relocalize-request>))
  (roslisp-msg-protocol:msg-deprecation-warning "Using old-style slot reader ground_air_msgs-srv:initial_guess-val is deprecated.  Use ground_air_msgs-srv:initial_guess instead.")
  (initial_guess m))

(cl:ensure-generic-function 'timeout-val :lambda-list '(m))
(cl:defmethod timeout-val ((m <Relocalize-request>))
  (roslisp-msg-protocol:msg-deprecation-warning "Using old-style slot reader ground_air_msgs-srv:timeout-val is deprecated.  Use ground_air_msgs-srv:timeout instead.")
  (timeout m))
(cl:defmethod roslisp-msg-protocol:serialize ((msg <Relocalize-request>) ostream)
  "Serializes a message object of type '<Relocalize-request>"
  (cl:write-byte (cl:ldb (cl:byte 8 0) (cl:if (cl:slot-value msg 'use_initial_guess) 1 0)) ostream)
  (roslisp-msg-protocol:serialize (cl:slot-value msg 'initial_guess) ostream)
  (cl:let ((bits (roslisp-utils:encode-double-float-bits (cl:slot-value msg 'timeout))))
    (cl:write-byte (cl:ldb (cl:byte 8 0) bits) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 8) bits) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 16) bits) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 24) bits) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 32) bits) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 40) bits) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 48) bits) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 56) bits) ostream))
)
(cl:defmethod roslisp-msg-protocol:deserialize ((msg <Relocalize-request>) istream)
  "Deserializes a message object of type '<Relocalize-request>"
    (cl:setf (cl:slot-value msg 'use_initial_guess) (cl:not (cl:zerop (cl:read-byte istream))))
  (roslisp-msg-protocol:deserialize (cl:slot-value msg 'initial_guess) istream)
    (cl:let ((bits 0))
      (cl:setf (cl:ldb (cl:byte 8 0) bits) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 8) bits) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 16) bits) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 24) bits) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 32) bits) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 40) bits) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 48) bits) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 56) bits) (cl:read-byte istream))
    (cl:setf (cl:slot-value msg 'timeout) (roslisp-utils:decode-double-float-bits bits)))
  msg
)
(cl:defmethod roslisp-msg-protocol:ros-datatype ((msg (cl:eql '<Relocalize-request>)))
  "Returns string type for a service object of type '<Relocalize-request>"
  "ground_air_msgs/RelocalizeRequest")
(cl:defmethod roslisp-msg-protocol:ros-datatype ((msg (cl:eql 'Relocalize-request)))
  "Returns string type for a service object of type 'Relocalize-request"
  "ground_air_msgs/RelocalizeRequest")
(cl:defmethod roslisp-msg-protocol:md5sum ((type (cl:eql '<Relocalize-request>)))
  "Returns md5sum for a message object of type '<Relocalize-request>"
  "c61b338cbffb25ec319cc4dabf79db05")
(cl:defmethod roslisp-msg-protocol:md5sum ((type (cl:eql 'Relocalize-request)))
  "Returns md5sum for a message object of type 'Relocalize-request"
  "c61b338cbffb25ec319cc4dabf79db05")
(cl:defmethod roslisp-msg-protocol:message-definition ((type (cl:eql '<Relocalize-request>)))
  "Returns full string definition for message of type '<Relocalize-request>"
  (cl:format cl:nil "bool use_initial_guess~%geometry_msgs/PoseWithCovarianceStamped initial_guess~%float64 timeout~%~%================================================================================~%MSG: geometry_msgs/PoseWithCovarianceStamped~%# This expresses an estimated pose with a reference coordinate frame and timestamp~%~%Header header~%PoseWithCovariance pose~%~%================================================================================~%MSG: std_msgs/Header~%# Standard metadata for higher-level stamped data types.~%# This is generally used to communicate timestamped data ~%# in a particular coordinate frame.~%# ~%# sequence ID: consecutively increasing ID ~%uint32 seq~%#Two-integer timestamp that is expressed as:~%# * stamp.sec: seconds (stamp_secs) since epoch (in Python the variable is called 'secs')~%# * stamp.nsec: nanoseconds since stamp_secs (in Python the variable is called 'nsecs')~%# time-handling sugar is provided by the client library~%time stamp~%#Frame this data is associated with~%string frame_id~%~%================================================================================~%MSG: geometry_msgs/PoseWithCovariance~%# This represents a pose in free space with uncertainty.~%~%Pose pose~%~%# Row-major representation of the 6x6 covariance matrix~%# The orientation parameters use a fixed-axis representation.~%# In order, the parameters are:~%# (x, y, z, rotation about X axis, rotation about Y axis, rotation about Z axis)~%float64[36] covariance~%~%================================================================================~%MSG: geometry_msgs/Pose~%# A representation of pose in free space, composed of position and orientation. ~%Point position~%Quaternion orientation~%~%================================================================================~%MSG: geometry_msgs/Point~%# This contains the position of a point in free space~%float64 x~%float64 y~%float64 z~%~%================================================================================~%MSG: geometry_msgs/Quaternion~%# This represents an orientation in free space in quaternion form.~%~%float64 x~%float64 y~%float64 z~%float64 w~%~%~%"))
(cl:defmethod roslisp-msg-protocol:message-definition ((type (cl:eql 'Relocalize-request)))
  "Returns full string definition for message of type 'Relocalize-request"
  (cl:format cl:nil "bool use_initial_guess~%geometry_msgs/PoseWithCovarianceStamped initial_guess~%float64 timeout~%~%================================================================================~%MSG: geometry_msgs/PoseWithCovarianceStamped~%# This expresses an estimated pose with a reference coordinate frame and timestamp~%~%Header header~%PoseWithCovariance pose~%~%================================================================================~%MSG: std_msgs/Header~%# Standard metadata for higher-level stamped data types.~%# This is generally used to communicate timestamped data ~%# in a particular coordinate frame.~%# ~%# sequence ID: consecutively increasing ID ~%uint32 seq~%#Two-integer timestamp that is expressed as:~%# * stamp.sec: seconds (stamp_secs) since epoch (in Python the variable is called 'secs')~%# * stamp.nsec: nanoseconds since stamp_secs (in Python the variable is called 'nsecs')~%# time-handling sugar is provided by the client library~%time stamp~%#Frame this data is associated with~%string frame_id~%~%================================================================================~%MSG: geometry_msgs/PoseWithCovariance~%# This represents a pose in free space with uncertainty.~%~%Pose pose~%~%# Row-major representation of the 6x6 covariance matrix~%# The orientation parameters use a fixed-axis representation.~%# In order, the parameters are:~%# (x, y, z, rotation about X axis, rotation about Y axis, rotation about Z axis)~%float64[36] covariance~%~%================================================================================~%MSG: geometry_msgs/Pose~%# A representation of pose in free space, composed of position and orientation. ~%Point position~%Quaternion orientation~%~%================================================================================~%MSG: geometry_msgs/Point~%# This contains the position of a point in free space~%float64 x~%float64 y~%float64 z~%~%================================================================================~%MSG: geometry_msgs/Quaternion~%# This represents an orientation in free space in quaternion form.~%~%float64 x~%float64 y~%float64 z~%float64 w~%~%~%"))
(cl:defmethod roslisp-msg-protocol:serialization-length ((msg <Relocalize-request>))
  (cl:+ 0
     1
     (roslisp-msg-protocol:serialization-length (cl:slot-value msg 'initial_guess))
     8
))
(cl:defmethod roslisp-msg-protocol:ros-message-to-list ((msg <Relocalize-request>))
  "Converts a ROS message object to a list"
  (cl:list 'Relocalize-request
    (cl:cons ':use_initial_guess (use_initial_guess msg))
    (cl:cons ':initial_guess (initial_guess msg))
    (cl:cons ':timeout (timeout msg))
))
;//! \htmlinclude Relocalize-response.msg.html

(cl:defclass <Relocalize-response> (roslisp-msg-protocol:ros-message)
  ((success
    :reader success
    :initarg :success
    :type cl:boolean
    :initform cl:nil)
   (message
    :reader message
    :initarg :message
    :type cl:string
    :initform "")
   (pose
    :reader pose
    :initarg :pose
    :type geometry_msgs-msg:PoseStamped
    :initform (cl:make-instance 'geometry_msgs-msg:PoseStamped))
   (fitness
    :reader fitness
    :initarg :fitness
    :type cl:float
    :initform 0.0)
   (rmse
    :reader rmse
    :initarg :rmse
    :type cl:float
    :initform 0.0))
)

(cl:defclass Relocalize-response (<Relocalize-response>)
  ())

(cl:defmethod cl:initialize-instance :after ((m <Relocalize-response>) cl:&rest args)
  (cl:declare (cl:ignorable args))
  (cl:unless (cl:typep m 'Relocalize-response)
    (roslisp-msg-protocol:msg-deprecation-warning "using old message class name ground_air_msgs-srv:<Relocalize-response> is deprecated: use ground_air_msgs-srv:Relocalize-response instead.")))

(cl:ensure-generic-function 'success-val :lambda-list '(m))
(cl:defmethod success-val ((m <Relocalize-response>))
  (roslisp-msg-protocol:msg-deprecation-warning "Using old-style slot reader ground_air_msgs-srv:success-val is deprecated.  Use ground_air_msgs-srv:success instead.")
  (success m))

(cl:ensure-generic-function 'message-val :lambda-list '(m))
(cl:defmethod message-val ((m <Relocalize-response>))
  (roslisp-msg-protocol:msg-deprecation-warning "Using old-style slot reader ground_air_msgs-srv:message-val is deprecated.  Use ground_air_msgs-srv:message instead.")
  (message m))

(cl:ensure-generic-function 'pose-val :lambda-list '(m))
(cl:defmethod pose-val ((m <Relocalize-response>))
  (roslisp-msg-protocol:msg-deprecation-warning "Using old-style slot reader ground_air_msgs-srv:pose-val is deprecated.  Use ground_air_msgs-srv:pose instead.")
  (pose m))

(cl:ensure-generic-function 'fitness-val :lambda-list '(m))
(cl:defmethod fitness-val ((m <Relocalize-response>))
  (roslisp-msg-protocol:msg-deprecation-warning "Using old-style slot reader ground_air_msgs-srv:fitness-val is deprecated.  Use ground_air_msgs-srv:fitness instead.")
  (fitness m))

(cl:ensure-generic-function 'rmse-val :lambda-list '(m))
(cl:defmethod rmse-val ((m <Relocalize-response>))
  (roslisp-msg-protocol:msg-deprecation-warning "Using old-style slot reader ground_air_msgs-srv:rmse-val is deprecated.  Use ground_air_msgs-srv:rmse instead.")
  (rmse m))
(cl:defmethod roslisp-msg-protocol:serialize ((msg <Relocalize-response>) ostream)
  "Serializes a message object of type '<Relocalize-response>"
  (cl:write-byte (cl:ldb (cl:byte 8 0) (cl:if (cl:slot-value msg 'success) 1 0)) ostream)
  (cl:let ((__ros_str_len (cl:length (cl:slot-value msg 'message))))
    (cl:write-byte (cl:ldb (cl:byte 8 0) __ros_str_len) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 8) __ros_str_len) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 16) __ros_str_len) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 24) __ros_str_len) ostream))
  (cl:map cl:nil #'(cl:lambda (c) (cl:write-byte (cl:char-code c) ostream)) (cl:slot-value msg 'message))
  (roslisp-msg-protocol:serialize (cl:slot-value msg 'pose) ostream)
  (cl:let ((bits (roslisp-utils:encode-double-float-bits (cl:slot-value msg 'fitness))))
    (cl:write-byte (cl:ldb (cl:byte 8 0) bits) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 8) bits) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 16) bits) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 24) bits) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 32) bits) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 40) bits) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 48) bits) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 56) bits) ostream))
  (cl:let ((bits (roslisp-utils:encode-double-float-bits (cl:slot-value msg 'rmse))))
    (cl:write-byte (cl:ldb (cl:byte 8 0) bits) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 8) bits) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 16) bits) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 24) bits) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 32) bits) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 40) bits) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 48) bits) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 56) bits) ostream))
)
(cl:defmethod roslisp-msg-protocol:deserialize ((msg <Relocalize-response>) istream)
  "Deserializes a message object of type '<Relocalize-response>"
    (cl:setf (cl:slot-value msg 'success) (cl:not (cl:zerop (cl:read-byte istream))))
    (cl:let ((__ros_str_len 0))
      (cl:setf (cl:ldb (cl:byte 8 0) __ros_str_len) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 8) __ros_str_len) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 16) __ros_str_len) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 24) __ros_str_len) (cl:read-byte istream))
      (cl:setf (cl:slot-value msg 'message) (cl:make-string __ros_str_len))
      (cl:dotimes (__ros_str_idx __ros_str_len msg)
        (cl:setf (cl:char (cl:slot-value msg 'message) __ros_str_idx) (cl:code-char (cl:read-byte istream)))))
  (roslisp-msg-protocol:deserialize (cl:slot-value msg 'pose) istream)
    (cl:let ((bits 0))
      (cl:setf (cl:ldb (cl:byte 8 0) bits) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 8) bits) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 16) bits) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 24) bits) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 32) bits) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 40) bits) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 48) bits) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 56) bits) (cl:read-byte istream))
    (cl:setf (cl:slot-value msg 'fitness) (roslisp-utils:decode-double-float-bits bits)))
    (cl:let ((bits 0))
      (cl:setf (cl:ldb (cl:byte 8 0) bits) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 8) bits) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 16) bits) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 24) bits) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 32) bits) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 40) bits) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 48) bits) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 56) bits) (cl:read-byte istream))
    (cl:setf (cl:slot-value msg 'rmse) (roslisp-utils:decode-double-float-bits bits)))
  msg
)
(cl:defmethod roslisp-msg-protocol:ros-datatype ((msg (cl:eql '<Relocalize-response>)))
  "Returns string type for a service object of type '<Relocalize-response>"
  "ground_air_msgs/RelocalizeResponse")
(cl:defmethod roslisp-msg-protocol:ros-datatype ((msg (cl:eql 'Relocalize-response)))
  "Returns string type for a service object of type 'Relocalize-response"
  "ground_air_msgs/RelocalizeResponse")
(cl:defmethod roslisp-msg-protocol:md5sum ((type (cl:eql '<Relocalize-response>)))
  "Returns md5sum for a message object of type '<Relocalize-response>"
  "c61b338cbffb25ec319cc4dabf79db05")
(cl:defmethod roslisp-msg-protocol:md5sum ((type (cl:eql 'Relocalize-response)))
  "Returns md5sum for a message object of type 'Relocalize-response"
  "c61b338cbffb25ec319cc4dabf79db05")
(cl:defmethod roslisp-msg-protocol:message-definition ((type (cl:eql '<Relocalize-response>)))
  "Returns full string definition for message of type '<Relocalize-response>"
  (cl:format cl:nil "bool success~%string message~%geometry_msgs/PoseStamped pose~%float64 fitness~%float64 rmse~%~%~%================================================================================~%MSG: geometry_msgs/PoseStamped~%# A Pose with reference coordinate frame and timestamp~%Header header~%Pose pose~%~%================================================================================~%MSG: std_msgs/Header~%# Standard metadata for higher-level stamped data types.~%# This is generally used to communicate timestamped data ~%# in a particular coordinate frame.~%# ~%# sequence ID: consecutively increasing ID ~%uint32 seq~%#Two-integer timestamp that is expressed as:~%# * stamp.sec: seconds (stamp_secs) since epoch (in Python the variable is called 'secs')~%# * stamp.nsec: nanoseconds since stamp_secs (in Python the variable is called 'nsecs')~%# time-handling sugar is provided by the client library~%time stamp~%#Frame this data is associated with~%string frame_id~%~%================================================================================~%MSG: geometry_msgs/Pose~%# A representation of pose in free space, composed of position and orientation. ~%Point position~%Quaternion orientation~%~%================================================================================~%MSG: geometry_msgs/Point~%# This contains the position of a point in free space~%float64 x~%float64 y~%float64 z~%~%================================================================================~%MSG: geometry_msgs/Quaternion~%# This represents an orientation in free space in quaternion form.~%~%float64 x~%float64 y~%float64 z~%float64 w~%~%~%"))
(cl:defmethod roslisp-msg-protocol:message-definition ((type (cl:eql 'Relocalize-response)))
  "Returns full string definition for message of type 'Relocalize-response"
  (cl:format cl:nil "bool success~%string message~%geometry_msgs/PoseStamped pose~%float64 fitness~%float64 rmse~%~%~%================================================================================~%MSG: geometry_msgs/PoseStamped~%# A Pose with reference coordinate frame and timestamp~%Header header~%Pose pose~%~%================================================================================~%MSG: std_msgs/Header~%# Standard metadata for higher-level stamped data types.~%# This is generally used to communicate timestamped data ~%# in a particular coordinate frame.~%# ~%# sequence ID: consecutively increasing ID ~%uint32 seq~%#Two-integer timestamp that is expressed as:~%# * stamp.sec: seconds (stamp_secs) since epoch (in Python the variable is called 'secs')~%# * stamp.nsec: nanoseconds since stamp_secs (in Python the variable is called 'nsecs')~%# time-handling sugar is provided by the client library~%time stamp~%#Frame this data is associated with~%string frame_id~%~%================================================================================~%MSG: geometry_msgs/Pose~%# A representation of pose in free space, composed of position and orientation. ~%Point position~%Quaternion orientation~%~%================================================================================~%MSG: geometry_msgs/Point~%# This contains the position of a point in free space~%float64 x~%float64 y~%float64 z~%~%================================================================================~%MSG: geometry_msgs/Quaternion~%# This represents an orientation in free space in quaternion form.~%~%float64 x~%float64 y~%float64 z~%float64 w~%~%~%"))
(cl:defmethod roslisp-msg-protocol:serialization-length ((msg <Relocalize-response>))
  (cl:+ 0
     1
     4 (cl:length (cl:slot-value msg 'message))
     (roslisp-msg-protocol:serialization-length (cl:slot-value msg 'pose))
     8
     8
))
(cl:defmethod roslisp-msg-protocol:ros-message-to-list ((msg <Relocalize-response>))
  "Converts a ROS message object to a list"
  (cl:list 'Relocalize-response
    (cl:cons ':success (success msg))
    (cl:cons ':message (message msg))
    (cl:cons ':pose (pose msg))
    (cl:cons ':fitness (fitness msg))
    (cl:cons ':rmse (rmse msg))
))
(cl:defmethod roslisp-msg-protocol:service-request-type ((msg (cl:eql 'Relocalize)))
  'Relocalize-request)
(cl:defmethod roslisp-msg-protocol:service-response-type ((msg (cl:eql 'Relocalize)))
  'Relocalize-response)
(cl:defmethod roslisp-msg-protocol:ros-datatype ((msg (cl:eql 'Relocalize)))
  "Returns string type for a service object of type '<Relocalize>"
  "ground_air_msgs/Relocalize")