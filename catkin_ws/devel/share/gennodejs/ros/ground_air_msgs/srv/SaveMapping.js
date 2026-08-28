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

class SaveMappingRequest {
  constructor(initObj={}) {
    if (initObj === null) {
      // initObj === null is a special case for deserialization where we don't initialize fields
    }
    else {
    }
  }

  static serialize(obj, buffer, bufferOffset) {
    // Serializes a message object of type SaveMappingRequest
    return bufferOffset;
  }

  static deserialize(buffer, bufferOffset=[0]) {
    //deserializes a message object of type SaveMappingRequest
    let len;
    let data = new SaveMappingRequest(null);
    return data;
  }

  static getMessageSize(object) {
    return 0;
  }

  static datatype() {
    // Returns string type for a service object
    return 'ground_air_msgs/SaveMappingRequest';
  }

  static md5sum() {
    //Returns md5sum for a message object
    return 'd41d8cd98f00b204e9800998ecf8427e';
  }

  static messageDefinition() {
    // Returns full string definition for message
    return `
    
    `;
  }

  static Resolve(msg) {
    // deep-construct a valid message object instance of whatever was passed in
    if (typeof msg !== 'object' || msg === null) {
      msg = {};
    }
    const resolved = new SaveMappingRequest(null);
    return resolved;
    }
};

class SaveMappingResponse {
  constructor(initObj={}) {
    if (initObj === null) {
      // initObj === null is a special case for deserialization where we don't initialize fields
      this.success = null;
      this.message = null;
      this.map_directory = null;
      this.point_count = null;
      this.map_area = null;
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
      if (initObj.hasOwnProperty('map_directory')) {
        this.map_directory = initObj.map_directory
      }
      else {
        this.map_directory = '';
      }
      if (initObj.hasOwnProperty('point_count')) {
        this.point_count = initObj.point_count
      }
      else {
        this.point_count = 0;
      }
      if (initObj.hasOwnProperty('map_area')) {
        this.map_area = initObj.map_area
      }
      else {
        this.map_area = 0.0;
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
    // Serializes a message object of type SaveMappingResponse
    // Serialize message field [success]
    bufferOffset = _serializer.bool(obj.success, buffer, bufferOffset);
    // Serialize message field [message]
    bufferOffset = _serializer.string(obj.message, buffer, bufferOffset);
    // Serialize message field [map_directory]
    bufferOffset = _serializer.string(obj.map_directory, buffer, bufferOffset);
    // Serialize message field [point_count]
    bufferOffset = _serializer.uint64(obj.point_count, buffer, bufferOffset);
    // Serialize message field [map_area]
    bufferOffset = _serializer.float64(obj.map_area, buffer, bufferOffset);
    // Serialize message field [status]
    bufferOffset = MappingStatus.serialize(obj.status, buffer, bufferOffset);
    return bufferOffset;
  }

  static deserialize(buffer, bufferOffset=[0]) {
    //deserializes a message object of type SaveMappingResponse
    let len;
    let data = new SaveMappingResponse(null);
    // Deserialize message field [success]
    data.success = _deserializer.bool(buffer, bufferOffset);
    // Deserialize message field [message]
    data.message = _deserializer.string(buffer, bufferOffset);
    // Deserialize message field [map_directory]
    data.map_directory = _deserializer.string(buffer, bufferOffset);
    // Deserialize message field [point_count]
    data.point_count = _deserializer.uint64(buffer, bufferOffset);
    // Deserialize message field [map_area]
    data.map_area = _deserializer.float64(buffer, bufferOffset);
    // Deserialize message field [status]
    data.status = MappingStatus.deserialize(buffer, bufferOffset);
    return data;
  }

  static getMessageSize(object) {
    let length = 0;
    length += _getByteLength(object.message);
    length += _getByteLength(object.map_directory);
    length += MappingStatus.getMessageSize(object.status);
    return length + 25;
  }

  static datatype() {
    // Returns string type for a service object
    return 'ground_air_msgs/SaveMappingResponse';
  }

  static md5sum() {
    //Returns md5sum for a message object
    return 'b55b1aad9049fd292f476b6b721de723';
  }

  static messageDefinition() {
    // Returns full string definition for message
    return `
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
    
    `;
  }

  static Resolve(msg) {
    // deep-construct a valid message object instance of whatever was passed in
    if (typeof msg !== 'object' || msg === null) {
      msg = {};
    }
    const resolved = new SaveMappingResponse(null);
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

    if (msg.map_directory !== undefined) {
      resolved.map_directory = msg.map_directory;
    }
    else {
      resolved.map_directory = ''
    }

    if (msg.point_count !== undefined) {
      resolved.point_count = msg.point_count;
    }
    else {
      resolved.point_count = 0
    }

    if (msg.map_area !== undefined) {
      resolved.map_area = msg.map_area;
    }
    else {
      resolved.map_area = 0.0
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
  Request: SaveMappingRequest,
  Response: SaveMappingResponse,
  md5sum() { return 'b55b1aad9049fd292f476b6b721de723'; },
  datatype() { return 'ground_air_msgs/SaveMapping'; }
};
