; Auto-generated. Do not edit!


(cl:in-package ground_air_msgs-srv)


;//! \htmlinclude SetVehicleMode-request.msg.html

(cl:defclass <SetVehicleMode-request> (roslisp-msg-protocol:ros-message)
  ((target_mode
    :reader target_mode
    :initarg :target_mode
    :type cl:fixnum
    :initform 0))
)

(cl:defclass SetVehicleMode-request (<SetVehicleMode-request>)
  ())

(cl:defmethod cl:initialize-instance :after ((m <SetVehicleMode-request>) cl:&rest args)
  (cl:declare (cl:ignorable args))
  (cl:unless (cl:typep m 'SetVehicleMode-request)
    (roslisp-msg-protocol:msg-deprecation-warning "using old message class name ground_air_msgs-srv:<SetVehicleMode-request> is deprecated: use ground_air_msgs-srv:SetVehicleMode-request instead.")))

(cl:ensure-generic-function 'target_mode-val :lambda-list '(m))
(cl:defmethod target_mode-val ((m <SetVehicleMode-request>))
  (roslisp-msg-protocol:msg-deprecation-warning "Using old-style slot reader ground_air_msgs-srv:target_mode-val is deprecated.  Use ground_air_msgs-srv:target_mode instead.")
  (target_mode m))
(cl:defmethod roslisp-msg-protocol:symbol-codes ((msg-type (cl:eql '<SetVehicleMode-request>)))
    "Constants for message type '<SetVehicleMode-request>"
  '((:GROUND . 1)
    (:AIR . 3))
)
(cl:defmethod roslisp-msg-protocol:symbol-codes ((msg-type (cl:eql 'SetVehicleMode-request)))
    "Constants for message type 'SetVehicleMode-request"
  '((:GROUND . 1)
    (:AIR . 3))
)
(cl:defmethod roslisp-msg-protocol:serialize ((msg <SetVehicleMode-request>) ostream)
  "Serializes a message object of type '<SetVehicleMode-request>"
  (cl:write-byte (cl:ldb (cl:byte 8 0) (cl:slot-value msg 'target_mode)) ostream)
)
(cl:defmethod roslisp-msg-protocol:deserialize ((msg <SetVehicleMode-request>) istream)
  "Deserializes a message object of type '<SetVehicleMode-request>"
    (cl:setf (cl:ldb (cl:byte 8 0) (cl:slot-value msg 'target_mode)) (cl:read-byte istream))
  msg
)
(cl:defmethod roslisp-msg-protocol:ros-datatype ((msg (cl:eql '<SetVehicleMode-request>)))
  "Returns string type for a service object of type '<SetVehicleMode-request>"
  "ground_air_msgs/SetVehicleModeRequest")
(cl:defmethod roslisp-msg-protocol:ros-datatype ((msg (cl:eql 'SetVehicleMode-request)))
  "Returns string type for a service object of type 'SetVehicleMode-request"
  "ground_air_msgs/SetVehicleModeRequest")
(cl:defmethod roslisp-msg-protocol:md5sum ((type (cl:eql '<SetVehicleMode-request>)))
  "Returns md5sum for a message object of type '<SetVehicleMode-request>"
  "ec2c78fe35d8769d286703fa442499f8")
(cl:defmethod roslisp-msg-protocol:md5sum ((type (cl:eql 'SetVehicleMode-request)))
  "Returns md5sum for a message object of type 'SetVehicleMode-request"
  "ec2c78fe35d8769d286703fa442499f8")
(cl:defmethod roslisp-msg-protocol:message-definition ((type (cl:eql '<SetVehicleMode-request>)))
  "Returns full string definition for message of type '<SetVehicleMode-request>"
  (cl:format cl:nil "uint8 GROUND=1~%uint8 AIR=3~%uint8 target_mode~%~%~%"))
(cl:defmethod roslisp-msg-protocol:message-definition ((type (cl:eql 'SetVehicleMode-request)))
  "Returns full string definition for message of type 'SetVehicleMode-request"
  (cl:format cl:nil "uint8 GROUND=1~%uint8 AIR=3~%uint8 target_mode~%~%~%"))
(cl:defmethod roslisp-msg-protocol:serialization-length ((msg <SetVehicleMode-request>))
  (cl:+ 0
     1
))
(cl:defmethod roslisp-msg-protocol:ros-message-to-list ((msg <SetVehicleMode-request>))
  "Converts a ROS message object to a list"
  (cl:list 'SetVehicleMode-request
    (cl:cons ':target_mode (target_mode msg))
))
;//! \htmlinclude SetVehicleMode-response.msg.html

(cl:defclass <SetVehicleMode-response> (roslisp-msg-protocol:ros-message)
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

(cl:defclass SetVehicleMode-response (<SetVehicleMode-response>)
  ())

(cl:defmethod cl:initialize-instance :after ((m <SetVehicleMode-response>) cl:&rest args)
  (cl:declare (cl:ignorable args))
  (cl:unless (cl:typep m 'SetVehicleMode-response)
    (roslisp-msg-protocol:msg-deprecation-warning "using old message class name ground_air_msgs-srv:<SetVehicleMode-response> is deprecated: use ground_air_msgs-srv:SetVehicleMode-response instead.")))

(cl:ensure-generic-function 'success-val :lambda-list '(m))
(cl:defmethod success-val ((m <SetVehicleMode-response>))
  (roslisp-msg-protocol:msg-deprecation-warning "Using old-style slot reader ground_air_msgs-srv:success-val is deprecated.  Use ground_air_msgs-srv:success instead.")
  (success m))

(cl:ensure-generic-function 'message-val :lambda-list '(m))
(cl:defmethod message-val ((m <SetVehicleMode-response>))
  (roslisp-msg-protocol:msg-deprecation-warning "Using old-style slot reader ground_air_msgs-srv:message-val is deprecated.  Use ground_air_msgs-srv:message instead.")
  (message m))

(cl:ensure-generic-function 'status-val :lambda-list '(m))
(cl:defmethod status-val ((m <SetVehicleMode-response>))
  (roslisp-msg-protocol:msg-deprecation-warning "Using old-style slot reader ground_air_msgs-srv:status-val is deprecated.  Use ground_air_msgs-srv:status instead.")
  (status m))
(cl:defmethod roslisp-msg-protocol:serialize ((msg <SetVehicleMode-response>) ostream)
  "Serializes a message object of type '<SetVehicleMode-response>"
  (cl:write-byte (cl:ldb (cl:byte 8 0) (cl:if (cl:slot-value msg 'success) 1 0)) ostream)
  (cl:let ((__ros_str_len (cl:length (cl:slot-value msg 'message))))
    (cl:write-byte (cl:ldb (cl:byte 8 0) __ros_str_len) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 8) __ros_str_len) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 16) __ros_str_len) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 24) __ros_str_len) ostream))
  (cl:map cl:nil #'(cl:lambda (c) (cl:write-byte (cl:char-code c) ostream)) (cl:slot-value msg 'message))
  (roslisp-msg-protocol:serialize (cl:slot-value msg 'status) ostream)
)
(cl:defmethod roslisp-msg-protocol:deserialize ((msg <SetVehicleMode-response>) istream)
  "Deserializes a message object of type '<SetVehicleMode-response>"
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
(cl:defmethod roslisp-msg-protocol:ros-datatype ((msg (cl:eql '<SetVehicleMode-response>)))
  "Returns string type for a service object of type '<SetVehicleMode-response>"
  "ground_air_msgs/SetVehicleModeResponse")
(cl:defmethod roslisp-msg-protocol:ros-datatype ((msg (cl:eql 'SetVehicleMode-response)))
  "Returns string type for a service object of type 'SetVehicleMode-response"
  "ground_air_msgs/SetVehicleModeResponse")
(cl:defmethod roslisp-msg-protocol:md5sum ((type (cl:eql '<SetVehicleMode-response>)))
  "Returns md5sum for a message object of type '<SetVehicleMode-response>"
  "ec2c78fe35d8769d286703fa442499f8")
(cl:defmethod roslisp-msg-protocol:md5sum ((type (cl:eql 'SetVehicleMode-response)))
  "Returns md5sum for a message object of type 'SetVehicleMode-response"
  "ec2c78fe35d8769d286703fa442499f8")
(cl:defmethod roslisp-msg-protocol:message-definition ((type (cl:eql '<SetVehicleMode-response>)))
  "Returns full string definition for message of type '<SetVehicleMode-response>"
  (cl:format cl:nil "bool success~%string message~%ground_air_msgs/VehicleStatus status~%~%~%================================================================================~%MSG: ground_air_msgs/VehicleStatus~%std_msgs/Header header~%~%uint8 UNKNOWN=0~%uint8 GROUND=1~%uint8 TAKEOFF=2~%uint8 AIR=3~%uint8 LANDING=4~%uint8 ESTOP=5~%uint8 FAULT=6~%~%uint8 mode~%bool connected~%bool armed~%bool localized~%bool emergency_stop~%float32 altitude~%string flight_mode~%string detail~%~%================================================================================~%MSG: std_msgs/Header~%# Standard metadata for higher-level stamped data types.~%# This is generally used to communicate timestamped data ~%# in a particular coordinate frame.~%# ~%# sequence ID: consecutively increasing ID ~%uint32 seq~%#Two-integer timestamp that is expressed as:~%# * stamp.sec: seconds (stamp_secs) since epoch (in Python the variable is called 'secs')~%# * stamp.nsec: nanoseconds since stamp_secs (in Python the variable is called 'nsecs')~%# time-handling sugar is provided by the client library~%time stamp~%#Frame this data is associated with~%string frame_id~%~%~%"))
(cl:defmethod roslisp-msg-protocol:message-definition ((type (cl:eql 'SetVehicleMode-response)))
  "Returns full string definition for message of type 'SetVehicleMode-response"
  (cl:format cl:nil "bool success~%string message~%ground_air_msgs/VehicleStatus status~%~%~%================================================================================~%MSG: ground_air_msgs/VehicleStatus~%std_msgs/Header header~%~%uint8 UNKNOWN=0~%uint8 GROUND=1~%uint8 TAKEOFF=2~%uint8 AIR=3~%uint8 LANDING=4~%uint8 ESTOP=5~%uint8 FAULT=6~%~%uint8 mode~%bool connected~%bool armed~%bool localized~%bool emergency_stop~%float32 altitude~%string flight_mode~%string detail~%~%================================================================================~%MSG: std_msgs/Header~%# Standard metadata for higher-level stamped data types.~%# This is generally used to communicate timestamped data ~%# in a particular coordinate frame.~%# ~%# sequence ID: consecutively increasing ID ~%uint32 seq~%#Two-integer timestamp that is expressed as:~%# * stamp.sec: seconds (stamp_secs) since epoch (in Python the variable is called 'secs')~%# * stamp.nsec: nanoseconds since stamp_secs (in Python the variable is called 'nsecs')~%# time-handling sugar is provided by the client library~%time stamp~%#Frame this data is associated with~%string frame_id~%~%~%"))
(cl:defmethod roslisp-msg-protocol:serialization-length ((msg <SetVehicleMode-response>))
  (cl:+ 0
     1
     4 (cl:length (cl:slot-value msg 'message))
     (roslisp-msg-protocol:serialization-length (cl:slot-value msg 'status))
))
(cl:defmethod roslisp-msg-protocol:ros-message-to-list ((msg <SetVehicleMode-response>))
  "Converts a ROS message object to a list"
  (cl:list 'SetVehicleMode-response
    (cl:cons ':success (success msg))
    (cl:cons ':message (message msg))
    (cl:cons ':status (status msg))
))
(cl:defmethod roslisp-msg-protocol:service-request-type ((msg (cl:eql 'SetVehicleMode)))
  'SetVehicleMode-request)
(cl:defmethod roslisp-msg-protocol:service-response-type ((msg (cl:eql 'SetVehicleMode)))
  'SetVehicleMode-response)
(cl:defmethod roslisp-msg-protocol:ros-datatype ((msg (cl:eql 'SetVehicleMode)))
  "Returns string type for a service object of type '<SetVehicleMode>"
  "ground_air_msgs/SetVehicleMode")