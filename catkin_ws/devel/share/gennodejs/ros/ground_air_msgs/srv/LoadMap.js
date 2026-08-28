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


//-----------------------------------------------------------

class LoadMapRequest {
  constructor(initObj={}) {
    if (initObj === null) {
      // initObj === null is a special case for deserialization where we don't initialize fields
      this.map_id = null;
      this.source_uri = null;
    }
    else {
      if (initObj.hasOwnProperty('map_id')) {
        this.map_id = initObj.map_id
      }
      else {
        this.map_id = '';
      }
      if (initObj.hasOwnProperty('source_uri')) {
        this.source_uri = initObj.source_uri
      }
      else {
        this.source_uri = '';
      }
    }
  }

  static serialize(obj, buffer, bufferOffset) {
    // Serializes a message object of type LoadMapRequest
    // Serialize message field [map_id]
    bufferOffset = _serializer.string(obj.map_id, buffer, bufferOffset);
    // Serialize message field [source_uri]
    bufferOffset = _serializer.string(obj.source_uri, buffer, bufferOffset);
    return bufferOffset;
  }

  static deserialize(buffer, bufferOffset=[0]) {
    //deserializes a message object of type LoadMapRequest
    let len;
    let data = new LoadMapRequest(null);
    // Deserialize message field [map_id]
    data.map_id = _deserializer.string(buffer, bufferOffset);
    // Deserialize message field [source_uri]
    data.source_uri = _deserializer.string(buffer, bufferOffset);
    return data;
  }

  static getMessageSize(object) {
    let length = 0;
    length += _getByteLength(object.map_id);
    length += _getByteLength(object.source_uri);
    return length + 8;
  }

  static datatype() {
    // Returns string type for a service object
    return 'ground_air_msgs/LoadMapRequest';
  }

  static md5sum() {
    //Returns md5sum for a message object
    return '2d03ea8f44443b8e20617fdf8c7bf1d5';
  }

  static messageDefinition() {
    // Returns full string definition for message
    return `
    string map_id
    string source_uri
    
    `;
  }

  static Resolve(msg) {
    // deep-construct a valid message object instance of whatever was passed in
    if (typeof msg !== 'object' || msg === null) {
      msg = {};
    }
    const resolved = new LoadMapRequest(null);
    if (msg.map_id !== undefined) {
      resolved.map_id = msg.map_id;
    }
    else {
      resolved.map_id = ''
    }

    if (msg.source_uri !== undefined) {
      resolved.source_uri = msg.source_uri;
    }
    else {
      resolved.source_uri = ''
    }

    return resolved;
    }
};

class LoadMapResponse {
  constructor(initObj={}) {
    if (initObj === null) {
      // initObj === null is a special case for deserialization where we don't initialize fields
      this.success = null;
      this.message = null;
      this.map_directory = null;
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
    }
  }

  static serialize(obj, buffer, bufferOffset) {
    // Serializes a message object of type LoadMapResponse
    // Serialize message field [success]
    bufferOffset = _serializer.bool(obj.success, buffer, bufferOffset);
    // Serialize message field [message]
    bufferOffset = _serializer.string(obj.message, buffer, bufferOffset);
    // Serialize message field [map_directory]
    bufferOffset = _serializer.string(obj.map_directory, buffer, bufferOffset);
    return bufferOffset;
  }

  static deserialize(buffer, bufferOffset=[0]) {
    //deserializes a message object of type LoadMapResponse
    let len;
    let data = new LoadMapResponse(null);
    // Deserialize message field [success]
    data.success = _deserializer.bool(buffer, bufferOffset);
    // Deserialize message field [message]
    data.message = _deserializer.string(buffer, bufferOffset);
    // Deserialize message field [map_directory]
    data.map_directory = _deserializer.string(buffer, bufferOffset);
    return data;
  }

  static getMessageSize(object) {
    let length = 0;
    length += _getByteLength(object.message);
    length += _getByteLength(object.map_directory);
    return length + 9;
  }

  static datatype() {
    // Returns string type for a service object
    return 'ground_air_msgs/LoadMapResponse';
  }

  static md5sum() {
    //Returns md5sum for a message object
    return '37940acb2ef0fe5f67032442ac40b545';
  }

  static messageDefinition() {
    // Returns full string definition for message
    return `
    bool success
    string message
    string map_directory
    
    
    `;
  }

  static Resolve(msg) {
    // deep-construct a valid message object instance of whatever was passed in
    if (typeof msg !== 'object' || msg === null) {
      msg = {};
    }
    const resolved = new LoadMapResponse(null);
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

    return resolved;
    }
};

module.exports = {
  Request: LoadMapRequest,
  Response: LoadMapResponse,
  md5sum() { return '0ad4fcd56eceaa84d4b9013dcb5a122f'; },
  datatype() { return 'ground_air_msgs/LoadMap'; }
};
