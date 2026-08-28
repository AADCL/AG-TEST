; Auto-generated. Do not edit!


(cl:in-package ground_air_msgs-srv)


;//! \htmlinclude StartMapping-request.msg.html

(cl:defclass <StartMapping-request> (roslisp-msg-protocol:ros-message)
  ((map_id
    :reader map_id
    :initarg :map_id
    :type cl:string
    :initform ""))
)

(cl:defclass StartMapping-request (<StartMapping-request>)
  ())

(cl:defmethod cl:initialize-instance :after ((m <StartMapping-request>) cl:&rest args)
  (cl:declare (cl:ignorable args))
  (cl:unless (cl:typep m 'StartMapping-request)
    (roslisp-msg-protocol:msg-deprecation-warning "using old message class name ground_air_msgs-srv:<StartMapping-request> is deprecated: use ground_air_msgs-srv:StartMapping-request instead.")))

(cl:ensure-generic-function 'map_id-val :lambda-list '(m))
(cl:defmethod map_id-val ((m <StartMapping-request>))
  (roslisp-msg-protocol:msg-deprecation-warning "Using old-style slot reader ground_air_msgs-srv:map_id-val is deprecated.  Use ground_air_msgs-srv:map_id instead.")
  (map_id m))
(cl:defmethod roslisp-msg-protocol:serialize ((msg <StartMapping-request>) ostream)
  "Serializes a message object of type '<StartMapping-request>"
  (cl:let ((__ros_str_len (cl:length (cl:slot-value msg 'map_id))))
    (cl:write-byte (cl:ldb (cl:byte 8 0) __ros_str_len) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 8) __ros_str_len) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 16) __ros_str_len) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 24) __ros_str_len) ostream))
  (cl:map cl:nil #'(cl:lambda (c) (cl:write-byte (cl:char-code c) ostream)) (cl:slot-value msg 'map_id))
)
(cl:defmethod roslisp-msg-protocol:deserialize ((msg <StartMapping-request>) istream)
  "Deserializes a message object of type '<StartMapping-request>"
    (cl:let ((__ros_str_len 0))
      (cl:setf (cl:ldb (cl:byte 8 0) __ros_str_len) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 8) __ros_str_len) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 16) __ros_str_len) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 24) __ros_str_len) (cl:read-byte istream))
      (cl:setf (cl:slot-value msg 'map_id) (cl:make-string __ros_str_len))
      (cl:dotimes (__ros_str_idx __ros_str_len msg)
        (cl:setf (cl:char (cl:slot-value msg 'map_id) __ros_str_idx) (cl:code-char (cl:read-byte istream)))))
  msg
)
(cl:defmethod roslisp-msg-protocol:ros-datatype ((msg (cl:eql '<StartMapping-request>)))
  "Returns string type for a service object of type '<StartMapping-request>"
  "ground_air_msgs/StartMappingRequest")
(cl:defmethod roslisp-msg-protocol:ros-datatype ((msg (cl:eql 'StartMapping-request)))
  "Returns string type for a service object of type 'StartMapping-request"
  "ground_air_msgs/StartMappingRequest")
(cl:defmethod roslisp-msg-protocol:md5sum ((type (cl:eql '<StartMapping-request>)))
  "Returns md5sum for a message object of type '<StartMapping-request>"
  "7109d91bb5e43bd6cea8265829bbdff6")
(cl:defmethod roslisp-msg-protocol:md5sum ((type (cl:eql 'StartMapping-request)))
  "Returns md5sum for a message object of type 'StartMapping-request"
  "7109d91bb5e43bd6cea8265829bbdff6")
(cl:defmethod roslisp-msg-protocol:message-definition ((type (cl:eql '<StartMapping-request>)))
  "Returns full string definition for message of type '<StartMapping-request>"
  (cl:format cl:nil "string map_id~%~%~%"))
(cl:defmethod roslisp-msg-protocol:message-definition ((type (cl:eql 'StartMapping-request)))
  "Returns full string definition for message of type 'StartMapping-request"
  (cl:format cl:nil "string map_id~%~%~%"))
(cl:defmethod roslisp-msg-protocol:serialization-length ((msg <StartMapping-request>))
  (cl:+ 0
     4 (cl:length (cl:slot-value msg 'map_id))
))
(cl:defmethod roslisp-msg-protocol:ros-message-to-list ((msg <StartMapping-request>))
  "Converts a ROS message object to a list"
  (cl:list 'StartMapping-request
    (cl:cons ':map_id (map_id msg))
))
;//! \htmlinclude StartMapping-response.msg.html

(cl:defclass <StartMapping-response> (roslisp-msg-protocol:ros-message)
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
   (status
    :reader status
    :initarg :status
    :type ground_air_msgs-msg:MappingStatus
    :initform (cl:make-instance 'ground_air_msgs-msg:MappingStatus)))
)

(cl:defclass StartMapping-response (<StartMapping-response>)
  ())

(cl:defmethod cl:initialize-instance :after ((m <StartMapping-response>) cl:&rest args)
  (cl:declare (cl:ignorable args))
  (cl:unless (cl:typep m 'StartMapping-response)
    (roslisp-msg-protocol:msg-deprecation-warning "using old message class name ground_air_msgs-srv:<StartMapping-response> is deprecated: use ground_air_msgs-srv:StartMapping-response instead.")))

(cl:ensure-generic-function 'success-val :lambda-list '(m))
(cl:defmethod success-val ((m <StartMapping-response>))
  (roslisp-msg-protocol:msg-deprecation-warning "Using old-style slot reader ground_air_msgs-srv:success-val is deprecated.  Use ground_air_msgs-srv:success instead.")
  (success m))

(cl:ensure-generic-function 'message-val :lambda-list '(m))
(cl:defmethod message-val ((m <StartMapping-response>))
  (roslisp-msg-protocol:msg-deprecation-warning "Using old-style slot reader ground_air_msgs-srv:message-val is deprecated.  Use ground_air_msgs-srv:message instead.")
  (message m))

(cl:ensure-generic-function 'status-val :lambda-list '(m))
(cl:defmethod status-val ((m <StartMapping-response>))
  (roslisp-msg-protocol:msg-deprecation-warning "Using old-style slot reader ground_air_msgs-srv:status-val is deprecated.  Use ground_air_msgs-srv:status instead.")
  (status m))
(cl:defmethod roslisp-msg-protocol:serialize ((msg <StartMapping-response>) ostream)
  "Serializes a message object of type '<StartMapping-response>"
  (cl:write-byte (cl:ldb (cl:byte 8 0) (cl:if (cl:slot-value msg 'success) 1 0)) ostream)
  (cl:let ((__ros_str_len (cl:length (cl:slot-value msg 'message))))
    (cl:write-byte (cl:ldb (cl:byte 8 0) __ros_str_len) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 8) __ros_str_len) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 16) __ros_str_len) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 24) __ros_str_len) ostream))
  (cl:map cl:nil #'(cl:lambda (c) (cl:write-byte (cl:char-code c) ostream)) (cl:slot-value msg 'message))
  (roslisp-msg-protocol:serialize (cl:slot-value msg 'status) ostream)
)
(cl:defmethod roslisp-msg-protocol:deserialize ((msg <StartMapping-response>) istream)
  "Deserializes a message object of type '<StartMapping-response>"
    (cl:setf (cl:slot-value msg 'success) (cl:not (cl:zerop (cl:read-byte istream))))
    (cl:let ((__ros_str_len 0))
      (cl:setf (cl:ldb (cl:byte 8 0) __ros_str_len) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 8) __ros_str_len) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 16) __ros_str_len) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 24) __ros_str_len) (cl:read-byte istream))
      (cl:setf (cl:slot-value msg 'message) (cl:make-string __ros_str_len))
      (cl:dotimes (__ros_str_idx __ros_str_len msg)
        (cl:setf (cl:char (cl:slot-value msg 'message) __ros_str_idx) (cl:code-char (cl:read-byte istream)))))
  (roslisp-msg-protocol:deserialize (cl:slot-value msg 'status) istream)
  msg
)
(cl:defmethod roslisp-msg-protocol:ros-datatype ((msg (cl:eql '<StartMapping-response>)))
  "Returns string type for a service object of type '<StartMapping-response>"
  "ground_air_msgs/StartMappingResponse")
(cl:defmethod roslisp-msg-protocol:ros-datatype ((msg (cl:eql 'StartMapping-response)))
  "Returns string type for a service object of type 'StartMapping-response"
  "ground_air_msgs/StartMappingResponse")
(cl:defmethod roslisp-msg-protocol:md5sum ((type (cl:eql '<StartMapping-response>)))
  "Returns md5sum for a message object of type '<StartMapping-response>"
  "7109d91bb5e43bd6cea8265829bbdff6")
(cl:defmethod roslisp-msg-protocol:md5sum ((type (cl:eql 'StartMapping-response)))
  "Returns md5sum for a message object of type 'StartMapping-response"
  "7109d91bb5e43bd6cea8265829bbdff6")
(cl:defmethod roslisp-msg-protocol:message-definition ((type (cl:eql '<StartMapping-response>)))
  "Returns full string definition for message of type '<StartMapping-response>"
  (cl:format cl:nil "bool success~%string message~%ground_air_msgs/MappingStatus status~%~%~%================================================================================~%MSG: ground_air_msgs/MappingStatus~%std_msgs/Header header~%~%uint8 IDLE=0~%uint8 RECORDING=1~%uint8 SAVING=2~%uint8 COMPLETE=3~%uint8 ERROR=4~%~%uint8 state~%string map_id~%uint64 point_count~%float64 map_area~%string message~%~%================================================================================~%MSG: std_msgs/Header~%# Standard metadata for higher-level stamped data types.~%# This is generally used to communicate timestamped data ~%# in a particular coordinate frame.~%# ~%# sequence ID: consecutively increasing ID ~%uint32 seq~%#Two-integer timestamp that is expressed as:~%# * stamp.sec: seconds (stamp_secs) since epoch (in Python the variable is called 'secs')~%# * stamp.nsec: nanoseconds since stamp_secs (in Python the variable is called 'nsecs')~%# time-handling sugar is provided by the client library~%time stamp~%#Frame this data is associated with~%string frame_id~%~%~%"))
(cl:defmethod roslisp-msg-protocol:message-definition ((type (cl:eql 'StartMapping-response)))
  "Returns full string definition for message of type 'StartMapping-response"
  (cl:format cl:nil "bool success~%string message~%ground_air_msgs/MappingStatus status~%~%~%================================================================================~%MSG: ground_air_msgs/MappingStatus~%std_msgs/Header header~%~%uint8 IDLE=0~%uint8 RECORDING=1~%uint8 SAVING=2~%uint8 COMPLETE=3~%uint8 ERROR=4~%~%uint8 state~%string map_id~%uint64 point_count~%float64 map_area~%string message~%~%================================================================================~%MSG: std_msgs/Header~%# Standard metadata for higher-level stamped data types.~%# This is generally used to communicate timestamped data ~%# in a particular coordinate frame.~%# ~%# sequence ID: consecutively increasing ID ~%uint32 seq~%#Two-integer timestamp that is expressed as:~%# * stamp.sec: seconds (stamp_secs) since epoch (in Python the variable is called 'secs')~%# * stamp.nsec: nanoseconds since stamp_secs (in Python the variable is called 'nsecs')~%# time-handling sugar is provided by the client library~%time stamp~%#Frame this data is associated with~%string frame_id~%~%~%"))
(cl:defmethod roslisp-msg-protocol:serialization-length ((msg <StartMapping-response>))
  (cl:+ 0
     1
     4 (cl:length (cl:slot-value msg 'message))
     (roslisp-msg-protocol:serialization-length (cl:slot-value msg 'status))
))
(cl:defmethod roslisp-msg-protocol:ros-message-to-list ((msg <StartMapping-response>))
  "Converts a ROS message object to a list"
  (cl:list 'StartMapping-response
    (cl:cons ':success (success msg))
    (cl:cons ':message (message msg))
    (cl:cons ':status (status msg))
))
(cl:defmethod roslisp-msg-protocol:service-request-type ((msg (cl:eql 'StartMapping)))
  'StartMapping-request)
(cl:defmethod roslisp-msg-protocol:service-response-type ((msg (cl:eql 'StartMapping)))
  'StartMapping-response)
(cl:defmethod roslisp-msg-protocol:ros-datatype ((msg (cl:eql 'StartMapping)))
  "Returns string type for a service object of type '<StartMapping>"
  "ground_air_msgs/StartMapping")