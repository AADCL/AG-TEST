#!/usr/bin/env python3
"""Pure validation helpers for the required ground-air TF topology."""

TARGET_EDGES = (
    ("world", "camera_init"),
    ("camera_init", "body"),
    ("body", "base_link"),
    ("base_link", "livox_frame"),
)


def normalize_frame(frame):
    return str(frame).strip().lstrip("/")


def validate_tf_tree(parents):
    normalized = {}
    for child, parent_set in parents.items():
        child_name = normalize_frame(child)
        normalized.setdefault(child_name, set()).update(
            normalize_frame(parent) for parent in parent_set
        )

    errors = []
    for child, parent_set in sorted(normalized.items()):
        if len(parent_set) > 1:
            errors.append(
                "child {} has multiple parents: {}".format(
                    child, ", ".join(sorted(parent_set))
                )
            )

    for parent, child in TARGET_EDGES:
        if parent not in normalized.get(child, set()):
            errors.append("missing target edge {} -> {}".format(parent, child))

    if "odom" in normalized or any("odom" in values for values in normalized.values()):
        errors.append("legacy odom frame is present")
    return errors

