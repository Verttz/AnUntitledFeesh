extends "res://scripts/bosses/Minion.gd"

# Tommy Gun Minion: Keeps distance and fires bursts at the player
var speed := 70
var preferred_distance := 160
var burst_count := 6
var burst_cooldown := 2.0
var burst_timer := 0.0

func _process(delta):
	if not is_instance_valid(player):
		return
	var to_player = player.global_position - global_position
	if abs(to_player.length() - preferred_distance) > 16:
		move_and_slide((to_player.normalized() * (to_player.length() > preferred_distance ? speed : -speed)))
	else:
		burst_timer -= delta
		if burst_timer <= 0.0:
			fire_burst()
			burst_timer = burst_cooldown

func fire_burst():
	for i in range(burst_count):
		# Implement bullet firing logic here
		pass
