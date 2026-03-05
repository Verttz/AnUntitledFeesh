
extends Node

"""
SettingsManager.gd
------------------
Singleton for persistent game settings. Handles saving and loading of user preferences such as audio, video, accessibility, and language.
"""

# --- Settings Data Structure ---
var settings_path := "user://settings.cfg" # Path to settings file
var settings = {
    "master_volume": 0.8,   # Master audio volume (0.0-1.0)
    "music_volume": 0.8,    # Music volume (0.0-1.0)
    "sfx_volume": 0.8,      # Sound effects volume (0.0-1.0)
    "mute_all": false,      # Mute all audio
    "screen_mode": 0,      # 0=windowed, 1=fullscreen, etc.
    "resolution": 1,       # Resolution preset index
    "vsync": true,         # Vertical sync enabled
    "subtitles": false,    # Subtitles on/off
    "text_speed": 1.0,     # Text display speed
    "colorblind": false,   # Colorblind mode
    "language": 0          # Language index
}

func _ready():
    load_settings()

func save_settings():
    """
    Saves the current settings to disk.
    """
    var file = FileAccess.open(settings_path, FileAccess.WRITE)
    if file:
        file.store_var(settings)
        file.close()
        print("Settings saved.")

func load_settings():
    """
    Loads settings from disk, merging with defaults so new keys are preserved.
    """
    if not FileAccess.file_exists(settings_path):
        print("No settings file found. Using defaults.")
        return
    var file = FileAccess.open(settings_path, FileAccess.READ)
    if file:
        var loaded = file.get_var(true)
        file.close()
        if loaded != null and typeof(loaded) == TYPE_DICTIONARY:
            for key in settings.keys():
                if key in loaded:
                    settings[key] = loaded[key]
            print("Settings loaded.")
        else:
            print("Invalid settings data. Using defaults.")
