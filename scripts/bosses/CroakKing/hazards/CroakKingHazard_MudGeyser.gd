extends "res://scripts/bosses/CroakKing/hazards/CroakKingHazard.gd"

# Mud Geyser Hazard

var geyser_timer := 2.5
var active := false

func _ready():
	hazard_type = "MudGeyser"

func trigger():
	if not active:
		active = true
		# Start geyser timer
		start_geyser()

func start_geyser():
	yield(get_tree().create_timer(geyser_timer), "timeout")
	shoot_geyser()

func shoot_geyser():
	# Deal damage, arc mud projectiles
	# Persist mud in area
	active = false
	pass
