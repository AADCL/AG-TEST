// Auto-generated. Do not edit!

// (in-package ground_air_msgs.msg)


"use strict";

const _serializer = _ros_msg_utils.Serialize;
const _arraySerializer = _serializer.Array;
const _deserializer = _ros_msg_utils.Deserialize;
const _arrayDeserializer = _deserializer.Array;
const _finder = _ros_msg_utils.Find;
const _getByteLength = _ros_msg_utils.getByteLength;
let std_msgs = _finder('std_msgs');

//-----------------------------------------------------------

class MissionStatus {
  constructor(initObj={}) {
    if (initObj === null) {
      // initObj === null is a special case for deserialization where we don't initialize fields
      this.header = null;
      this.state = null;
      this.current_index = null;
      this.total_goals = null;
      this.mission_id = null;
      this.detail = null;
    }
    else {
      if (initObj.hasOwnProperty('header')) {
        this.header = initObj.header
      }
      else {
        this.header = new std_msgs.msg.Header();
      }
      if (initObj.hasOwnProperty('state')) {
        this.state = initObj.state
      }
      else {
        this.state = 0;
      }
      if (initObj.hasOwnProperty('current_index')) {
        this.current_index = initObj.current_index
      }
      else {
        this.current_index = 0;
      }
      if (initObj.hasOwnProperty('total_goals')) {
        this.total_goals = initObj.total_goals
      }
      else {
        this.total_goals = 0;
      }
      if (initObj.hasOwnProperty('mission_id')) {
        this.mission_id = initObj.mission_id
      }
      else {
        this.mission_id = '';
      }
      if (initObj.hasOwnProperty('detail')) {
        this.detail = initObj.detail
      }
      else {
        this.detail = '';
      }
    }
  }

  static serialize(obj, buffer, bufferOffset) {
    // Serializes a message object of type MissionStatus
    // Serialize message field [header]
    bufferOffset = std_msgs.msg.Header.serialize(obj.header, buffer, bufferOffset);
    // Serialize message field [state]
    bufferOffset = _serializer.uint8(obj.state, buffer, bufferOffset);
    // Serialize message field [current_index]
    bufferOffset = _serializer.uint32(obj.current_index, buffer, bufferOffset);
    // Serialize message field [total_goals]
    bufferOffset = _serializer.uint32(obj.total_goals, buffer, bufferOffset);
    // Serialize message field [mission_id]
    bufferOffset = _serializer.string(obj.mission_id, buffer, bufferOffset);
    // Serialize message field [detail]
    bufferOffset = _serializer.string(obj.detail, buffer, bufferOffset);
    return bufferOffset;
  }

  static deserialize(buffer, bufferOffset=[0]) {
    //deserializes a message object of type MissionStatus
    let len;
    let data = new MissionStatus(null);
    // Deserialize message field [header]
    data.header = std_msgs.msg.Header.deserialize(buffer, bufferOffset);
    // Deserialize message field [state]
    data.state = _deserializer.uint8(buffer, bufferOffset);
    // Deserialize message field [current_index]
    data.current_index = _deserializer.uint32(buffer, bufferOffset);
    // Deserialize message field [total_goals]
    data.total_goals = _deserializer.uint32(buffer, bufferOffset);
    // Deserialize message field [mission_id]
    data.mission_id = _deserializer.string(buffer, bufferOffset);
    // Deserialize message field [detail]
    data.detail = _deserializer.string(buffer, bufferOffset);
    return data;
  }

  static getMessageSize(object) {
    let length = 0;
    length += std_msgs.msg.Header.getMessageSize(object.header);
    length += _getByteLength(object.mission_id);
    length += _getByteLength(object.detail);
    return length + 17;
  }

  static datatype() {
    // Returns string type for a message object
    return 'ground_air_msgs/MissionStatus';
  }

  static md5sum() {
    //Returns md5sum for a message object
    return '23946ede182678d2d602626aab96cd05';
  }

  static messageDefinition() {
    // Returns full string definition for message
    return `
    std_msgs/Header header
    
    uint8 IDLE=0
    uint8 RUNNING=1
    uint8 DWELLING=2
    uint8 PAUSED=3
    uint8 SUCCEEDED=4
    uint8 FAILED=5
    uint8 CANCELED=6
    uint8 WAITING_FOR_LAND=7
    
    uint8 state
    uint32 current_index
    uint32 total_goals
    string mission_id
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
    const resolved = new MissionStatus(null);
    if (msg.header !== undefined) {
      resolved.header = std_msgs.msg.Header.Resolve(msg.header)
    }
    else {
      resolved.header = new std_msgs.msg.Header()
    }

    if (msg.state !== undefined) {
      resolved.state = msg.state;
    }
    else {
      resolved.state = 0
    }

    if (msg.current_index !== undefined) {
      resolved.current_index = msg.current_index;
    }
    else {
      resolved.current_index = 0
    }

    if (msg.total_goals !== undefined) {
      resolved.total_goals = msg.total_goals;
    }
    else {
      resolved.total_goals = 0
    }

    if (msg.mission_id !== undefined) {
      resolved.mission_id = msg.mission_id;
    }
    else {
      resolved.mission_id = ''
    }

    if (msg.detail !== undefined) {
      resolved.detail = msg.detail;
    }
    else {
      resolved.detail = ''
    }

    return resolved;
    }
};

// Constants for message
MissionStatus.Constants = {
  IDLE: 0,
  RUNNING: 1,
  DWELLING: 2,
  PAUSED: 3,
  SUCCEEDED: 4,
  FAILED: 5,
  CANCELED: 6,
  WAITING_FOR_LAND: 7,
}

module.exports = MissionStatus;
