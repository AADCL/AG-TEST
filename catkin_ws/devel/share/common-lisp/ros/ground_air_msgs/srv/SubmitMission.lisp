; Auto-generated. Do not edit!


(cl:in-package ground_air_msgs-srv)


;//! \htmlinclude SubmitMission-request.msg.html

(cl:defclass <SubmitMission-request> (roslisp-msg-protocol:ros-message)
  ((mission_id
    :reader mission_id
    :initarg :mission_id
    :type cl:string
    :initform "")
   (goals
    :reader goals
    :initarg :goals
    :type (cl:vector geometry_msgs-msg:PoseStamped)
   :initform (cl:make-array 0 :element-type 'geometry_msgs-msg:PoseStamped :initial-element (cl:make-instance 'geometry_msgs-msg:PoseStamped))))
)

(cl:defclass SubmitMission-request (<SubmitMission-request>)
  ())

(cl:defmethod cl:initialize-instance :after ((m <SubmitMission-request>) cl:&rest args)
  (cl:declare (cl:ignorable args))
  (cl:unless (cl:typep m 'SubmitMission-request)
    (roslisp-msg-protocol:msg-deprecation-warning "using old message class name ground_air_msgs-srv:<SubmitMission-request> is deprecated: use ground_air_msgs-srv:SubmitMission-request instead.")))

(cl:ensure-generic-function 'mission_id-val :lambda-list '(m))
(cl:defmethod mission_id-val ((m <SubmitMission-request>))
  (roslisp-msg-protocol:msg-deprecation-warning "Using old-style slot reader ground_air_msgs-srv:mission_id-val is deprecated.  Use ground_air_msgs-srv:mission_id instead.")
  (mission_id m))

(cl:ensure-generic-function 'goals-val :lambda-list '(m))
(cl:defmethod goals-val ((m <SubmitMission-request>))
  (roslisp-msg-protocol:msg-deprecation-warning "Using old-style slot reader ground_air_msgs-srv:goals-val is deprecated.  Use ground_air_msgs-srv:goals instead.")
  (goals m))
(cl:defmethod roslisp-msg-protocol:serialize ((msg <SubmitMission-request>) ostream)
  "Serializes a message object of type '<SubmitMission-request>"
  (cl:let ((__ros_str_len (cl:length (cl:slot-value msg 'mission_id))))
    (cl:write-byte (cl:ldb (cl:byte 8 0) __ros_str_len) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 8) __ros_str_len) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 16) __ros_str_len) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 24) __ros_str_len) ostream))
  (cl:map cl:nil #'(cl:lambda (c) (cl:write-byte (cl:char-code c) ostream)) (cl:slot-value msg 'mission_id))
  (cl:let ((__ros_arr_len (cl:length (cl:slot-value msg 'goals))))
    (cl:write-byte (cl:ldb (cl:byte 8 0) __ros_arr_len) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 8) __ros_arr_len) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 16) __ros_arr_len) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 24) __ros_arr_len) ostream))
  (cl:map cl:nil #'(cl:lambda (ele) (roslisp-msg-protocol:serialize ele ostream))
   (cl:slot-value msg 'goals))
)
(cl:defmethod roslisp-msg-protocol:deserialize ((msg <SubmitMission-request>) istream)
  "Deserializes a message object of type '<SubmitMission-request>"
    (cl:let ((__ros_str_len 0))
      (cl:setf (cl:ldb (cl:byte 8 0) __ros_str_len) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 8) __ros_str_len) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 16) __ros_str_len) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 24) __ros_str_len) (cl:read-byte istream))
      (cl:setf (cl:slot-value msg 'mission_id) (cl:make-string __ros_str_len))
      (cl:dotimes (__ros_str_idx __ros_str_len msg)
        (cl:setf (cl:char (cl:slot-value msg 'mission_id) __ros_str_idx) (cl:code-char (cl:read-byte istream)))))
  (cl:let ((__ros_arr_len 0))
    (cl:setf (cl:ldb (cl:byte 8 0) __ros_arr_len) (cl:read-byte istream))
    (cl:setf (cl:ldb (cl:byte 8 8) __ros_arr_len) (cl:read-byte istream))
    (cl:setf (cl:ldb (cl:byte 8 16) __ros_arr_len) (cl:read-byte istream))
    (cl:setf (cl:ldb (cl:byte 8 24) __ros_arr_len) (cl:read-byte istream))
  (cl:setf (cl:slot-value msg 'goals) (cl:make-array __ros_arr_len))
  (cl:let ((vals (cl:slot-value msg 'goals)))
    (cl:dotimes (i __ros_arr_len)
    (cl:setf (cl:aref vals i) (cl:make-instance 'geometry_msgs-msg:PoseStamped))
  (roslisp-msg-protocol:deserialize (cl:aref vals i) istream))))
  msg
)
(cl:defmethod roslisp-msg-protocol:ros-datatype ((msg (cl:eql '<SubmitMission-request>)))
  "Returns string type for a service object of type '<SubmitMission-request>"
  "ground_air_msgs/SubmitMissionRequest")
(cl:defmethod roslisp-msg-protocol:ros-datatype ((msg (cl:eql 'SubmitMission-request)))
  "Returns string type for a service object of type 'SubmitMission-request"
  "ground_air_msgs/SubmitMissionRequest")
(cl:defmethod roslisp-msg-protocol:md5sum ((type (cl:eql '<SubmitMission-request>)))
  "Returns md5sum for a message object of type '<SubmitMission-request>"
  "0b7be7b794768c0b19086f237b7f7bf0")
(cl:defmethod roslisp-msg-protocol:md5sum ((type (cl:eql 'SubmitMission-request)))
  "Returns md5sum for a message object of type 'SubmitMission-request"
  "0b7be7b794768c0b19086f237b7f7bf0")
(cl:defmethod roslisp-msg-protocol:message-definition ((type (cl:eql '<SubmitMission-request>)))
  "Returns full string definition for message of type '<SubmitMission-request>"
  (cl:format cl:nil "string mission_id~%geometry_msgs/PoseStamped[] goals~%~%================================================================================~%MSG: geometry_msgs/PoseStamped~%# A Pose with reference coordinate frame and timestamp~%Header header~%Pose pose~%~%================================================================================~%MSG: std_msgs/Header~%# Standard metadata for higher-level stamped data types.~%# This is generally used to communicate timestamped data ~%# in a particular coordinate frame.~%# ~%# sequence ID: consecutively increasing ID ~%uint32 seq~%#Two-integer timestamp that is expressed as:~%# * stamp.sec: seconds (stamp_secs) since epoch (in Python the variable is called 'secs')~%# * stamp.nsec: nanoseconds since stamp_secs (in Python the variable is called 'nsecs')~%# time-handling sugar is provided by the client library~%time stamp~%#Frame this data is associated with~%string frame_id~%~%================================================================================~%MSG: geometry_msgs/Pose~%# A representation of pose in free space, composed of position and orientation. ~%Point position~%Quaternion orientation~%~%================================================================================~%MSG: geometry_msgs/Point~%# This contains the position of a point in free space~%float64 x~%float64 y~%float64 z~%~%================================================================================~%MSG: geometry_msgs/Quaternion~%# This represents an orientation in free space in quaternion form.~%~%float64 x~%float64 y~%float64 z~%float64 w~%~%~%"))
(cl:defmethod roslisp-msg-protocol:message-definition ((type (cl:eql 'SubmitMission-request)))
  "Returns full string definition for message of type 'SubmitMission-request"
  (cl:format cl:nil "string mission_id~%geometry_msgs/PoseStamped[] goals~%~%================================================================================~%MSG: geometry_msgs/PoseStamped~%# A Pose with reference coordinate frame and timestamp~%Header header~%Pose pose~%~%================================================================================~%MSG: std_msgs/Header~%# Standard metadata for higher-level stamped data types.~%# This is generally used to communicate timestamped data ~%# in a particular coordinate frame.~%# ~%# sequence ID: consecutively increasing ID ~%uint32 seq~%#Two-integer timestamp that is expressed as:~%# * stamp.sec: seconds (stamp_secs) since epoch (in Python the variable is called 'secs')~%# * stamp.nsec: nanoseconds since stamp_secs (in Python the variable is called 'nsecs')~%# time-handling sugar is provided by the client library~%time stamp~%#Frame this data is associated with~%string frame_id~%~%================================================================================~%MSG: geometry_msgs/Pose~%# A representation of pose in free space, composed of position and orientation. ~%Point position~%Quaternion orientation~%~%================================================================================~%MSG: geometry_msgs/Point~%# This contains the position of a point in free space~%float64 x~%float64 y~%float64 z~%~%================================================================================~%MSG: geometry_msgs/Quaternion~%# This represents an orientation in free space in quaternion form.~%~%float64 x~%float64 y~%float64 z~%float64 w~%~%~%"))
(cl:defmethod roslisp-msg-protocol:serialization-length ((msg <SubmitMission-request>))
  (cl:+ 0
     4 (cl:length (cl:slot-value msg 'mission_id))
     4 (cl:reduce #'cl:+ (cl:slot-value msg 'goals) :key #'(cl:lambda (ele) (cl:declare (cl:ignorable ele)) (cl:+ (roslisp-msg-protocol:serialization-length ele))))
))
(cl:defmethod roslisp-msg-protocol:ros-message-to-list ((msg <SubmitMission-request>))
  "Converts a ROS message object to a list"
  (cl:list 'SubmitMission-request
    (cl:cons ':mission_id (mission_id msg))
    (cl:cons ':goals (goals msg))
))
;//! \htmlinclude SubmitMission-response.msg.html

(cl:defclass <SubmitMission-response> (roslisp-msg-protocol:ros-message)
  ((accepted
    :reader accepted
    :initarg :accepted
    :type cl:boolean
    :initform cl:nil)
   (message
    :reader message
    :initarg :message
    :type cl:string
    :initform "")
   (goal_count
    :reader goal_count
    :initarg :goal_count
    :type cl:integer
    :initform 0))
)

(cl:defclass SubmitMission-response (<SubmitMission-response>)
  ())

(cl:defmethod cl:initialize-instance :after ((m <SubmitMission-response>) cl:&rest args)
  (cl:declare (cl:ignorable args))
  (cl:unless (cl:typep m 'SubmitMission-response)
    (roslisp-msg-protocol:msg-deprecation-warning "using old message class name ground_air_msgs-srv:<SubmitMission-response> is deprecated: use ground_air_msgs-srv:SubmitMission-response instead.")))

(cl:ensure-generic-function 'accepted-val :lambda-list '(m))
(cl:defmethod accepted-val ((m <SubmitMission-response>))
  (roslisp-msg-protocol:msg-deprecation-warning "Using old-style slot reader ground_air_msgs-srv:accepted-val is deprecated.  Use ground_air_msgs-srv:accepted instead.")
  (accepted m))

(cl:ensure-generic-function 'message-val :lambda-list '(m))
(cl:defmethod message-val ((m <SubmitMission-response>))
  (roslisp-msg-protocol:msg-deprecation-warning "Using old-style slot reader ground_air_msgs-srv:message-val is deprecated.  Use ground_air_msgs-srv:message instead.")
  (message m))

(cl:ensure-generic-function 'goal_count-val :lambda-list '(m))
(cl:defmethod goal_count-val ((m <SubmitMission-response>))
  (roslisp-msg-protocol:msg-deprecation-warning "Using old-style slot reader ground_air_msgs-srv:goal_count-val is deprecated.  Use ground_air_msgs-srv:goal_count instead.")
  (goal_count m))
(cl:defmethod roslisp-msg-protocol:serialize ((msg <SubmitMission-response>) ostream)
  "Serializes a message object of type '<SubmitMission-response>"
  (cl:write-byte (cl:ldb (cl:byte 8 0) (cl:if (cl:slot-value msg 'accepted) 1 0)) ostream)
  (cl:let ((__ros_str_len (cl:length (cl:slot-value msg 'message))))
    (cl:write-byte (cl:ldb (cl:byte 8 0) __ros_str_len) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 8) __ros_str_len) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 16) __ros_str_len) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 24) __ros_str_len) ostream))
  (cl:map cl:nil #'(cl:lambda (c) (cl:write-byte (cl:char-code c) ostream)) (cl:slot-value msg 'message))
  (cl:write-byte (cl:ldb (cl:byte 8 0) (cl:slot-value msg 'goal_count)) ostream)
  (cl:write-byte (cl:ldb (cl:byte 8 8) (cl:slot-value msg 'goal_count)) ostream)
  (cl:write-byte (cl:ldb (cl:byte 8 16) (cl:slot-value msg 'goal_count)) ostream)
  (cl:write-byte (cl:ldb (cl:byte 8 24) (cl:slot-value msg 'goal_count)) ostream)
)
(cl:defmethod roslisp-msg-protocol:deserialize ((msg <SubmitMission-response>) istream)
  "Deserializes a message object of type '<SubmitMission-response>"
    (cl:setf (cl:slot-value msg 'accepted) (cl:not (cl:zerop (cl:read-byte istream))))
    (cl:let ((__ros_str_len 0))
      (cl:setf (cl:ldb (cl:byte 8 0) __ros_str_len) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 8) __ros_str_len) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 16) __ros_str_len) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 24) __ros_str_len) (cl:read-byte istream))
      (cl:setf (cl:slot-value msg 'message) (cl:make-string __ros_str_len))
      (cl:dotimes (__ros_str_idx __ros_str_len msg)
        (cl:setf (cl:char (cl:slot-value msg 'message) __ros_str_idx) (cl:code-char (cl:read-byte istream)))))
    (cl:setf (cl:ldb (cl:byte 8 0) (cl:slot-value msg 'goal_count)) (cl:read-byte istream))
    (cl:setf (cl:ldb (cl:byte 8 8) (cl:slot-value msg 'goal_count)) (cl:read-byte istream))
    (cl:setf (cl:ldb (cl:byte 8 16) (cl:slot-value msg 'goal_count)) (cl:read-byte istream))
    (cl:setf (cl:ldb (cl:byte 8 24) (cl:slot-value msg 'goal_count)) (cl:read-byte istream))
  msg
)
(cl:defmethod roslisp-msg-protocol:ros-datatype ((msg (cl:eql '<SubmitMission-response>)))
  "Returns string type for a service object of type '<SubmitMission-response>"
  "ground_air_msgs/SubmitMissionResponse")
(cl:defmethod roslisp-msg-protocol:ros-datatype ((msg (cl:eql 'SubmitMission-response)))
  "Returns string type for a service object of type 'SubmitMission-response"
  "ground_air_msgs/SubmitMissionResponse")
(cl:defmethod roslisp-msg-protocol:md5sum ((type (cl:eql '<SubmitMission-response>)))
  "Returns md5sum for a message object of type '<SubmitMission-response>"
  "0b7be7b794768c0b19086f237b7f7bf0")
(cl:defmethod roslisp-msg-protocol:md5sum ((type (cl:eql 'SubmitMission-response)))
  "Returns md5sum for a message object of type 'SubmitMission-response"
  "0b7be7b794768c0b19086f237b7f7bf0")
(cl:defmethod roslisp-msg-protocol:message-definition ((type (cl:eql '<SubmitMission-response>)))
  "Returns full string definition for message of type '<SubmitMission-response>"
  (cl:format cl:nil "bool accepted~%string message~%uint32 goal_count~%~%~%~%"))
(cl:defmethod roslisp-msg-protocol:message-definition ((type (cl:eql 'SubmitMission-response)))
  "Returns full string definition for message of type 'SubmitMission-response"
  (cl:format cl:nil "bool accepted~%string message~%uint32 goal_count~%~%~%~%"))
(cl:defmethod roslisp-msg-protocol:serialization-length ((msg <SubmitMission-response>))
  (cl:+ 0
     1
     4 (cl:length (cl:slot-value msg 'message))
     4
))
(cl:defmethod roslisp-msg-protocol:ros-message-to-list ((msg <SubmitMission-response>))
  "Converts a ROS message object to a list"
  (cl:list 'SubmitMission-response
    (cl:cons ':accepted (accepted msg))
    (cl:cons ':message (message msg))
    (cl:cons ':goal_count (goal_count msg))
))
(cl:defmethod roslisp-msg-protocol:service-request-type ((msg (cl:eql 'SubmitMission)))
  'SubmitMission-request)
(cl:defmethod roslisp-msg-protocol:service-response-type ((msg (cl:eql 'SubmitMission)))
  'SubmitMission-response)
(cl:defmethod roslisp-msg-protocol:ros-datatype ((msg (cl:eql 'SubmitMission)))
  "Returns string type for a service object of type '<SubmitMission>"
  "ground_air_msgs/SubmitMission")