
extends Control

# Robust settings menu with persistent settings
var settings = {}

func _ready():
    $Panel/VBoxContainer/MasterVolumeSlider.connect("value_changed", self, "_on_master_volume_changed")
    $Panel/VBoxContainer/MusicVolumeSlider.connect("value_changed", self, "_on_music_volume_changed")
    $Panel/VBoxContainer/SFXVolumeSlider.connect("value_changed", self, "_on_sfx_volume_changed")
    $Panel/VBoxContainer/MuteAll.connect("toggled", self, "_on_mute_all_toggled")
    $Panel/VBoxContainer/ScreenModeOption.connect("item_selected", self, "_on_screen_mode_selected")
    $Panel/VBoxContainer/ResolutionOption.connect("item_selected", self, "_on_resolution_selected")
    $Panel/VBoxContainer/VSync.connect("toggled", self, "_on_vsync_toggled")
    $Panel/VBoxContainer/Subtitles.connect("toggled", self, "_on_subtitles_toggled")
    $Panel/VBoxContainer/TextSpeedSlider.connect("value_changed", self, "_on_text_speed_changed")
    $Panel/VBoxContainer/ColorblindMode.connect("toggled", self, "_on_colorblind_toggled")
    $Panel/VBoxContainer/LanguageOption.connect("item_selected", self, "_on_language_selected")
    $Panel/VBoxContainer/BackButton.connect("pressed", self, "_on_back_pressed")
    # Load settings from SettingsManager
    if typeof(SettingsManager) != TYPE_NIL:
        SettingsManager.load_settings()
        settings = SettingsManager.settings.duplicate()

func open():
    visible = true
    _sync_ui_to_settings()
    grab_focus()

func close():
    visible = false

func _sync_ui_to_settings():
    $Panel/VBoxContainer/MasterVolumeSlider.value = settings.get("master_volume", 0.8)
    $Panel/VBoxContainer/MusicVolumeSlider.value = settings.get("music_volume", 0.8)
    $Panel/VBoxContainer/SFXVolumeSlider.value = settings.get("sfx_volume", 0.8)
    $Panel/VBoxContainer/MuteAll.button_pressed = settings.get("mute_all", false)
    $Panel/VBoxContainer/ScreenModeOption.select(settings.get("screen_mode", 0))
    $Panel/VBoxContainer/ResolutionOption.select(settings.get("resolution", 1))
    $Panel/VBoxContainer/VSync.button_pressed = settings.get("vsync", true)
    $Panel/VBoxContainer/Subtitles.button_pressed = settings.get("subtitles", false)
    $Panel/VBoxContainer/TextSpeedSlider.value = settings.get("text_speed", 1.0)
    $Panel/VBoxContainer/ColorblindMode.button_pressed = settings.get("colorblind", false)
    $Panel/VBoxContainer/LanguageOption.select(settings.get("language", 0))

func _on_master_volume_changed(value):
    settings.master_volume = value
    AudioServer.set_bus_volume_db(0, linear2db(value))
    _save_settings()

func _on_music_volume_changed(value):
    settings.music_volume = value
    AudioServer.set_bus_volume_db(1, linear2db(value))
    _save_settings()

func _on_sfx_volume_changed(value):
    settings.sfx_volume = value
    AudioServer.set_bus_volume_db(2, linear2db(value))
    _save_settings()

func _on_mute_all_toggled(pressed):
    settings.mute_all = pressed
    for i in range(AudioServer.bus_count):
        AudioServer.set_bus_mute(i, pressed)
    _save_settings()

func _on_screen_mode_selected(idx):
    settings.screen_mode = idx
    if idx == 0:
        DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
    elif idx == 1:
        DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
    _save_settings()

func _on_resolution_selected(idx):
    settings.resolution = idx
    var resolutions = [Vector2i(1280,720), Vector2i(1920,1080), Vector2i(2560,1440)]
    if idx >= 0 and idx < resolutions.size():
        DisplayServer.window_set_size(resolutions[idx])
    _save_settings()

func _on_vsync_toggled(pressed):
    settings.vsync = pressed
    DisplayServer.window_set_vsync_mode(pressed ? DisplayServer.VSYNC_ENABLED : DisplayServer.VSYNC_DISABLED)
    _save_settings()

func _on_subtitles_toggled(pressed):
    settings.subtitles = pressed
    _save_settings()
    # TODO: Actually show/hide subtitles in cutscenes/dialogue

func _on_text_speed_changed(value):
    settings.text_speed = value
    _save_settings()
    # TODO: Apply text speed to dialogue/cutscene text

func _on_colorblind_toggled(pressed):
    settings.colorblind = pressed
    _save_settings()
    # TODO: Apply colorblind mode to game visuals

func _on_language_selected(idx):
    settings.language = idx
    _save_settings()
    # TODO: Switch game language (requires translation support)

func _on_back_pressed():
    _save_settings()
    close()

func _save_settings():
    if typeof(SettingsManager) != TYPE_NIL:
        SettingsManager.settings = settings.duplicate()
        SettingsManager.save_settings()

func linear2db(linear):
    if linear <= 0:
        return -80
    return 20 * log10(linear)
