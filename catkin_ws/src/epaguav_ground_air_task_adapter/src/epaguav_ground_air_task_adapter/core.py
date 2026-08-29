"""ROS-independent task adapter state."""

from collections import OrderedDict
from copy import deepcopy
from dataclasses import dataclass


class CoreError(RuntimeError):
    def __init__(self, message, error_code="INTERNAL_ERROR"):
        super().__init__(str(message))
        self.error_code = str(error_code)


@dataclass(frozen=True)
class TaskIdentity:
    task_id: str
    subtask_id: str
    device_id: str
    revision: int


class RequestCache:
    def __init__(self, capacity=256):
        if int(capacity) < 1:
            raise ValueError("capacity must be positive")
        self._capacity = int(capacity)
        self._entries = OrderedDict()

    def lookup(self, request_id, signature):
        request_id = str(request_id)
        if request_id not in self._entries:
            return None
        stored_signature, response = self._entries[request_id]
        if stored_signature != tuple(signature):
            raise CoreError(
                "request ID was reused with different content",
                "REQUEST_ID_CONFLICT",
            )
        self._entries.move_to_end(request_id)
        return deepcopy(response)

    def store(self, request_id, signature, response):
        request_id = str(request_id)
        self._entries[request_id] = (tuple(signature), deepcopy(response))
        self._entries.move_to_end(request_id)
        while len(self._entries) > self._capacity:
            self._entries.popitem(last=False)


class AdapterCore:
    def __init__(self):
        self.prepared = None
        self.state = "empty"
        self._generation = 0

    @property
    def generation(self):
        return self._generation

    def prepare(self, identity):
        if not isinstance(identity, TaskIdentity):
            raise TypeError("identity must be TaskIdentity")
        self._generation += 1
        self.prepared = identity
        self.state = "ready"
        return self._generation

    def schedule(self, identity):
        if self.prepared != identity:
            error_code = (
                "REVISION_MISMATCH"
                if self.prepared is not None
                and self.prepared.task_id == identity.task_id
                and self.prepared.subtask_id == identity.subtask_id
                and self.prepared.device_id == identity.device_id
                else "UNKNOWN_TASK"
            )
            raise CoreError("scheduled task does not match prepared task", error_code)
        self.state = "scheduled"
        return self._generation

    def can_start(self, token):
        return int(token) == self._generation and self.state == "scheduled"

    def mark_running(self, token):
        if not self.can_start(token):
            raise CoreError("scheduled task generation is stale", "EXECUTION_CONFLICT")
        self.state = "running"

    def stop(self):
        self._generation += 1
        self.state = "stopped"

    def unload(self):
        self._generation += 1
        self.prepared = None
        self.state = "empty"
