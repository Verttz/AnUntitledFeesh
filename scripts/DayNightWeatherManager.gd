# DayNightWeatherManager.gd
# Integrates DayNightSystem and WeatherSystem for the overworld.
extends Node

"""
This manager instantiates and coordinates the DayNightSystem and WeatherSystem.
It advances time/weather, connects signals, and provides hooks for UI and gameplay.
"""

@onready var day_night = preload("res://scripts/DayNightSystem.gd").new()
@onready var weather = preload("res://scripts/WeatherSystem.gd").new()

var timer := null

func _ready():
    # Add systems as children for signal connections
    add_child(day_night)
    add_child(weather)
    # Connect signals to local handlers (expand as needed)
    day_night.connect("phase_changed", self, "_on_phase_changed")
    day_night.connect("time_advanced", self, "_on_time_advanced")
    weather.connect("weather_changed", self, "_on_weather_changed")
    # Start timer to advance time/weather every second (10 in-game minutes)
    timer = Timer.new()
    timer.wait_time = 1.0
    timer.autostart = true
    timer.one_shot = false
    timer.connect("timeout", self, "_on_timer_tick")
    add_child(timer)

func _on_timer_tick():
    day_night.advance_time()
    weather.advance_weather()

func _on_phase_changed(new_phase):
    # TODO: Integrate with lighting, music, and gameplay
    print("Day phase changed to:", new_phase)

func _on_time_advanced(current_time):
    # TODO: Update UI with new time
    print("Time advanced:", day_night.get_time_string())

func _on_weather_changed(new_weather):
    # TODO: Integrate with weather visuals, audio, and gameplay
    print("Weather changed to:", new_weather)

func get_time_string():
    return day_night.get_time_string()

func get_weather():
    return weather.get_weather()

# TODO: Add methods to pause/resume time, force weather, or trigger events as needed.
