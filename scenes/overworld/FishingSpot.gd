extends Area2D

signal fishing_started

func _on_player_interact():
    fishing_started.emit()
    # Trigger fishing minigame or mode
