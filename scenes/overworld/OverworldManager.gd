extends Node

# Manages loading/unloading screens and transitions

var current_screen = null
var fade_layer = null

func _ready():
    fade_layer = $FadeLayer
    load_screen("res://scenes/overworld/OverworldScreen.tscn")

func load_screen(path):
    if current_screen:
        remove_child(current_screen)
        current_screen.queue_free()
    # Autosave on screen transition (exploration only)
    var did_autosave = false
    if typeof(SaveManager) != TYPE_NIL and SaveManager.can_save("exploration"):
        SaveManager.autosave()
        did_autosave = true
    fade_out()
    yield(get_tree().create_timer(0.5), "timeout")
    current_screen = load(path).instance()
    add_child(current_screen)
    current_screen.connect("screen_exit", self, "on_screen_exit")
    fade_in()
    # Show autosave notification if possible
    if did_autosave and current_screen and current_screen.has_method("show_save_notification"):
        current_screen.show_save_notification()

func on_screen_exit(direction):
    # Determine next screen path based on direction and current biome
    var next_path = get_next_screen_path(direction)
    load_screen(next_path)

func get_next_screen_path(direction):
    # Placeholder: implement biome/screen logic
    return "res://scenes/overworld/OverworldScreen.tscn"

func fade_out():
    fade_layer.modulate.a = 0
    fade_layer.show()
    fade_layer.create_tween().tween_property(fade_layer, "modulate:a", 1, 0.5)

func fade_in():
    fade_layer.create_tween().tween_property(fade_layer, "modulate:a", 0, 0.5)
    yield(get_tree().create_timer(0.5), "timeout")
    fade_layer.hide()
