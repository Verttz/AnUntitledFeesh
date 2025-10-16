extends Node2D

# Croak King Environmental Hazard Base

var hazard_type := "MudGeyser" # or BugNest, LilyPad
var triggered := false

func trigger():
	triggered = true
	# Implement hazard effect (damage, spawn bugs, etc.)
	pass

func reset():
	triggered = false
	# Reset hazard state if needed
	pass
