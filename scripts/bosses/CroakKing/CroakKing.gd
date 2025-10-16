extends "res://scripts/bosses/Boss.gd"

# Croak King

var throne = null
var ceremony_timer = null
var flood_timer = null
var finale = false
var throne_destroyed = false
var converted_minions = []

func _ready():
	health = max_health
	if has_node("../Throne"): throne = get_node("../Throne")
	start_phase(1)
	start_ceremony_timer()
	start_flood_timer()

func start_phase(new_phase):
	phase = new_phase
	emit_signal("phase_changed", phase)
	if phase == 1:
		start_attack("lily_pad_barrage")
	elif phase == 2:
		start_attack("royal_croak")
		start_attack("mud_toss")
		start_attack("bug_buffet")
		start_attack("throne_hop")

func check_phase_transition():
	   if health <= max_health * 0.3 and phase == 1:
		   start_phase(2)
	if health <= max_health * 0.2 and not finale:
		start_finale()

func start_attack(attack_name):
   emit_signal("attack_started", attack_name)
   match attack_name:
	   "lily_pad_barrage":
		   lily_pad_barrage()
	   "royal_croak":
		   royal_croak()
	   "tongue_grab":
		   tongue_grab()
	   "minion_frogs":
		   minion_frogs()
	   "mud_toss":
		   mud_toss()
	   "bug_buffet":
		   bug_buffet()
	   "throne_hop":
		   throne_hop()
func mud_toss():
	# Throws mud hazards
	var mud_scene = preload("res://scenes/arenas/CroakKing/hazards/MudGeyser.tscn")
	for i in range(2):
		var mud = mud_scene.instance()
		mud.position = position + Vector2(randf_range(-120,120), randf_range(-60,60))
		get_parent().add_child(mud)

func bug_buffet():
	# Eats or spits bugs for buffs/projectiles
	var bug_scene = preload("res://scenes/arenas/CroakKing/hazards/BugNest.tscn")
	var bug = bug_scene.instance()
	bug.position = position + Vector2(randf_range(-100,100), -40)
	get_parent().add_child(bug)

func throne_hop():
	# Jumps to throne or lily pad, creates waves
	if throne and not throne_destroyed:
		position = throne.position + Vector2(randf_range(-40,40), -20)
		emit_signal("throne_hop")

func start_ceremony_timer():
	ceremony_timer = Timer.new()
	ceremony_timer.wait_time = randf_range(20, 45)
	ceremony_timer.one_shot = false
	ceremony_timer.connect("timeout", self, "_on_ceremony")
	add_child(ceremony_timer)
	ceremony_timer.start()

func _on_ceremony():
	if finale: return
	# Start knighting ceremony
	var ceremony_scene = preload("res://scripts/bosses/CroakKing/ceremony/CroakKingCeremony.gd")
	var ceremony = ceremony_scene.new()
	ceremony.connect("minion_converted", self, "on_minion_converted")
	ceremony.connect("minion_knighted", self, "on_minion_knighted")
	ceremony.connect("ceremony_interrupted", self, "on_ceremony_interrupted")
	get_parent().add_child(ceremony)
	emit_signal("ceremony_started", ceremony)

func on_minion_converted(minion):
	converted_minions.append(minion)
	minion.set_loyalty("player")

func on_minion_knighted(minion):
	minion.set_loyalty("king")

func on_ceremony_interrupted(minion):
	on_minion_converted(minion)

func start_flood_timer():
	flood_timer = Timer.new()
	flood_timer.wait_time = randf_range(18, 32)
	flood_timer.one_shot = false
	flood_timer.connect("timeout", self, "_on_flood_event")
	add_child(flood_timer)
	flood_timer.start()

func _on_flood_event():
	# Flood or drain arena
	var arena = get_tree().get_root().find_node("CroakKingArena", true, false)
	if arena and arena.has_method("toggle_flood"):
		arena.toggle_flood()
	emit_signal("arena_flooded")

func on_throne_damaged():
	if throne and throne.health <= 0 and not throne_destroyed:
		throne_destroyed = true
		emit_signal("throne_destroyed")
		check_finale_state()

func check_finale_state():
	if health <= max_health * 0.2 and not finale:
		start_finale()

func start_finale():
	finale = true
	if throne_destroyed:
		# Wild enrage, mass minion conversion, unstable arena
		for m in get_tree().get_nodes_in_group("minions"):
			if m.loyalty != "player":
				m.set_loyalty("player")
				converted_minions.append(m)
		emit_signal("finale_wild_enrage")
		# Hazards trigger randomly
		for i in range(3):
			mud_toss()
			bug_buffet()
	else:
		# Composed enrage, desperate defense
		emit_signal("finale_composed_enrage")
		start_attack("royal_croak")
		start_attack("minion_frogs")

func on_croak_king_defeated():
	# Victory flair: buried in mud, minion celebration
	emit_signal("croak_king_defeated")
	$VictoryEffect.show()
	$VictoryEffect.play("victory")
	$Sprite.play("buried_in_mud")
	for m in get_tree().get_nodes_in_group("minions"):
		m.celebrate()

func lily_pad_barrage():
	# Launches lily pads as projectiles/platforms
	var pad_scene = preload("res://scenes/arenas/CroakKing/hazards/LilyPad.tscn")
	for i in range(4):
		var pad = pad_scene.instance()
		pad.position = position + Vector2(randf_range(-100,100), -50)
		pad.linear_velocity = Vector2(randf_range(-100,100), 300)
		get_parent().add_child(pad)

func royal_croak():
	# Emits a shockwave or stuns player, breaks lily pads
	var player = get_tree().get_root().find_node("Player", true, false)
	if player and (player.position - position).length() < 400:
		player.stun(1.5)
	# Break lily pads in radius
	for pad in get_tree().get_nodes_in_group("lilypads"):
		if (pad.position - position).length() < 300:
			pad.break_pad()

func tongue_grab():
	# Tries to grab and pull player in, more effective if stuck in mud
	var player = get_tree().get_root().find_node("Player", true, false)
	if player and (player.position - position).length() < 350:
		if player.is_in_mud():
			player.take_damage(2)
		else:
			player.pull_to(position)
			player.take_damage(1)

func minion_frogs():
	# Summons smaller frogs to assist
	var minion_scene = preload("res://scenes/arenas/CroakKing/minions/DirectDefectorMinion.tscn")
	for i in range(2):
		var minion = minion_scene.instance()
		minion.position = position + Vector2(randf_range(-80,80), randf_range(40,120))
		get_parent().add_child(minion)

func _on_tongue_grabbed():
	set_vulnerable(true)
	yield(get_tree().create_timer(1.5), "timeout")
	set_vulnerable(false)
func take_damage(amount):
	health -= amount
	if health <= 0:
		health = 0
		on_croak_king_defeated()
	else:
		check_phase_transition()
