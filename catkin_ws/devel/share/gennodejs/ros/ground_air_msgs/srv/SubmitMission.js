// Auto-generated. Do not edit!

// (in-package ground_air_msgs.srv)


"use strict";

const _serializer = _ros_msg_utils.Serialize;
const _arraySerializer = _serializer.Array;
const _deserializer = _ros_msg_utils.Deserialize;
const _arrayDeserializer = _deserializer.Array;
const _finder = _ros_msg_utils.Find;
const _getByteLength = _ros_msg_utils.getByteLength;
let geometry_msgs = _finder('geometry_msgs');

//-----------------------------------------------------------


//-----------------------------------------------------------

class SubmitMissionRequest {
  constructor(initObj={}) {
    if (initObj === null) {
      // initObj === null is a special case for deserialization where we don't initialize fields
      this.mission_id = null;
      this.goals = null;
    }
    else {
      if (initObj.hasOwnProperty('mission_id')) {
        this.mission_id = initObj.mission_id
      }
      else {
        this.mission_id = '';
      }
      if (initObj.hasOwnProperty('goals')) {
        this.goals = initObj.goals
      }
      else {
        this.goals = [];
      }
    }
  }

  static serialize(obj, buffer, bufferOffset) {
    // Serializes a message object of type SubmitMissionRequest
    // Serialize message field [mission_id]
    bufferOffset = _serializer.string(obj.mission_id, buffer, bufferOffset);
    // Serialize message field [goals]
    // Serialize the length for message field [goals]
    bufferOffset = _serializer.uint32(obj.goals.length, buffer, bufferOffset);
    obj.goals.forEach((val) => {
      bufferOffset = geometry_msgs.msg.PoseStamped.serialize(val, buffer, bufferOffset);
    });
    return bufferOffset;
  }

  static deserialize(buffer, bufferOffset=[0]) {
    //deserializes a message object of type SubmitMissionRequest
    let len;
    let data = new SubmitMissionRequest(null);
    // Deserialize message field [mission_id]
    data.mission_id = _deserializer.string(buffer, bufferOffset);
    // Deserialize message field [goals]
    // Deserialize array length for message field [goals]
    len = _deserializer.uint32(buffer, bufferOffset);
    data.goals = new Array(len);
    for (let i = 0; i < len; ++i) {
      data.goals[i] = geometry_msgs.msg.PoseStamped.deserialize(buffer, bufferOffset)
    }
    return data;
  }

  static getMessageSize(object) {
    let length = 0;
    length += _getByteLength(object.mission_id);
    object.goals.forEach((val) => {
      length += geometry_msgs.msg.PoseStamped.getMessageSize(val);
    });
    return length + 8;
  }

  static datatype() {
    // Returns string type for a service object
    return 'ground_air_msgs/SubmitMissionRequest';
  }

  static md5sum() {
    //Returns md5sum for a message object
    return 'e691f5914610d0d03746740d82f81b59';
  }

  static messageDefinition() {
    // Returns full string definition for message
    return `
    string mission_id
    geometry_msgs/PoseStamped[] goals
    
    ================================================================================
    MSG: geometry_msgs/PoseStamped
    # A Pose with reference coordinate frame and timestamp
    Header header
    Pose pose
    
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
    
    ================================================================================
    MSG: geometry_msgs/Pose
    # A representation of pose in free space, composed of position and orientation. 
    Point position
    Quaternion orientation
    
    ================================================================================
    MSG: geometry_msgs/Point
    # This contains the position of a point in free space
    float64 x
    float64 y
    float64 z
    
    ================================================================================
    MSG: geometry_msgs/Quaternion
    # This represents an orientation in free space in quaternion form.
    
    float64 x
    float64 y
    float64 z
    float64 w
    
    `;
  }

  static Resolve(msg) {
    // deep-construct a valid message object instance of whatever was passed in
    if (typeof msg !== 'object' || msg === null) {
      msg = {};
    }
    const resolved = new SubmitMissionRequest(null);
    if (msg.mission_id !== undefined) {
      resolved.mission_id = msg.mission_id;
    }
    else {
      resolved.mission_id = ''
    }

    if (msg.goals !== undefined) {
      resolved.goals = new Array(msg.goals.length);
      for (let i = 0; i < resolved.goals.length; ++i) {
        resolved.goals[i] = geometry_msgs.msg.PoseStamped.Resolve(msg.goals[i]);
      }
    }
    else {
      resolved.goals = []
    }

    return resolved;
    }
};

class SubmitMissionResponse {
  constructor(initObj={}) {
    if (initObj === null) {
      // initObj === null is a special case for deserialization where we don't initialize fields
      this.accepted = null;
      this.message = null;
      this.goal_count = null;
    }
    else {
      if (initObj.hasOwnProperty('accepted')) {
        this.accepted = initObj.accepted
      }
      else {
        this.accepted = false;
      }
      if (initObj.hasOwnProperty('message')) {
        this.message = initObj.message
      }
      else {
        this.message = '';
      }
      if (initObj.hasOwnProperty('goal_count')) {
        this.goal_count = initObj.goal_count
      }
      else {
        this.goal_count = 0;
      }
    }
  }

  static serialize(obj, buffer, bufferOffset) {
    // Serializes a message object of type SubmitMissionResponse
    // Serialize message field [accepted]
    bufferOffset = _serializer.bool(obj.accepted, buffer, bufferOffset);
    // Serialize message field [message]
    bufferOffset = _serializer.string(obj.message, buffer, bufferOffset);
    // Serialize message field [goal_count]
    bufferOffset = _serializer.uint32(obj.goal_count, buffer, bufferOffset);
    return bufferOffset;
  }

  static deserialize(buffer, bufferOffset=[0]) {
    //deserializes a message object of type SubmitMissionResponse
    let len;
    let data = new SubmitMissionResponse(null);
    // Deserialize message field [accepted]
    data.accepted = _deserializer.bool(buffer, bufferOffset);
    // Deserialize message field [message]
    data.message = _deserializer.string(buffer, bufferOffset);
    // Deserialize message field [goal_count]
    data.goal_count = _deserializer.uint32(buffer, bufferOffset);
    return data;
  }

  static getMessageSize(object) {
    let length = 0;
    length += _getByteLength(object.message);
    return length + 9;
  }

  static datatype() {
    // Returns string type for a service object
    return 'ground_air_msgs/SubmitMissionResponse';
  }

  static md5sum() {
    //Returns md5sum for a message object
    return '4a8874339fceff65d93337f129e3c7b6';
  }

  static messageDefinition() {
    // Returns full string definition for message
    return `
    bool accepted
    string message
    uint32 goal_count
    
    
    `;
  }

  static Resolve(msg) {
    // deep-construct a valid message object instance of whatever was passed in
    if (typeof msg !== 'object' || msg === null) {
      msg = {};
    }
    const resolved = new SubmitMissionResponse(null);
    if (msg.accepted !== undefined) {
      resolved.accepted = msg.accepted;
    }
    else {
      resolved.accepted = false
    }

    if (msg.message !== undefined) {
      resolved.message = msg.message;
    }
    else {
      resolved.message = ''
    }

    if (msg.goal_count !== undefined) {
      resolved.goal_count = msg.goal_count;
    }
    else {
      resolved.goal_count = 0
    }

    return resolved;
    }
};

module.exports = {
  Request: SubmitMissionRequest,
  Response: SubmitMissionResponse,
  md5sum() { return '0b7be7b794768c0b19086f237b7f7bf0'; },
  datatype() { return 'ground_air_msgs/SubmitMission'; }
};
