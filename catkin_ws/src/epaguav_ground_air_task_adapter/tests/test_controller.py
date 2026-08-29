import os
import tempfile
import unittest
from types import SimpleNamespace

from epaguav_ground_air_task_adapter import controller


XML = """<?xml version='1.0' encoding='utf-8'?>
<trajectory schema_version="2" task_id="task-a" subtask_id="sub-a"
 device_id="AGV_001" revision="3" crc32="123">
  <metadata task_name="test" map_id="map-a" frame_id="map"
   cruise_speed_mps="0.5" start_delay_seconds="2.0" />
  <waypoints count="2">
    <waypoint index="0" waypoint_id="wp-0" x="1.0" y="0.0" z="0.0" />
    <waypoint index="1" waypoint_id="wp-1" x="2.0" y="0.0" z="0.0" />
  </waypoints>
</trajectory>
"""


class FakeBackend:
    def __init__(self):
        self.calls = []

    def submit(self, mission):
        self.calls.append(("submit", mission.mission_id))
        return "mission accepted"

    def start(self):
        self.calls.append(("start",))
        return "mission started"

    def cancel(self):
        self.calls.append(("cancel",))
        return "mission canceled"


class ControllerTests(unittest.TestCase):
    def setUp(self):
        self.root = tempfile.TemporaryDirectory()
        self.addCleanup(self.root.cleanup)
        self.xml_path = os.path.join(self.root.name, "trajectory.xml")
        with open(self.xml_path, "w", encoding="utf-8") as stream:
            stream.write(XML)
        self.backend = FakeBackend()
        self.assertTrue(hasattr(controller, "TaskAdapterController"))
        self.adapter = controller.TaskAdapterController(self.root.name, self.backend)

    def command(self, action, request_id, execution_id="", scheduled_at=0.0):
        return SimpleNamespace(
            action=action,
            request_id=request_id,
            task_id="task-a",
            subtask_id="sub-a",
            device_id="AGV_001",
            execution_id=execution_id,
            revision=3,
            xml_path=self.xml_path,
            frame_id="map",
            map_id="map-a",
            scheduled_at=scheduled_at,
        )

    def test_prepare_submits_once_and_replays_duplicate_feedback(self):
        command = self.command(controller.PREPARE, "prepare-1")
        first = self.adapter.handle(command, current_xy=(0.0, 0.0))
        second = self.adapter.handle(command, current_xy=(99.0, 99.0))
        self.assertEqual(first.state, "ready")
        self.assertEqual(second, first)
        self.assertEqual(self.backend.calls, [("submit", "task-a:sub-a:r3")])

    def test_schedule_starts_only_after_due_time(self):
        self.adapter.handle(self.command(controller.PREPARE, "prepare-1"))
        scheduled = self.adapter.handle(
            self.command(controller.SCHEDULE, "schedule-1", "execution-1", 50.0),
            now=40.0,
        )
        self.assertEqual(scheduled.state, "scheduled")
        self.assertIsNone(self.adapter.tick(49.9))
        running = self.adapter.tick(50.0)
        self.assertEqual(running.state, "running")
        self.assertEqual(self.backend.calls[-1], ("start",))
        self.assertIsNone(self.adapter.tick(60.0))

    def test_stop_invalidates_scheduled_start_and_unload_clears_task(self):
        self.adapter.handle(self.command(controller.PREPARE, "prepare-1"))
        self.adapter.handle(
            self.command(controller.SCHEDULE, "schedule-1", "execution-1", 50.0),
            now=40.0,
        )
        stopped = self.adapter.handle(
            self.command(controller.STOP, "stop-1", "execution-1"), now=41.0
        )
        self.assertEqual(stopped.state, "stopped")
        self.assertIsNone(self.adapter.tick(60.0))
        unloaded = self.adapter.handle(self.command(controller.UNLOAD, "unload-1"))
        self.assertEqual(unloaded.state, "unloaded")
        self.assertIsNone(self.adapter.core.prepared)
        self.assertNotIn(("start",), self.backend.calls)

    def test_mission_status_maps_to_progress_and_terminal_feedback(self):
        self.adapter.handle(self.command(controller.PREPARE, "prepare-1"))
        self.adapter.handle(
            self.command(controller.SCHEDULE, "schedule-1", "execution-1", 10.0),
            now=9.0,
        )
        self.adapter.tick(10.0)
        progress = self.adapter.update_mission_status(
            state=1, current_index=1, total_goals=2, detail="navigating",
            position=(1.2, 0.3, 0.0),
        )
        self.assertEqual(progress.state, "running")
        self.assertEqual(progress.waypoint_index, 1)
        self.assertEqual(progress.waypoint_count, 2)
        self.assertAlmostEqual(progress.progress, 0.5)
        completed = self.adapter.update_mission_status(
            state=4, current_index=1, total_goals=2, detail="mission completed",
            position=(2.0, 0.0, 0.0),
        )
        self.assertEqual(completed.state, "completed")
        self.assertEqual(completed.progress, 1.0)

    def test_conflicting_request_id_is_rejected_without_side_effect(self):
        original = self.command(controller.PREPARE, "same")
        self.adapter.handle(original)
        rejected = self.adapter.handle(self.command(controller.UNLOAD, "same"))
        self.assertEqual(rejected.state, "failed")
        self.assertEqual(rejected.error_code, "REQUEST_ID_CONFLICT")
        self.assertIsNotNone(self.adapter.core.prepared)
        replayed = self.adapter.handle(original)
        self.assertEqual(replayed.state, "ready")
        self.assertEqual(self.backend.calls, [("submit", "task-a:sub-a:r3")])


if __name__ == "__main__":
    unittest.main()
