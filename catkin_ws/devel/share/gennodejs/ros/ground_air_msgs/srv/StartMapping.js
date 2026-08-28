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

let MappingStatus = require('../msg/MappingStatus.js');

//-----------------------------------------------------------

class StartMappingRequest {
  constructor(initObj={}) {
    if (initObj === null) {
      // initObj === null is a special case for deserialization where we don't initialize fields
      this.map_id = null;
    }
    else {
      if (initObj.hasOwnProperty('map_id')) {
        this.map_id = initObj.map_id
      }
      else {
        this.map_id = '';
      }
    }
  }

  static serialize(obj, buffer, bufferOffset) {
    // Serializes a message object of type StartMappingRequest
    // Serialize message field [map_id]
    bufferOffset = _serializer.string(obj.map_id, buffer, bufferOffset);
    return bufferOffset;
  }

  static deserialize(buffer, bufferOffset=[0]) {
    //deserializes a message object of type StartMappingRequest
    let len;
    let data = new StartMappingRequest(null);
    // Deserialize message field [map_id]
    data.map_id = _deserializer.string(buffer, bufferOffset);
    return data;
  }

  static getMessageSize(object) {
    let length = 0;
    length += _getByteLength(object.map_id);
    return length + 4;
  }

  static datatype() {
    // Returns string type for a service object
    return 'ground_air_msgs/StartMappingRequest';
  }

  static md5sum() {
    //Returns md5sum for a message object
    return 'd742ddbd5e3e8937162044ae4b300275';
  }

  static messageDefinition() {
    // Returns full string definition for message
    return `
    string map_id
    
    `;
  }

  static Resolve(msg) {
    // deep-construct a valid message object instance of whatever was passed in
    if (typeof msg !== 'object' || msg === null) {
      msg = {};
    }
    const resolved = new StartMappingRequest(null);
    if (msg.map_id !== undefined) {
      resolved.map_id = msg.map_id;
    }
    else {
      resolved.map_id = ''
    }

    return resolved;
    }
};

class StartMappingResponse {
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
        this.status = new MappingStatus();
      }
    }
  }

  static serialize(obj, buffer, bufferOffset) {
    // Serializes a message object of type StartMappingResponse
    // Serialize message field [success]
    bufferOffset = _serializer.bool(obj.success, buffer, bufferOffset);
    // Serialize message field [message]
    bufferOffset = _serializer.string(obj.message, buffer, bufferOffset);
    // Serialize message field [status]
    bufferOffset = MappingStatus.serialize(obj.status, buffer, bufferOffset);
    return bufferOffset;
  }

  static deserialize(buffer, bufferOffset=[0]) {
    //deserializes a message object of type StartMappingResponse
    let len;
    let data = new StartMappingResponse(null);
    // Deserialize message field [success]
    data.success = _deserializer.bool(buffer, bufferOffset);
    // Deserialize message field [message]
    data.message = _deserializer.string(buffer, bufferOffset);
    // Deserialize message field [status]
    data.status = MappingStatus.deserialize(buffer, bufferOffset);
    return data;
  }

  static getMessageSize(object) {
    let length = 0;
    length += _getByteLength(object.message);
    length += MappingStatus.getMessageSize(object.status);
    return length + 5;
  }

  static datatype() {
    // Returns string type for a service object
    return 'ground_air_msgs/StartMappingResponse';
  }

  static md5sum() {
    //Returns md5sum for a message object
    return 'f53bcbb847686d2c913ba3597034a5e0';
  }

  static messageDefinition() {
    // Returns full string definition for message
    return `
    bool success
    string message
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
    
    `;
  }

  static Resolve(msg) {
    // deep-construct a valid message object instance of whatever was passed in
    if (typeof msg !== 'object' || msg === null) {
      msg = {};
    }
    const resolved = new StartMappingResponse(null);
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
      resolved.status = MappingStatus.Resolve(msg.status)
    }
    else {
      resolved.status = new MappingStatus()
    }

    return resolved;
    }
};

module.exports = {
  Request: StartMappingRequest,
  Response: StartMappingResponse,
  md5sum() { return '7109d91bb5e43bd6cea8265829bbdff6'; },
  datatype() { return 'ground_air_msgs/StartMapping'; }
};
