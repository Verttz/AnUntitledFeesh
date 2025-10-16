extends "res://scripts/bosses/CroakKing/minions/CroakKingMinion.gd"

# Distraction (Jester) Minion

var distracting := false

func _ready():
	minion_type = "Distraction"

func _process(delta):
	if converted and not distracting:
		start_distraction()

func start_distraction():
	distracting = true
	# Perform antics to distract Croak King or enemy minions
	pass

func prank_boss():
	# Debuff or stun Croak King
	pass
