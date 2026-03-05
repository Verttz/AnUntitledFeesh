extends "res://scripts/bosses/Boss.gd"
# Telegraphing utility: emits a signal and can be used to show a visual/audio cue before an attack
signal telegraph_attack(attack_name)

# --- Don Catfishoni: Bullet Hell Attacks & Unique Mechanics ---

# Minion types
var minion_types = ["BrassKnuckleMinion", "TommyGunMinion"]
var minions = []

func tommy_gun_squirt():
	attack_started.emit("tommy_gun_squirt")
	# Fire rapid streams of water bullets in sweeping patterns
	for i in range(5):
		var angle = -30 + i * 15
		fire_arc(global_position, 8, 60, 600, angle_offset=angle)

func cigar_smoke_rings():
	attack_started.emit("cigar_smoke_rings")
	# Fire expanding rings of slow-moving smoke bullets
	for i in range(3):
		await get_tree().create_timer(0.5 * i).timeout
		fire_circle(global_position, 12, 200 + i*80)

func goon_crossfire():
	attack_started.emit("goon_crossfire")
	# Line up all TommyGunMinions at arena edge and fire spreads
	var arena_bounds = Rect2(Vector2(0,0), Vector2(1024,768))
	var edge_y = arena_bounds.position.y + 40
	var tg_minions = []
	for minion in minions:
		if minion.has_method("is_tommy_gun") and minion.is_tommy_gun():
			tg_minions.append(minion)
	var spacing = arena_bounds.size.x / max(1, tg_minions.size())
	for idx in range(tg_minions.size()):
		var minion = tg_minions[idx]
		minion.global_position = Vector2(arena_bounds.position.x + spacing * idx, edge_y)
		if minion.has_method("fire_crossfire"):
			minion.fire_crossfire()

func whisker_sweep():
	attack_started.emit("whisker_sweep")
	# Sweep whiskers, launch curved bullet trails
	for i in range(3):
		var angle = -60 + i * 60
		fire_arc(global_position, 10, 120, 400, angle_offset=angle)

func firework_finale():
	attack_started.emit("firework_finale")
	# Firework Fishes launch starburst patterns
	# (Stub: call firework fish scripts to launch starbursts)
	for i in range(5):
		var pos = global_position + Vector2(randf_range(-200,200), randf_range(-100,100))
		fire_circle(pos, 16, 500)

# --- Arena Hazards & Events ---
func trigger_market_lockdown():
	attack_started.emit("market_lockdown")
	var arena = get_tree().get_root().find_child("DonCatfishoniArena", true, false)
	if arena and arena.has_method("lockdown"):
		arena.lockdown()

func trigger_police_raid():
	attack_started.emit("police_raid")
	var raid = preload("res://scripts/bosses/DonCatfishoni/hazards/PoliceRaid.gd").new()
	get_parent().add_child(raid)
	raid.start_raid()

func trigger_contraband_crate():
	attack_started.emit("contraband_crate")
	var crate = preload("res://scripts/bosses/DonCatfishoni/hazards/ContrabandCrate.gd").new()
	crate.position = global_position + Vector2(randf_range(-150,150), randf_range(-80,80))
	get_parent().add_child(crate)

func trigger_fireworks_cache():
	attack_started.emit("fireworks_cache")
	var cache = preload("res://scripts/bosses/DonCatfishoni/hazards/FireworksCache.gd").new()
	cache.position = global_position + Vector2(randf_range(-180,180), randf_range(-100,100))
	get_parent().add_child(cache)
	cache.launch_fireworks()

func trigger_market_flood():
	attack_started.emit("market_flood")
	var flood = preload("res://scripts/bosses/DonCatfishoni/hazards/MarketFlood.gd").new()
	get_parent().add_child(flood)
	flood.start_flood()

# --- Unique Mechanics ---
func negotiation_interrupt():
	attack_started.emit("negotiation_interrupt")
	# If player acts quickly, open damage window
	set_vulnerable(true)
	await get_tree().create_timer(2.0).timeout
	set_vulnerable(false)

func mobster_deal_roulette():
	attack_started.emit("mobster_deal_roulette")
	# (Stub: spin wheel, apply random effect)
	pass

func on_goon_stunned(goon):
	# If goon is pushed into Don, deal bonus damage and fluster
	set_vulnerable(true)
	await get_tree().create_timer(1.5).timeout
	set_vulnerable(false)

# --- Victory Flair ---
func on_player_win():
	# Don surrenders, tosses fedora/cigar, minions scatter
	$VictoryEffect.show()
	$VictoryEffect.play("victory")
	$SurrenderSound.play()
	$Sprite.play("surrender")
	# Minions scatter
	for minion in minions:
		if minion.has_method("scatter"):
			minion.scatter()
	await get_tree().create_timer(2.0).timeout
	$Sprite.hide()

func telegraph_and_attack(attack_name, telegraph_time := 0.7):
	telegraph_attack.emit(attack_name)
	await get_tree().create_timer(telegraph_time).timeout
	attack_started.emit(attack_name)
	# Attack logic handled by timers and methods below


# Don Catfishoni (The Catfish Mobster)

var goon_timer = null
var pearl_bomb_timer = null
var protection_racket_timer = null
var smoke_timer = null
var bribe_timer = null
var sitdown_timer = null
var enraged = false

func _ready():
	max_health = 30000
	health = max_health
	start_phase(1)

func start_phase(new_phase):
	phase = new_phase
	phase_changed.emit(phase)
	if phase == 1:
		start_attack("goonswarm")
		goon_timer = _start_timer(3.0, "_goonswarm")
		pearl_bomb_timer = _start_timer(4.5, "_pearl_bomb")
		protection_racket_timer = _start_timer(8.0, "_protection_racket")
		smoke_timer = _start_timer(10.0, "_cigar_smoke")
		bribe_timer = _start_timer(12.0, "_bribe_break")
		sitdown_timer = _start_timer(18.0, "_sitdown_minigame")
		enraged = false
	elif phase == 2:
		start_attack("goonswarm")
		goon_timer = _start_timer(2.0, "_goonswarm", true)
		pearl_bomb_timer = _start_timer(3.0, "_pearl_bomb", true)
		protection_racket_timer = _start_timer(6.0, "_protection_racket", true)
		smoke_timer = _start_timer(8.0, "_cigar_smoke", true)
		bribe_timer = _start_timer(10.0, "_bribe_break", true)
		sitdown_timer = _start_timer(14.0, "_sitdown_minigame", true)
		enraged = true

func check_phase_transition():
	if health <= max_health * 0.3 and phase == 1:
		start_phase(2)

func start_attack(attack_name):
	attack_started.emit(attack_name)
	# Attack logic handled by timers and methods below

# --- Attack Patterns ---
func _goonswarm():
	attack_started.emit("goonswarm")
	var count = 5 if enraged else 3
	for i in range(count):
		var minion_type = minion_types[randi() % minion_types.size()]
		var scene_path = "res://scripts/bosses/DonCatfishoni/minions/%s.tscn" % minion_type
		if ResourceLoader.exists(scene_path):
			var minion = load(scene_path).instantiate()
			minion.global_position = global_position + Vector2(randf_range(-200,200), randf_range(-100,100))
			get_parent().add_child(minion)
			minion.stunned.connect(func(): on_goon_stunned(minion))
			minions.append(minion)
			if enraged and minion_type == "TommyGunMinion" and minion.has_method("set_elite"):
				minion.set_elite(true)

func _pearl_bomb():
	attack_started.emit("pearl_bomb")
	# Spit bouncing pearls that explode after a delay
	# In phase 2, leave sticky cement puddles
	if enraged:
		# Spawn cement puddle on explosion
		pass

func _protection_racket():
	attack_started.emit("protection_racket")
	# Demand tribute: spawn coins in arena
	# If player doesn't collect enough, Don attacks faster for a short time
	pass

func _cigar_smoke():
	attack_started.emit("cigar_smoke")
	# Obscure part of the arena with smoke, hide goons/hazards
	pass

func _concrete_shoes():
	attack_started.emit("concrete_shoes")
	# Slam ground, concrete shoes rise, trap player if not dodged
	pass

func _bribe_break():
	attack_started.emit("bribe_break")
	# Toss money bag: if collected, buff player but summon more goons
	pass

func _sitdown_minigame():
	attack_started.emit("sitdown_minigame")
	# Quick negotiation minigame: bluff, pay, or threaten for effects
	pass

func _offer_you_cant_refuse():
	attack_started.emit("offer_you_cant_refuse")
	# Surprise attack if player stands still too long
	pass

# --- Unique Mechanic: Turn goons against Don ---
# (Handled by on_goon_stunned above)

# --- Timer Utility ---
func _start_timer(time, method, repeat := false):
	var timer = Timer.new()
	timer.wait_time = time
	timer.one_shot = not repeat
	timer.timeout.connect(Callable(self, method))
	add_child(timer)
	timer.start()
	return timer
