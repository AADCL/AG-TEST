
(cl:in-package :asdf)

(defsystem "ground_air_msgs-srv"
  :depends-on (:roslisp-msg-protocol :roslisp-utils :geometry_msgs-msg
               :ground_air_msgs-msg
)
  :components ((:file "_package")
    (:file "LoadMap" :depends-on ("_package_LoadMap"))
    (:file "_package_LoadMap" :depends-on ("_package"))
    (:file "Relocalize" :depends-on ("_package_Relocalize"))
    (:file "_package_Relocalize" :depends-on ("_package"))
    (:file "SaveMapping" :depends-on ("_package_SaveMapping"))
    (:file "_package_SaveMapping" :depends-on ("_package"))
    (:file "SetEmergencyStop" :depends-on ("_package_SetEmergencyStop"))
    (:file "_package_SetEmergencyStop" :depends-on ("_package"))
    (:file "SetVehicleMode" :depends-on ("_package_SetVehicleMode"))
    (:file "_package_SetVehicleMode" :depends-on ("_package"))
    (:file "StartMapping" :depends-on ("_package_StartMapping"))
    (:file "_package_StartMapping" :depends-on ("_package"))
    (:file "SubmitMission" :depends-on ("_package_SubmitMission"))
    (:file "_package_SubmitMission" :depends-on ("_package"))
  ))