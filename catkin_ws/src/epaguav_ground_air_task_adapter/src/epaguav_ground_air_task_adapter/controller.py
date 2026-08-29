"""Protocol-neutral controller for the CCS ROS task boundary."""

from dataclasses import dataclass
import math

from .core import AdapterCore, CoreError, RequestCache, TaskIdentity
from .trajectory import AdapterError, load_trajectory


SCHEDULE = 1
CANCEL = 2
STOP = 3
PREPARE = 4
UNLOAD = 5


class BackendError(RuntimeError):
    def __init__(self, message, error_code="INTERNAL_ERROR"):
        super().__init__(str(message))
        self.error_code = str(error_code)


@dataclass(frozen=True)
class Feedback:
    request_id: str
    task_id: str
    subtask_id: str
    device_id: str
    execution_id: str
    revision: int
    state: str
    waypoint_index: int = -1
    waypoint_count: int = 0
    progress: float = 0.0
    position: tuple = (0.0, 0.0, 0.0)
    error_code: str = ""
    message: str = ""


class TaskAdapterController:
    def __init__(self, mission_root, backend, request_cache_capacity=256):
        self.mission_root = str(mission_root)
        self.backend = backend
        self.core = AdapterCore()
        self.cache = RequestCache(request_cache_capacity)
        self._scheduled_at = None
        self._schedule_token = None
        self._execution_command = None

    @staticmethod
    def _identity(command):
        return TaskIdentity(
            str(command.task_id),
            str(command.subtask_id),
            str(command.device_id),
            int(command.revision),
        )

    @staticmethod
    def _signature(command):
        return (
            int(command.action),
            str(command.task_id),
            str(command.subtask_id),
            str(command.device_id),
            str(command.execution_id),
            int(command.revision),
            str(command.xml_path),
            str(command.frame_id),
            str(command.map_id),
            float(command.scheduled_at),
        )

    @staticmethod
    def _feedback(command, state, **values):
        return Feedback(
            request_id=str(command.request_id),
            task_id=str(command.task_id),
            subtask_id=str(command.subtask_id),
            device_id=str(command.device_id),
            execution_id=str(command.execution_id),
            revision=int(command.revision),
            state=str(state),
            **values
        )

    def handle(self, command, current_xy=None, now=None):
        del now
        request_id = str(command.request_id)
        if not request_id:
            return self._feedback(
                command, "failed", error_code="INVALID_COMMAND", message="request_id is required"
            )
        signature = self._signature(command)
        try:
            cached = self.cache.lookup(request_id, signature)
        except CoreError as exc:
            return self._feedback(
                command,
                "failed",
                error_code=exc.error_code,
                message=str(exc),
            )
        if cached is not None:
            return cached
        try:
            action = int(command.action)
            if action == PREPARE:
                result = self._prepare(command, current_xy)
            elif action == SCHEDULE:
                result = self._schedule(command)
            elif action in (CANCEL, STOP):
                result = self._stop(command)
            elif action == UNLOAD:
                result = self._unload(command)
            else:
                result = self._feedback(
                    command,
                    "failed",
                    error_code="INVALID_COMMAND",
                    message="unsupported task action",
                )
        except (AdapterError, CoreError, BackendError) as exc:
            result = self._feedback(
                command,
                "failed",
                error_code=exc.error_code,
                message=str(exc),
            )
        self.cache.store(request_id, signature, result)
        return result

    def _prepare(self, command, current_xy):
        mission = load_trajectory(
            command.xml_path,
            self.mission_root,
            task_id=command.task_id,
            subtask_id=command.subtask_id,
            device_id=command.device_id,
            revision=command.revision,
            map_id=command.map_id,
            frame_id=command.frame_id,
            current_xy=current_xy,
        )
        message = self.backend.submit(mission)
        self.core.prepare(self._identity(command))
        self._scheduled_at = None
        self._schedule_token = None
        self._execution_command = None
        return self._feedback(
            command,
            "ready",
            waypoint_count=len(mission.waypoints),
            message=message,
        )

    def _schedule(self, command):
        if not str(command.execution_id):
            raise CoreError("execution_id is required", "EXECUTION_CONFLICT")
        scheduled_at = float(command.scheduled_at)
        if not math.isfinite(scheduled_at) or scheduled_at < 0.0:
            raise CoreError("scheduled_at is invalid", "CLOCK_UNSYNCED")
        self._schedule_token = self.core.schedule(self._identity(command))
        self._scheduled_at = scheduled_at
        self._execution_command = command
        return self._feedback(command, "scheduled", message="task scheduled")

    def _stop(self, command):
        message = self.backend.cancel()
        self.core.stop()
        self._scheduled_at = None
        self._schedule_token = None
        self._execution_command = None
        return self._feedback(command, "stopped", message=message)

    def _unload(self, command):
        try:
            message = self.backend.cancel()
        except BackendError as exc:
            message = "task state cleared; cancel reported: {}".format(exc)
        self.core.unload()
        self._scheduled_at = None
        self._schedule_token = None
        self._execution_command = None
        return self._feedback(command, "unloaded", message=message)

    def tick(self, now):
        if self._scheduled_at is None or float(now) < self._scheduled_at:
            return None
        token = self._schedule_token
        command = self._execution_command
        self._scheduled_at = None
        self._schedule_token = None
        if command is None or not self.core.can_start(token):
            return None
        try:
            message = self.backend.start()
            self.core.mark_running(token)
            return self._feedback(command, "running", message=message)
        except (BackendError, CoreError) as exc:
            self.core.stop()
            return self._feedback(
                command, "failed", error_code=exc.error_code, message=str(exc)
            )

    def update_mission_status(
        self, state, current_index, total_goals, detail, position=(0.0, 0.0, 0.0)
    ):
        command = self._execution_command
        if command is None:
            return None
        state = int(state)
        total = max(0, int(total_goals))
        index = max(-1, int(current_index))
        active_states = {1, 2, 3, 7}
        if state in active_states:
            output_state = "running"
            error_code = ""
            progress = 0.0 if total == 0 else min(1.0, max(0.0, float(index) / total))
        elif state == 4:
            output_state = "completed"
            error_code = ""
            progress = 1.0
            self.core.state = "completed"
        elif state == 5:
            output_state = "failed"
            lowered = str(detail).lower()
            error_code = (
                "LOCALIZATION_UNAVAILABLE"
                if "localization" in lowered
                else "EMERGENCY_STOP"
                if "emergency" in lowered
                else "NAVIGATION_PLAN_FAILED"
            )
            progress = 0.0 if total == 0 else min(1.0, max(0.0, float(index) / total))
            self.core.state = "failed"
        elif state == 6:
            output_state = "stopped"
            error_code = ""
            progress = 0.0 if total == 0 else min(1.0, max(0.0, float(index) / total))
            self.core.state = "stopped"
        else:
            return None
        return self._feedback(
            command,
            output_state,
            waypoint_index=index,
            waypoint_count=total,
            progress=progress,
            position=tuple(float(value) for value in position),
            error_code=error_code,
            message=str(detail),
        )
