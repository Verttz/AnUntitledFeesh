extends Node

signal flood_started
signal flood_ended

func start_flood():
	emit_signal("flood_started")
	# Implement water rising, slowing movement, and washing away hazards/minions

func end_flood():
	emit_signal("flood_ended")
	# Restore arena to normal
