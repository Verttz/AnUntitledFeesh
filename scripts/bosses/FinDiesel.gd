extends "res://scripts/bosses/Boss.gd"


# Fin Diesel (The Shark Bouncer)
# Beachside Club Arena Boss Fight Implementation

var velvet_ropes = []
var ruffian_minions = []
var crowd_items = []
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
	# ...attack logic here

func bubblegum_bomb(fast=false):
	# Spits bubblegum at player, sticks and requires button mash
	# ...attack logic here

func velvet_rope_control(double=false):
	# Manipulate velvet ropes, possibly electrified
	# ...attack logic here

func guest_list_gimmick():
	# Checks guest list, pauses if player stands still, cross off minions
	# ...attack logic here

func ruffian_roll_call(fast=false):
	# Summon ruffians from club entrance, can be knocked into boss
	# ...attack logic here

func no_splash_zone(fast=false):
	# Slam ground, create wave hazard
	# ...attack logic here

func beach_crowd_interference(fast=false):
	# Beachgoers toss items, some helpful, some hazards
	# ...attack logic here

func rip_off_bowtie():
	# Animation/sound for serious mode
	# ...animation logic here

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
	# ...animation logic here

func open_club_door():
	club_door_open = true
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
