// Auto-generated. Do not edit!

// (in-package epgeneral_task_control.msg)


"use strict";

const _serializer = _ros_msg_utils.Serialize;
const _arraySerializer = _serializer.Array;
const _deserializer = _ros_msg_utils.Deserialize;
const _arrayDeserializer = _deserializer.Array;
const _finder = _ros_msg_utils.Find;
const _getByteLength = _ros_msg_utils.getByteLength;
let geometry_msgs = _finder('geometry_msgs');

//-----------------------------------------------------------

class TaskExecutionFeedback {
  constructor(initObj={}) {
    if (initObj === null) {
      // initObj === null is a special case for deserialization where we don't initialize fields
      this.request_id = null;
      this.task_id = null;
      this.subtask_id = null;
      this.device_id = null;
      this.execution_id = null;
      this.revision = null;
      this.state = null;
      this.waypoint_index = null;
      this.waypoint_count = null;
      this.progress = null;
      this.position = null;
      this.error_code = null;
      this.message = null;
    }
    else {
      if (initObj.hasOwnProperty('request_id')) {
        this.request_id = initObj.request_id
      }
      else {
        this.request_id = '';
      }
      if (initObj.hasOwnProperty('task_id')) {
        this.task_id = initObj.task_id
      }
      else {
        this.task_id = '';
      }
      if (initObj.hasOwnProperty('subtask_id')) {
        this.subtask_id = initObj.subtask_id
      }
      else {
        this.subtask_id = '';
      }
      if (initObj.hasOwnProperty('device_id')) {
        this.device_id = initObj.device_id
      }
      else {
        this.device_id = '';
      }
      if (initObj.hasOwnProperty('execution_id')) {
        this.execution_id = initObj.execution_id
      }
      else {
        this.execution_id = '';
      }
      if (initObj.hasOwnProperty('revision')) {
        this.revision = initObj.revision
      }
      else {
        this.revision = 0;
      }
      if (initObj.hasOwnProperty('state')) {
        this.state = initObj.state
      }
      else {
        this.state = '';
      }
      if (initObj.hasOwnProperty('waypoint_index')) {
        this.waypoint_index = initObj.waypoint_index
      }
      else {
        this.waypoint_index = 0;
      }
      if (initObj.hasOwnProperty('waypoint_count')) {
        this.waypoint_count = initObj.waypoint_count
      }
      else {
        this.waypoint_count = 0;
      }
      if (initObj.hasOwnProperty('progress')) {
        this.progress = initObj.progress
      }
      else {
        this.progress = 0.0;
      }
      if (initObj.hasOwnProperty('position')) {
        this.position = initObj.position
      }
      else {
        this.position = new geometry_msgs.msg.Point();
      }
      if (initObj.hasOwnProperty('error_code')) {
        this.error_code = initObj.error_code
      }
      else {
        this.error_code = '';
      }
      if (initObj.hasOwnProperty('message')) {
        this.message = initObj.message
      }
      else {
        this.message = '';
      }
    }
  }

  static serialize(obj, buffer, bufferOffset) {
    // Serializes a message object of type TaskExecutionFeedback
    // Serialize message field [request_id]
    bufferOffset = _serializer.string(obj.request_id, buffer, bufferOffset);
    // Serialize message field [task_id]
    bufferOffset = _serializer.string(obj.task_id, buffer, bufferOffset);
    // Serialize message field [subtask_id]
    bufferOffset = _serializer.string(obj.subtask_id, buffer, bufferOffset);
    // Serialize message field [device_id]
    bufferOffset = _serializer.string(obj.device_id, buffer, bufferOffset);
    // Serialize message field [execution_id]
    bufferOffset = _serializer.string(obj.execution_id, buffer, bufferOffset);
    // Serialize message field [revision]
    bufferOffset = _serializer.uint32(obj.revision, buffer, bufferOffset);
    // Serialize message field [state]
    bufferOffset = _serializer.string(obj.state, buffer, bufferOffset);
    // Serialize message field [waypoint_index]
    bufferOffset = _serializer.int32(obj.waypoint_index, buffer, bufferOffset);
    // Serialize message field [waypoint_count]
    bufferOffset = _serializer.int32(obj.waypoint_count, buffer, bufferOffset);
    // Serialize message field [progress]
    bufferOffset = _serializer.float64(obj.progress, buffer, bufferOffset);
    // Serialize message field [position]
    bufferOffset = geometry_msgs.msg.Point.serialize(obj.position, buffer, bufferOffset);
    // Serialize message field [error_code]
    bufferOffset = _serializer.string(obj.error_code, buffer, bufferOffset);
    // Serialize message field [message]
    bufferOffset = _serializer.string(obj.message, buffer, bufferOffset);
    return bufferOffset;
  }

  static deserialize(buffer, bufferOffset=[0]) {
    //deserializes a message object of type TaskExecutionFeedback
    let len;
    let data = new TaskExecutionFeedback(null);
    // Deserialize message field [request_id]
    data.request_id = _deserializer.string(buffer, bufferOffset);
    // Deserialize message field [task_id]
    data.task_id = _deserializer.string(buffer, bufferOffset);
    // Deserialize message field [subtask_id]
    data.subtask_id = _deserializer.string(buffer, bufferOffset);
    // Deserialize message field [device_id]
    data.device_id = _deserializer.string(buffer, bufferOffset);
    // Deserialize message field [execution_id]
    data.execution_id = _deserializer.string(buffer, bufferOffset);
    // Deserialize message field [revision]
    data.revision = _deserializer.uint32(buffer, bufferOffset);
    // Deserialize message field [state]
    data.state = _deserializer.string(buffer, bufferOffset);
    // Deserialize message field [waypoint_index]
    data.waypoint_index = _deserializer.int32(buffer, bufferOffset);
    // Deserialize message field [waypoint_count]
    data.waypoint_count = _deserializer.int32(buffer, bufferOffset);
    // Deserialize message field [progress]
    data.progress = _deserializer.float64(buffer, bufferOffset);
    // Deserialize message field [position]
    data.position = geometry_msgs.msg.Point.deserialize(buffer, bufferOffset);
    // Deserialize message field [error_code]
    data.error_code = _deserializer.string(buffer, bufferOffset);
    // Deserialize message field [message]
    data.message = _deserializer.string(buffer, bufferOffset);
    return data;
  }

  static getMessageSize(object) {
    let length = 0;
    length += _getByteLength(object.request_id);
    length += _getByteLength(object.task_id);
    length += _getByteLength(object.subtask_id);
    length += _getByteLength(object.device_id);
    length += _getByteLength(object.execution_id);
    length += _getByteLength(object.state);
    length += _getByteLength(object.error_code);
    length += _getByteLength(object.message);
    return length + 76;
  }

  static datatype() {
    // Returns string type for a message object
    return 'epgeneral_task_control/TaskExecutionFeedback';
  }

  static md5sum() {
    //Returns md5sum for a message object
    return '992f61c604e3ed23f3589fd880757815';
  }

  static messageDefinition() {
    // Returns full string definition for message
    return `
    string request_id
    string task_id
    string subtask_id
    string device_id
    string execution_id
    uint32 revision
    string state
    int32 waypoint_index
    int32 waypoint_count
    float64 progress
    geometry_msgs/Point position
    string error_code
    string message
    
    ================================================================================
    MSG: geometry_msgs/Point
    # This contains the position of a point in free space
    float64 x
    float64 y
    float64 z
    
    `;
  }

  static Resolve(msg) {
    // deep-construct a valid message object instance of whatever was passed in
    if (typeof msg !== 'object' || msg === null) {
      msg = {};
    }
    const resolved = new TaskExecutionFeedback(null);
    if (msg.request_id !== undefined) {
      resolved.request_id = msg.request_id;
    }
    else {
      resolved.request_id = ''
    }

    if (msg.task_id !== undefined) {
      resolved.task_id = msg.task_id;
    }
    else {
      resolved.task_id = ''
    }

    if (msg.subtask_id !== undefined) {
      resolved.subtask_id = msg.subtask_id;
    }
    else {
      resolved.subtask_id = ''
    }

    if (msg.device_id !== undefined) {
      resolved.device_id = msg.device_id;
    }
    else {
      resolved.device_id = ''
    }

    if (msg.execution_id !== undefined) {
      resolved.execution_id = msg.execution_id;
    }
    else {
      resolved.execution_id = ''
    }

    if (msg.revision !== undefined) {
      resolved.revision = msg.revision;
    }
    else {
      resolved.revision = 0
    }

    if (msg.state !== undefined) {
      resolved.state = msg.state;
    }
    else {
      resolved.state = ''
    }

    if (msg.waypoint_index !== undefined) {
      resolved.waypoint_index = msg.waypoint_index;
    }
    else {
      resolved.waypoint_index = 0
    }

    if (msg.waypoint_count !== undefined) {
      resolved.waypoint_count = msg.waypoint_count;
    }
    else {
      resolved.waypoint_count = 0
    }

    if (msg.progress !== undefined) {
      resolved.progress = msg.progress;
    }
    else {
      resolved.progress = 0.0
    }

    if (msg.position !== undefined) {
      resolved.position = geometry_msgs.msg.Point.Resolve(msg.position)
    }
    else {
      resolved.position = new geometry_msgs.msg.Point()
    }

    if (msg.error_code !== undefined) {
      resolved.error_code = msg.error_code;
    }
    else {
      resolved.error_code = ''
    }

    if (msg.message !== undefined) {
      resolved.message = msg.message;
    }
    else {
      resolved.message = ''
    }

    return resolved;
    }
};

module.exports = TaskExecutionFeedback;
