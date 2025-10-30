extends Control

func _ready():
    yield(get_tree().create_timer(2.5), "timeout")
    _end_cutscene()

func _end_cutscene():
    # TODO: Replace with transition to overworld or first gameplay scene
    print("Cutscene ended. Transition to game start.")
