// Auto-generated. Do not edit!

// (in-package epgeneral_task_control.msg)


"use strict";

const _serializer = _ros_msg_utils.Serialize;
const _arraySerializer = _serializer.Array;
const _deserializer = _ros_msg_utils.Deserialize;
const _arrayDeserializer = _deserializer.Array;
const _finder = _ros_msg_utils.Find;
const _getByteLength = _ros_msg_utils.getByteLength;

//-----------------------------------------------------------

class TaskExecutionCommand {
  constructor(initObj={}) {
    if (initObj === null) {
      // initObj === null is a special case for deserialization where we don't initialize fields
      this.action = null;
      this.request_id = null;
      this.task_id = null;
      this.subtask_id = null;
      this.device_id = null;
      this.execution_id = null;
      this.revision = null;
      this.xml_path = null;
      this.frame_id = null;
      this.map_id = null;
      this.scheduled_at = null;
    }
    else {
      if (initObj.hasOwnProperty('action')) {
        this.action = initObj.action
      }
      else {
        this.action = 0;
      }
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
      if (initObj.hasOwnProperty('xml_path')) {
        this.xml_path = initObj.xml_path
      }
      else {
        this.xml_path = '';
      }
      if (initObj.hasOwnProperty('frame_id')) {
        this.frame_id = initObj.frame_id
      }
      else {
        this.frame_id = '';
      }
      if (initObj.hasOwnProperty('map_id')) {
        this.map_id = initObj.map_id
      }
      else {
        this.map_id = '';
      }
      if (initObj.hasOwnProperty('scheduled_at')) {
        this.scheduled_at = initObj.scheduled_at
      }
      else {
        this.scheduled_at = {secs: 0, nsecs: 0};
      }
    }
  }

  static serialize(obj, buffer, bufferOffset) {
    // Serializes a message object of type TaskExecutionCommand
    // Serialize message field [action]
    bufferOffset = _serializer.uint8(obj.action, buffer, bufferOffset);
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
    // Serialize message field [xml_path]
    bufferOffset = _serializer.string(obj.xml_path, buffer, bufferOffset);
    // Serialize message field [frame_id]
    bufferOffset = _serializer.string(obj.frame_id, buffer, bufferOffset);
    // Serialize message field [map_id]
    bufferOffset = _serializer.string(obj.map_id, buffer, bufferOffset);
    // Serialize message field [scheduled_at]
    bufferOffset = _serializer.time(obj.scheduled_at, buffer, bufferOffset);
    return bufferOffset;
  }

  static deserialize(buffer, bufferOffset=[0]) {
    //deserializes a message object of type TaskExecutionCommand
    let len;
    let data = new TaskExecutionCommand(null);
    // Deserialize message field [action]
    data.action = _deserializer.uint8(buffer, bufferOffset);
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
    // Deserialize message field [xml_path]
    data.xml_path = _deserializer.string(buffer, bufferOffset);
    // Deserialize message field [frame_id]
    data.frame_id = _deserializer.string(buffer, bufferOffset);
    // Deserialize message field [map_id]
    data.map_id = _deserializer.string(buffer, bufferOffset);
    // Deserialize message field [scheduled_at]
    data.scheduled_at = _deserializer.time(buffer, bufferOffset);
    return data;
  }

  static getMessageSize(object) {
    let length = 0;
    length += _getByteLength(object.request_id);
    length += _getByteLength(object.task_id);
    length += _getByteLength(object.subtask_id);
    length += _getByteLength(object.device_id);
    length += _getByteLength(object.execution_id);
    length += _getByteLength(object.xml_path);
    length += _getByteLength(object.frame_id);
    length += _getByteLength(object.map_id);
    return length + 45;
  }

  static datatype() {
    // Returns string type for a message object
    return 'epgeneral_task_control/TaskExecutionCommand';
  }

  static md5sum() {
    //Returns md5sum for a message object
    return 'b02f521e09d483449a5b659a3a48f813';
  }

  static messageDefinition() {
    // Returns full string definition for message
    return `
    uint8 SCHEDULE=1
    uint8 CANCEL=2
    uint8 STOP=3
    uint8 PREPARE=4
    uint8 UNLOAD=5
    uint8 action
    string request_id
    string task_id
    string subtask_id
    string device_id
    string execution_id
    uint32 revision
    string xml_path
    string frame_id
    string map_id
    time scheduled_at
    
    `;
  }

  static Resolve(msg) {
    // deep-construct a valid message object instance of whatever was passed in
    if (typeof msg !== 'object' || msg === null) {
      msg = {};
    }
    const resolved = new TaskExecutionCommand(null);
    if (msg.action !== undefined) {
      resolved.action = msg.action;
    }
    else {
      resolved.action = 0
    }

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

    if (msg.xml_path !== undefined) {
      resolved.xml_path = msg.xml_path;
    }
    else {
      resolved.xml_path = ''
    }

    if (msg.frame_id !== undefined) {
      resolved.frame_id = msg.frame_id;
    }
    else {
      resolved.frame_id = ''
    }

    if (msg.map_id !== undefined) {
      resolved.map_id = msg.map_id;
    }
    else {
      resolved.map_id = ''
    }

    if (msg.scheduled_at !== undefined) {
      resolved.scheduled_at = msg.scheduled_at;
    }
    else {
      resolved.scheduled_at = {secs: 0, nsecs: 0}
    }

    return resolved;
    }
};

// Constants for message
TaskExecutionCommand.Constants = {
  SCHEDULE: 1,
  CANCEL: 2,
  STOP: 3,
  PREPARE: 4,
  UNLOAD: 5,
}

module.exports = TaskExecutionCommand;
