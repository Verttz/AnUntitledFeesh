extends Node

signal raid_started
signal raid_ended

func start_raid():
	emit_signal("raid_started")
	# Implement sirens, spotlights, and stall closing/barrier spawning

func end_raid():
	emit_signal("raid_ended")
	# Remove spotlights and restore arena
