extends "res://scripts/bosses/CroakKing/minions/CroakKingMinion.gd"

# Direct Defector Minion

func _ready():
	minion_type = "DirectDefector"

func _process(delta):
	if converted:
		# Attack Croak King or enemy minions
		attack_boss()
	elif knighted:
		# Attack player
		attack_player()

func attack_boss():
	# Implement attack logic against Croak King
	pass

func attack_player():
	# Implement attack logic against player
	pass
