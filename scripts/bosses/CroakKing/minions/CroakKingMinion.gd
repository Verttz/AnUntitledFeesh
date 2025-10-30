extends CharacterBody2D

# Croak King Minion Base

var knighted := false
var killed := false
var converted := false
var minion_type := "DirectDefector" # or Tower, LadyLilypad, Distraction, Saboteur, Medic

func empower():
	# Called when knighted by the King
	knighted = true
	# Add empowered state/attack logic here
	pass

func die():
	killed = true
	queue_free()

func convert():
	converted = true
	# Change allegiance, update visuals/AI
	pass

# Override for each minion type as needed
