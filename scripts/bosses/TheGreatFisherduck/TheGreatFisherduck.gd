extends "res://scripts/bosses/Boss.gd"

# The Great Fisherduck

var golden_duckling = null
var duckling_jump_count = 0
var duckling_target_point = Vector2.ZERO

# Junk system
var junk_list = []
var junk_types = ["boot", "can", "lawn_chair", "tackle_box"]
var max_junk = 12

var _attack_queue := []
var _attack_index := 0
var _rotation_timer: Timer = null

func _ready():
	max_health = 20000
	health = max_health
	start_phase(1)


func start_phase(new_phase):
	# Visual/sound telegraph for phase change
	$PhaseChangeEffect.play()
	$QuackSound.play()
	phase = new_phase
	phase_changed.emit(phase)
	if _rotation_timer:
		_rotation_timer.stop()
		_rotation_timer.queue_free()
		_rotation_timer = null
	if phase == 1:
		_attack_queue = ["rod_and_reel", "multi_lure_mayhem", "tangled_line", "trophy_toss", "bait_and_switch", "duckling_gang", "dive_bomb"]
		_attack_index = 0
		_start_rotation(3.0)
	elif phase == 2:
		start_attack("giant_golden_duckling")
		_attack_queue = ["rod_and_reel", "multi_lure_mayhem", "tangled_line", "trophy_toss", "bait_and_switch", "duckling_gang", "dive_bomb"]
		_attack_index = 0
		_start_rotation(2.0)

func _start_rotation(interval: float) -> void:
	_rotation_timer = Timer.new()
	_rotation_timer.wait_time = interval
	_rotation_timer.one_shot = false
	_rotation_timer.timeout.connect(_next_queued_attack)
	add_child(_rotation_timer)
	_rotation_timer.start()
	_next_queued_attack()

func _next_queued_attack() -> void:
	if _attack_queue.is_empty():
		return
	var attack_name = _attack_queue[_attack_index]
	_attack_index = (_attack_index + 1) % _attack_queue.size()
	start_attack(attack_name, phase == 2)

func check_phase_transition():
	if health <= max_health * 0.3 and phase == 1:
		start_phase(2)


func start_attack(attack_name, fast=false):
	attack_started.emit(attack_name)
	match attack_name:
		"rod_and_reel":
			rod_and_reel(fast)
		"multi_lure_mayhem":
			multi_lure_mayhem(fast)
		"tangled_line":
			tangled_line(fast)
		"trophy_toss":
			trophy_toss(fast)
		"bait_and_switch":
			bait_and_switch(fast)
		"duckling_gang":
			duckling_gang(fast)
		"dive_bomb":
			dive_bomb(fast)
		"giant_golden_duckling":
			# ...existing golden duckling logic
			pass

# Rod & Reel: Casts a huge fishing line to catch and reel in the player
func rod_and_reel(fast=false):
	$AttackTelegraph.show()
	$AttackTelegraph.play("rod_and_reel")
	var player = get_tree().get_root().find_child("Player", true, false)
	if player and (player.position - position).length() < 400:
		player.snare_and_pull_to(position, fast)
		# Slap with fish or whack with tackle box
		player.take_damage(1)
		# Fire a quick arc of water bullets as a follow-up
		fire_arc(global_position, 7 if fast else 5, 60, 500 if fast else 350, angle_offset=0)
		attack_started.emit("rod_and_reel")

# Multi-Lure Mayhem: Casts several lures with different effects
func multi_lure_mayhem(fast=false):
	$AttackTelegraph.show()
	$AttackTelegraph.play("multi_lure_mayhem")
	var effects = ["stun", "explode", "boot", "reel"]
	var player = get_tree().get_root().find_child("Player", true, false)
	for i in range(effects.size()):
		var angle = -30 + i * 20
		var pos = global_position + Vector2(randf_range(-50,50), randf_range(-50,50))
		var speed = 700 if fast else 500
		if player:
			fire_aimed(pos, player.global_position, speed)
		var lure = spawn_junk("can", pos)
		lure.effect = effects[i]

# Tangled Line: Sends hooks everywhere, can snag player or minions
func tangled_line(fast=false):
	$AttackTelegraph.show()
	$AttackTelegraph.play("tangled_line")
	var hook_count = 8 if fast else 5
	fire_circle(global_position, hook_count, 600 if fast else 400)
	attack_started.emit("tangled_line")

# Trophy Toss: Throws a trophy catch at the player
func trophy_toss(fast=false):
	$AttackTelegraph.show()
	$AttackTelegraph.play("trophy_toss")
	var trophies = ["giant_fish", "boot", "lawn_chair"]
	var trophy = trophies[randi() % trophies.size()]
	var pos = global_position + Vector2(randf_range(-100,100), randf_range(-50,50))
	var player = get_tree().get_root().find_child("Player", true, false)
	if player:
		fire_aimed(pos, player.global_position, 900 if fast else 700)
	var trophy_obj = spawn_junk(trophy, pos)

# Bait-and-Switch: Throws glowing bait, can spawn mini Fisherduck or heal player
func bait_and_switch(fast=false):
	$AttackTelegraph.show()
	$AttackTelegraph.play("bait_and_switch")
	var bait = spawn_junk("can", global_position + Vector2(randf_range(-50,50), randf_range(-50,50)))
	bait.is_bait = true
	bait.attacked.connect(_on_bait_attacked)

func _on_bait_attacked(bait):
	if randi() % 2 == 0:
		# Spawn mini Fisherduck
		var mini = preload("res://scenes/arenas/MiniFisherduck.tscn").instantiate()
		mini.position = bait.position
		get_parent().add_child(mini)
	else:
		# Heal player
		var player = get_tree().get_root().find_child("Player", true, false)
		if player:
			player.heal(1)
	bait.queue_free()

# Duckling Gang: Summons a flock of angry ducklings
func duckling_gang(fast=false):
	$AttackTelegraph.show()
	$AttackTelegraph.play("duckling_gang")
	var count = 8 if fast else 5
	for i in range(count):
		var duckling = preload("res://scenes/arenas/Duckling.tscn").instantiate()
		duckling.position = global_position + Vector2(randf_range(-150,150), randf_range(-100,100))
		get_parent().add_child(duckling)

# Dive Bomb: Dives underwater, pops up elsewhere for a surprise attack
func dive_bomb(fast=false):
	$AttackTelegraph.show()
	$AttackTelegraph.play("dive_bomb")
	# Fisherduck disappears (hide sprite, disable collision)
	$Sprite.hide()
	set_physics_process(false)
	attack_started.emit("dive_bomb_start")
	await get_tree().create_timer(0.7).timeout
	# Reappear at a random location in the arena
	var arena_bounds = Rect2(Vector2(0,0), Vector2(1024,768)) # Example bounds, adjust as needed
	var new_pos = arena_bounds.position + Vector2(randf() * arena_bounds.size.x, randf() * arena_bounds.size.y)
	global_position = new_pos
	$Sprite.show()
	set_physics_process(true)
	attack_started.emit("dive_bomb_reappear")
	# Drop a barrage of fish or junk and fire a spiral of water bullets
	var barrage_count = 10 if fast else 6
	for i in range(barrage_count):
		var drop_type = "giant_fish" if (randi() % 2 == 0) else "boot"
		var drop_pos = global_position + Vector2(randf_range(-80,80), randf_range(-40,40))
		var drop = spawn_junk(drop_type, drop_pos)
		drop.apply_impulse(Vector2(0, 600 + randf() * 200))
	fire_spiral(global_position, 18 if fast else 12, 500 if fast else 350, rotations=1.5)
	attack_started.emit("dive_bomb_barrage")

# Disarm mechanic: Player can hook hat or rod
func on_player_hooks_disarm():
	$StunEffect.show()
	$StunEffect.play("stun")
	set_vulnerable(true)
	attack_started.emit("disarmed")
	await get_tree().create_timer(2.0).timeout
	set_vulnerable(false)

# Phase 2 erratic behavior
func on_phase2_erratic():
	# Hat falls over eyes, attacks become wild
	attack_started.emit("erratic")

func spawn_giant_golden_duckling():
	$SparkleEffect.show()
	$SparkleEffect.play("sparkle")
	# Assume a GoldenDuckling scene exists
	golden_duckling = preload("res://scenes/arenas/GoldenDuckling.tscn").instantiate()
	get_parent().add_child(golden_duckling)
	golden_duckling.position = position + Vector2(0, -100)
	duckling_jump_count = 0
	_start_duckling_jump()

func _start_duckling_jump():
	if golden_duckling:
		golden_duckling.leave_sparkle_trail = true
	if not golden_duckling:
		return
	duckling_jump_count += 1
	if duckling_jump_count % 3 == 2:
		# Lock target at player's current position
		var player = get_tree().get_root().find_child("Player", true, false)
		if player:
			duckling_target_point = player.position
		else:
			duckling_target_point = golden_duckling.position + Vector2(randf_range(-200,200), randf_range(-200,200))
	elif duckling_jump_count % 3 == 0:
		# Jump toward locked target
		golden_duckling.jump_to(duckling_target_point)
	else:
		# Pseudo-random jump
		var arena_bounds = Rect2(Vector2(0,0), Vector2(1024,768)) # Example bounds
		var rand_point = arena_bounds.position + Vector2(randf() * arena_bounds.size.x, randf() * arena_bounds.size.y)
		golden_duckling.jump_to(rand_point)
	# Leave a trail of sparkles
	golden_duckling.leave_sparkle_trail = true
	# Schedule next jump
	golden_duckling.jump_finished.connect(_start_duckling_jump, CONNECT_ONE_SHOT)

func spawn_junk(junk_type, pos):
	# Clamp position to arena bounds
	var arena_bounds = Rect2(Vector2(0,0), Vector2(1024,768))
	var clamped_pos = pos.clamped(arena_bounds.size) + arena_bounds.position
	var scene_path = "res://scenes/arenas/Junk_%s.tscn" % junk_type.capitalize()
	var junk = load(scene_path).instantiate()
	junk.position = clamped_pos
	get_parent().add_child(junk)
	junk_list.append(junk)
	if junk_type == "boot":
		junk.landed.connect(_on_boot_landed)
	if junk_type == "can":
		junk.hit.connect(_on_can_hit)
	if junk_type in ["lawn_chair", "tackle_box"]:
		junk.broken.connect(_on_junk_broken)
	_check_junk_clutter()

func _on_boot_landed(pos):
	# Leave a persistent boot print and splash effect
	var boot_print = preload("res://scenes/arenas/BootPrint.tscn").instantiate()
	boot_print.position = pos
	get_parent().add_child(boot_print)
	$SplashEffect.global_position = pos
	$SplashEffect.show()
	$SplashEffect.play("splash")

func _on_can_hit():
	# Play rattling sound
	$RattleSound.play()

func _on_junk_broken(junk):
	if junk in junk_list:
		junk_list.erase(junk)

func _check_junk_clutter():
	if junk_list.size() > max_junk:
		_clear_arena_junk()

func _clear_arena_junk():
	for junk in junk_list:
		junk.queue_free()
	junk_list.clear()
	# Fisherduck quacks and splashes
	$QuackSound.play()
	$SplashEffect.global_position = global_position
	$SplashEffect.show()
	$SplashEffect.play("splash")
	attack_started.emit("arena_clear")

# Junk/attack interactions
func on_lure_hits_junk(junk):
	var outcome = randi() % 3
	if outcome == 0:
		# Snap line
		$StunEffect.show()
		$StunEffect.play("stun")
		attack_started.emit("line_snapped")
	elif outcome == 1:
		# Pull junk to Fisherduck, hit and stun
		junk.move_toward(global_position)
		$StunEffect.show()
		$StunEffect.play("stun")
		attack_started.emit("junk_stun")
	elif outcome == 2:
		# Swing junk at player
		junk.swing_at_player()
		attack_started.emit("junk_swing")

# Boots/cans can be hit by player or projectiles
func on_junk_hit(junk, direction):
	if junk.type in ["boot", "can"]:
		junk.apply_impulse(direction * 500)
		$SplashEffect.global_position = junk.position
		$SplashEffect.show()
		$SplashEffect.play("splash")

# Lawn chairs/tackle boxes are obstacles, breakable
func on_junk_attacked(junk):
	if junk.type in ["lawn_chair", "tackle_box"]:
		junk.take_damage(1)
		$SplashEffect.global_position = junk.position
		$SplashEffect.show()
		$SplashEffect.play("splash")
func on_player_win():
	# Victory/defeat animation and flair
	$VictoryEffect.show()
	$VictoryEffect.play("victory")
	$QuackSound.play()
	$SplashEffect.global_position = global_position
	$SplashEffect.show()
	$SplashEffect.play("splash")
	$Sprite.play("collapse")
	await get_tree().create_timer(2.0).timeout
	$Sprite.hide()
