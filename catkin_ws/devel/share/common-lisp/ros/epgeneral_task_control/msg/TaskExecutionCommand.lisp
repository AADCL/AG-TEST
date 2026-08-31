; Auto-generated. Do not edit!


(cl:in-package epgeneral_task_control-msg)


;//! \htmlinclude TaskExecutionCommand.msg.html

(cl:defclass <TaskExecutionCommand> (roslisp-msg-protocol:ros-message)
  ((action
    :reader action
    :initarg :action
    :type cl:fixnum
    :initform 0)
   (request_id
    :reader request_id
    :initarg :request_id
    :type cl:string
    :initform "")
   (task_id
    :reader task_id
    :initarg :task_id
    :type cl:string
    :initform "")
   (subtask_id
    :reader subtask_id
    :initarg :subtask_id
    :type cl:string
    :initform "")
   (device_id
    :reader device_id
    :initarg :device_id
    :type cl:string
    :initform "")
   (execution_id
    :reader execution_id
    :initarg :execution_id
    :type cl:string
    :initform "")
   (revision
    :reader revision
    :initarg :revision
    :type cl:integer
    :initform 0)
   (xml_path
    :reader xml_path
    :initarg :xml_path
    :type cl:string
    :initform "")
   (frame_id
    :reader frame_id
    :initarg :frame_id
    :type cl:string
    :initform "")
   (map_id
    :reader map_id
    :initarg :map_id
    :type cl:string
    :initform "")
   (scheduled_at
    :reader scheduled_at
    :initarg :scheduled_at
    :type cl:real
    :initform 0))
)

(cl:defclass TaskExecutionCommand (<TaskExecutionCommand>)
  ())

(cl:defmethod cl:initialize-instance :after ((m <TaskExecutionCommand>) cl:&rest args)
  (cl:declare (cl:ignorable args))
  (cl:unless (cl:typep m 'TaskExecutionCommand)
    (roslisp-msg-protocol:msg-deprecation-warning "using old message class name epgeneral_task_control-msg:<TaskExecutionCommand> is deprecated: use epgeneral_task_control-msg:TaskExecutionCommand instead.")))

(cl:ensure-generic-function 'action-val :lambda-list '(m))
(cl:defmethod action-val ((m <TaskExecutionCommand>))
  (roslisp-msg-protocol:msg-deprecation-warning "Using old-style slot reader epgeneral_task_control-msg:action-val is deprecated.  Use epgeneral_task_control-msg:action instead.")
  (action m))

(cl:ensure-generic-function 'request_id-val :lambda-list '(m))
(cl:defmethod request_id-val ((m <TaskExecutionCommand>))
  (roslisp-msg-protocol:msg-deprecation-warning "Using old-style slot reader epgeneral_task_control-msg:request_id-val is deprecated.  Use epgeneral_task_control-msg:request_id instead.")
  (request_id m))

(cl:ensure-generic-function 'task_id-val :lambda-list '(m))
(cl:defmethod task_id-val ((m <TaskExecutionCommand>))
  (roslisp-msg-protocol:msg-deprecation-warning "Using old-style slot reader epgeneral_task_control-msg:task_id-val is deprecated.  Use epgeneral_task_control-msg:task_id instead.")
  (task_id m))

(cl:ensure-generic-function 'subtask_id-val :lambda-list '(m))
(cl:defmethod subtask_id-val ((m <TaskExecutionCommand>))
  (roslisp-msg-protocol:msg-deprecation-warning "Using old-style slot reader epgeneral_task_control-msg:subtask_id-val is deprecated.  Use epgeneral_task_control-msg:subtask_id instead.")
  (subtask_id m))

(cl:ensure-generic-function 'device_id-val :lambda-list '(m))
(cl:defmethod device_id-val ((m <TaskExecutionCommand>))
  (roslisp-msg-protocol:msg-deprecation-warning "Using old-style slot reader epgeneral_task_control-msg:device_id-val is deprecated.  Use epgeneral_task_control-msg:device_id instead.")
  (device_id m))

(cl:ensure-generic-function 'execution_id-val :lambda-list '(m))
(cl:defmethod execution_id-val ((m <TaskExecutionCommand>))
  (roslisp-msg-protocol:msg-deprecation-warning "Using old-style slot reader epgeneral_task_control-msg:execution_id-val is deprecated.  Use epgeneral_task_control-msg:execution_id instead.")
  (execution_id m))

(cl:ensure-generic-function 'revision-val :lambda-list '(m))
(cl:defmethod revision-val ((m <TaskExecutionCommand>))
  (roslisp-msg-protocol:msg-deprecation-warning "Using old-style slot reader epgeneral_task_control-msg:revision-val is deprecated.  Use epgeneral_task_control-msg:revision instead.")
  (revision m))

(cl:ensure-generic-function 'xml_path-val :lambda-list '(m))
(cl:defmethod xml_path-val ((m <TaskExecutionCommand>))
  (roslisp-msg-protocol:msg-deprecation-warning "Using old-style slot reader epgeneral_task_control-msg:xml_path-val is deprecated.  Use epgeneral_task_control-msg:xml_path instead.")
  (xml_path m))

(cl:ensure-generic-function 'frame_id-val :lambda-list '(m))
(cl:defmethod frame_id-val ((m <TaskExecutionCommand>))
  (roslisp-msg-protocol:msg-deprecation-warning "Using old-style slot reader epgeneral_task_control-msg:frame_id-val is deprecated.  Use epgeneral_task_control-msg:frame_id instead.")
  (frame_id m))

(cl:ensure-generic-function 'map_id-val :lambda-list '(m))
(cl:defmethod map_id-val ((m <TaskExecutionCommand>))
  (roslisp-msg-protocol:msg-deprecation-warning "Using old-style slot reader epgeneral_task_control-msg:map_id-val is deprecated.  Use epgeneral_task_control-msg:map_id instead.")
  (map_id m))

(cl:ensure-generic-function 'scheduled_at-val :lambda-list '(m))
(cl:defmethod scheduled_at-val ((m <TaskExecutionCommand>))
  (roslisp-msg-protocol:msg-deprecation-warning "Using old-style slot reader epgeneral_task_control-msg:scheduled_at-val is deprecated.  Use epgeneral_task_control-msg:scheduled_at instead.")
  (scheduled_at m))
(cl:defmethod roslisp-msg-protocol:symbol-codes ((msg-type (cl:eql '<TaskExecutionCommand>)))
    "Constants for message type '<TaskExecutionCommand>"
  '((:SCHEDULE . 1)
    (:CANCEL . 2)
    (:STOP . 3)
    (:PREPARE . 4)
    (:UNLOAD . 5))
)
(cl:defmethod roslisp-msg-protocol:symbol-codes ((msg-type (cl:eql 'TaskExecutionCommand)))
    "Constants for message type 'TaskExecutionCommand"
  '((:SCHEDULE . 1)
    (:CANCEL . 2)
    (:STOP . 3)
    (:PREPARE . 4)
    (:UNLOAD . 5))
)
(cl:defmethod roslisp-msg-protocol:serialize ((msg <TaskExecutionCommand>) ostream)
  "Serializes a message object of type '<TaskExecutionCommand>"
  (cl:write-byte (cl:ldb (cl:byte 8 0) (cl:slot-value msg 'action)) ostream)
  (cl:let ((__ros_str_len (cl:length (cl:slot-value msg 'request_id))))
    (cl:write-byte (cl:ldb (cl:byte 8 0) __ros_str_len) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 8) __ros_str_len) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 16) __ros_str_len) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 24) __ros_str_len) ostream))
  (cl:map cl:nil #'(cl:lambda (c) (cl:write-byte (cl:char-code c) ostream)) (cl:slot-value msg 'request_id))
  (cl:let ((__ros_str_len (cl:length (cl:slot-value msg 'task_id))))
    (cl:write-byte (cl:ldb (cl:byte 8 0) __ros_str_len) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 8) __ros_str_len) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 16) __ros_str_len) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 24) __ros_str_len) ostream))
  (cl:map cl:nil #'(cl:lambda (c) (cl:write-byte (cl:char-code c) ostream)) (cl:slot-value msg 'task_id))
  (cl:let ((__ros_str_len (cl:length (cl:slot-value msg 'subtask_id))))
    (cl:write-byte (cl:ldb (cl:byte 8 0) __ros_str_len) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 8) __ros_str_len) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 16) __ros_str_len) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 24) __ros_str_len) ostream))
  (cl:map cl:nil #'(cl:lambda (c) (cl:write-byte (cl:char-code c) ostream)) (cl:slot-value msg 'subtask_id))
  (cl:let ((__ros_str_len (cl:length (cl:slot-value msg 'device_id))))
    (cl:write-byte (cl:ldb (cl:byte 8 0) __ros_str_len) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 8) __ros_str_len) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 16) __ros_str_len) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 24) __ros_str_len) ostream))
  (cl:map cl:nil #'(cl:lambda (c) (cl:write-byte (cl:char-code c) ostream)) (cl:slot-value msg 'device_id))
  (cl:let ((__ros_str_len (cl:length (cl:slot-value msg 'execution_id))))
    (cl:write-byte (cl:ldb (cl:byte 8 0) __ros_str_len) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 8) __ros_str_len) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 16) __ros_str_len) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 24) __ros_str_len) ostream))
  (cl:map cl:nil #'(cl:lambda (c) (cl:write-byte (cl:char-code c) ostream)) (cl:slot-value msg 'execution_id))
  (cl:write-byte (cl:ldb (cl:byte 8 0) (cl:slot-value msg 'revision)) ostream)
  (cl:write-byte (cl:ldb (cl:byte 8 8) (cl:slot-value msg 'revision)) ostream)
  (cl:write-byte (cl:ldb (cl:byte 8 16) (cl:slot-value msg 'revision)) ostream)
  (cl:write-byte (cl:ldb (cl:byte 8 24) (cl:slot-value msg 'revision)) ostream)
  (cl:let ((__ros_str_len (cl:length (cl:slot-value msg 'xml_path))))
    (cl:write-byte (cl:ldb (cl:byte 8 0) __ros_str_len) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 8) __ros_str_len) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 16) __ros_str_len) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 24) __ros_str_len) ostream))
  (cl:map cl:nil #'(cl:lambda (c) (cl:write-byte (cl:char-code c) ostream)) (cl:slot-value msg 'xml_path))
  (cl:let ((__ros_str_len (cl:length (cl:slot-value msg 'frame_id))))
    (cl:write-byte (cl:ldb (cl:byte 8 0) __ros_str_len) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 8) __ros_str_len) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 16) __ros_str_len) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 24) __ros_str_len) ostream))
  (cl:map cl:nil #'(cl:lambda (c) (cl:write-byte (cl:char-code c) ostream)) (cl:slot-value msg 'frame_id))
  (cl:let ((__ros_str_len (cl:length (cl:slot-value msg 'map_id))))
    (cl:write-byte (cl:ldb (cl:byte 8 0) __ros_str_len) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 8) __ros_str_len) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 16) __ros_str_len) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 24) __ros_str_len) ostream))
  (cl:map cl:nil #'(cl:lambda (c) (cl:write-byte (cl:char-code c) ostream)) (cl:slot-value msg 'map_id))
  (cl:let ((__sec (cl:floor (cl:slot-value msg 'scheduled_at)))
        (__nsec (cl:round (cl:* 1e9 (cl:- (cl:slot-value msg 'scheduled_at) (cl:floor (cl:slot-value msg 'scheduled_at)))))))
    (cl:write-byte (cl:ldb (cl:byte 8 0) __sec) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 8) __sec) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 16) __sec) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 24) __sec) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 0) __nsec) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 8) __nsec) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 16) __nsec) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 24) __nsec) ostream))
)
(cl:defmethod roslisp-msg-protocol:deserialize ((msg <TaskExecutionCommand>) istream)
  "Deserializes a message object of type '<TaskExecutionCommand>"
    (cl:setf (cl:ldb (cl:byte 8 0) (cl:slot-value msg 'action)) (cl:read-byte istream))
    (cl:let ((__ros_str_len 0))
      (cl:setf (cl:ldb (cl:byte 8 0) __ros_str_len) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 8) __ros_str_len) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 16) __ros_str_len) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 24) __ros_str_len) (cl:read-byte istream))
      (cl:setf (cl:slot-value msg 'request_id) (cl:make-string __ros_str_len))
      (cl:dotimes (__ros_str_idx __ros_str_len msg)
        (cl:setf (cl:char (cl:slot-value msg 'request_id) __ros_str_idx) (cl:code-char (cl:read-byte istream)))))
    (cl:let ((__ros_str_len 0))
      (cl:setf (cl:ldb (cl:byte 8 0) __ros_str_len) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 8) __ros_str_len) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 16) __ros_str_len) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 24) __ros_str_len) (cl:read-byte istream))
      (cl:setf (cl:slot-value msg 'task_id) (cl:make-string __ros_str_len))
      (cl:dotimes (__ros_str_idx __ros_str_len msg)
        (cl:setf (cl:char (cl:slot-value msg 'task_id) __ros_str_idx) (cl:code-char (cl:read-byte istream)))))
    (cl:let ((__ros_str_len 0))
      (cl:setf (cl:ldb (cl:byte 8 0) __ros_str_len) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 8) __ros_str_len) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 16) __ros_str_len) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 24) __ros_str_len) (cl:read-byte istream))
      (cl:setf (cl:slot-value msg 'subtask_id) (cl:make-string __ros_str_len))
      (cl:dotimes (__ros_str_idx __ros_str_len msg)
        (cl:setf (cl:char (cl:slot-value msg 'subtask_id) __ros_str_idx) (cl:code-char (cl:read-byte istream)))))
    (cl:let ((__ros_str_len 0))
      (cl:setf (cl:ldb (cl:byte 8 0) __ros_str_len) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 8) __ros_str_len) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 16) __ros_str_len) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 24) __ros_str_len) (cl:read-byte istream))
      (cl:setf (cl:slot-value msg 'device_id) (cl:make-string __ros_str_len))
      (cl:dotimes (__ros_str_idx __ros_str_len msg)
        (cl:setf (cl:char (cl:slot-value msg 'device_id) __ros_str_idx) (cl:code-char (cl:read-byte istream)))))
    (cl:let ((__ros_str_len 0))
      (cl:setf (cl:ldb (cl:byte 8 0) __ros_str_len) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 8) __ros_str_len) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 16) __ros_str_len) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 24) __ros_str_len) (cl:read-byte istream))
      (cl:setf (cl:slot-value msg 'execution_id) (cl:make-string __ros_str_len))
      (cl:dotimes (__ros_str_idx __ros_str_len msg)
        (cl:setf (cl:char (cl:slot-value msg 'execution_id) __ros_str_idx) (cl:code-char (cl:read-byte istream)))))
    (cl:setf (cl:ldb (cl:byte 8 0) (cl:slot-value msg 'revision)) (cl:read-byte istream))
    (cl:setf (cl:ldb (cl:byte 8 8) (cl:slot-value msg 'revision)) (cl:read-byte istream))
    (cl:setf (cl:ldb (cl:byte 8 16) (cl:slot-value msg 'revision)) (cl:read-byte istream))
    (cl:setf (cl:ldb (cl:byte 8 24) (cl:slot-value msg 'revision)) (cl:read-byte istream))
    (cl:let ((__ros_str_len 0))
      (cl:setf (cl:ldb (cl:byte 8 0) __ros_str_len) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 8) __ros_str_len) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 16) __ros_str_len) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 24) __ros_str_len) (cl:read-byte istream))
      (cl:setf (cl:slot-value msg 'xml_path) (cl:make-string __ros_str_len))
      (cl:dotimes (__ros_str_idx __ros_str_len msg)
        (cl:setf (cl:char (cl:slot-value msg 'xml_path) __ros_str_idx) (cl:code-char (cl:read-byte istream)))))
    (cl:let ((__ros_str_len 0))
      (cl:setf (cl:ldb (cl:byte 8 0) __ros_str_len) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 8) __ros_str_len) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 16) __ros_str_len) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 24) __ros_str_len) (cl:read-byte istream))
      (cl:setf (cl:slot-value msg 'frame_id) (cl:make-string __ros_str_len))
      (cl:dotimes (__ros_str_idx __ros_str_len msg)
        (cl:setf (cl:char (cl:slot-value msg 'frame_id) __ros_str_idx) (cl:code-char (cl:read-byte istream)))))
    (cl:let ((__ros_str_len 0))
      (cl:setf (cl:ldb (cl:byte 8 0) __ros_str_len) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 8) __ros_str_len) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 16) __ros_str_len) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 24) __ros_str_len) (cl:read-byte istream))
      (cl:setf (cl:slot-value msg 'map_id) (cl:make-string __ros_str_len))
      (cl:dotimes (__ros_str_idx __ros_str_len msg)
        (cl:setf (cl:char (cl:slot-value msg 'map_id) __ros_str_idx) (cl:code-char (cl:read-byte istream)))))
    (cl:let ((__sec 0) (__nsec 0))
      (cl:setf (cl:ldb (cl:byte 8 0) __sec) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 8) __sec) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 16) __sec) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 24) __sec) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 0) __nsec) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 8) __nsec) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 16) __nsec) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 24) __nsec) (cl:read-byte istream))
      (cl:setf (cl:slot-value msg 'scheduled_at) (cl:+ (cl:coerce __sec 'cl:double-float) (cl:/ __nsec 1e9))))
  msg
)
(cl:defmethod roslisp-msg-protocol:ros-datatype ((msg (cl:eql '<TaskExecutionCommand>)))
  "Returns string type for a message object of type '<TaskExecutionCommand>"
  "epgeneral_task_control/TaskExecutionCommand")
(cl:defmethod roslisp-msg-protocol:ros-datatype ((msg (cl:eql 'TaskExecutionCommand)))
  "Returns string type for a message object of type 'TaskExecutionCommand"
  "epgeneral_task_control/TaskExecutionCommand")
(cl:defmethod roslisp-msg-protocol:md5sum ((type (cl:eql '<TaskExecutionCommand>)))
  "Returns md5sum for a message object of type '<TaskExecutionCommand>"
  "b02f521e09d483449a5b659a3a48f813")
(cl:defmethod roslisp-msg-protocol:md5sum ((type (cl:eql 'TaskExecutionCommand)))
  "Returns md5sum for a message object of type 'TaskExecutionCommand"
  "b02f521e09d483449a5b659a3a48f813")
(cl:defmethod roslisp-msg-protocol:message-definition ((type (cl:eql '<TaskExecutionCommand>)))
  "Returns full string definition for message of type '<TaskExecutionCommand>"
  (cl:format cl:nil "uint8 SCHEDULE=1~%uint8 CANCEL=2~%uint8 STOP=3~%uint8 PREPARE=4~%uint8 UNLOAD=5~%uint8 action~%string request_id~%string task_id~%string subtask_id~%string device_id~%string execution_id~%uint32 revision~%string xml_path~%string frame_id~%string map_id~%time scheduled_at~%~%~%"))
(cl:defmethod roslisp-msg-protocol:message-definition ((type (cl:eql 'TaskExecutionCommand)))
  "Returns full string definition for message of type 'TaskExecutionCommand"
  (cl:format cl:nil "uint8 SCHEDULE=1~%uint8 CANCEL=2~%uint8 STOP=3~%uint8 PREPARE=4~%uint8 UNLOAD=5~%uint8 action~%string request_id~%string task_id~%string subtask_id~%string device_id~%string execution_id~%uint32 revision~%string xml_path~%string frame_id~%string map_id~%time scheduled_at~%~%~%"))
(cl:defmethod roslisp-msg-protocol:serialization-length ((msg <TaskExecutionCommand>))
  (cl:+ 0
     1
     4 (cl:length (cl:slot-value msg 'request_id))
     4 (cl:length (cl:slot-value msg 'task_id))
     4 (cl:length (cl:slot-value msg 'subtask_id))
     4 (cl:length (cl:slot-value msg 'device_id))
     4 (cl:length (cl:slot-value msg 'execution_id))
     4
     4 (cl:length (cl:slot-value msg 'xml_path))
     4 (cl:length (cl:slot-value msg 'frame_id))
     4 (cl:length (cl:slot-value msg 'map_id))
     8
))
(cl:defmethod roslisp-msg-protocol:ros-message-to-list ((msg <TaskExecutionCommand>))
  "Converts a ROS message object to a list"
  (cl:list 'TaskExecutionCommand
    (cl:cons ':action (action msg))
    (cl:cons ':request_id (request_id msg))
    (cl:cons ':task_id (task_id msg))
    (cl:cons ':subtask_id (subtask_id msg))
    (cl:cons ':device_id (device_id msg))
    (cl:cons ':execution_id (execution_id msg))
    (cl:cons ':revision (revision msg))
    (cl:cons ':xml_path (xml_path msg))
    (cl:cons ':frame_id (frame_id msg))
    (cl:cons ':map_id (map_id msg))
    (cl:cons ':scheduled_at (scheduled_at msg))
))
