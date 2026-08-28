; Auto-generated. Do not edit!


(cl:in-package ground_air_msgs-msg)


;//! \htmlinclude MappingStatus.msg.html

(cl:defclass <MappingStatus> (roslisp-msg-protocol:ros-message)
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
   (map_id
    :reader map_id
    :initarg :map_id
    :type cl:string
    :initform "")
   (point_count
    :reader point_count
    :initarg :point_count
    :type cl:integer
    :initform 0)
   (map_area
    :reader map_area
    :initarg :map_area
    :type cl:float
    :initform 0.0)
   (message
    :reader message
    :initarg :message
    :type cl:string
    :initform ""))
)

(cl:defclass MappingStatus (<MappingStatus>)
  ())

(cl:defmethod cl:initialize-instance :after ((m <MappingStatus>) cl:&rest args)
  (cl:declare (cl:ignorable args))
  (cl:unless (cl:typep m 'MappingStatus)
    (roslisp-msg-protocol:msg-deprecation-warning "using old message class name ground_air_msgs-msg:<MappingStatus> is deprecated: use ground_air_msgs-msg:MappingStatus instead.")))

(cl:ensure-generic-function 'header-val :lambda-list '(m))
(cl:defmethod header-val ((m <MappingStatus>))
  (roslisp-msg-protocol:msg-deprecation-warning "Using old-style slot reader ground_air_msgs-msg:header-val is deprecated.  Use ground_air_msgs-msg:header instead.")
  (header m))

(cl:ensure-generic-function 'state-val :lambda-list '(m))
(cl:defmethod state-val ((m <MappingStatus>))
  (roslisp-msg-protocol:msg-deprecation-warning "Using old-style slot reader ground_air_msgs-msg:state-val is deprecated.  Use ground_air_msgs-msg:state instead.")
  (state m))

(cl:ensure-generic-function 'map_id-val :lambda-list '(m))
(cl:defmethod map_id-val ((m <MappingStatus>))
  (roslisp-msg-protocol:msg-deprecation-warning "Using old-style slot reader ground_air_msgs-msg:map_id-val is deprecated.  Use ground_air_msgs-msg:map_id instead.")
  (map_id m))

(cl:ensure-generic-function 'point_count-val :lambda-list '(m))
(cl:defmethod point_count-val ((m <MappingStatus>))
  (roslisp-msg-protocol:msg-deprecation-warning "Using old-style slot reader ground_air_msgs-msg:point_count-val is deprecated.  Use ground_air_msgs-msg:point_count instead.")
  (point_count m))

(cl:ensure-generic-function 'map_area-val :lambda-list '(m))
(cl:defmethod map_area-val ((m <MappingStatus>))
  (roslisp-msg-protocol:msg-deprecation-warning "Using old-style slot reader ground_air_msgs-msg:map_area-val is deprecated.  Use ground_air_msgs-msg:map_area instead.")
  (map_area m))

(cl:ensure-generic-function 'message-val :lambda-list '(m))
(cl:defmethod message-val ((m <MappingStatus>))
  (roslisp-msg-protocol:msg-deprecation-warning "Using old-style slot reader ground_air_msgs-msg:message-val is deprecated.  Use ground_air_msgs-msg:message instead.")
  (message m))
(cl:defmethod roslisp-msg-protocol:symbol-codes ((msg-type (cl:eql '<MappingStatus>)))
    "Constants for message type '<MappingStatus>"
  '((:IDLE . 0)
    (:RECORDING . 1)
    (:SAVING . 2)
    (:COMPLETE . 3)
    (:ERROR . 4))
)
(cl:defmethod roslisp-msg-protocol:symbol-codes ((msg-type (cl:eql 'MappingStatus)))
    "Constants for message type 'MappingStatus"
  '((:IDLE . 0)
    (:RECORDING . 1)
    (:SAVING . 2)
    (:COMPLETE . 3)
    (:ERROR . 4))
)
(cl:defmethod roslisp-msg-protocol:serialize ((msg <MappingStatus>) ostream)
  "Serializes a message object of type '<MappingStatus>"
  (roslisp-msg-protocol:serialize (cl:slot-value msg 'header) ostream)
  (cl:write-byte (cl:ldb (cl:byte 8 0) (cl:slot-value msg 'state)) ostream)
  (cl:let ((__ros_str_len (cl:length (cl:slot-value msg 'map_id))))
    (cl:write-byte (cl:ldb (cl:byte 8 0) __ros_str_len) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 8) __ros_str_len) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 16) __ros_str_len) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 24) __ros_str_len) ostream))
  (cl:map cl:nil #'(cl:lambda (c) (cl:write-byte (cl:char-code c) ostream)) (cl:slot-value msg 'map_id))
  (cl:write-byte (cl:ldb (cl:byte 8 0) (cl:slot-value msg 'point_count)) ostream)
  (cl:write-byte (cl:ldb (cl:byte 8 8) (cl:slot-value msg 'point_count)) ostream)
  (cl:write-byte (cl:ldb (cl:byte 8 16) (cl:slot-value msg 'point_count)) ostream)
  (cl:write-byte (cl:ldb (cl:byte 8 24) (cl:slot-value msg 'point_count)) ostream)
  (cl:write-byte (cl:ldb (cl:byte 8 32) (cl:slot-value msg 'point_count)) ostream)
  (cl:write-byte (cl:ldb (cl:byte 8 40) (cl:slot-value msg 'point_count)) ostream)
  (cl:write-byte (cl:ldb (cl:byte 8 48) (cl:slot-value msg 'point_count)) ostream)
  (cl:write-byte (cl:ldb (cl:byte 8 56) (cl:slot-value msg 'point_count)) ostream)
  (cl:let ((bits (roslisp-utils:encode-double-float-bits (cl:slot-value msg 'map_area))))
    (cl:write-byte (cl:ldb (cl:byte 8 0) bits) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 8) bits) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 16) bits) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 24) bits) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 32) bits) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 40) bits) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 48) bits) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 56) bits) ostream))
  (cl:let ((__ros_str_len (cl:length (cl:slot-value msg 'message))))
    (cl:write-byte (cl:ldb (cl:byte 8 0) __ros_str_len) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 8) __ros_str_len) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 16) __ros_str_len) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 24) __ros_str_len) ostream))
  (cl:map cl:nil #'(cl:lambda (c) (cl:write-byte (cl:char-code c) ostream)) (cl:slot-value msg 'message))
)
(cl:defmethod roslisp-msg-protocol:deserialize ((msg <MappingStatus>) istream)
  "Deserializes a message object of type '<MappingStatus>"
  (roslisp-msg-protocol:deserialize (cl:slot-value msg 'header) istream)
    (cl:setf (cl:ldb (cl:byte 8 0) (cl:slot-value msg 'state)) (cl:read-byte istream))
    (cl:let ((__ros_str_len 0))
      (cl:setf (cl:ldb (cl:byte 8 0) __ros_str_len) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 8) __ros_str_len) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 16) __ros_str_len) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 24) __ros_str_len) (cl:read-byte istream))
      (cl:setf (cl:slot-value msg 'map_id) (cl:make-string __ros_str_len))
      (cl:dotimes (__ros_str_idx __ros_str_len msg)
        (cl:setf (cl:char (cl:slot-value msg 'map_id) __ros_str_idx) (cl:code-char (cl:read-byte istream)))))
    (cl:setf (cl:ldb (cl:byte 8 0) (cl:slot-value msg 'point_count)) (cl:read-byte istream))
    (cl:setf (cl:ldb (cl:byte 8 8) (cl:slot-value msg 'point_count)) (cl:read-byte istream))
    (cl:setf (cl:ldb (cl:byte 8 16) (cl:slot-value msg 'point_count)) (cl:read-byte istream))
    (cl:setf (cl:ldb (cl:byte 8 24) (cl:slot-value msg 'point_count)) (cl:read-byte istream))
    (cl:setf (cl:ldb (cl:byte 8 32) (cl:slot-value msg 'point_count)) (cl:read-byte istream))
    (cl:setf (cl:ldb (cl:byte 8 40) (cl:slot-value msg 'point_count)) (cl:read-byte istream))
    (cl:setf (cl:ldb (cl:byte 8 48) (cl:slot-value msg 'point_count)) (cl:read-byte istream))
    (cl:setf (cl:ldb (cl:byte 8 56) (cl:slot-value msg 'point_count)) (cl:read-byte istream))
    (cl:let ((bits 0))
      (cl:setf (cl:ldb (cl:byte 8 0) bits) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 8) bits) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 16) bits) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 24) bits) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 32) bits) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 40) bits) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 48) bits) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 56) bits) (cl:read-byte istream))
    (cl:setf (cl:slot-value msg 'map_area) (roslisp-utils:decode-double-float-bits bits)))
    (cl:let ((__ros_str_len 0))
      (cl:setf (cl:ldb (cl:byte 8 0) __ros_str_len) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 8) __ros_str_len) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 16) __ros_str_len) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 24) __ros_str_len) (cl:read-byte istream))
      (cl:setf (cl:slot-value msg 'message) (cl:make-string __ros_str_len))
      (cl:dotimes (__ros_str_idx __ros_str_len msg)
        (cl:setf (cl:char (cl:slot-value msg 'message) __ros_str_idx) (cl:code-char (cl:read-byte istream)))))
  msg
)
(cl:defmethod roslisp-msg-protocol:ros-datatype ((msg (cl:eql '<MappingStatus>)))
  "Returns string type for a message object of type '<MappingStatus>"
  "ground_air_msgs/MappingStatus")
(cl:defmethod roslisp-msg-protocol:ros-datatype ((msg (cl:eql 'MappingStatus)))
  "Returns string type for a message object of type 'MappingStatus"
  "ground_air_msgs/MappingStatus")
(cl:defmethod roslisp-msg-protocol:md5sum ((type (cl:eql '<MappingStatus>)))
  "Returns md5sum for a message object of type '<MappingStatus>"
  "e7b4d3ace6c9bf72b66602ccfc54bf23")
(cl:defmethod roslisp-msg-protocol:md5sum ((type (cl:eql 'MappingStatus)))
  "Returns md5sum for a message object of type 'MappingStatus"
  "e7b4d3ace6c9bf72b66602ccfc54bf23")
(cl:defmethod roslisp-msg-protocol:message-definition ((type (cl:eql '<MappingStatus>)))
  "Returns full string definition for message of type '<MappingStatus>"
  (cl:format cl:nil "std_msgs/Header header~%~%uint8 IDLE=0~%uint8 RECORDING=1~%uint8 SAVING=2~%uint8 COMPLETE=3~%uint8 ERROR=4~%~%uint8 state~%string map_id~%uint64 point_count~%float64 map_area~%string message~%~%================================================================================~%MSG: std_msgs/Header~%# Standard metadata for higher-level stamped data types.~%# This is generally used to communicate timestamped data ~%# in a particular coordinate frame.~%# ~%# sequence ID: consecutively increasing ID ~%uint32 seq~%#Two-integer timestamp that is expressed as:~%# * stamp.sec: seconds (stamp_secs) since epoch (in Python the variable is called 'secs')~%# * stamp.nsec: nanoseconds since stamp_secs (in Python the variable is called 'nsecs')~%# time-handling sugar is provided by the client library~%time stamp~%#Frame this data is associated with~%string frame_id~%~%~%"))
(cl:defmethod roslisp-msg-protocol:message-definition ((type (cl:eql 'MappingStatus)))
  "Returns full string definition for message of type 'MappingStatus"
  (cl:format cl:nil "std_msgs/Header header~%~%uint8 IDLE=0~%uint8 RECORDING=1~%uint8 SAVING=2~%uint8 COMPLETE=3~%uint8 ERROR=4~%~%uint8 state~%string map_id~%uint64 point_count~%float64 map_area~%string message~%~%================================================================================~%MSG: std_msgs/Header~%# Standard metadata for higher-level stamped data types.~%# This is generally used to communicate timestamped data ~%# in a particular coordinate frame.~%# ~%# sequence ID: consecutively increasing ID ~%uint32 seq~%#Two-integer timestamp that is expressed as:~%# * stamp.sec: seconds (stamp_secs) since epoch (in Python the variable is called 'secs')~%# * stamp.nsec: nanoseconds since stamp_secs (in Python the variable is called 'nsecs')~%# time-handling sugar is provided by the client library~%time stamp~%#Frame this data is associated with~%string frame_id~%~%~%"))
(cl:defmethod roslisp-msg-protocol:serialization-length ((msg <MappingStatus>))
  (cl:+ 0
     (roslisp-msg-protocol:serialization-length (cl:slot-value msg 'header))
     1
     4 (cl:length (cl:slot-value msg 'map_id))
     8
     8
     4 (cl:length (cl:slot-value msg 'message))
))
(cl:defmethod roslisp-msg-protocol:ros-message-to-list ((msg <MappingStatus>))
  "Converts a ROS message object to a list"
  (cl:list 'MappingStatus
    (cl:cons ':header (header msg))
    (cl:cons ':state (state msg))
    (cl:cons ':map_id (map_id msg))
    (cl:cons ':point_count (point_count msg))
    (cl:cons ':map_area (map_area msg))
    (cl:cons ':message (message msg))
))
