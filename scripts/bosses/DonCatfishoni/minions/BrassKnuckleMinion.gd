extends "res://scripts/bosses/Minion.gd"

# Brass Knuckle Minion: Walks toward the player and attacks at close range
var speed := 80
var attack_range := 32
var attack_cooldown := 1.2
var attack_timer := 0.0

func _process(delta):
	if not is_instance_valid(player):
		return
	var to_player = player.global_position - global_position
	if to_player.length() > attack_range:
		move_and_slide(to_player.normalized() * speed)
	else:
		attack_timer -= delta
		if attack_timer <= 0.0:
			attack_player()
			attack_timer = attack_cooldown

func attack_player():
	# Implement damage to player here
	pass
