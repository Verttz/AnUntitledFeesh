# WeatherSystem.gd
# Handles random and scripted weather events, state, and emits signals for weather changes.
extends Node

"""
WeatherSystem
-------------
- Tracks current weather state (e.g., clear, rain, storm, fog).
- Can randomize weather or be set by script.
- Emits signals on weather changes for integration with visuals, audio, and gameplay.
- All visual/audio hooks are left as TODOs for Godot integration.
"""

signal weather_changed(new_weather)

var weather_types := ["clear", "rain", "storm", "fog"]
var current_weather := "clear"
var weather_duration := 0 # Minutes remaining in current weather

func _ready():
    # TODO: Connect to day/night system or timer to call advance_weather()
    pass

func advance_weather():
    """
    Advances weather timer, randomizes or transitions weather as needed.
    """
    weather_duration -= 10 # Assume called every 10 in-game minutes
    if weather_duration <= 0:
        set_random_weather()

func set_random_weather():
    """
    Picks a random weather type and sets duration.
    """
    var new_weather = weather_types[randi() % weather_types.size()]
    set_weather(new_weather)

func set_weather(new_weather):
    """
    Sets the current weather and emits signal if changed.
    """
    if new_weather != current_weather:
        current_weather = new_weather
        weather_duration = 60 + randi() % 120 # 1-3 hours
        emit_signal("weather_changed", current_weather)
        # TODO: Trigger visual/audio/UI changes for new weather

func get_weather():
    return current_weather

# TODO: Add methods for scripted weather events, forced transitions, or weather forecasting.
