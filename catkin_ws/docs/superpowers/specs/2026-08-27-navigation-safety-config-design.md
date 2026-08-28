# Navigation Safety Configuration Design

## Goal

Prepare the existing move_base/GlobalPlanner/TEB configuration for the first low-speed ground-mode hardware test without changing mapping, relocalization, TF ownership, or actuator code.

## Design

`bz_navigation.launch` remains the single navigation entry point. It will explicitly load `global_planner_params.yaml`, then start `global_planner/GlobalPlanner` and `teb_local_planner/TebLocalPlannerROS` as before.

The ground-test profile uses conservative behavior: unknown map cells are not traversable, goals require stopping, translation/yaw tolerances are tightened to 0.25 m and 0.35 rad, angular acceleration is positive, and obstacle layers accept points from 0.15 m above the map ground plane. TEB predictive dynamic-obstacle handling is disabled until a velocity-estimation source exists; ordinary real-time point-cloud obstacle marking, clearing, inflation, and TEB avoidance remain active.

## Safety boundaries

- No launch is started by this change.
- No velocity, arming, takeoff, landing, or mode command is emitted.
- Mapping and relocalization files and interfaces are unchanged.
- Physical footprint values remain unchanged until the vehicle is measured.

## Verification

A Python contract test reads the actual launch and YAML files and rejects missing global-planner loading, unsafe goal behavior, zero angular acceleration, permissive unknown-space planning, unsupported predictive dynamic-obstacle mode, or excessive minimum obstacle height. The package test and a workspace build must pass before handoff.
