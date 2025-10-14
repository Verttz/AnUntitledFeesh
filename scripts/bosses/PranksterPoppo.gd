extends "res://scripts/bosses/Boss.gd"


# Prankster Poppo (Lava Pool Jester Boss)
# Pops in and out of lava pools, taunts, uses puppet decoys, and is defeated by blocking all pools.

var phase = 1
var lava_pools = []
var blocked_pools = []
var poppo_decoy_scene = preload("res://scenes/arenas/PoppoDecoy.tscn")
var poppo_projectile_types = ["firecracker", "hot_pepper", "confetti_bomb"]
var vulnerable = false
var fake_defeat_triggered = false

signal pool_blocked
signal poppo_popped
signal poppo_decoy_popped
signal fake_defeat
signal real_defeat


func _ready():
	health = max_health
	setup_lava_pools()
	start_phase(1)

func setup_lava_pools():
	# Find or create lava pool nodes in the arena
	lava_pools = get_parent().find_children("LavaPool", "Node2D", true, false)
	blocked_pools = []


func start_phase(new_phase):
	phase = new_phase
	emit_signal("phase_changed", phase)
	if phase == 1:
		next_lava_pop()
	elif phase == 2:
		fake_defeat_triggered = false
		next_lava_pop()


func check_phase_transition():
	if health <= max_health * 0.5 and phase == 1:
		start_phase(2)


func start_attack(attack_name):
	emit_signal("attack_started", attack_name)
	# Placeholder for attack logic

func next_lava_pop():
	var available_pools = []
	for pool in lava_pools:
		if pool not in blocked_pools:
			available_pools.append(pool)
	if available_pools.size() == 0:
		on_real_defeat()
		return
	var use_decoy = (randi() % 4 == 0) # 25% chance to use decoy
	var pop_pool = available_pools[randi() % available_pools.size()]
	if use_decoy:
		# Spawn decoy puppet
		var decoy = poppo_decoy_scene.instance()
		decoy.position = pop_pool.position
		get_parent().add_child(decoy)
		emit_signal("poppo_decoy_popped", pop_pool)
		# Real Poppo pops from another pool
		var other_pools = available_pools.filter(func(p): return p != pop_pool)
		if other_pools.size() > 0:
			var real_pool = other_pools[randi() % other_pools.size()]
			poppo_pop(real_pool)
		else:
			poppo_pop(pop_pool)
	else:
		poppo_pop(pop_pool)

func poppo_pop(pool):
	# Poppo emerges, taunts, and attacks
	emit_signal("poppo_popped", pool)
	var proj_type = poppo_projectile_types[randi() % poppo_projectile_types.size()]
	# ...spawn projectile (firecracker, hot pepper, confetti bomb)
	# ...play taunt/animation
	yield(get_tree().create_timer(1.0), "timeout")
	if phase == 2 and not fake_defeat_triggered and health <= max_health * 0.25:
		fake_defeat_triggered = true
		on_fake_defeat()
		return
	next_lava_pop()

func block_pool(pool):
	if pool not in blocked_pools:
		blocked_pools.append(pool)
		emit_signal("pool_blocked", pool)

func on_fake_defeat():
	emit_signal("fake_defeat")
	# Play fake defeat animation, NOT YET banner, circus music
	yield(get_tree().create_timer(2.0), "timeout")
	next_lava_pop()

func on_real_defeat():
	emit_signal("real_defeat")
	# Play real defeat animation, confetti/steam burst


# Trap backfire not used in this version
