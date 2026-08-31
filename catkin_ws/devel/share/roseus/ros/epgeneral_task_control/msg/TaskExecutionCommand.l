;; Auto-generated. Do not edit!


(when (boundp 'epgeneral_task_control::TaskExecutionCommand)
  (if (not (find-package "EPGENERAL_TASK_CONTROL"))
    (make-package "EPGENERAL_TASK_CONTROL"))
  (shadow 'TaskExecutionCommand (find-package "EPGENERAL_TASK_CONTROL")))
(unless (find-package "EPGENERAL_TASK_CONTROL::TASKEXECUTIONCOMMAND")
  (make-package "EPGENERAL_TASK_CONTROL::TASKEXECUTIONCOMMAND"))

(in-package "ROS")
;;//! \htmlinclude TaskExecutionCommand.msg.html


(intern "*SCHEDULE*" (find-package "EPGENERAL_TASK_CONTROL::TASKEXECUTIONCOMMAND"))
(shadow '*SCHEDULE* (find-package "EPGENERAL_TASK_CONTROL::TASKEXECUTIONCOMMAND"))
(defconstant epgeneral_task_control::TaskExecutionCommand::*SCHEDULE* 1)
(intern "*CANCEL*" (find-package "EPGENERAL_TASK_CONTROL::TASKEXECUTIONCOMMAND"))
(shadow '*CANCEL* (find-package "EPGENERAL_TASK_CONTROL::TASKEXECUTIONCOMMAND"))
(defconstant epgeneral_task_control::TaskExecutionCommand::*CANCEL* 2)
(intern "*STOP*" (find-package "EPGENERAL_TASK_CONTROL::TASKEXECUTIONCOMMAND"))
(shadow '*STOP* (find-package "EPGENERAL_TASK_CONTROL::TASKEXECUTIONCOMMAND"))
(defconstant epgeneral_task_control::TaskExecutionCommand::*STOP* 3)
(intern "*PREPARE*" (find-package "EPGENERAL_TASK_CONTROL::TASKEXECUTIONCOMMAND"))
(shadow '*PREPARE* (find-package "EPGENERAL_TASK_CONTROL::TASKEXECUTIONCOMMAND"))
(defconstant epgeneral_task_control::TaskExecutionCommand::*PREPARE* 4)
(intern "*UNLOAD*" (find-package "EPGENERAL_TASK_CONTROL::TASKEXECUTIONCOMMAND"))
(shadow '*UNLOAD* (find-package "EPGENERAL_TASK_CONTROL::TASKEXECUTIONCOMMAND"))
(defconstant epgeneral_task_control::TaskExecutionCommand::*UNLOAD* 5)

(defun epgeneral_task_control::TaskExecutionCommand-to-symbol (const)
  (cond
        ((= const 1) 'epgeneral_task_control::TaskExecutionCommand::*SCHEDULE*)
        ((= const 2) 'epgeneral_task_control::TaskExecutionCommand::*CANCEL*)
        ((= const 3) 'epgeneral_task_control::TaskExecutionCommand::*STOP*)
        ((= const 4) 'epgeneral_task_control::TaskExecutionCommand::*PREPARE*)
        ((= const 5) 'epgeneral_task_control::TaskExecutionCommand::*UNLOAD*)
        (t nil)))

(defclass epgeneral_task_control::TaskExecutionCommand
  :super ros::object
  :slots (_action _request_id _task_id _subtask_id _device_id _execution_id _revision _xml_path _frame_id _map_id _scheduled_at ))

(defmethod epgeneral_task_control::TaskExecutionCommand
  (:init
   (&key
    ((:action __action) 0)
    ((:request_id __request_id) "")
    ((:task_id __task_id) "")
    ((:subtask_id __subtask_id) "")
    ((:device_id __device_id) "")
    ((:execution_id __execution_id) "")
    ((:revision __revision) 0)
    ((:xml_path __xml_path) "")
    ((:frame_id __frame_id) "")
    ((:map_id __map_id) "")
    ((:scheduled_at __scheduled_at) (instance ros::time :init))
    )
   (send-super :init)
   (setq _action (round __action))
   (setq _request_id (string __request_id))
   (setq _task_id (string __task_id))
   (setq _subtask_id (string __subtask_id))
   (setq _device_id (string __device_id))
   (setq _execution_id (string __execution_id))
   (setq _revision (round __revision))
   (setq _xml_path (string __xml_path))
   (setq _frame_id (string __frame_id))
   (setq _map_id (string __map_id))
   (setq _scheduled_at __scheduled_at)
   self)
  (:action
   (&optional __action)
   (if __action (setq _action __action)) _action)
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
  (:xml_path
   (&optional __xml_path)
   (if __xml_path (setq _xml_path __xml_path)) _xml_path)
  (:frame_id
   (&optional __frame_id)
   (if __frame_id (setq _frame_id __frame_id)) _frame_id)
  (:map_id
   (&optional __map_id)
   (if __map_id (setq _map_id __map_id)) _map_id)
  (:scheduled_at
   (&optional __scheduled_at)
   (if __scheduled_at (setq _scheduled_at __scheduled_at)) _scheduled_at)
  (:serialization-length
   ()
   (+
    ;; uint8 _action
    1
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
    ;; string _xml_path
    4 (length _xml_path)
    ;; string _frame_id
    4 (length _frame_id)
    ;; string _map_id
    4 (length _map_id)
    ;; time _scheduled_at
    8
    ))
  (:serialize
   (&optional strm)
   (let ((s (if strm strm
              (make-string-output-stream (send self :serialization-length)))))
     ;; uint8 _action
       (write-byte _action s)
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
     ;; string _xml_path
       (write-long (length _xml_path) s) (princ _xml_path s)
     ;; string _frame_id
       (write-long (length _frame_id) s) (princ _frame_id s)
     ;; string _map_id
       (write-long (length _map_id) s) (princ _map_id s)
     ;; time _scheduled_at
       (write-long (send _scheduled_at :sec) s) (write-long (send _scheduled_at :nsec) s)
     ;;
     (if (null strm) (get-output-stream-string s))))
  (:deserialize
   (buf &optional (ptr- 0))
   ;; uint8 _action
     (setq _action (sys::peek buf ptr- :char)) (incf ptr- 1)
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
   ;; string _xml_path
     (let (n) (setq n (sys::peek buf ptr- :integer)) (incf ptr- 4) (setq _xml_path (subseq buf ptr- (+ ptr- n))) (incf ptr- n))
   ;; string _frame_id
     (let (n) (setq n (sys::peek buf ptr- :integer)) (incf ptr- 4) (setq _frame_id (subseq buf ptr- (+ ptr- n))) (incf ptr- n))
   ;; string _map_id
     (let (n) (setq n (sys::peek buf ptr- :integer)) (incf ptr- 4) (setq _map_id (subseq buf ptr- (+ ptr- n))) (incf ptr- n))
   ;; time _scheduled_at
     (send _scheduled_at :sec (sys::peek buf ptr- :integer)) (incf ptr- 4)  (send _scheduled_at :nsec (sys::peek buf ptr- :integer)) (incf ptr- 4)
   ;;
   self)
  )

(setf (get epgeneral_task_control::TaskExecutionCommand :md5sum-) "b02f521e09d483449a5b659a3a48f813")
(setf (get epgeneral_task_control::TaskExecutionCommand :datatype-) "epgeneral_task_control/TaskExecutionCommand")
(setf (get epgeneral_task_control::TaskExecutionCommand :definition-)
      "uint8 SCHEDULE=1
uint8 CANCEL=2
uint8 STOP=3
uint8 PREPARE=4
uint8 UNLOAD=5
uint8 action
string request_id
string task_id
string subtask_id
string device_id
string execution_id
uint32 revision
string xml_path
string frame_id
string map_id
time scheduled_at

")



(provide :epgeneral_task_control/TaskExecutionCommand "b02f521e09d483449a5b659a3a48f813")


