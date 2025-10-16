extends Control

var settings_menu = null

func _ready():
    $VBoxContainer/NewGameButton.connect("pressed", self, "_on_new_game")
    $VBoxContainer/ContinueButton.connect("pressed", self, "_on_continue")
    $VBoxContainer/SettingsButton.connect("pressed", self, "_on_settings")
    $VBoxContainer/QuitButton.connect("pressed", self, "_on_quit")
    _update_continue_button()
    # Add settings menu as child
    settings_menu = preload("res://scenes/ui/SettingsMenuV2.tscn").instantiate()
    add_child(settings_menu)
    settings_menu.visible = false

func _update_continue_button():
    var save_path = "user://savegame.dat"
    if not FileAccess.file_exists(save_path):
        $VBoxContainer/ContinueButton.hide()
    else:
        $VBoxContainer/ContinueButton.show()


func _on_new_game():
    # Start opening cutscene and reset save
    SaveManager.save_data = {"player": {}, "world": {}, "progress": {}} # Reset data
    SaveManager.save_game()
    get_tree().change_scene_to_file("res://scenes/ui/OpeningCutscene.tscn")

func _on_continue():
    var loaded = SaveManager.load_game()
    if loaded:
        # TODO: Replace with transition to overworld or last saved scene
        get_tree().change_scene_to_file("res://scenes/overworld/OverworldManager.tscn")
    else:
        print("No save found.")

func _on_settings():
    if settings_menu:
        settings_menu.open()

func _on_quit():
    get_tree().quit()
