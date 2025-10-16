extends Control

# Pause menu logic: manual save, settings, quit

var settings_menu = null

func _ready():
    $Panel/VBoxContainer/SaveButton.connect("pressed", self, "_on_save_pressed")
    $Panel/VBoxContainer/SettingsButton.connect("pressed", self, "_on_settings_pressed")
    $Panel/VBoxContainer/QuitButton.connect("pressed", self, "_on_quit_pressed")
    # Add settings menu as child
    settings_menu = preload("res://scenes/ui/SettingsMenuV2.tscn").instantiate()
    add_child(settings_menu)
    settings_menu.visible = false

func open():
    visible = true
    get_tree().paused = true

func close():
    visible = false
    get_tree().paused = false

func _on_save_pressed():
    # Only allow save in exploration mode
    var can_save = typeof(SaveManager) != TYPE_NIL and SaveManager.can_save("exploration")
    if can_save:
        SaveManager.request_save("exploration")
        # Show save notification in bottom left
        var parent = get_parent()
        if parent and parent.has_method("show_save_notification"):
            parent.show_save_notification()
        print("Game saved.")
    else:
        print("Cannot save right now.")

func _on_settings_pressed():
    if settings_menu:
        settings_menu.open()

func _on_quit_pressed():
    get_tree().paused = false
    get_tree().change_scene_to_file("res://scenes/ui/MainMenu.tscn")
