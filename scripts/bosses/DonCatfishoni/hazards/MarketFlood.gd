extends Node

signal flood_started
signal flood_ended

func start_flood():
	flood_started.emit()
	# Implement water rising, slowing movement, and washing away hazards/minions

func end_flood():
	flood_ended.emit()
	# Restore arena to normal
