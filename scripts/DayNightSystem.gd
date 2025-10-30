# DayNightSystem.gd
# Handles in-game time progression, day/night transitions, and emits signals for phase changes.
extends Node

"""
DayNightSystem
--------------
- Tracks in-game time (minutes, hours, days).
- Emits signals on sunrise, sunset, and phase changes (morning, afternoon, evening, night).
- Designed for easy integration with lighting, music, and gameplay events.
- All visual/audio hooks are left as TODOs for Godot integration.
"""

signal time_advanced(current_time)
signal phase_changed(new_phase)

var minutes_per_tick := 10 # How many in-game minutes pass per tick
var current_time := {"hour": 6, "minute": 0, "day": 1}
var phase := "morning" # [morning, afternoon, evening, night]

func _ready():
    # TODO: Connect to a timer or game loop to call advance_time()
    pass

func advance_time():
    """
    Advances the in-game clock by minutes_per_tick.
    Emits signals if phase or day changes.
    """
    current_time["minute"] += minutes_per_tick
    if current_time["minute"] >= 60:
        current_time["minute"] -= 60
        current_time["hour"] += 1
    if current_time["hour"] >= 24:
        current_time["hour"] = 0
        current_time["day"] += 1
    emit_signal("time_advanced", current_time)
    var new_phase = get_phase()
    if new_phase != phase:
        phase = new_phase
        emit_signal("phase_changed", phase)
        # TODO: Trigger lighting/music/UI changes for new phase

func get_phase():
    """
    Returns the current phase of day based on hour.
    """
    var h = current_time["hour"]
    if h >= 6 and h < 12:
        return "morning"
    elif h >= 12 and h < 18:
        return "afternoon"
    elif h >= 18 and h < 21:
        return "evening"
    else:
        return "night"

func get_time_string():
    """
    Returns a formatted string of the current time (e.g., 06:30 Day 1).
    """
    return "%02d:%02d Day %d" % [current_time["hour"], current_time["minute"], current_time["day"]]

# TODO: Add methods to set time, skip to next phase, or pause/resume time as needed.
