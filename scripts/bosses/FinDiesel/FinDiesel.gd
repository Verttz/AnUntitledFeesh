extends "res://scripts/bosses/Boss.gd"


# Fin Diesel (The Shark Bouncer)
# Beachside Club Arena Boss Fight Implementation

var velvet_ropes = []
var ruffian_minions = []
var crowd_items = []
var rope_sprites = []
var guest_list = []
var phase = 1
var stunned = false
var serious_mode = false
var club_door_open = false

signal rope_reconfigured
signal minion_summoned
signal crowd_item_thrown
signal guest_list_updated
signal club_door_opened
signal victory_flair


func _ready():
	health = max_health
	setup_arena()
	setup_guest_list()
	start_phase(1)

func setup_arena():
	# Initialize velvet ropes, hazards, and crowd
	velvet_ropes = [create_velvet_rope(pos) for pos in get_rope_positions()]
	crowd_items = []
	# ...setup beachgoers, sandcastles, etc.

func setup_guest_list():
	guest_list = ["Big Tuna", "Gill Murray", "Sal Monella", "Ruffian 1", "Ruffian 2", "Ruffian 3"]
	emit_signal("guest_list_updated", guest_list)

func get_rope_positions():
	# Return positions for velvet ropes
	return [Vector2(200, 100), Vector2(400, 100)]

func create_velvet_rope(pos):
	# Placeholder for rope instance
	var rope = {"position": pos, "electric": false}
	return rope


func start_phase(new_phase):
	phase = new_phase
	emit_signal("phase_changed", phase)
	if phase == 1:
		start_attack("bouncer_bash")
		start_attack("bubblegum_bomb")
		start_attack("velvet_rope_control")
		start_attack("guest_list_gimmick")
		start_attack("ruffian_roll_call")
		start_attack("no_splash_zone")
		start_attack("beach_crowd_interference")
	elif phase == 2:
		serious_mode = true
		rip_off_bowtie()
		start_attack("bouncer_bash", fast=true)
		start_attack("bubblegum_bomb", fast=true)
		start_attack("velvet_rope_control", double=true)
		start_attack("ruffian_roll_call", fast=true)
		start_attack("no_splash_zone", fast=true)
		start_attack("beach_crowd_interference", fast=true)


func check_phase_transition():
	if health <= max_health * 0.5 and phase == 1:
		start_phase(2)


func start_attack(attack_name, fast=false, double=false):
	emit_signal("attack_started", attack_name)
	match attack_name:
		"bouncer_bash":
			bouncer_bash(fast)
		"bubblegum_bomb":
			bubblegum_bomb(fast)
		"velvet_rope_control":
			velvet_rope_control(double)
		"guest_list_gimmick":
			guest_list_gimmick()
		"ruffian_roll_call":
			ruffian_roll_call(fast)
		"no_splash_zone":
			no_splash_zone(fast)
		"beach_crowd_interference":
			beach_crowd_interference(fast)

func bouncer_bash(fast=false):
	# Swings fists, sends shockwaves, interacts with sandcastles/beach balls
	var speed = fast ? 2.0 : 1.0
	emit_signal("attack_started", "bouncer_bash")
	# Fire shockwave arc
	fire_arc(global_position, fast ? 10 : 6, 90, fast ? 600 : 400)
	# Knock over sandcastles and bounce beach balls (stub: call arena/scene methods)

func bubblegum_bomb(fast=false):
	# Spit bubblegum at player, sticks and requires button mash
	emit_signal("attack_started", "bubblegum_bomb")
	var player = get_tree().get_root().find_node("Player", true, false)
	if player:
		fire_aimed(global_position, player.global_position, fast ? 700 : 500)
		# If hit, player must mash to escape, else slowed/vulnerable (stub: call player method)

func velvet_rope_control(double=false):
	# Manipulate velvet ropes, possibly electrified
	emit_signal("attack_started", "velvet_rope_control")
	for i in range(2 if double else 1):
		var idx = i % velvet_ropes.size()
		var rope = velvet_ropes[idx]
		# Move rope to block/lasso (stub: animate rope sprite, electrify if serious_mode)
		# If electrified, deal damage on contact (stub: call player method)

func guest_list_gimmick():
	# Checks guest list, pauses if player stands still, cross off minions
	emit_signal("attack_started", "guest_list_gimmick")
	var player = get_tree().get_root().find_node("Player", true, false)
	if player and player.is_standing_still():
		# Pause attacks, open counterattack window
		set_vulnerable(true)
		yield(get_tree().create_timer(1.5), "timeout")
		set_vulnerable(false)

func ruffian_roll_call(fast=false):
	# Summon ruffians from club entrance, can be knocked into boss
	emit_signal("attack_started", "ruffian_roll_call")
	var count = fast ? 5 : 3
	for i in range(count):
		var minion = preload("res://scripts/bosses/FinDiesel/RuffianMinion.tscn").instance()
		minion.global_position = Vector2(100 + i*80, 600)
		get_parent().add_child(minion)
		minion.connect("defeated", self, "on_minion_defeated", ["Ruffian %d" % (i+1)])
		minion.connect("knocked_into_boss", self, "_on_minion_knocked_into_boss")
		ruffian_minions.append(minion)

func no_splash_zone(fast=false):
	# Slam ground, create wave hazard
	emit_signal("attack_started", "no_splash_zone")
	# Fire a wide arc of water bullets to push player
	fire_arc(global_position, fast ? 14 : 8, 120, fast ? 700 : 400)

func beach_crowd_interference(fast=false):
	# Beachgoers toss items, some helpful, some hazards
	emit_signal("attack_started", "beach_crowd_interference")
	var item_types = ["snack", "buff", "sunscreen", "sand_bucket"]
	var count = fast ? 6 : 3
	for i in range(count):
		var item_type = item_types[randi() % item_types.size()]
		var item = preload("res://scripts/bosses/FinDiesel/CrowdItem_%s.tscn" % item_type.capitalize()).instance()
		item.global_position = Vector2(randf_range(100,700), randf_range(200,500))
		get_parent().add_child(item)
		crowd_items.append(item)

func rip_off_bowtie():
	# Animation/sound for serious mode
	$BowtieSprite.hide()
	$RipSound.play()

func on_minion_defeated(minion_name):
	# Cross off minion from guest list
	if minion_name in guest_list:
		guest_list.erase(minion_name)
		emit_signal("guest_list_updated", guest_list)

func on_player_win():
	# Victory flair: Fin Diesel collapses, reaches for rope, falls unconscious
	emit_signal("victory_flair")
	play_victory_animation()
	open_club_door()

func play_victory_animation():
	# Animation: collapse, reach for rope, sunglasses fall off
	$Sprite.play("collapse")
	$SunglassesSprite.hide()
	$CollapseSound.play()

func open_club_door():
	club_door_open = true
	var arena = get_tree().get_root().find_node("FinDieselArena", true, false)
	if arena and arena.has_method("open_club_door"):
		arena.open_club_door()
	emit_signal("club_door_opened")

func _on_stunned():
	stunned = true
	set_vulnerable(true)
	yield(get_tree().create_timer(2.0), "timeout")
	set_vulnerable(false)
	stunned = false

func _on_stunned():
	set_vulnerable(true)
	yield(get_tree().create_timer(2.0), "timeout")
	set_vulnerable(false)
