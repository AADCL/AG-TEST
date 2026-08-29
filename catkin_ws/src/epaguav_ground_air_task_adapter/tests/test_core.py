import unittest

from epaguav_ground_air_task_adapter import core


class CoreTests(unittest.TestCase):
    def test_request_cache_replays_same_request_and_rejects_conflicting_reuse(self):
        self.assertTrue(hasattr(core, "RequestCache"))
        cache = core.RequestCache(capacity=2)
        signature = (4, "task-a", "sub-a", 3)
        self.assertIsNone(cache.lookup("request-a", signature))
        response = {"state": "ready", "message": "prepared"}
        cache.store("request-a", signature, response)
        self.assertEqual(cache.lookup("request-a", signature), response)
        with self.assertRaises(core.CoreError) as raised:
            cache.lookup("request-a", (5, "task-a", "sub-a", 3))
        self.assertEqual(raised.exception.error_code, "REQUEST_ID_CONFLICT")

    def test_new_generation_invalidates_a_stale_scheduled_start(self):
        self.assertTrue(hasattr(core, "AdapterCore"))
        state = core.AdapterCore()
        identity = core.TaskIdentity("task-a", "sub-a", "AGV_001", 3)
        state.prepare(identity)
        token = state.schedule(identity)
        self.assertTrue(state.can_start(token))
        state.stop()
        self.assertFalse(state.can_start(token))
        self.assertEqual(state.state, "stopped")

    def test_schedule_requires_the_current_prepared_identity(self):
        self.assertTrue(hasattr(core, "AdapterCore"))
        state = core.AdapterCore()
        prepared = core.TaskIdentity("task-a", "sub-a", "AGV_001", 3)
        other = core.TaskIdentity("task-a", "sub-a", "AGV_001", 4)
        state.prepare(prepared)
        with self.assertRaises(core.CoreError) as raised:
            state.schedule(other)
        self.assertEqual(raised.exception.error_code, "REVISION_MISMATCH")

    def test_unload_clears_prepared_task_and_invalidates_generation(self):
        self.assertTrue(hasattr(core, "AdapterCore"))
        state = core.AdapterCore()
        identity = core.TaskIdentity("task-a", "sub-a", "AGV_001", 3)
        state.prepare(identity)
        token = state.schedule(identity)
        state.unload()
        self.assertIsNone(state.prepared)
        self.assertEqual(state.state, "empty")
        self.assertFalse(state.can_start(token))


if __name__ == "__main__":
    unittest.main()
