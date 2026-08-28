
(cl:in-package :asdf)

(defsystem "ground_air_msgs-msg"
  :depends-on (:roslisp-msg-protocol :roslisp-utils :std_msgs-msg
)
  :components ((:file "_package")
    (:file "MappingStatus" :depends-on ("_package_MappingStatus"))
    (:file "_package_MappingStatus" :depends-on ("_package"))
    (:file "MissionStatus" :depends-on ("_package_MissionStatus"))
    (:file "_package_MissionStatus" :depends-on ("_package"))
    (:file "VehicleStatus" :depends-on ("_package_VehicleStatus"))
    (:file "_package_VehicleStatus" :depends-on ("_package"))
  ))