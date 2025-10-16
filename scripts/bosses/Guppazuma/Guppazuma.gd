
extends "res://scripts/bosses/Boss.gd"

## Guppazuma the Idol King - Finalized Design Implementation

var favor = 0 # -100 (crowd loves Guppazuma) to 100 (crowd loves player)
var favor_totems = null
var crowd_audio = null
var voting_timer = null
var audience_event_timer = null
var phase_thresholds = [75, 50, 25]
var current_phase = 1

func _ready():
	health = max_health
	current_phase = 1
	if has_node("../FavorTotems"): favor_totems = get_node("../FavorTotems")
	if has_node("../CrowdAudio"): crowd_audio = get_node("../CrowdAudio")
	start_phase(current_phase)
	start_audience_event_timer()
	start_voting_timer()
func start_audience_event_timer():
	audience_event_timer = Timer.new()
	audience_event_timer.wait_time = 4.0
	audience_event_timer.one_shot = false
	audience_event_timer.connect("timeout", self, "_on_audience_event")
	add_child(audience_event_timer)
	audience_event_timer.start()

func _on_audience_event():
	var event_roll = randi() % 6
	match event_roll:
		0:
			fruit_toss()
		1:
			cheer_wave()
		2:
			confetti_storm()
		3:
			rotten_fruit_or_peel()
		4:
			wild_animal_interference()
		5:
			boo_bomb()

func fruit_toss():
	var fruit_scene = preload("res://scenes/arenas/Fruit.tscn")
	var fruit = fruit_scene.instance()
	fruit.position = global_position + Vector2(randf_range(-200,200), -250)
	fruit.target = favor > 0 ? "Player" : "Guppazuma"
	get_parent().add_child(fruit)

func cheer_wave():
	if favor > 0:
		# Player favored: clear bullets, slow boss
		emit_signal("cheer_wave_player")
		set_physics_process(false)
		yield(get_tree().create_timer(1.0), "timeout")
		set_physics_process(true)
	else:
		# Guppazuma favored: radial bullet burst
		var proj_scene = preload("res://scenes/arenas/StoneProjectile.tscn")
		for i in range(12):
			var proj = proj_scene.instance()
			proj.position = global_position
			proj.linear_velocity = Vector2.RIGHT.rotated(deg2rad(i*30)) * 350
			get_parent().add_child(proj)

func confetti_storm():
	if favor > 0:
		# Player favored: highlight safe zones
		emit_signal("confetti_safe_zones")
	else:
		# Guppazuma favored: obscure vision
		emit_signal("confetti_hazard")

func rotten_fruit_or_peel():
	var is_peel = randi() % 2 == 0
	if is_peel:
		var peel_scene = preload("res://scenes/arenas/BananaPeel.tscn")
		var peel = peel_scene.instance()
		peel.position = global_position + Vector2(randf_range(-180,180), 0)
		get_parent().add_child(peel)
	else:
		var rotten_scene = preload("res://scenes/arenas/RottenFruit.tscn")
		var rotten = rotten_scene.instance()
		rotten.position = global_position + Vector2(randf_range(-180,180), 0)
		get_parent().add_child(rotten)

func wild_animal_interference():
	var animal_scene = preload("res://scenes/arenas/WildAnimal.tscn")
	var animal = animal_scene.instance()
	animal.position = global_position + Vector2(randf_range(-250,250), -300)
	animal.target = favor > 0 ? "Guppazuma" : "Player"
	get_parent().add_child(animal)

func boo_bomb():
	var bomb_scene = preload("res://scenes/arenas/BooBomb.tscn")
	var bomb = bomb_scene.instance()
	bomb.position = global_position + Vector2(randf_range(-200,200), -250)
	get_parent().add_child(bomb)
func start_voting_timer():
	voting_timer = Timer.new()
	voting_timer.wait_time = 12.0
	voting_timer.one_shot = false
	voting_timer.connect("timeout", self, "_on_voting_moment")
	add_child(voting_timer)
	voting_timer.start()

func _on_voting_moment():
	# Jungle Idol Voting: crowd votes for player or Guppazuma
	if favor > 20:
		# Player wins vote: Guppazuma stunned
		set_vulnerable(true)
		emit_signal("idol_vote_player")
		yield(get_tree().create_timer(2.0), "timeout")
		set_vulnerable(false)
	elif favor < -20:
		# Guppazuma wins vote: gets buff
		emit_signal("idol_vote_guppazuma")
		# Example: speed up attacks
		for t in attack_timers.values():
			t.wait_time = max(1.0, t.wait_time * 0.7)
	else:
		# Tie: both get minor effects
		emit_signal("idol_vote_tie")

func start_phase(new_phase):
	phase = new_phase
	emit_signal("phase_changed", phase)
	if phase == 1:
		_start_phase1()
	elif phase == 2:
		_start_phase2()
	elif phase == 3:
		_start_phase3()
	elif phase == 4:
		_start_phase4()

func check_phase_transition():
	var favor_percent = (favor + 100) / 2 # 0-100
	if phase == 1 and favor_percent >= phase_thresholds[0]:
		start_phase(2)
	elif phase == 2 and favor_percent >= phase_thresholds[1]:
		start_phase(3)
	elif phase == 3 and favor_percent >= phase_thresholds[2]:
		start_phase(4)

func _start_phase1():
	# Normal attacks, crowd on Guppazuma's side
	_start_attack_timer("stone_piranha_swarm", 3.0)
	_start_attack_timer("idol_beam", 7.0)
	_start_attack_timer("arena_shift", 10.0)

func _start_phase2():
	# Mimicry phase, crowd starts noticing player
	_start_attack_timer("stone_piranha_swarm", 4.0)
	_start_attack_timer("idol_beam", 8.0)
	_start_attack_timer("arena_shift", 10.0)
	_start_attack_timer("mimicry", 6.0)

func _start_phase3():
	# Exaggerated mimicry, crowd roots for player
	_start_attack_timer("stone_piranha_swarm", 4.0)
	_start_attack_timer("idol_beam", 8.0)
	_start_attack_timer("arena_shift", 8.0)
	_start_attack_timer("mimicry", 4.0)

func _start_phase4():
	# Showdown: wild, unpredictable, crowd is wild
	_start_attack_timer("stone_piranha_swarm", 3.0)
	_start_attack_timer("idol_beam", 6.0)
	_start_attack_timer("arena_shift", 6.0)
	_start_attack_timer("mimicry", 3.0)
	_start_attack_timer("unpredictable", 5.0)

var attack_timers = {}

func _start_attack_timer(name, interval):
	if attack_timers.has(name):
		attack_timers[name].stop()
	var timer = Timer.new()
	timer.wait_time = interval
	timer.one_shot = false
	timer.connect("timeout", self, "_on_attack_timer", [name])
	add_child(timer)
	timer.start()
	attack_timers[name] = timer

func _on_attack_timer(name):
	match name:
		"stone_piranha_swarm":
			stone_piranha_swarm()
		"idol_beam":
			idol_beam()
		"arena_shift":
			arena_shift()
		"mimicry":
			mimicry_attack()
		"unpredictable":
			unpredictable_attack()

func stone_piranha_swarm():
	# Classic bullet hell pattern: spawn waves of stone piranhas from arena edges
	var piranha_scene = preload("res://scenes/arenas/StonePiranha.tscn")
	var directions = [Vector2(-1,0), Vector2(1,0), Vector2(0,-1), Vector2(0,1)]
	for dir in directions:
		for i in range(3):
			var piranha = piranha_scene.instance()
			piranha.position = global_position + dir * 300 + Vector2(randf_range(-40,40), randf_range(-40,40))
			piranha.linear_velocity = dir * randf_range(200, 350)
			get_parent().add_child(piranha)

func idol_beam():
	# Channels a beam attack in the direction of the last mimicked player action
	# (Assume last_mimic_direction is set by mimicry_attack)
	if not has_node("../Arena"): return
	var arena = get_node("../Arena")
	var beam_scene = preload("res://scenes/arenas/IdolBeam.tscn")
	var beam = beam_scene.instance()
	beam.position = global_position
	beam.rotation = last_mimic_direction.angle() if typeof(last_mimic_direction) == TYPE_VECTOR2 else 0
	arena.add_child(beam)

func arena_shift():
	# Rotates or tilts the arena, triggers hazard changes
	if has_node("../Arena"):
		get_node("../Arena").shift_platform(randf_range(-30,30))
	# Optionally spawn hazards or move cover

var last_mimic_direction = Vector2.RIGHT
func mimicry_attack():
	# Copies player's last attack/move in exaggerated fashion
	var player = get_tree().get_root().find_node("Player", true, false)
	if not player:
		return
	var move_type = player.get_last_move_type() # e.g. "dash", "ranged", "circle"
	last_mimic_direction = player.get_last_move_direction()
	match move_type:
		"dash":
			# Heavy sliding dash with shockwave
			mimic_dash(last_mimic_direction)
		"ranged":
			# Volley of stone projectiles
			mimic_ranged(last_mimic_direction)
		"circle":
			# Spin and whirlwind
			mimic_spin()
		_:
			# Default: taunt
			mimic_taunt()

func mimic_dash(direction):
	# Exaggerated dash with shockwave
	position += direction.normalized() * 200
	if has_node("../Arena"):
		get_node("../Arena").spawn_shockwave(global_position, direction)

func mimic_ranged(direction):
	# Fire volley of stone projectiles
	var proj_scene = preload("res://scenes/arenas/StoneProjectile.tscn")
	for i in range(5):
		var proj = proj_scene.instance()
		proj.position = global_position
		proj.linear_velocity = direction.rotated(deg2rad(-20 + 10*i)) * 400
		get_parent().add_child(proj)

func mimic_spin():
	# Spin and create whirlwind or debris
	if has_node("../Arena"):
		get_node("../Arena").spawn_whirlwind(global_position)

func mimic_taunt():
	# Flashy pose or dance move (can be interrupted)
	set_vulnerable(true)
	yield(get_tree().create_timer(1.5), "timeout")
	set_vulnerable(false)

func unpredictable_attack():
	# Wild, desperate attacks in final phase
	var attack = randi() % 3
	if attack == 0:
		mimicry_attack()
	elif attack == 1:
		arena_shift()
	else:
		stone_piranha_swarm()

func on_player_stylish_dodge():
	favor = min(favor + 10, 100)
	_update_crowd_feedback()

func on_player_combo():
	favor = min(favor + 8, 100)
	_update_crowd_feedback()

func on_player_interrupt_mockery():
	favor = min(favor + 12, 100)
	_update_crowd_feedback()

func on_player_catch_fruit():
	favor = min(favor + 7, 100)
	_update_crowd_feedback()

func on_player_counter_mimicry():
	favor = min(favor + 10, 100)
	_update_crowd_feedback()

func on_player_escape_hazard():
	favor = min(favor + 6, 100)
	_update_crowd_feedback()

func on_player_clutch_comeback():
	favor = min(favor + 15, 100)
	_update_crowd_feedback()
func _update_crowd_feedback():
	# Update totem lights, crowd audio, and visual feedback
	if favor_totems:
		favor_totems.set_favor(favor)
	if crowd_audio:
		crowd_audio.set_cheer_intensity(favor)
	# Optionally trigger crowd animations, confetti, etc.

func take_damage(amount):
	if is_vulnerable:
		health -= amount
		if health <= 0:
			health = 0
			on_guppazuma_defeated()
		else:
			check_phase_transition()
func on_guppazuma_defeated():
	# Victory flair: bow, crack, gems/confetti shower, crowd goes wild
	emit_signal("guppazuma_defeated")
	$VictoryEffect.show()
	$VictoryEffect.play("victory")
	$Sprite.play("bow_and_crack")
	if favor_totems:
		favor_totems.celebrate()
	if crowd_audio:
		crowd_audio.crowd_cheer()
