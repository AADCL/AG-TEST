;; Auto-generated. Do not edit!


(when (boundp 'ground_air_msgs::SaveMapping)
  (if (not (find-package "GROUND_AIR_MSGS"))
    (make-package "GROUND_AIR_MSGS"))
  (shadow 'SaveMapping (find-package "GROUND_AIR_MSGS")))
(unless (find-package "GROUND_AIR_MSGS::SAVEMAPPING")
  (make-package "GROUND_AIR_MSGS::SAVEMAPPING"))
(unless (find-package "GROUND_AIR_MSGS::SAVEMAPPINGREQUEST")
  (make-package "GROUND_AIR_MSGS::SAVEMAPPINGREQUEST"))
(unless (find-package "GROUND_AIR_MSGS::SAVEMAPPINGRESPONSE")
  (make-package "GROUND_AIR_MSGS::SAVEMAPPINGRESPONSE"))

(in-package "ROS")





(defclass ground_air_msgs::SaveMappingRequest
  :super ros::object
  :slots ())

(defmethod ground_air_msgs::SaveMappingRequest
  (:init
   (&key
    )
   (send-super :init)
   self)
  (:serialization-length
   ()
   (+
    0
    ))
  (:serialize
   (&optional strm)
   (let ((s (if strm strm
              (make-string-output-stream (send self :serialization-length)))))
     ;;
     (if (null strm) (get-output-stream-string s))))
  (:deserialize
   (buf &optional (ptr- 0))
   ;;
   self)
  )

(defclass ground_air_msgs::SaveMappingResponse
  :super ros::object
  :slots (_success _message _map_directory _point_count _map_area _status ))

(defmethod ground_air_msgs::SaveMappingResponse
  (:init
   (&key
    ((:success __success) nil)
    ((:message __message) "")
    ((:map_directory __map_directory) "")
    ((:point_count __point_count) 0)
    ((:map_area __map_area) 0.0)
    ((:status __status) (instance ground_air_msgs::MappingStatus :init))
    )
   (send-super :init)
   (setq _success __success)
   (setq _message (string __message))
   (setq _map_directory (string __map_directory))
   (setq _point_count (round __point_count))
   (setq _map_area (float __map_area))
   (setq _status __status)
   self)
  (:success
   (&optional (__success :null))
   (if (not (eq __success :null)) (setq _success __success)) _success)
  (:message
   (&optional __message)
   (if __message (setq _message __message)) _message)
  (:map_directory
   (&optional __map_directory)
   (if __map_directory (setq _map_directory __map_directory)) _map_directory)
  (:point_count
   (&optional __point_count)
   (if __point_count (setq _point_count __point_count)) _point_count)
  (:map_area
   (&optional __map_area)
   (if __map_area (setq _map_area __map_area)) _map_area)
  (:status
   (&rest __status)
   (if (keywordp (car __status))
       (send* _status __status)
     (progn
       (if __status (setq _status (car __status)))
       _status)))
  (:serialization-length
   ()
   (+
    ;; bool _success
    1
    ;; string _message
    4 (length _message)
    ;; string _map_directory
    4 (length _map_directory)
    ;; uint64 _point_count
    8
    ;; float64 _map_area
    8
    ;; ground_air_msgs/MappingStatus _status
    (send _status :serialization-length)
    ))
  (:serialize
   (&optional strm)
   (let ((s (if strm strm
              (make-string-output-stream (send self :serialization-length)))))
     ;; bool _success
       (if _success (write-byte -1 s) (write-byte 0 s))
     ;; string _message
       (write-long (length _message) s) (princ _message s)
     ;; string _map_directory
       (write-long (length _map_directory) s) (princ _map_directory s)
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
     ;; ground_air_msgs/MappingStatus _status
       (send _status :serialize s)
     ;;
     (if (null strm) (get-output-stream-string s))))
  (:deserialize
   (buf &optional (ptr- 0))
   ;; bool _success
     (setq _success (not (= 0 (sys::peek buf ptr- :char)))) (incf ptr- 1)
   ;; string _message
     (let (n) (setq n (sys::peek buf ptr- :integer)) (incf ptr- 4) (setq _message (subseq buf ptr- (+ ptr- n))) (incf ptr- n))
   ;; string _map_directory
     (let (n) (setq n (sys::peek buf ptr- :integer)) (incf ptr- 4) (setq _map_directory (subseq buf ptr- (+ ptr- n))) (incf ptr- n))
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
   ;; ground_air_msgs/MappingStatus _status
     (send _status :deserialize buf ptr-) (incf ptr- (send _status :serialization-length))
   ;;
   self)
  )

(defclass ground_air_msgs::SaveMapping
  :super ros::object
  :slots ())

(setf (get ground_air_msgs::SaveMapping :md5sum-) "b55b1aad9049fd292f476b6b721de723")
(setf (get ground_air_msgs::SaveMapping :datatype-) "ground_air_msgs/SaveMapping")
(setf (get ground_air_msgs::SaveMapping :request) ground_air_msgs::SaveMappingRequest)
(setf (get ground_air_msgs::SaveMapping :response) ground_air_msgs::SaveMappingResponse)

(defmethod ground_air_msgs::SaveMappingRequest
  (:response () (instance ground_air_msgs::SaveMappingResponse :init)))

(setf (get ground_air_msgs::SaveMappingRequest :md5sum-) "b55b1aad9049fd292f476b6b721de723")
(setf (get ground_air_msgs::SaveMappingRequest :datatype-) "ground_air_msgs/SaveMappingRequest")
(setf (get ground_air_msgs::SaveMappingRequest :definition-)
      "---
bool success
string message
string map_directory
uint64 point_count
float64 map_area
ground_air_msgs/MappingStatus status


================================================================================
MSG: ground_air_msgs/MappingStatus
std_msgs/Header header

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

(setf (get ground_air_msgs::SaveMappingResponse :md5sum-) "b55b1aad9049fd292f476b6b721de723")
(setf (get ground_air_msgs::SaveMappingResponse :datatype-) "ground_air_msgs/SaveMappingResponse")
(setf (get ground_air_msgs::SaveMappingResponse :definition-)
      "---
bool success
string message
string map_directory
uint64 point_count
float64 map_area
ground_air_msgs/MappingStatus status


================================================================================
MSG: ground_air_msgs/MappingStatus
std_msgs/Header header

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



(provide :ground_air_msgs/SaveMapping "b55b1aad9049fd292f476b6b721de723")


