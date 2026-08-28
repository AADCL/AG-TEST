;; Auto-generated. Do not edit!


(when (boundp 'ground_air_msgs::LoadMap)
  (if (not (find-package "GROUND_AIR_MSGS"))
    (make-package "GROUND_AIR_MSGS"))
  (shadow 'LoadMap (find-package "GROUND_AIR_MSGS")))
(unless (find-package "GROUND_AIR_MSGS::LOADMAP")
  (make-package "GROUND_AIR_MSGS::LOADMAP"))
(unless (find-package "GROUND_AIR_MSGS::LOADMAPREQUEST")
  (make-package "GROUND_AIR_MSGS::LOADMAPREQUEST"))
(unless (find-package "GROUND_AIR_MSGS::LOADMAPRESPONSE")
  (make-package "GROUND_AIR_MSGS::LOADMAPRESPONSE"))

(in-package "ROS")





(defclass ground_air_msgs::LoadMapRequest
  :super ros::object
  :slots (_map_id _source_uri ))

(defmethod ground_air_msgs::LoadMapRequest
  (:init
   (&key
    ((:map_id __map_id) "")
    ((:source_uri __source_uri) "")
    )
   (send-super :init)
   (setq _map_id (string __map_id))
   (setq _source_uri (string __source_uri))
   self)
  (:map_id
   (&optional __map_id)
   (if __map_id (setq _map_id __map_id)) _map_id)
  (:source_uri
   (&optional __source_uri)
   (if __source_uri (setq _source_uri __source_uri)) _source_uri)
  (:serialization-length
   ()
   (+
    ;; string _map_id
    4 (length _map_id)
    ;; string _source_uri
    4 (length _source_uri)
    ))
  (:serialize
   (&optional strm)
   (let ((s (if strm strm
              (make-string-output-stream (send self :serialization-length)))))
     ;; string _map_id
       (write-long (length _map_id) s) (princ _map_id s)
     ;; string _source_uri
       (write-long (length _source_uri) s) (princ _source_uri s)
     ;;
     (if (null strm) (get-output-stream-string s))))
  (:deserialize
   (buf &optional (ptr- 0))
   ;; string _map_id
     (let (n) (setq n (sys::peek buf ptr- :integer)) (incf ptr- 4) (setq _map_id (subseq buf ptr- (+ ptr- n))) (incf ptr- n))
   ;; string _source_uri
     (let (n) (setq n (sys::peek buf ptr- :integer)) (incf ptr- 4) (setq _source_uri (subseq buf ptr- (+ ptr- n))) (incf ptr- n))
   ;;
   self)
  )

(defclass ground_air_msgs::LoadMapResponse
  :super ros::object
  :slots (_success _message _map_directory ))

(defmethod ground_air_msgs::LoadMapResponse
  (:init
   (&key
    ((:success __success) nil)
    ((:message __message) "")
    ((:map_directory __map_directory) "")
    )
   (send-super :init)
   (setq _success __success)
   (setq _message (string __message))
   (setq _map_directory (string __map_directory))
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
  (:serialization-length
   ()
   (+
    ;; bool _success
    1
    ;; string _message
    4 (length _message)
    ;; string _map_directory
    4 (length _map_directory)
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
   ;;
   self)
  )

(defclass ground_air_msgs::LoadMap
  :super ros::object
  :slots ())

(setf (get ground_air_msgs::LoadMap :md5sum-) "0ad4fcd56eceaa84d4b9013dcb5a122f")
(setf (get ground_air_msgs::LoadMap :datatype-) "ground_air_msgs/LoadMap")
(setf (get ground_air_msgs::LoadMap :request) ground_air_msgs::LoadMapRequest)
(setf (get ground_air_msgs::LoadMap :response) ground_air_msgs::LoadMapResponse)

(defmethod ground_air_msgs::LoadMapRequest
  (:response () (instance ground_air_msgs::LoadMapResponse :init)))

(setf (get ground_air_msgs::LoadMapRequest :md5sum-) "0ad4fcd56eceaa84d4b9013dcb5a122f")
(setf (get ground_air_msgs::LoadMapRequest :datatype-) "ground_air_msgs/LoadMapRequest")
(setf (get ground_air_msgs::LoadMapRequest :definition-)
      "string map_id
string source_uri
---
bool success
string message
string map_directory

")

(setf (get ground_air_msgs::LoadMapResponse :md5sum-) "0ad4fcd56eceaa84d4b9013dcb5a122f")
(setf (get ground_air_msgs::LoadMapResponse :datatype-) "ground_air_msgs/LoadMapResponse")
(setf (get ground_air_msgs::LoadMapResponse :definition-)
      "string map_id
string source_uri
---
bool success
string message
string map_directory

")



(provide :ground_air_msgs/LoadMap "0ad4fcd56eceaa84d4b9013dcb5a122f")


