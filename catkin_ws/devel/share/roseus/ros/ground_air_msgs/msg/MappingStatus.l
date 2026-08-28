;; Auto-generated. Do not edit!


(when (boundp 'ground_air_msgs::MappingStatus)
  (if (not (find-package "GROUND_AIR_MSGS"))
    (make-package "GROUND_AIR_MSGS"))
  (shadow 'MappingStatus (find-package "GROUND_AIR_MSGS")))
(unless (find-package "GROUND_AIR_MSGS::MAPPINGSTATUS")
  (make-package "GROUND_AIR_MSGS::MAPPINGSTATUS"))

(in-package "ROS")
;;//! \htmlinclude MappingStatus.msg.html
(if (not (find-package "STD_MSGS"))
  (ros::roseus-add-msgs "std_msgs"))


(intern "*IDLE*" (find-package "GROUND_AIR_MSGS::MAPPINGSTATUS"))
(shadow '*IDLE* (find-package "GROUND_AIR_MSGS::MAPPINGSTATUS"))
(defconstant ground_air_msgs::MappingStatus::*IDLE* 0)
(intern "*RECORDING*" (find-package "GROUND_AIR_MSGS::MAPPINGSTATUS"))
(shadow '*RECORDING* (find-package "GROUND_AIR_MSGS::MAPPINGSTATUS"))
(defconstant ground_air_msgs::MappingStatus::*RECORDING* 1)
(intern "*SAVING*" (find-package "GROUND_AIR_MSGS::MAPPINGSTATUS"))
(shadow '*SAVING* (find-package "GROUND_AIR_MSGS::MAPPINGSTATUS"))
(defconstant ground_air_msgs::MappingStatus::*SAVING* 2)
(intern "*COMPLETE*" (find-package "GROUND_AIR_MSGS::MAPPINGSTATUS"))
(shadow '*COMPLETE* (find-package "GROUND_AIR_MSGS::MAPPINGSTATUS"))
(defconstant ground_air_msgs::MappingStatus::*COMPLETE* 3)
(intern "*ERROR*" (find-package "GROUND_AIR_MSGS::MAPPINGSTATUS"))
(shadow '*ERROR* (find-package "GROUND_AIR_MSGS::MAPPINGSTATUS"))
(defconstant ground_air_msgs::MappingStatus::*ERROR* 4)

(defun ground_air_msgs::MappingStatus-to-symbol (const)
  (cond
        ((= const 0) 'ground_air_msgs::MappingStatus::*IDLE*)
        ((= const 1) 'ground_air_msgs::MappingStatus::*RECORDING*)
        ((= const 2) 'ground_air_msgs::MappingStatus::*SAVING*)
        ((= const 3) 'ground_air_msgs::MappingStatus::*COMPLETE*)
        ((= const 4) 'ground_air_msgs::MappingStatus::*ERROR*)
        (t nil)))

(defclass ground_air_msgs::MappingStatus
  :super ros::object
  :slots (_header _state _map_id _point_count _map_area _message ))

(defmethod ground_air_msgs::MappingStatus
  (:init
   (&key
    ((:header __header) (instance std_msgs::Header :init))
    ((:state __state) 0)
    ((:map_id __map_id) "")
    ((:point_count __point_count) 0)
    ((:map_area __map_area) 0.0)
    ((:message __message) "")
    )
   (send-super :init)
   (setq _header __header)
   (setq _state (round __state))
   (setq _map_id (string __map_id))
   (setq _point_count (round __point_count))
   (setq _map_area (float __map_area))
   (setq _message (string __message))
   self)
  (:header
   (&rest __header)
   (if (keywordp (car __header))
       (send* _header __header)
     (progn
       (if __header (setq _header (car __header)))
       _header)))
  (:state
   (&optional __state)
   (if __state (setq _state __state)) _state)
  (:map_id
   (&optional __map_id)
   (if __map_id (setq _map_id __map_id)) _map_id)
  (:point_count
   (&optional __point_count)
   (if __point_count (setq _point_count __point_count)) _point_count)
  (:map_area
   (&optional __map_area)
   (if __map_area (setq _map_area __map_area)) _map_area)
  (:message
   (&optional __message)
   (if __message (setq _message __message)) _message)
  (:serialization-length
   ()
   (+
    ;; std_msgs/Header _header
    (send _header :serialization-length)
    ;; uint8 _state
    1
    ;; string _map_id
    4 (length _map_id)
    ;; uint64 _point_count
    8
    ;; float64 _map_area
    8
    ;; string _message
    4 (length _message)
    ))
  (:serialize
   (&optional strm)
   (let ((s (if strm strm
              (make-string-output-stream (send self :serialization-length)))))
     ;; std_msgs/Header _header
       (send _header :serialize s)
     ;; uint8 _state
       (write-byte _state s)
     ;; string _map_id
       (write-long (length _map_id) s) (princ _map_id s)
     ;; uint64 _point_count
#+(or :alpha :irix6 :x86_64)
       (progn (sys::poke _point_count (send s :buffer) (send s :count) :long) (incf (stream-count s) 8))
#-(or :alpha :irix6 :x86_64)
       (cond ((and (class _point_count) (= (length (_point_count . bv)) 2)) ;; bignum
              (write-long (ash (elt (_point_count . bv) 0) 0) s)
              (write-long (ash (elt (_point_count . bv) 1) -1) s))
             ((and (class _point_count) (= (length (_point_count . bv)) 1)) ;; big1
              (write-long (elt (_point_count . bv) 0) s)
              (write-long (if (>= _point_count 0) 0 #xffffffff) s))
             (t                                         ;; integer
              (write-long _point_count s)(write-long (if (>= _point_count 0) 0 #xffffffff) s)))
     ;; float64 _map_area
       (sys::poke _map_area (send s :buffer) (send s :count) :double) (incf (stream-count s) 8)
     ;; string _message
       (write-long (length _message) s) (princ _message s)
     ;;
     (if (null strm) (get-output-stream-string s))))
  (:deserialize
   (buf &optional (ptr- 0))
   ;; std_msgs/Header _header
     (send _header :deserialize buf ptr-) (incf ptr- (send _header :serialization-length))
   ;; uint8 _state
     (setq _state (sys::peek buf ptr- :char)) (incf ptr- 1)
   ;; string _map_id
     (let (n) (setq n (sys::peek buf ptr- :integer)) (incf ptr- 4) (setq _map_id (subseq buf ptr- (+ ptr- n))) (incf ptr- n))
   ;; uint64 _point_count
     
#+(or :alpha :irix6 :x86_64)
      (setf _point_count (prog1 (sys::peek buf ptr- :long) (incf ptr- 8)))
#-(or :alpha :irix6 :x86_64)
      (setf _point_count (let ((b0 (prog1 (sys::peek buf ptr- :integer) (incf ptr- 4)))
                  (b1 (prog1 (sys::peek buf ptr- :integer) (incf ptr- 4))))
              (cond ((= b1 -1) b0)
                     ((and (= b1  0)
                           (<= lisp::most-negative-fixnum b0 lisp::most-positive-fixnum))
                      b0)
                    ((= b1  0) (make-instance bignum :size 1 :bv (integer-vector b0)))
                    (t (make-instance bignum :size 2 :bv (integer-vector b0 (ash b1 1)))))))
   ;; float64 _map_area
     (setq _map_area (sys::peek buf ptr- :double)) (incf ptr- 8)
   ;; string _message
     (let (n) (setq n (sys::peek buf ptr- :integer)) (incf ptr- 4) (setq _message (subseq buf ptr- (+ ptr- n))) (incf ptr- n))
   ;;
   self)
  )

(setf (get ground_air_msgs::MappingStatus :md5sum-) "e7b4d3ace6c9bf72b66602ccfc54bf23")
(setf (get ground_air_msgs::MappingStatus :datatype-) "ground_air_msgs/MappingStatus")
(setf (get ground_air_msgs::MappingStatus :definition-)
      "std_msgs/Header header

uint8 IDLE=0
uint8 RECORDING=1
uint8 SAVING=2
uint8 COMPLETE=3
uint8 ERROR=4

uint8 state
string map_id
uint64 point_count
float64 map_area
string message

================================================================================
MSG: std_msgs/Header
# Standard metadata for higher-level stamped data types.
# This is generally used to communicate timestamped data 
# in a particular coordinate frame.
# 
# sequence ID: consecutively increasing ID 
uint32 seq
#Two-integer timestamp that is expressed as:
# * stamp.sec: seconds (stamp_secs) since epoch (in Python the variable is called 'secs')
# * stamp.nsec: nanoseconds since stamp_secs (in Python the variable is called 'nsecs')
# time-handling sugar is provided by the client library
time stamp
#Frame this data is associated with
string frame_id

")



(provide :ground_air_msgs/MappingStatus "e7b4d3ace6c9bf72b66602ccfc54bf23")


