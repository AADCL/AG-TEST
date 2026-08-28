// Auto-generated. Do not edit!

// (in-package ground_air_msgs.srv)


"use strict";

const _serializer = _ros_msg_utils.Serialize;
const _arraySerializer = _serializer.Array;
const _deserializer = _ros_msg_utils.Deserialize;
const _arrayDeserializer = _deserializer.Array;
const _finder = _ros_msg_utils.Find;
const _getByteLength = _ros_msg_utils.getByteLength;

//-----------------------------------------------------------

let VehicleStatus = require('../msg/VehicleStatus.js');

//-----------------------------------------------------------

class SetVehicleModeRequest {
  constructor(initObj={}) {
    if (initObj === null) {
      // initObj === null is a special case for deserialization where we don't initialize fields
      this.target_mode = null;
    }
    else {
      if (initObj.hasOwnProperty('target_mode')) {
        this.target_mode = initObj.target_mode
      }
      else {
        this.target_mode = 0;
      }
    }
  }

  static serialize(obj, buffer, bufferOffset) {
    // Serializes a message object of type SetVehicleModeRequest
    // Serialize message field [target_mode]
    bufferOffset = _serializer.uint8(obj.target_mode, buffer, bufferOffset);
    return bufferOffset;
  }

  static deserialize(buffer, bufferOffset=[0]) {
    //deserializes a message object of type SetVehicleModeRequest
    let len;
    let data = new SetVehicleModeRequest(null);
    // Deserialize message field [target_mode]
    data.target_mode = _deserializer.uint8(buffer, bufferOffset);
    return data;
  }

  static getMessageSize(object) {
    return 1;
  }

  static datatype() {
    // Returns string type for a service object
    return 'ground_air_msgs/SetVehicleModeRequest';
  }

  static md5sum() {
    //Returns md5sum for a message object
    return '2278b60c8ae8a1e23e584b07983ecfd3';
  }

  static messageDefinition() {
    // Returns full string definition for message
    return `
    uint8 GROUND=1
    uint8 AIR=3
    uint8 target_mode
    
    `;
  }

  static Resolve(msg) {
    // deep-construct a valid message object instance of whatever was passed in
    if (typeof msg !== 'object' || msg === null) {
      msg = {};
    }
    const resolved = new SetVehicleModeRequest(null);
    if (msg.target_mode !== undefined) {
      resolved.target_mode = msg.target_mode;
    }
    else {
      resolved.target_mode = 0
    }

    return resolved;
    }
};

// Constants for message
SetVehicleModeRequest.Constants = {
  GROUND: 1,
  AIR: 3,
}

class SetVehicleModeResponse {
  constructor(initObj={}) {
    if (initObj === null) {
      // initObj === null is a special case for deserialization where we don't initialize fields
      this.success = null;
      this.message = null;
      this.status = null;
    }
    else {
      if (initObj.hasOwnProperty('success')) {
        this.success = initObj.success
      }
      else {
        this.success = false;
      }
      if (initObj.hasOwnProperty('message')) {
        this.message = initObj.message
      }
      else {
        this.message = '';
      }
      if (initObj.hasOwnProperty('status')) {
        this.status = initObj.status
      }
      else {
        this.status = new VehicleStatus();
      }
    }
  }

  static serialize(obj, buffer, bufferOffset) {
    // Serializes a message object of type SetVehicleModeResponse
    // Serialize message field [success]
    bufferOffset = _serializer.bool(obj.success, buffer, bufferOffset);
    // Serialize message field [message]
    bufferOffset = _serializer.string(obj.message, buffer, bufferOffset);
    // Serialize message field [status]
    bufferOffset = VehicleStatus.serialize(obj.status, buffer, bufferOffset);
    return bufferOffset;
  }

  static deserialize(buffer, bufferOffset=[0]) {
    //deserializes a message object of type SetVehicleModeResponse
    let len;
    let data = new SetVehicleModeResponse(null);
    // Deserialize message field [success]
    data.success = _deserializer.bool(buffer, bufferOffset);
    // Deserialize message field [message]
    data.message = _deserializer.string(buffer, bufferOffset);
    // Deserialize message field [status]
    data.status = VehicleStatus.deserialize(buffer, bufferOffset);
    return data;
  }

  static getMessageSize(object) {
    let length = 0;
    length += _getByteLength(object.message);
    length += VehicleStatus.getMessageSize(object.status);
    return length + 5;
  }

  static datatype() {
    // Returns string type for a service object
    return 'ground_air_msgs/SetVehicleModeResponse';
  }

  static md5sum() {
    //Returns md5sum for a message object
    return 'f0928d6f1b6cc7f23580e750a31f1e15';
  }

  static messageDefinition() {
    // Returns full string definition for message
    return `
    bool success
    string message
    ground_air_msgs/VehicleStatus status
    
    
    ================================================================================
    MSG: ground_air_msgs/VehicleStatus
    std_msgs/Header header
    
    uint8 UNKNOWN=0
    uint8 GROUND=1
    uint8 TAKEOFF=2
    uint8 AIR=3
    uint8 LANDING=4
    uint8 ESTOP=5
    uint8 FAULT=6
    
    uint8 mode
    bool connected
    bool armed
    bool localized
    bool emergency_stop
    float32 altitude
    string flight_mode
    string detail
    
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
    
    `;
  }

  static Resolve(msg) {
    // deep-construct a valid message object instance of whatever was passed in
    if (typeof msg !== 'object' || msg === null) {
      msg = {};
    }
    const resolved = new SetVehicleModeResponse(null);
    if (msg.success !== undefined) {
      resolved.success = msg.success;
    }
    else {
      resolved.success = false
    }

    if (msg.message !== undefined) {
      resolved.message = msg.message;
    }
    else {
      resolved.message = ''
    }

    if (msg.status !== undefined) {
      resolved.status = VehicleStatus.Resolve(msg.status)
    }
    else {
      resolved.status = new VehicleStatus()
    }

    return resolved;
    }
};

module.exports = {
  Request: SetVehicleModeRequest,
  Response: SetVehicleModeResponse,
  md5sum() { return 'ec2c78fe35d8769d286703fa442499f8'; },
  datatype() { return 'ground_air_msgs/SetVehicleMode'; }
};
