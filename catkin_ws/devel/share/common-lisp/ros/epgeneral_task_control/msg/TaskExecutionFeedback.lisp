; Auto-generated. Do not edit!


(cl:in-package epgeneral_task_control-msg)


;//! \htmlinclude TaskExecutionFeedback.msg.html

(cl:defclass <TaskExecutionFeedback> (roslisp-msg-protocol:ros-message)
  ((request_id
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
   (state
    :reader state
    :initarg :state
    :type cl:string
    :initform "")
   (waypoint_index
    :reader waypoint_index
    :initarg :waypoint_index
    :type cl:integer
    :initform 0)
   (waypoint_count
    :reader waypoint_count
    :initarg :waypoint_count
    :type cl:integer
    :initform 0)
   (progress
    :reader progress
    :initarg :progress
    :type cl:float
    :initform 0.0)
   (position
    :reader position
    :initarg :position
    :type geometry_msgs-msg:Point
    :initform (cl:make-instance 'geometry_msgs-msg:Point))
   (error_code
    :reader error_code
    :initarg :error_code
    :type cl:string
    :initform "")
   (message
    :reader message
    :initarg :message
    :type cl:string
    :initform ""))
)

(cl:defclass TaskExecutionFeedback (<TaskExecutionFeedback>)
  ())

(cl:defmethod cl:initialize-instance :after ((m <TaskExecutionFeedback>) cl:&rest args)
  (cl:declare (cl:ignorable args))
  (cl:unless (cl:typep m 'TaskExecutionFeedback)
    (roslisp-msg-protocol:msg-deprecation-warning "using old message class name epgeneral_task_control-msg:<TaskExecutionFeedback> is deprecated: use epgeneral_task_control-msg:TaskExecutionFeedback instead.")))

(cl:ensure-generic-function 'request_id-val :lambda-list '(m))
(cl:defmethod request_id-val ((m <TaskExecutionFeedback>))
  (roslisp-msg-protocol:msg-deprecation-warning "Using old-style slot reader epgeneral_task_control-msg:request_id-val is deprecated.  Use epgeneral_task_control-msg:request_id instead.")
  (request_id m))

(cl:ensure-generic-function 'task_id-val :lambda-list '(m))
(cl:defmethod task_id-val ((m <TaskExecutionFeedback>))
  (roslisp-msg-protocol:msg-deprecation-warning "Using old-style slot reader epgeneral_task_control-msg:task_id-val is deprecated.  Use epgeneral_task_control-msg:task_id instead.")
  (task_id m))

(cl:ensure-generic-function 'subtask_id-val :lambda-list '(m))
(cl:defmethod subtask_id-val ((m <TaskExecutionFeedback>))
  (roslisp-msg-protocol:msg-deprecation-warning "Using old-style slot reader epgeneral_task_control-msg:subtask_id-val is deprecated.  Use epgeneral_task_control-msg:subtask_id instead.")
  (subtask_id m))

(cl:ensure-generic-function 'device_id-val :lambda-list '(m))
(cl:defmethod device_id-val ((m <TaskExecutionFeedback>))
  (roslisp-msg-protocol:msg-deprecation-warning "Using old-style slot reader epgeneral_task_control-msg:device_id-val is deprecated.  Use epgeneral_task_control-msg:device_id instead.")
  (device_id m))

(cl:ensure-generic-function 'execution_id-val :lambda-list '(m))
(cl:defmethod execution_id-val ((m <TaskExecutionFeedback>))
  (roslisp-msg-protocol:msg-deprecation-warning "Using old-style slot reader epgeneral_task_control-msg:execution_id-val is deprecated.  Use epgeneral_task_control-msg:execution_id instead.")
  (execution_id m))

(cl:ensure-generic-function 'revision-val :lambda-list '(m))
(cl:defmethod revision-val ((m <TaskExecutionFeedback>))
  (roslisp-msg-protocol:msg-deprecation-warning "Using old-style slot reader epgeneral_task_control-msg:revision-val is deprecated.  Use epgeneral_task_control-msg:revision instead.")
  (revision m))

(cl:ensure-generic-function 'state-val :lambda-list '(m))
(cl:defmethod state-val ((m <TaskExecutionFeedback>))
  (roslisp-msg-protocol:msg-deprecation-warning "Using old-style slot reader epgeneral_task_control-msg:state-val is deprecated.  Use epgeneral_task_control-msg:state instead.")
  (state m))

(cl:ensure-generic-function 'waypoint_index-val :lambda-list '(m))
(cl:defmethod waypoint_index-val ((m <TaskExecutionFeedback>))
  (roslisp-msg-protocol:msg-deprecation-warning "Using old-style slot reader epgeneral_task_control-msg:waypoint_index-val is deprecated.  Use epgeneral_task_control-msg:waypoint_index instead.")
  (waypoint_index m))

(cl:ensure-generic-function 'waypoint_count-val :lambda-list '(m))
(cl:defmethod waypoint_count-val ((m <TaskExecutionFeedback>))
  (roslisp-msg-protocol:msg-deprecation-warning "Using old-style slot reader epgeneral_task_control-msg:waypoint_count-val is deprecated.  Use epgeneral_task_control-msg:waypoint_count instead.")
  (waypoint_count m))

(cl:ensure-generic-function 'progress-val :lambda-list '(m))
(cl:defmethod progress-val ((m <TaskExecutionFeedback>))
  (roslisp-msg-protocol:msg-deprecation-warning "Using old-style slot reader epgeneral_task_control-msg:progress-val is deprecated.  Use epgeneral_task_control-msg:progress instead.")
  (progress m))

(cl:ensure-generic-function 'position-val :lambda-list '(m))
(cl:defmethod position-val ((m <TaskExecutionFeedback>))
  (roslisp-msg-protocol:msg-deprecation-warning "Using old-style slot reader epgeneral_task_control-msg:position-val is deprecated.  Use epgeneral_task_control-msg:position instead.")
  (position m))

(cl:ensure-generic-function 'error_code-val :lambda-list '(m))
(cl:defmethod error_code-val ((m <TaskExecutionFeedback>))
  (roslisp-msg-protocol:msg-deprecation-warning "Using old-style slot reader epgeneral_task_control-msg:error_code-val is deprecated.  Use epgeneral_task_control-msg:error_code instead.")
  (error_code m))

(cl:ensure-generic-function 'message-val :lambda-list '(m))
(cl:defmethod message-val ((m <TaskExecutionFeedback>))
  (roslisp-msg-protocol:msg-deprecation-warning "Using old-style slot reader epgeneral_task_control-msg:message-val is deprecated.  Use epgeneral_task_control-msg:message instead.")
  (message m))
(cl:defmethod roslisp-msg-protocol:serialize ((msg <TaskExecutionFeedback>) ostream)
  "Serializes a message object of type '<TaskExecutionFeedback>"
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
  (cl:let ((__ros_str_len (cl:length (cl:slot-value msg 'state))))
    (cl:write-byte (cl:ldb (cl:byte 8 0) __ros_str_len) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 8) __ros_str_len) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 16) __ros_str_len) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 24) __ros_str_len) ostream))
  (cl:map cl:nil #'(cl:lambda (c) (cl:write-byte (cl:char-code c) ostream)) (cl:slot-value msg 'state))
  (cl:let* ((signed (cl:slot-value msg 'waypoint_index)) (unsigned (cl:if (cl:< signed 0) (cl:+ signed 4294967296) signed)))
    (cl:write-byte (cl:ldb (cl:byte 8 0) unsigned) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 8) unsigned) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 16) unsigned) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 24) unsigned) ostream)
    )
  (cl:let* ((signed (cl:slot-value msg 'waypoint_count)) (unsigned (cl:if (cl:< signed 0) (cl:+ signed 4294967296) signed)))
    (cl:write-byte (cl:ldb (cl:byte 8 0) unsigned) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 8) unsigned) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 16) unsigned) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 24) unsigned) ostream)
    )
  (cl:let ((bits (roslisp-utils:encode-double-float-bits (cl:slot-value msg 'progress))))
    (cl:write-byte (cl:ldb (cl:byte 8 0) bits) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 8) bits) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 16) bits) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 24) bits) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 32) bits) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 40) bits) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 48) bits) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 56) bits) ostream))
  (roslisp-msg-protocol:serialize (cl:slot-value msg 'position) ostream)
  (cl:let ((__ros_str_len (cl:length (cl:slot-value msg 'error_code))))
    (cl:write-byte (cl:ldb (cl:byte 8 0) __ros_str_len) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 8) __ros_str_len) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 16) __ros_str_len) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 24) __ros_str_len) ostream))
  (cl:map cl:nil #'(cl:lambda (c) (cl:write-byte (cl:char-code c) ostream)) (cl:slot-value msg 'error_code))
  (cl:let ((__ros_str_len (cl:length (cl:slot-value msg 'message))))
    (cl:write-byte (cl:ldb (cl:byte 8 0) __ros_str_len) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 8) __ros_str_len) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 16) __ros_str_len) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 24) __ros_str_len) ostream))
  (cl:map cl:nil #'(cl:lambda (c) (cl:write-byte (cl:char-code c) ostream)) (cl:slot-value msg 'message))
)
(cl:defmethod roslisp-msg-protocol:deserialize ((msg <TaskExecutionFeedback>) istream)
  "Deserializes a message object of type '<TaskExecutionFeedback>"
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
      (cl:setf (cl:slot-value msg 'state) (cl:make-string __ros_str_len))
      (cl:dotimes (__ros_str_idx __ros_str_len msg)
        (cl:setf (cl:char (cl:slot-value msg 'state) __ros_str_idx) (cl:code-char (cl:read-byte istream)))))
    (cl:let ((unsigned 0))
      (cl:setf (cl:ldb (cl:byte 8 0) unsigned) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 8) unsigned) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 16) unsigned) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 24) unsigned) (cl:read-byte istream))
      (cl:setf (cl:slot-value msg 'waypoint_index) (cl:if (cl:< unsigned 2147483648) unsigned (cl:- unsigned 4294967296))))
    (cl:let ((unsigned 0))
      (cl:setf (cl:ldb (cl:byte 8 0) unsigned) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 8) unsigned) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 16) unsigned) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 24) unsigned) (cl:read-byte istream))
      (cl:setf (cl:slot-value msg 'waypoint_count) (cl:if (cl:< unsigned 2147483648) unsigned (cl:- unsigned 4294967296))))
    (cl:let ((bits 0))
      (cl:setf (cl:ldb (cl:byte 8 0) bits) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 8) bits) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 16) bits) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 24) bits) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 32) bits) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 40) bits) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 48) bits) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 56) bits) (cl:read-byte istream))
    (cl:setf (cl:slot-value msg 'progress) (roslisp-utils:decode-double-float-bits bits)))
  (roslisp-msg-protocol:deserialize (cl:slot-value msg 'position) istream)
    (cl:let ((__ros_str_len 0))
      (cl:setf (cl:ldb (cl:byte 8 0) __ros_str_len) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 8) __ros_str_len) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 16) __ros_str_len) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 24) __ros_str_len) (cl:read-byte istream))
      (cl:setf (cl:slot-value msg 'error_code) (cl:make-string __ros_str_len))
      (cl:dotimes (__ros_str_idx __ros_str_len msg)
        (cl:setf (cl:char (cl:slot-value msg 'error_code) __ros_str_idx) (cl:code-char (cl:read-byte istream)))))
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
(cl:defmethod roslisp-msg-protocol:ros-datatype ((msg (cl:eql '<TaskExecutionFeedback>)))
  "Returns string type for a message object of type '<TaskExecutionFeedback>"
  "epgeneral_task_control/TaskExecutionFeedback")
(cl:defmethod roslisp-msg-protocol:ros-datatype ((msg (cl:eql 'TaskExecutionFeedback)))
  "Returns string type for a message object of type 'TaskExecutionFeedback"
  "epgeneral_task_control/TaskExecutionFeedback")
(cl:defmethod roslisp-msg-protocol:md5sum ((type (cl:eql '<TaskExecutionFeedback>)))
  "Returns md5sum for a message object of type '<TaskExecutionFeedback>"
  "992f61c604e3ed23f3589fd880757815")
(cl:defmethod roslisp-msg-protocol:md5sum ((type (cl:eql 'TaskExecutionFeedback)))
  "Returns md5sum for a message object of type 'TaskExecutionFeedback"
  "992f61c604e3ed23f3589fd880757815")
(cl:defmethod roslisp-msg-protocol:message-definition ((type (cl:eql '<TaskExecutionFeedback>)))
  "Returns full string definition for message of type '<TaskExecutionFeedback>"
  (cl:format cl:nil "string request_id~%string task_id~%string subtask_id~%string device_id~%string execution_id~%uint32 revision~%string state~%int32 waypoint_index~%int32 waypoint_count~%float64 progress~%geometry_msgs/Point position~%string error_code~%string message~%~%================================================================================~%MSG: geometry_msgs/Point~%# This contains the position of a point in free space~%float64 x~%float64 y~%float64 z~%~%~%"))
(cl:defmethod roslisp-msg-protocol:message-definition ((type (cl:eql 'TaskExecutionFeedback)))
  "Returns full string definition for message of type 'TaskExecutionFeedback"
  (cl:format cl:nil "string request_id~%string task_id~%string subtask_id~%string device_id~%string execution_id~%uint32 revision~%string state~%int32 waypoint_index~%int32 waypoint_count~%float64 progress~%geometry_msgs/Point position~%string error_code~%string message~%~%================================================================================~%MSG: geometry_msgs/Point~%# This contains the position of a point in free space~%float64 x~%float64 y~%float64 z~%~%~%"))
(cl:defmethod roslisp-msg-protocol:serialization-length ((msg <TaskExecutionFeedback>))
  (cl:+ 0
     4 (cl:length (cl:slot-value msg 'request_id))
     4 (cl:length (cl:slot-value msg 'task_id))
     4 (cl:length (cl:slot-value msg 'subtask_id))
     4 (cl:length (cl:slot-value msg 'device_id))
     4 (cl:length (cl:slot-value msg 'execution_id))
     4
     4 (cl:length (cl:slot-value msg 'state))
     4
     4
     8
     (roslisp-msg-protocol:serialization-length (cl:slot-value msg 'position))
     4 (cl:length (cl:slot-value msg 'error_code))
     4 (cl:length (cl:slot-value msg 'message))
))
(cl:defmethod roslisp-msg-protocol:ros-message-to-list ((msg <TaskExecutionFeedback>))
  "Converts a ROS message object to a list"
  (cl:list 'TaskExecutionFeedback
    (cl:cons ':request_id (request_id msg))
    (cl:cons ':task_id (task_id msg))
    (cl:cons ':subtask_id (subtask_id msg))
    (cl:cons ':device_id (device_id msg))
    (cl:cons ':execution_id (execution_id msg))
    (cl:cons ':revision (revision msg))
    (cl:cons ':state (state msg))
    (cl:cons ':waypoint_index (waypoint_index msg))
    (cl:cons ':waypoint_count (waypoint_count msg))
    (cl:cons ':progress (progress msg))
    (cl:cons ':position (position msg))
    (cl:cons ':error_code (error_code msg))
    (cl:cons ':message (message msg))
))
