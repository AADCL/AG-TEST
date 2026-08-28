#!/usr/bin/env python3
from pathlib import Path
from types import SimpleNamespace
import importlib.util
import unittest


ROOT = Path(__file__).resolve().parents[1]
MODULE = ROOT / "scripts" / "ground_air_operation_core.py"


def load_core():
    if not MODULE.is_file():
        raise AssertionError("ground_air_operation_core.py is missing")
    spec = importlib.util.spec_from_file_location("ground_air_operation_core", str(MODULE))
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


class FakeApi:
    def __init__(self, load_success=True, operation_success=True):
        self.calls = []
        self.load_success = load_success
        self.operation_success = operation_success

    def start_mapping(self, map_id):
        self.calls.append(("start_mapping", map_id))
        return SimpleNamespace(success=self.operation_success, message="start")

    def save_mapping(self):
        self.calls.append(("save_mapping",))
        return SimpleNamespace(success=self.operation_success, message="save")

    def load_map(self, map_id):
        self.calls.append(("load_map", map_id))
        return SimpleNamespace(success=self.load_success, message="load")

    def relocalize(self, timeout):
        self.calls.append(("relocalize", timeout))
        return SimpleNamespace(success=self.operation_success, message="relocalize")


class GroundAirOperationCoreTests(unittest.TestCase):
    def test_start_mapping_forwards_map_id(self):
        core = load_core()
        api = FakeApi()
        response = core.execute("start_mapping", api, map_id="site_a")
        self.assertTrue(response.success)
        self.assertEqual([("start_mapping", "site_a")], api.calls)

    def test_save_mapping_calls_only_save(self):
        core = load_core()
        api = FakeApi()
        response = core.execute("save_mapping", api)
        self.assertTrue(response.success)
        self.assertEqual([("save_mapping",)], api.calls)

    def test_relocalization_loads_map_before_registration(self):
        core = load_core()
        api = FakeApi()
        response = core.execute("relocalize", api, map_id="site_a", timeout=45.0)
        self.assertTrue(response.success)
        self.assertEqual([("load_map", "site_a"), ("relocalize", 45.0)], api.calls)

    def test_relocalization_stops_when_map_load_fails(self):
        core = load_core()
        api = FakeApi(load_success=False)
        with self.assertRaises(core.OperationError):
            core.execute("relocalize", api, map_id="missing", timeout=60.0)
        self.assertEqual([("load_map", "missing")], api.calls)

    def test_map_id_is_required_for_start_and_relocalize(self):
        core = load_core()
        for operation in ("start_mapping", "relocalize"):
            with self.subTest(operation=operation):
                with self.assertRaises(core.OperationError):
                    core.execute(operation, FakeApi(), map_id="")


if __name__ == "__main__":
    unittest.main()
