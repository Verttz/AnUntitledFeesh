extends "res://scripts/bosses/CroakKing/minions/CroakKingMinion.gd"

# Tower Minion

var tower_built := false

func _ready():
	minion_type = "Tower"

func _process(delta):
	if converted and not tower_built:
		build_tower()
	if tower_built:
		fire_projectiles()

func build_tower():
	tower_built = true
	# Spawn tower visual, set up firing logic
	pass

func fire_projectiles():
	# Fire at Croak King or enemy minions
	pass
