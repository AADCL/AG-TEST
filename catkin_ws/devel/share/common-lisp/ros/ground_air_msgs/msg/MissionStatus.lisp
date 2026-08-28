; Auto-generated. Do not edit!


(cl:in-package ground_air_msgs-msg)


;//! \htmlinclude MissionStatus.msg.html

(cl:defclass <MissionStatus> (roslisp-msg-protocol:ros-message)
  ((header
    :reader header
    :initarg :header
    :type std_msgs-msg:Header
    :initform (cl:make-instance 'std_msgs-msg:Header))
   (state
    :reader state
    :initarg :state
    :type cl:fixnum
    :initform 0)
   (current_index
    :reader current_index
    :initarg :current_index
    :type cl:integer
    :initform 0)
   (total_goals
    :reader total_goals
    :initarg :total_goals
    :type cl:integer
    :initform 0)
   (mission_id
    :reader mission_id
    :initarg :mission_id
    :type cl:string
    :initform "")
   (detail
    :reader detail
    :initarg :detail
    :type cl:string
    :initform ""))
)

(cl:defclass MissionStatus (<MissionStatus>)
  ())

(cl:defmethod cl:initialize-instance :after ((m <MissionStatus>) cl:&rest args)
  (cl:declare (cl:ignorable args))
  (cl:unless (cl:typep m 'MissionStatus)
    (roslisp-msg-protocol:msg-deprecation-warning "using old message class name ground_air_msgs-msg:<MissionStatus> is deprecated: use ground_air_msgs-msg:MissionStatus instead.")))

(cl:ensure-generic-function 'header-val :lambda-list '(m))
(cl:defmethod header-val ((m <MissionStatus>))
  (roslisp-msg-protocol:msg-deprecation-warning "Using old-style slot reader ground_air_msgs-msg:header-val is deprecated.  Use ground_air_msgs-msg:header instead.")
  (header m))

(cl:ensure-generic-function 'state-val :lambda-list '(m))
(cl:defmethod state-val ((m <MissionStatus>))
  (roslisp-msg-protocol:msg-deprecation-warning "Using old-style slot reader ground_air_msgs-msg:state-val is deprecated.  Use ground_air_msgs-msg:state instead.")
  (state m))

(cl:ensure-generic-function 'current_index-val :lambda-list '(m))
(cl:defmethod current_index-val ((m <MissionStatus>))
  (roslisp-msg-protocol:msg-deprecation-warning "Using old-style slot reader ground_air_msgs-msg:current_index-val is deprecated.  Use ground_air_msgs-msg:current_index instead.")
  (current_index m))

(cl:ensure-generic-function 'total_goals-val :lambda-list '(m))
(cl:defmethod total_goals-val ((m <MissionStatus>))
  (roslisp-msg-protocol:msg-deprecation-warning "Using old-style slot reader ground_air_msgs-msg:total_goals-val is deprecated.  Use ground_air_msgs-msg:total_goals instead.")
  (total_goals m))

(cl:ensure-generic-function 'mission_id-val :lambda-list '(m))
(cl:defmethod mission_id-val ((m <MissionStatus>))
  (roslisp-msg-protocol:msg-deprecation-warning "Using old-style slot reader ground_air_msgs-msg:mission_id-val is deprecated.  Use ground_air_msgs-msg:mission_id instead.")
  (mission_id m))

(cl:ensure-generic-function 'detail-val :lambda-list '(m))
(cl:defmethod detail-val ((m <MissionStatus>))
  (roslisp-msg-protocol:msg-deprecation-warning "Using old-style slot reader ground_air_msgs-msg:detail-val is deprecated.  Use ground_air_msgs-msg:detail instead.")
  (detail m))
(cl:defmethod roslisp-msg-protocol:symbol-codes ((msg-type (cl:eql '<MissionStatus>)))
    "Constants for message type '<MissionStatus>"
  '((:IDLE . 0)
    (:RUNNING . 1)
    (:DWELLING . 2)
    (:PAUSED . 3)
    (:SUCCEEDED . 4)
    (:FAILED . 5)
    (:CANCELED . 6)
    (:WAITING_FOR_LAND . 7))
)
(cl:defmethod roslisp-msg-protocol:symbol-codes ((msg-type (cl:eql 'MissionStatus)))
    "Constants for message type 'MissionStatus"
  '((:IDLE . 0)
    (:RUNNING . 1)
    (:DWELLING . 2)
    (:PAUSED . 3)
    (:SUCCEEDED . 4)
    (:FAILED . 5)
    (:CANCELED . 6)
    (:WAITING_FOR_LAND . 7))
)
(cl:defmethod roslisp-msg-protocol:serialize ((msg <MissionStatus>) ostream)
  "Serializes a message object of type '<MissionStatus>"
  (roslisp-msg-protocol:serialize (cl:slot-value msg 'header) ostream)
  (cl:write-byte (cl:ldb (cl:byte 8 0) (cl:slot-value msg 'state)) ostream)
  (cl:write-byte (cl:ldb (cl:byte 8 0) (cl:slot-value msg 'current_index)) ostream)
  (cl:write-byte (cl:ldb (cl:byte 8 8) (cl:slot-value msg 'current_index)) ostream)
  (cl:write-byte (cl:ldb (cl:byte 8 16) (cl:slot-value msg 'current_index)) ostream)
  (cl:write-byte (cl:ldb (cl:byte 8 24) (cl:slot-value msg 'current_index)) ostream)
  (cl:write-byte (cl:ldb (cl:byte 8 0) (cl:slot-value msg 'total_goals)) ostream)
  (cl:write-byte (cl:ldb (cl:byte 8 8) (cl:slot-value msg 'total_goals)) ostream)
  (cl:write-byte (cl:ldb (cl:byte 8 16) (cl:slot-value msg 'total_goals)) ostream)
  (cl:write-byte (cl:ldb (cl:byte 8 24) (cl:slot-value msg 'total_goals)) ostream)
  (cl:let ((__ros_str_len (cl:length (cl:slot-value msg 'mission_id))))
    (cl:write-byte (cl:ldb (cl:byte 8 0) __ros_str_len) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 8) __ros_str_len) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 16) __ros_str_len) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 24) __ros_str_len) ostream))
  (cl:map cl:nil #'(cl:lambda (c) (cl:write-byte (cl:char-code c) ostream)) (cl:slot-value msg 'mission_id))
  (cl:let ((__ros_str_len (cl:length (cl:slot-value msg 'detail))))
    (cl:write-byte (cl:ldb (cl:byte 8 0) __ros_str_len) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 8) __ros_str_len) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 16) __ros_str_len) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 24) __ros_str_len) ostream))
  (cl:map cl:nil #'(cl:lambda (c) (cl:write-byte (cl:char-code c) ostream)) (cl:slot-value msg 'detail))
)
(cl:defmethod roslisp-msg-protocol:deserialize ((msg <MissionStatus>) istream)
  "Deserializes a message object of type '<MissionStatus>"
  (roslisp-msg-protocol:deserialize (cl:slot-value msg 'header) istream)
    (cl:setf (cl:ldb (cl:byte 8 0) (cl:slot-value msg 'state)) (cl:read-byte istream))
    (cl:setf (cl:ldb (cl:byte 8 0) (cl:slot-value msg 'current_index)) (cl:read-byte istream))
    (cl:setf (cl:ldb (cl:byte 8 8) (cl:slot-value msg 'current_index)) (cl:read-byte istream))
    (cl:setf (cl:ldb (cl:byte 8 16) (cl:slot-value msg 'current_index)) (cl:read-byte istream))
    (cl:setf (cl:ldb (cl:byte 8 24) (cl:slot-value msg 'current_index)) (cl:read-byte istream))
    (cl:setf (cl:ldb (cl:byte 8 0) (cl:slot-value msg 'total_goals)) (cl:read-byte istream))
    (cl:setf (cl:ldb (cl:byte 8 8) (cl:slot-value msg 'total_goals)) (cl:read-byte istream))
    (cl:setf (cl:ldb (cl:byte 8 16) (cl:slot-value msg 'total_goals)) (cl:read-byte istream))
    (cl:setf (cl:ldb (cl:byte 8 24) (cl:slot-value msg 'total_goals)) (cl:read-byte istream))
    (cl:let ((__ros_str_len 0))
      (cl:setf (cl:ldb (cl:byte 8 0) __ros_str_len) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 8) __ros_str_len) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 16) __ros_str_len) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 24) __ros_str_len) (cl:read-byte istream))
      (cl:setf (cl:slot-value msg 'mission_id) (cl:make-string __ros_str_len))
      (cl:dotimes (__ros_str_idx __ros_str_len msg)
        (cl:setf (cl:char (cl:slot-value msg 'mission_id) __ros_str_idx) (cl:code-char (cl:read-byte istream)))))
    (cl:let ((__ros_str_len 0))
      (cl:setf (cl:ldb (cl:byte 8 0) __ros_str_len) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 8) __ros_str_len) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 16) __ros_str_len) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 24) __ros_str_len) (cl:read-byte istream))
      (cl:setf (cl:slot-value msg 'detail) (cl:make-string __ros_str_len))
      (cl:dotimes (__ros_str_idx __ros_str_len msg)
        (cl:setf (cl:char (cl:slot-value msg 'detail) __ros_str_idx) (cl:code-char (cl:read-byte istream)))))
  msg
)
(cl:defmethod roslisp-msg-protocol:ros-datatype ((msg (cl:eql '<MissionStatus>)))
  "Returns string type for a message object of type '<MissionStatus>"
  "ground_air_msgs/MissionStatus")
(cl:defmethod roslisp-msg-protocol:ros-datatype ((msg (cl:eql 'MissionStatus)))
  "Returns string type for a message object of type 'MissionStatus"
  "ground_air_msgs/MissionStatus")
(cl:defmethod roslisp-msg-protocol:md5sum ((type (cl:eql '<MissionStatus>)))
  "Returns md5sum for a message object of type '<MissionStatus>"
  "23946ede182678d2d602626aab96cd05")
(cl:defmethod roslisp-msg-protocol:md5sum ((type (cl:eql 'MissionStatus)))
  "Returns md5sum for a message object of type 'MissionStatus"
  "23946ede182678d2d602626aab96cd05")
(cl:defmethod roslisp-msg-protocol:message-definition ((type (cl:eql '<MissionStatus>)))
  "Returns full string definition for message of type '<MissionStatus>"
  (cl:format cl:nil "std_msgs/Header header~%~%uint8 IDLE=0~%uint8 RUNNING=1~%uint8 DWELLING=2~%uint8 PAUSED=3~%uint8 SUCCEEDED=4~%uint8 FAILED=5~%uint8 CANCELED=6~%uint8 WAITING_FOR_LAND=7~%~%uint8 state~%uint32 current_index~%uint32 total_goals~%string mission_id~%string detail~%~%================================================================================~%MSG: std_msgs/Header~%# Standard metadata for higher-level stamped data types.~%# This is generally used to communicate timestamped data ~%# in a particular coordinate frame.~%# ~%# sequence ID: consecutively increasing ID ~%uint32 seq~%#Two-integer timestamp that is expressed as:~%# * stamp.sec: seconds (stamp_secs) since epoch (in Python the variable is called 'secs')~%# * stamp.nsec: nanoseconds since stamp_secs (in Python the variable is called 'nsecs')~%# time-handling sugar is provided by the client library~%time stamp~%#Frame this data is associated with~%string frame_id~%~%~%"))
(cl:defmethod roslisp-msg-protocol:message-definition ((type (cl:eql 'MissionStatus)))
  "Returns full string definition for message of type 'MissionStatus"
  (cl:format cl:nil "std_msgs/Header header~%~%uint8 IDLE=0~%uint8 RUNNING=1~%uint8 DWELLING=2~%uint8 PAUSED=3~%uint8 SUCCEEDED=4~%uint8 FAILED=5~%uint8 CANCELED=6~%uint8 WAITING_FOR_LAND=7~%~%uint8 state~%uint32 current_index~%uint32 total_goals~%string mission_id~%string detail~%~%================================================================================~%MSG: std_msgs/Header~%# Standard metadata for higher-level stamped data types.~%# This is generally used to communicate timestamped data ~%# in a particular coordinate frame.~%# ~%# sequence ID: consecutively increasing ID ~%uint32 seq~%#Two-integer timestamp that is expressed as:~%# * stamp.sec: seconds (stamp_secs) since epoch (in Python the variable is called 'secs')~%# * stamp.nsec: nanoseconds since stamp_secs (in Python the variable is called 'nsecs')~%# time-handling sugar is provided by the client library~%time stamp~%#Frame this data is associated with~%string frame_id~%~%~%"))
(cl:defmethod roslisp-msg-protocol:serialization-length ((msg <MissionStatus>))
  (cl:+ 0
     (roslisp-msg-protocol:serialization-length (cl:slot-value msg 'header))
     1
     4
     4
     4 (cl:length (cl:slot-value msg 'mission_id))
     4 (cl:length (cl:slot-value msg 'detail))
))
(cl:defmethod roslisp-msg-protocol:ros-message-to-list ((msg <MissionStatus>))
  "Converts a ROS message object to a list"
  (cl:list 'MissionStatus
    (cl:cons ':header (header msg))
    (cl:cons ':state (state msg))
    (cl:cons ':current_index (current_index msg))
    (cl:cons ':total_goals (total_goals msg))
    (cl:cons ':mission_id (mission_id msg))
    (cl:cons ':detail (detail msg))
))
