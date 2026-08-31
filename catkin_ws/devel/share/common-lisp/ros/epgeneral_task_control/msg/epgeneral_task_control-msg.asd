
(cl:in-package :asdf)

(defsystem "epgeneral_task_control-msg"
  :depends-on (:roslisp-msg-protocol :roslisp-utils :geometry_msgs-msg
)
  :components ((:file "_package")
    (:file "TaskExecutionCommand" :depends-on ("_package_TaskExecutionCommand"))
    (:file "_package_TaskExecutionCommand" :depends-on ("_package"))
    (:file "TaskExecutionFeedback" :depends-on ("_package_TaskExecutionFeedback"))
    (:file "_package_TaskExecutionFeedback" :depends-on ("_package"))
  ))