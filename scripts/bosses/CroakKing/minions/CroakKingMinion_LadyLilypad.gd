extends "res://scripts/bosses/CroakKing/minions/CroakKingMinion.gd"

# Lady Lilypad Minion

var safe_zone_active := false

func _ready():
	minion_type = "LadyLilypad"

func _process(delta):
	if converted and not safe_zone_active:
		create_safe_zone()

func create_safe_zone():
	safe_zone_active = true
	# Create safe zone or purify mud
	pass

func cheerlead():
	# Temporarily boost player speed or attack
	pass
