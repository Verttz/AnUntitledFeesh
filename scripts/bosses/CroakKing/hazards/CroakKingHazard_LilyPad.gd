extends "res://scripts/bosses/CroakKing/hazards/CroakKingHazard.gd"

# Lily Pad Hazard

var sinking := false
var mud_zone := false

func _ready():
	hazard_type = "LilyPad"

func trigger():
	if not sinking:
		sinking = true
		start_sinking()

func start_sinking():
	# Gradually submerge, then become mud
	mud_zone = true
	# Apply mud slow effect to player
	pass
