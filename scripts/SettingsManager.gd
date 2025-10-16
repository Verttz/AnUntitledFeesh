extends Node

# Singleton for persistent game settings
var settings_path := "user://settings.cfg"
var settings = {
    "master_volume": 0.8,
    "music_volume": 0.8,
    "sfx_volume": 0.8,
    "mute_all": false,
    "screen_mode": 0,
    "resolution": 1,
    "vsync": true,
    "subtitles": false,
    "text_speed": 1.0,
    "colorblind": false,
    "language": 0
}

func save_settings():
    var file = FileAccess.open(settings_path, FileAccess.WRITE)
    if file:
        file.store_var(settings)
        file.close()
        print("Settings saved.")

func load_settings():
    if not FileAccess.file_exists(settings_path):
        print("No settings file found. Using defaults.")
        return
    var file = FileAccess.open(settings_path, FileAccess.READ)
    if file:
        settings = file.get_var()
        file.close()
        print("Settings loaded.")
