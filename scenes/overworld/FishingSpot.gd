extends Area2D

signal fishing_started

func _on_player_interact():
    emit_signal("fishing_started")
    # Trigger fishing minigame or mode
