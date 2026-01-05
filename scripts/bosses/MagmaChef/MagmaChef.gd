# Magma Chef Boss Script
extends Node2D

# Signals
signal attack_started(name)
signal phase_changed(phase)

# State
var phase := 1
var health := 1.0
var is_stunned := false
var sous_chefs := []

func _ready():
	# Initialize boss, minions, and arena
	spawn_sous_chefs()
	# ...other setup

func spawn_sous_chefs():
	# Sous-Chef Shrimp Spawning Logic:
	# - Spawn a set number of sous-chef shrimp minions at designated kitchen stations or random positions.
	# - Each sous-chef can have unique behaviors (e.g., throw ingredients, block player, repair hazards).
	# - Add each spawned sous-chef to the sous_chefs array for tracking.
	# - If a sous-chef is defeated, respawn after a delay or escalate boss attacks.
	pass

func start_phase(phase_num):
	phase = phase_num
	emit_signal("phase_changed", phase)
	if phase == 1:
		# Standard attacks and hazards
		start_attack_cycle()
	elif phase == 2:
		# More frantic, new hazards
		start_attack_cycle(frantic=true)

func start_attack_cycle(frantic=false):
	# Main Attack Loop Logic:
	# - Loop through signature attacks in a set or random order.
	# - If frantic is true (phase 2), increase attack speed, add new hazards, or combine attacks.
	# - Use timers or coroutines to schedule attacks and pauses.
	# - Example pseudocode:
	#   1. While boss is alive and not stunned:
	#       a. Pick next attack (random or weighted).
	#       b. Call the attack function.
	#       c. Wait for attack cooldown (shorter if frantic).
	#   2. Repeat until phase or state changes.
	pass

# --- Signature Attacks ---
func boiling_soup_splash():
	emit_signal("attack_started", "boiling_soup_splash")
	# Hurl ladlefuls of lava soup, create burning puddles
	pass

func pepper_bomb():
	emit_signal("attack_started", "pepper_bomb")
	# Toss magma peppers that explode
	pass

func pot_block():
	emit_signal("attack_started", "pot_block")
	# Block player, sweep ladle, create fire walls
	pass

func spicy_steam():
	emit_signal("attack_started", "spicy_steam")
	# Breathe spicy steam, slow/blur player
	pass

func sous_chef_summon():
	emit_signal("attack_started", "sous_chef_summon")
	# Sous-chef shrimp attack if player is close
	pass

# --- Unique Mechanics ---
func interact_with_station(station):
	# Player messes up a station, chef rushes over, becomes vulnerable
	pass

func toss_ingredient(ingredient):
	# Player tosses ingredient into pot, check for eruption combo
	pass

func catch_pepper_bomb(bomb):
	# Player catches and throws back pepper bomb
	pass

func erupt_pot():
	# Pot erupts, stuns chef, damages minions
	pass

# --- Phase & Damage Logic ---
func take_damage(amount):
	if is_stunned:
		health -= amount
		if health <= 0.5 and phase == 1:
			start_phase(2)
		elif health <= 0:
			defeat()

func defeat():
	# Chef drops ladle, pot erupts, kitchen chaos
	pass
extends "res://scripts/bosses/Boss.gd"

# Magma Chef

func _ready():
	health = max_health
	start_phase(1)

func start_phase(new_phase):
	phase = new_phase
	emit_signal("phase_changed", phase)
	if phase == 1:
		start_attack("boiling_broth")
	elif phase == 2:
		start_attack("spicy_meatball")

func check_phase_transition():
	   if health <= max_health * 0.3 and phase == 1:
		   start_phase(2)

func start_attack(attack_name):
	emit_signal("attack_started", attack_name)
	# Attack Logic:
	# - Based on attack_name, call the corresponding attack function (e.g., boiling_soup_splash, pepper_bomb).
	# - Each attack function should handle its own telegraphing, animation, and effect logic.
	# - If attack_name is not recognized, log a warning.
	# - Example pseudocode:
	#   match attack_name:
	#       "boiling_soup_splash": boiling_soup_splash()
	#       "pepper_bomb": pepper_bomb()
	#       ...
	#       _: print("Unknown attack: " + attack_name)

func _on_pot_lid_opened():
	set_vulnerable(true)
	await get_tree().create_timer(1.5).timeout
	set_vulnerable(false)
