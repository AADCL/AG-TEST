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

class RelocalizeRequest {
  constructor(initObj={}) {
    if (initObj === null) {
      // initObj === null is a special case for deserialization where we don't initialize fields
      this.use_initial_guess = null;
      this.initial_guess = null;
      this.timeout = null;
    }
    else {
      if (initObj.hasOwnProperty('use_initial_guess')) {
        this.use_initial_guess = initObj.use_initial_guess
      }
      else {
        this.use_initial_guess = false;
      }
      if (initObj.hasOwnProperty('initial_guess')) {
        this.initial_guess = initObj.initial_guess
      }
      else {
        this.initial_guess = new geometry_msgs.msg.PoseWithCovarianceStamped();
      }
      if (initObj.hasOwnProperty('timeout')) {
        this.timeout = initObj.timeout
      }
      else {
        this.timeout = 0.0;
      }
    }
  }

  static serialize(obj, buffer, bufferOffset) {
    // Serializes a message object of type RelocalizeRequest
    // Serialize message field [use_initial_guess]
    bufferOffset = _serializer.bool(obj.use_initial_guess, buffer, bufferOffset);
    // Serialize message field [initial_guess]
    bufferOffset = geometry_msgs.msg.PoseWithCovarianceStamped.serialize(obj.initial_guess, buffer, bufferOffset);
    // Serialize message field [timeout]
    bufferOffset = _serializer.float64(obj.timeout, buffer, bufferOffset);
    return bufferOffset;
  }

  static deserialize(buffer, bufferOffset=[0]) {
    //deserializes a message object of type RelocalizeRequest
    let len;
    let data = new RelocalizeRequest(null);
    // Deserialize message field [use_initial_guess]
    data.use_initial_guess = _deserializer.bool(buffer, bufferOffset);
    // Deserialize message field [initial_guess]
    data.initial_guess = geometry_msgs.msg.PoseWithCovarianceStamped.deserialize(buffer, bufferOffset);
    // Deserialize message field [timeout]
    data.timeout = _deserializer.float64(buffer, bufferOffset);
    return data;
  }

  static getMessageSize(object) {
    let length = 0;
    length += geometry_msgs.msg.PoseWithCovarianceStamped.getMessageSize(object.initial_guess);
    return length + 9;
  }

  static datatype() {
    // Returns string type for a service object
    return 'ground_air_msgs/RelocalizeRequest';
  }

  static md5sum() {
    //Returns md5sum for a message object
    return '38a86b8be42751f8c4670c5b973218e7';
  }

  static messageDefinition() {
    // Returns full string definition for message
    return `
    bool use_initial_guess
    geometry_msgs/PoseWithCovarianceStamped initial_guess
    float64 timeout
    
    ================================================================================
    MSG: geometry_msgs/PoseWithCovarianceStamped
    # This expresses an estimated pose with a reference coordinate frame and timestamp
    
    Header header
    PoseWithCovariance pose
    
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
    MSG: geometry_msgs/PoseWithCovariance
    # This represents a pose in free space with uncertainty.
    
    Pose pose
    
    # Row-major representation of the 6x6 covariance matrix
    # The orientation parameters use a fixed-axis representation.
    # In order, the parameters are:
    # (x, y, z, rotation about X axis, rotation about Y axis, rotation about Z axis)
    float64[36] covariance
    
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
    const resolved = new RelocalizeRequest(null);
    if (msg.use_initial_guess !== undefined) {
      resolved.use_initial_guess = msg.use_initial_guess;
    }
    else {
      resolved.use_initial_guess = false
    }

    if (msg.initial_guess !== undefined) {
      resolved.initial_guess = geometry_msgs.msg.PoseWithCovarianceStamped.Resolve(msg.initial_guess)
    }
    else {
      resolved.initial_guess = new geometry_msgs.msg.PoseWithCovarianceStamped()
    }

    if (msg.timeout !== undefined) {
      resolved.timeout = msg.timeout;
    }
    else {
      resolved.timeout = 0.0
    }

    return resolved;
    }
};

class RelocalizeResponse {
  constructor(initObj={}) {
    if (initObj === null) {
      // initObj === null is a special case for deserialization where we don't initialize fields
      this.success = null;
      this.message = null;
      this.pose = null;
      this.fitness = null;
      this.rmse = null;
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
      if (initObj.hasOwnProperty('pose')) {
        this.pose = initObj.pose
      }
      else {
        this.pose = new geometry_msgs.msg.PoseStamped();
      }
      if (initObj.hasOwnProperty('fitness')) {
        this.fitness = initObj.fitness
      }
      else {
        this.fitness = 0.0;
      }
      if (initObj.hasOwnProperty('rmse')) {
        this.rmse = initObj.rmse
      }
      else {
        this.rmse = 0.0;
      }
    }
  }

  static serialize(obj, buffer, bufferOffset) {
    // Serializes a message object of type RelocalizeResponse
    // Serialize message field [success]
    bufferOffset = _serializer.bool(obj.success, buffer, bufferOffset);
    // Serialize message field [message]
    bufferOffset = _serializer.string(obj.message, buffer, bufferOffset);
    // Serialize message field [pose]
    bufferOffset = geometry_msgs.msg.PoseStamped.serialize(obj.pose, buffer, bufferOffset);
    // Serialize message field [fitness]
    bufferOffset = _serializer.float64(obj.fitness, buffer, bufferOffset);
    // Serialize message field [rmse]
    bufferOffset = _serializer.float64(obj.rmse, buffer, bufferOffset);
    return bufferOffset;
  }

  static deserialize(buffer, bufferOffset=[0]) {
    //deserializes a message object of type RelocalizeResponse
    let len;
    let data = new RelocalizeResponse(null);
    // Deserialize message field [success]
    data.success = _deserializer.bool(buffer, bufferOffset);
    // Deserialize message field [message]
    data.message = _deserializer.string(buffer, bufferOffset);
    // Deserialize message field [pose]
    data.pose = geometry_msgs.msg.PoseStamped.deserialize(buffer, bufferOffset);
    // Deserialize message field [fitness]
    data.fitness = _deserializer.float64(buffer, bufferOffset);
    // Deserialize message field [rmse]
    data.rmse = _deserializer.float64(buffer, bufferOffset);
    return data;
  }

  static getMessageSize(object) {
    let length = 0;
    length += _getByteLength(object.message);
    length += geometry_msgs.msg.PoseStamped.getMessageSize(object.pose);
    return length + 21;
  }

  static datatype() {
    // Returns string type for a service object
    return 'ground_air_msgs/RelocalizeResponse';
  }

  static md5sum() {
    //Returns md5sum for a message object
    return '497124ea16f468a12b52f1f8f4476ae7';
  }

  static messageDefinition() {
    // Returns full string definition for message
    return `
    bool success
    string message
    geometry_msgs/PoseStamped pose
    float64 fitness
    float64 rmse
    
    
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
    const resolved = new RelocalizeResponse(null);
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

    if (msg.pose !== undefined) {
      resolved.pose = geometry_msgs.msg.PoseStamped.Resolve(msg.pose)
    }
    else {
      resolved.pose = new geometry_msgs.msg.PoseStamped()
    }

    if (msg.fitness !== undefined) {
      resolved.fitness = msg.fitness;
    }
    else {
      resolved.fitness = 0.0
    }

    if (msg.rmse !== undefined) {
      resolved.rmse = msg.rmse;
    }
    else {
      resolved.rmse = 0.0
    }

    return resolved;
    }
};

module.exports = {
  Request: RelocalizeRequest,
  Response: RelocalizeResponse,
  md5sum() { return 'c61b338cbffb25ec319cc4dabf79db05'; },
  datatype() { return 'ground_air_msgs/Relocalize'; }
};
