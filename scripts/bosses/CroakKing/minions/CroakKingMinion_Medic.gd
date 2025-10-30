extends "res://scripts/bosses/CroakKing/minions/CroakKingMinion.gd"

# Medic Minion

var healing := false

func _ready():
	minion_type = "Medic"

func _process(delta):
	if converted and not healing:
		heal_player()

func heal_player():
	healing = true
	# Heal or shield the player, revive other minions
	pass

func revive_minion(minion):
	# Revive a fallen converted minion
	pass
