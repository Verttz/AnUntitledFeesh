extends Node

signal raid_started
signal raid_ended

func start_raid():
	raid_started.emit()
	# Implement sirens, spotlights, and stall closing/barrier spawning

func end_raid():
	raid_ended.emit()
	# Remove spotlights and restore arena
