extends "res://scripts/bosses/CroakKing/hazards/CroakKingHazard.gd"

# Bug Nest Hazard

var destroyed := false

func _ready():
	hazard_type = "BugNest"

func trigger():
	if not destroyed:
		destroyed = true
		release_bugs()

func release_bugs():
	# Randomly provide healing item or spawn bug swarm
	# Bug swarm chases player, deals contact damage, lasts 10s
	pass
