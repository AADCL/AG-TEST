;; Auto-generated. Do not edit!


(when (boundp 'epgeneral_task_control::TaskExecutionFeedback)
  (if (not (find-package "EPGENERAL_TASK_CONTROL"))
    (make-package "EPGENERAL_TASK_CONTROL"))
  (shadow 'TaskExecutionFeedback (find-package "EPGENERAL_TASK_CONTROL")))
(unless (find-package "EPGENERAL_TASK_CONTROL::TASKEXECUTIONFEEDBACK")
  (make-package "EPGENERAL_TASK_CONTROL::TASKEXECUTIONFEEDBACK"))

(in-package "ROS")
;;//! \htmlinclude TaskExecutionFeedback.msg.html
(if (not (find-package "GEOMETRY_MSGS"))
  (ros::roseus-add-msgs "geometry_msgs"))


(defclass epgeneral_task_control::TaskExecutionFeedback
  :super ros::object
  :slots (_request_id _task_id _subtask_id _device_id _execution_id _revision _state _waypoint_index _waypoint_count _progress _position _error_code _message ))

(defmethod epgeneral_task_control::TaskExecutionFeedback
  (:init
   (&key
    ((:request_id __request_id) "")
    ((:task_id __task_id) "")
    ((:subtask_id __subtask_id) "")
    ((:device_id __device_id) "")
    ((:execution_id __execution_id) "")
    ((:revision __revision) 0)
    ((:state __state) "")
    ((:waypoint_index __waypoint_index) 0)
    ((:waypoint_count __waypoint_count) 0)
    ((:progress __progress) 0.0)
    ((:position __position) (instance geometry_msgs::Point :init))
    ((:error_code __error_code) "")
    ((:message __message) "")
    )
   (send-super :init)
   (setq _request_id (string __request_id))
   (setq _task_id (string __task_id))
   (setq _subtask_id (string __subtask_id))
   (setq _device_id (string __device_id))
   (setq _execution_id (string __execution_id))
   (setq _revision (round __revision))
   (setq _state (string __state))
   (setq _waypoint_index (round __waypoint_index))
   (setq _waypoint_count (round __waypoint_count))
   (setq _progress (float __progress))
   (setq _position __position)
   (setq _error_code (string __error_code))
   (setq _message (string __message))
   self)
  (:request_id
   (&optional __request_id)
   (if __request_id (setq _request_id __request_id)) _request_id)
  (:task_id
   (&optional __task_id)
   (if __task_id (setq _task_id __task_id)) _task_id)
  (:subtask_id
   (&optional __subtask_id)
   (if __subtask_id (setq _subtask_id __subtask_id)) _subtask_id)
  (:device_id
   (&optional __device_id)
   (if __device_id (setq _device_id __device_id)) _device_id)
  (:execution_id
   (&optional __execution_id)
   (if __execution_id (setq _execution_id __execution_id)) _execution_id)
  (:revision
   (&optional __revision)
   (if __revision (setq _revision __revision)) _revision)
  (:state
   (&optional __state)
   (if __state (setq _state __state)) _state)
  (:waypoint_index
   (&optional __waypoint_index)
   (if __waypoint_index (setq _waypoint_index __waypoint_index)) _waypoint_index)
  (:waypoint_count
   (&optional __waypoint_count)
   (if __waypoint_count (setq _waypoint_count __waypoint_count)) _waypoint_count)
  (:progress
   (&optional __progress)
   (if __progress (setq _progress __progress)) _progress)
  (:position
   (&rest __position)
   (if (keywordp (car __position))
       (send* _position __position)
     (progn
       (if __position (setq _position (car __position)))
       _position)))
  (:error_code
   (&optional __error_code)
   (if __error_code (setq _error_code __error_code)) _error_code)
  (:message
   (&optional __message)
   (if __message (setq _message __message)) _message)
  (:serialization-length
   ()
   (+
    ;; string _request_id
    4 (length _request_id)
    ;; string _task_id
    4 (length _task_id)
    ;; string _subtask_id
    4 (length _subtask_id)
    ;; string _device_id
    4 (length _device_id)
    ;; string _execution_id
    4 (length _execution_id)
    ;; uint32 _revision
    4
    ;; string _state
    4 (length _state)
    ;; int32 _waypoint_index
    4
    ;; int32 _waypoint_count
    4
    ;; float64 _progress
    8
    ;; geometry_msgs/Point _position
    (send _position :serialization-length)
    ;; string _error_code
    4 (length _error_code)
    ;; string _message
    4 (length _message)
    ))
  (:serialize
   (&optional strm)
   (let ((s (if strm strm
              (make-string-output-stream (send self :serialization-length)))))
     ;; string _request_id
       (write-long (length _request_id) s) (princ _request_id s)
     ;; string _task_id
       (write-long (length _task_id) s) (princ _task_id s)
     ;; string _subtask_id
       (write-long (length _subtask_id) s) (princ _subtask_id s)
     ;; string _device_id
       (write-long (length _device_id) s) (princ _device_id s)
     ;; string _execution_id
       (write-long (length _execution_id) s) (princ _execution_id s)
     ;; uint32 _revision
       (write-long _revision s)
     ;; string _state
       (write-long (length _state) s) (princ _state s)
     ;; int32 _waypoint_index
       (write-long _waypoint_index s)
     ;; int32 _waypoint_count
       (write-long _waypoint_count s)
     ;; float64 _progress
       (sys::poke _progress (send s :buffer) (send s :count) :double) (incf (stream-count s) 8)
     ;; geometry_msgs/Point _position
       (send _position :serialize s)
     ;; string _error_code
       (write-long (length _error_code) s) (princ _error_code s)
     ;; string _message
       (write-long (length _message) s) (princ _message s)
     ;;
     (if (null strm) (get-output-stream-string s))))
  (:deserialize
   (buf &optional (ptr- 0))
   ;; string _request_id
     (let (n) (setq n (sys::peek buf ptr- :integer)) (incf ptr- 4) (setq _request_id (subseq buf ptr- (+ ptr- n))) (incf ptr- n))
   ;; string _task_id
     (let (n) (setq n (sys::peek buf ptr- :integer)) (incf ptr- 4) (setq _task_id (subseq buf ptr- (+ ptr- n))) (incf ptr- n))
   ;; string _subtask_id
     (let (n) (setq n (sys::peek buf ptr- :integer)) (incf ptr- 4) (setq _subtask_id (subseq buf ptr- (+ ptr- n))) (incf ptr- n))
   ;; string _device_id
     (let (n) (setq n (sys::peek buf ptr- :integer)) (incf ptr- 4) (setq _device_id (subseq buf ptr- (+ ptr- n))) (incf ptr- n))
   ;; string _execution_id
     (let (n) (setq n (sys::peek buf ptr- :integer)) (incf ptr- 4) (setq _execution_id (subseq buf ptr- (+ ptr- n))) (incf ptr- n))
   ;; uint32 _revision
     (setq _revision (sys::peek buf ptr- :integer)) (incf ptr- 4)
   ;; string _state
     (let (n) (setq n (sys::peek buf ptr- :integer)) (incf ptr- 4) (setq _state (subseq buf ptr- (+ ptr- n))) (incf ptr- n))
   ;; int32 _waypoint_index
     (setq _waypoint_index (sys::peek buf ptr- :integer)) (incf ptr- 4)
   ;; int32 _waypoint_count
     (setq _waypoint_count (sys::peek buf ptr- :integer)) (incf ptr- 4)
   ;; float64 _progress
     (setq _progress (sys::peek buf ptr- :double)) (incf ptr- 8)
   ;; geometry_msgs/Point _position
     (send _position :deserialize buf ptr-) (incf ptr- (send _position :serialization-length))
   ;; string _error_code
     (let (n) (setq n (sys::peek buf ptr- :integer)) (incf ptr- 4) (setq _error_code (subseq buf ptr- (+ ptr- n))) (incf ptr- n))
   ;; string _message
     (let (n) (setq n (sys::peek buf ptr- :integer)) (incf ptr- 4) (setq _message (subseq buf ptr- (+ ptr- n))) (incf ptr- n))
   ;;
   self)
  )

(setf (get epgeneral_task_control::TaskExecutionFeedback :md5sum-) "992f61c604e3ed23f3589fd880757815")
(setf (get epgeneral_task_control::TaskExecutionFeedback :datatype-) "epgeneral_task_control/TaskExecutionFeedback")
(setf (get epgeneral_task_control::TaskExecutionFeedback :definition-)
      "string request_id
string task_id
string subtask_id
string device_id
string execution_id
uint32 revision
string state
int32 waypoint_index
int32 waypoint_count
float64 progress
geometry_msgs/Point position
string error_code
string message

================================================================================
MSG: geometry_msgs/Point
# This contains the position of a point in free space
float64 x
float64 y
float64 z

")



(provide :epgeneral_task_control/TaskExecutionFeedback "992f61c604e3ed23f3589fd880757815")


