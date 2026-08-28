#!/usr/bin/env python3
"""Pure operation sequencing shared by the one-shot ROS launch helper."""


class OperationError(RuntimeError):
    pass


def _require_map_id(map_id):
    value = str(map_id).strip()
    if not value:
        raise OperationError("map_id must not be empty")
    return value


def _require_success(response, label):
    if not bool(response.success):
        raise OperationError("{} failed: {}".format(label, response.message))
    return response


def execute(operation, api, map_id="", timeout=60.0):
    if operation == "start_mapping":
        return _require_success(
            api.start_mapping(_require_map_id(map_id)), "start mapping"
        )
    if operation == "save_mapping":
        return _require_success(api.save_mapping(), "save mapping")
    if operation == "relocalize":
        selected_map = _require_map_id(map_id)
        _require_success(api.load_map(selected_map), "load map")
        return _require_success(api.relocalize(float(timeout)), "relocalization")
    raise OperationError("unsupported operation: {}".format(operation))
