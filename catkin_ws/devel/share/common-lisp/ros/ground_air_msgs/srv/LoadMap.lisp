; Auto-generated. Do not edit!


(cl:in-package ground_air_msgs-srv)


;//! \htmlinclude LoadMap-request.msg.html

(cl:defclass <LoadMap-request> (roslisp-msg-protocol:ros-message)
  ((map_id
    :reader map_id
    :initarg :map_id
    :type cl:string
    :initform "")
   (source_uri
    :reader source_uri
    :initarg :source_uri
    :type cl:string
    :initform ""))
)

(cl:defclass LoadMap-request (<LoadMap-request>)
  ())

(cl:defmethod cl:initialize-instance :after ((m <LoadMap-request>) cl:&rest args)
  (cl:declare (cl:ignorable args))
  (cl:unless (cl:typep m 'LoadMap-request)
    (roslisp-msg-protocol:msg-deprecation-warning "using old message class name ground_air_msgs-srv:<LoadMap-request> is deprecated: use ground_air_msgs-srv:LoadMap-request instead.")))

(cl:ensure-generic-function 'map_id-val :lambda-list '(m))
(cl:defmethod map_id-val ((m <LoadMap-request>))
  (roslisp-msg-protocol:msg-deprecation-warning "Using old-style slot reader ground_air_msgs-srv:map_id-val is deprecated.  Use ground_air_msgs-srv:map_id instead.")
  (map_id m))

(cl:ensure-generic-function 'source_uri-val :lambda-list '(m))
(cl:defmethod source_uri-val ((m <LoadMap-request>))
  (roslisp-msg-protocol:msg-deprecation-warning "Using old-style slot reader ground_air_msgs-srv:source_uri-val is deprecated.  Use ground_air_msgs-srv:source_uri instead.")
  (source_uri m))
(cl:defmethod roslisp-msg-protocol:serialize ((msg <LoadMap-request>) ostream)
  "Serializes a message object of type '<LoadMap-request>"
  (cl:let ((__ros_str_len (cl:length (cl:slot-value msg 'map_id))))
    (cl:write-byte (cl:ldb (cl:byte 8 0) __ros_str_len) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 8) __ros_str_len) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 16) __ros_str_len) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 24) __ros_str_len) ostream))
  (cl:map cl:nil #'(cl:lambda (c) (cl:write-byte (cl:char-code c) ostream)) (cl:slot-value msg 'map_id))
  (cl:let ((__ros_str_len (cl:length (cl:slot-value msg 'source_uri))))
    (cl:write-byte (cl:ldb (cl:byte 8 0) __ros_str_len) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 8) __ros_str_len) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 16) __ros_str_len) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 24) __ros_str_len) ostream))
  (cl:map cl:nil #'(cl:lambda (c) (cl:write-byte (cl:char-code c) ostream)) (cl:slot-value msg 'source_uri))
)
(cl:defmethod roslisp-msg-protocol:deserialize ((msg <LoadMap-request>) istream)
  "Deserializes a message object of type '<LoadMap-request>"
    (cl:let ((__ros_str_len 0))
      (cl:setf (cl:ldb (cl:byte 8 0) __ros_str_len) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 8) __ros_str_len) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 16) __ros_str_len) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 24) __ros_str_len) (cl:read-byte istream))
      (cl:setf (cl:slot-value msg 'map_id) (cl:make-string __ros_str_len))
      (cl:dotimes (__ros_str_idx __ros_str_len msg)
        (cl:setf (cl:char (cl:slot-value msg 'map_id) __ros_str_idx) (cl:code-char (cl:read-byte istream)))))
    (cl:let ((__ros_str_len 0))
      (cl:setf (cl:ldb (cl:byte 8 0) __ros_str_len) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 8) __ros_str_len) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 16) __ros_str_len) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 24) __ros_str_len) (cl:read-byte istream))
      (cl:setf (cl:slot-value msg 'source_uri) (cl:make-string __ros_str_len))
      (cl:dotimes (__ros_str_idx __ros_str_len msg)
        (cl:setf (cl:char (cl:slot-value msg 'source_uri) __ros_str_idx) (cl:code-char (cl:read-byte istream)))))
  msg
)
(cl:defmethod roslisp-msg-protocol:ros-datatype ((msg (cl:eql '<LoadMap-request>)))
  "Returns string type for a service object of type '<LoadMap-request>"
  "ground_air_msgs/LoadMapRequest")
(cl:defmethod roslisp-msg-protocol:ros-datatype ((msg (cl:eql 'LoadMap-request)))
  "Returns string type for a service object of type 'LoadMap-request"
  "ground_air_msgs/LoadMapRequest")
(cl:defmethod roslisp-msg-protocol:md5sum ((type (cl:eql '<LoadMap-request>)))
  "Returns md5sum for a message object of type '<LoadMap-request>"
  "0ad4fcd56eceaa84d4b9013dcb5a122f")
(cl:defmethod roslisp-msg-protocol:md5sum ((type (cl:eql 'LoadMap-request)))
  "Returns md5sum for a message object of type 'LoadMap-request"
  "0ad4fcd56eceaa84d4b9013dcb5a122f")
(cl:defmethod roslisp-msg-protocol:message-definition ((type (cl:eql '<LoadMap-request>)))
  "Returns full string definition for message of type '<LoadMap-request>"
  (cl:format cl:nil "string map_id~%string source_uri~%~%~%"))
(cl:defmethod roslisp-msg-protocol:message-definition ((type (cl:eql 'LoadMap-request)))
  "Returns full string definition for message of type 'LoadMap-request"
  (cl:format cl:nil "string map_id~%string source_uri~%~%~%"))
(cl:defmethod roslisp-msg-protocol:serialization-length ((msg <LoadMap-request>))
  (cl:+ 0
     4 (cl:length (cl:slot-value msg 'map_id))
     4 (cl:length (cl:slot-value msg 'source_uri))
))
(cl:defmethod roslisp-msg-protocol:ros-message-to-list ((msg <LoadMap-request>))
  "Converts a ROS message object to a list"
  (cl:list 'LoadMap-request
    (cl:cons ':map_id (map_id msg))
    (cl:cons ':source_uri (source_uri msg))
))
;//! \htmlinclude LoadMap-response.msg.html

(cl:defclass <LoadMap-response> (roslisp-msg-protocol:ros-message)
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
   (map_directory
    :reader map_directory
    :initarg :map_directory
    :type cl:string
    :initform ""))
)

(cl:defclass LoadMap-response (<LoadMap-response>)
  ())

(cl:defmethod cl:initialize-instance :after ((m <LoadMap-response>) cl:&rest args)
  (cl:declare (cl:ignorable args))
  (cl:unless (cl:typep m 'LoadMap-response)
    (roslisp-msg-protocol:msg-deprecation-warning "using old message class name ground_air_msgs-srv:<LoadMap-response> is deprecated: use ground_air_msgs-srv:LoadMap-response instead.")))

(cl:ensure-generic-function 'success-val :lambda-list '(m))
(cl:defmethod success-val ((m <LoadMap-response>))
  (roslisp-msg-protocol:msg-deprecation-warning "Using old-style slot reader ground_air_msgs-srv:success-val is deprecated.  Use ground_air_msgs-srv:success instead.")
  (success m))

(cl:ensure-generic-function 'message-val :lambda-list '(m))
(cl:defmethod message-val ((m <LoadMap-response>))
  (roslisp-msg-protocol:msg-deprecation-warning "Using old-style slot reader ground_air_msgs-srv:message-val is deprecated.  Use ground_air_msgs-srv:message instead.")
  (message m))

(cl:ensure-generic-function 'map_directory-val :lambda-list '(m))
(cl:defmethod map_directory-val ((m <LoadMap-response>))
  (roslisp-msg-protocol:msg-deprecation-warning "Using old-style slot reader ground_air_msgs-srv:map_directory-val is deprecated.  Use ground_air_msgs-srv:map_directory instead.")
  (map_directory m))
(cl:defmethod roslisp-msg-protocol:serialize ((msg <LoadMap-response>) ostream)
  "Serializes a message object of type '<LoadMap-response>"
  (cl:write-byte (cl:ldb (cl:byte 8 0) (cl:if (cl:slot-value msg 'success) 1 0)) ostream)
  (cl:let ((__ros_str_len (cl:length (cl:slot-value msg 'message))))
    (cl:write-byte (cl:ldb (cl:byte 8 0) __ros_str_len) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 8) __ros_str_len) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 16) __ros_str_len) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 24) __ros_str_len) ostream))
  (cl:map cl:nil #'(cl:lambda (c) (cl:write-byte (cl:char-code c) ostream)) (cl:slot-value msg 'message))
  (cl:let ((__ros_str_len (cl:length (cl:slot-value msg 'map_directory))))
    (cl:write-byte (cl:ldb (cl:byte 8 0) __ros_str_len) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 8) __ros_str_len) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 16) __ros_str_len) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 24) __ros_str_len) ostream))
  (cl:map cl:nil #'(cl:lambda (c) (cl:write-byte (cl:char-code c) ostream)) (cl:slot-value msg 'map_directory))
)
(cl:defmethod roslisp-msg-protocol:deserialize ((msg <LoadMap-response>) istream)
  "Deserializes a message object of type '<LoadMap-response>"
    (cl:setf (cl:slot-value msg 'success) (cl:not (cl:zerop (cl:read-byte istream))))
    (cl:let ((__ros_str_len 0))
      (cl:setf (cl:ldb (cl:byte 8 0) __ros_str_len) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 8) __ros_str_len) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 16) __ros_str_len) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 24) __ros_str_len) (cl:read-byte istream))
      (cl:setf (cl:slot-value msg 'message) (cl:make-string __ros_str_len))
      (cl:dotimes (__ros_str_idx __ros_str_len msg)
        (cl:setf (cl:char (cl:slot-value msg 'message) __ros_str_idx) (cl:code-char (cl:read-byte istream)))))
    (cl:let ((__ros_str_len 0))
      (cl:setf (cl:ldb (cl:byte 8 0) __ros_str_len) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 8) __ros_str_len) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 16) __ros_str_len) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 24) __ros_str_len) (cl:read-byte istream))
      (cl:setf (cl:slot-value msg 'map_directory) (cl:make-string __ros_str_len))
      (cl:dotimes (__ros_str_idx __ros_str_len msg)
        (cl:setf (cl:char (cl:slot-value msg 'map_directory) __ros_str_idx) (cl:code-char (cl:read-byte istream)))))
  msg
)
(cl:defmethod roslisp-msg-protocol:ros-datatype ((msg (cl:eql '<LoadMap-response>)))
  "Returns string type for a service object of type '<LoadMap-response>"
  "ground_air_msgs/LoadMapResponse")
(cl:defmethod roslisp-msg-protocol:ros-datatype ((msg (cl:eql 'LoadMap-response)))
  "Returns string type for a service object of type 'LoadMap-response"
  "ground_air_msgs/LoadMapResponse")
(cl:defmethod roslisp-msg-protocol:md5sum ((type (cl:eql '<LoadMap-response>)))
  "Returns md5sum for a message object of type '<LoadMap-response>"
  "0ad4fcd56eceaa84d4b9013dcb5a122f")
(cl:defmethod roslisp-msg-protocol:md5sum ((type (cl:eql 'LoadMap-response)))
  "Returns md5sum for a message object of type 'LoadMap-response"
  "0ad4fcd56eceaa84d4b9013dcb5a122f")
(cl:defmethod roslisp-msg-protocol:message-definition ((type (cl:eql '<LoadMap-response>)))
  "Returns full string definition for message of type '<LoadMap-response>"
  (cl:format cl:nil "bool success~%string message~%string map_directory~%~%~%~%"))
(cl:defmethod roslisp-msg-protocol:message-definition ((type (cl:eql 'LoadMap-response)))
  "Returns full string definition for message of type 'LoadMap-response"
  (cl:format cl:nil "bool success~%string message~%string map_directory~%~%~%~%"))
(cl:defmethod roslisp-msg-protocol:serialization-length ((msg <LoadMap-response>))
  (cl:+ 0
     1
     4 (cl:length (cl:slot-value msg 'message))
     4 (cl:length (cl:slot-value msg 'map_directory))
))
(cl:defmethod roslisp-msg-protocol:ros-message-to-list ((msg <LoadMap-response>))
  "Converts a ROS message object to a list"
  (cl:list 'LoadMap-response
    (cl:cons ':success (success msg))
    (cl:cons ':message (message msg))
    (cl:cons ':map_directory (map_directory msg))
))
(cl:defmethod roslisp-msg-protocol:service-request-type ((msg (cl:eql 'LoadMap)))
  'LoadMap-request)
(cl:defmethod roslisp-msg-protocol:service-response-type ((msg (cl:eql 'LoadMap)))
  'LoadMap-response)
(cl:defmethod roslisp-msg-protocol:ros-datatype ((msg (cl:eql 'LoadMap)))
  "Returns string type for a service object of type '<LoadMap>"
  "ground_air_msgs/LoadMap")