; Auto-generated. Do not edit!


(cl:in-package ground_air_msgs-srv)


;//! \htmlinclude SetEmergencyStop-request.msg.html

(cl:defclass <SetEmergencyStop-request> (roslisp-msg-protocol:ros-message)
  ((active
    :reader active
    :initarg :active
    :type cl:boolean
    :initform cl:nil))
)

(cl:defclass SetEmergencyStop-request (<SetEmergencyStop-request>)
  ())

(cl:defmethod cl:initialize-instance :after ((m <SetEmergencyStop-request>) cl:&rest args)
  (cl:declare (cl:ignorable args))
  (cl:unless (cl:typep m 'SetEmergencyStop-request)
    (roslisp-msg-protocol:msg-deprecation-warning "using old message class name ground_air_msgs-srv:<SetEmergencyStop-request> is deprecated: use ground_air_msgs-srv:SetEmergencyStop-request instead.")))

(cl:ensure-generic-function 'active-val :lambda-list '(m))
(cl:defmethod active-val ((m <SetEmergencyStop-request>))
  (roslisp-msg-protocol:msg-deprecation-warning "Using old-style slot reader ground_air_msgs-srv:active-val is deprecated.  Use ground_air_msgs-srv:active instead.")
  (active m))
(cl:defmethod roslisp-msg-protocol:serialize ((msg <SetEmergencyStop-request>) ostream)
  "Serializes a message object of type '<SetEmergencyStop-request>"
  (cl:write-byte (cl:ldb (cl:byte 8 0) (cl:if (cl:slot-value msg 'active) 1 0)) ostream)
)
(cl:defmethod roslisp-msg-protocol:deserialize ((msg <SetEmergencyStop-request>) istream)
  "Deserializes a message object of type '<SetEmergencyStop-request>"
    (cl:setf (cl:slot-value msg 'active) (cl:not (cl:zerop (cl:read-byte istream))))
  msg
)
(cl:defmethod roslisp-msg-protocol:ros-datatype ((msg (cl:eql '<SetEmergencyStop-request>)))
  "Returns string type for a service object of type '<SetEmergencyStop-request>"
  "ground_air_msgs/SetEmergencyStopRequest")
(cl:defmethod roslisp-msg-protocol:ros-datatype ((msg (cl:eql 'SetEmergencyStop-request)))
  "Returns string type for a service object of type 'SetEmergencyStop-request"
  "ground_air_msgs/SetEmergencyStopRequest")
(cl:defmethod roslisp-msg-protocol:md5sum ((type (cl:eql '<SetEmergencyStop-request>)))
  "Returns md5sum for a message object of type '<SetEmergencyStop-request>"
  "6adfca563192fe56ca02041330bd55c8")
(cl:defmethod roslisp-msg-protocol:md5sum ((type (cl:eql 'SetEmergencyStop-request)))
  "Returns md5sum for a message object of type 'SetEmergencyStop-request"
  "6adfca563192fe56ca02041330bd55c8")
(cl:defmethod roslisp-msg-protocol:message-definition ((type (cl:eql '<SetEmergencyStop-request>)))
  "Returns full string definition for message of type '<SetEmergencyStop-request>"
  (cl:format cl:nil "bool active~%~%~%"))
(cl:defmethod roslisp-msg-protocol:message-definition ((type (cl:eql 'SetEmergencyStop-request)))
  "Returns full string definition for message of type 'SetEmergencyStop-request"
  (cl:format cl:nil "bool active~%~%~%"))
(cl:defmethod roslisp-msg-protocol:serialization-length ((msg <SetEmergencyStop-request>))
  (cl:+ 0
     1
))
(cl:defmethod roslisp-msg-protocol:ros-message-to-list ((msg <SetEmergencyStop-request>))
  "Converts a ROS message object to a list"
  (cl:list 'SetEmergencyStop-request
    (cl:cons ':active (active msg))
))
;//! \htmlinclude SetEmergencyStop-response.msg.html

(cl:defclass <SetEmergencyStop-response> (roslisp-msg-protocol:ros-message)
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
    :type ground_air_msgs-msg:VehicleStatus
    :initform (cl:make-instance 'ground_air_msgs-msg:VehicleStatus)))
)

(cl:defclass SetEmergencyStop-response (<SetEmergencyStop-response>)
  ())

(cl:defmethod cl:initialize-instance :after ((m <SetEmergencyStop-response>) cl:&rest args)
  (cl:declare (cl:ignorable args))
  (cl:unless (cl:typep m 'SetEmergencyStop-response)
    (roslisp-msg-protocol:msg-deprecation-warning "using old message class name ground_air_msgs-srv:<SetEmergencyStop-response> is deprecated: use ground_air_msgs-srv:SetEmergencyStop-response instead.")))

(cl:ensure-generic-function 'success-val :lambda-list '(m))
(cl:defmethod success-val ((m <SetEmergencyStop-response>))
  (roslisp-msg-protocol:msg-deprecation-warning "Using old-style slot reader ground_air_msgs-srv:success-val is deprecated.  Use ground_air_msgs-srv:success instead.")
  (success m))

(cl:ensure-generic-function 'message-val :lambda-list '(m))
(cl:defmethod message-val ((m <SetEmergencyStop-response>))
  (roslisp-msg-protocol:msg-deprecation-warning "Using old-style slot reader ground_air_msgs-srv:message-val is deprecated.  Use ground_air_msgs-srv:message instead.")
  (message m))

(cl:ensure-generic-function 'status-val :lambda-list '(m))
(cl:defmethod status-val ((m <SetEmergencyStop-response>))
  (roslisp-msg-protocol:msg-deprecation-warning "Using old-style slot reader ground_air_msgs-srv:status-val is deprecated.  Use ground_air_msgs-srv:status instead.")
  (status m))
(cl:defmethod roslisp-msg-protocol:serialize ((msg <SetEmergencyStop-response>) ostream)
  "Serializes a message object of type '<SetEmergencyStop-response>"
  (cl:write-byte (cl:ldb (cl:byte 8 0) (cl:if (cl:slot-value msg 'success) 1 0)) ostream)
  (cl:let ((__ros_str_len (cl:length (cl:slot-value msg 'message))))
    (cl:write-byte (cl:ldb (cl:byte 8 0) __ros_str_len) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 8) __ros_str_len) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 16) __ros_str_len) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 24) __ros_str_len) ostream))
  (cl:map cl:nil #'(cl:lambda (c) (cl:write-byte (cl:char-code c) ostream)) (cl:slot-value msg 'message))
  (roslisp-msg-protocol:serialize (cl:slot-value msg 'status) ostream)
)
(cl:defmethod roslisp-msg-protocol:deserialize ((msg <SetEmergencyStop-response>) istream)
  "Deserializes a message object of type '<SetEmergencyStop-response>"
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
(cl:defmethod roslisp-msg-protocol:ros-datatype ((msg (cl:eql '<SetEmergencyStop-response>)))
  "Returns string type for a service object of type '<SetEmergencyStop-response>"
  "ground_air_msgs/SetEmergencyStopResponse")
(cl:defmethod roslisp-msg-protocol:ros-datatype ((msg (cl:eql 'SetEmergencyStop-response)))
  "Returns string type for a service object of type 'SetEmergencyStop-response"
  "ground_air_msgs/SetEmergencyStopResponse")
(cl:defmethod roslisp-msg-protocol:md5sum ((type (cl:eql '<SetEmergencyStop-response>)))
  "Returns md5sum for a message object of type '<SetEmergencyStop-response>"
  "6adfca563192fe56ca02041330bd55c8")
(cl:defmethod roslisp-msg-protocol:md5sum ((type (cl:eql 'SetEmergencyStop-response)))
  "Returns md5sum for a message object of type 'SetEmergencyStop-response"
  "6adfca563192fe56ca02041330bd55c8")
(cl:defmethod roslisp-msg-protocol:message-definition ((type (cl:eql '<SetEmergencyStop-response>)))
  "Returns full string definition for message of type '<SetEmergencyStop-response>"
  (cl:format cl:nil "bool success~%string message~%ground_air_msgs/VehicleStatus status~%~%~%================================================================================~%MSG: ground_air_msgs/VehicleStatus~%std_msgs/Header header~%~%uint8 UNKNOWN=0~%uint8 GROUND=1~%uint8 TAKEOFF=2~%uint8 AIR=3~%uint8 LANDING=4~%uint8 ESTOP=5~%uint8 FAULT=6~%~%uint8 mode~%bool connected~%bool armed~%bool localized~%bool emergency_stop~%float32 altitude~%string flight_mode~%string detail~%~%================================================================================~%MSG: std_msgs/Header~%# Standard metadata for higher-level stamped data types.~%# This is generally used to communicate timestamped data ~%# in a particular coordinate frame.~%# ~%# sequence ID: consecutively increasing ID ~%uint32 seq~%#Two-integer timestamp that is expressed as:~%# * stamp.sec: seconds (stamp_secs) since epoch (in Python the variable is called 'secs')~%# * stamp.nsec: nanoseconds since stamp_secs (in Python the variable is called 'nsecs')~%# time-handling sugar is provided by the client library~%time stamp~%#Frame this data is associated with~%string frame_id~%~%~%"))
(cl:defmethod roslisp-msg-protocol:message-definition ((type (cl:eql 'SetEmergencyStop-response)))
  "Returns full string definition for message of type 'SetEmergencyStop-response"
  (cl:format cl:nil "bool success~%string message~%ground_air_msgs/VehicleStatus status~%~%~%================================================================================~%MSG: ground_air_msgs/VehicleStatus~%std_msgs/Header header~%~%uint8 UNKNOWN=0~%uint8 GROUND=1~%uint8 TAKEOFF=2~%uint8 AIR=3~%uint8 LANDING=4~%uint8 ESTOP=5~%uint8 FAULT=6~%~%uint8 mode~%bool connected~%bool armed~%bool localized~%bool emergency_stop~%float32 altitude~%string flight_mode~%string detail~%~%================================================================================~%MSG: std_msgs/Header~%# Standard metadata for higher-level stamped data types.~%# This is generally used to communicate timestamped data ~%# in a particular coordinate frame.~%# ~%# sequence ID: consecutively increasing ID ~%uint32 seq~%#Two-integer timestamp that is expressed as:~%# * stamp.sec: seconds (stamp_secs) since epoch (in Python the variable is called 'secs')~%# * stamp.nsec: nanoseconds since stamp_secs (in Python the variable is called 'nsecs')~%# time-handling sugar is provided by the client library~%time stamp~%#Frame this data is associated with~%string frame_id~%~%~%"))
(cl:defmethod roslisp-msg-protocol:serialization-length ((msg <SetEmergencyStop-response>))
  (cl:+ 0
     1
     4 (cl:length (cl:slot-value msg 'message))
     (roslisp-msg-protocol:serialization-length (cl:slot-value msg 'status))
))
(cl:defmethod roslisp-msg-protocol:ros-message-to-list ((msg <SetEmergencyStop-response>))
  "Converts a ROS message object to a list"
  (cl:list 'SetEmergencyStop-response
    (cl:cons ':success (success msg))
    (cl:cons ':message (message msg))
    (cl:cons ':status (status msg))
))
(cl:defmethod roslisp-msg-protocol:service-request-type ((msg (cl:eql 'SetEmergencyStop)))
  'SetEmergencyStop-request)
(cl:defmethod roslisp-msg-protocol:service-response-type ((msg (cl:eql 'SetEmergencyStop)))
  'SetEmergencyStop-response)
(cl:defmethod roslisp-msg-protocol:ros-datatype ((msg (cl:eql 'SetEmergencyStop)))
  "Returns string type for a service object of type '<SetEmergencyStop>"
  "ground_air_msgs/SetEmergencyStop")