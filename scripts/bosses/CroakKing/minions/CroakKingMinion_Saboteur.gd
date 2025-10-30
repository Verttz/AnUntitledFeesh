extends "res://scripts/bosses/CroakKing/minions/CroakKingMinion.gd"

# Saboteur Minion

var sabotaging := false

func _ready():
	minion_type = "Saboteur"

func _process(delta):
	if converted and not sabotaging:
		sabotage_arena()

func sabotage_arena():
	sabotaging = true
	# Cause hazards to backfire on Croak King
	pass
