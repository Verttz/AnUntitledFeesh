extends "res://scripts/bosses/Boss.gd"

# Magma Chef Boss Script

var sous_chefs := []

func _ready():
	max_health = 80000
	health = max_health
	spawn_sous_chefs()
	start_phase(1)

func spawn_sous_chefs():
	# Sous-Chef Shrimp Spawning Logic:
	# - Spawn a set number of sous-chef shrimp minions at designated kitchen stations or random positions.
	# - Each sous-chef can have unique behaviors (e.g., throw ingredients, block player, repair hazards).
	# - Add each spawned sous-chef to the sous_chefs array for tracking.
	# - If a sous-chef is defeated, respawn after a delay or escalate boss attacks.
	pass

func start_phase(new_phase):
	phase = new_phase
	phase_changed.emit(phase)
	if phase == 1:
		start_attack_cycle()
	elif phase == 2:
		start_attack_cycle(true)

func start_attack_cycle(frantic := false):
	# Main Attack Loop Logic:
	# - Loop through signature attacks in a set or random order.
	# - If frantic is true (phase 2), increase attack speed, add new hazards, or combine attacks.
	# - Use timers or coroutines to schedule attacks and pauses.
	pass

func check_phase_transition():
	if health <= max_health * 0.5 and phase == 1:
		start_phase(2)

# --- Signature Attacks ---
func boiling_soup_splash():
	attack_started.emit("boiling_soup_splash")
	# Hurl ladlefuls of lava soup, create burning puddles
	pass

func pepper_bomb():
	attack_started.emit("pepper_bomb")
	# Toss magma peppers that explode
	pass

func pot_block():
	attack_started.emit("pot_block")
	# Block player, sweep ladle, create fire walls
	pass

func spicy_steam():
	attack_started.emit("spicy_steam")
	# Breathe spicy steam, slow/blur player
	pass

func sous_chef_summon():
	attack_started.emit("sous_chef_summon")
	# Sous-chef shrimp attack if player is close
	pass

func start_attack(attack_name):
	attack_started.emit(attack_name)
	match attack_name:
		"boiling_soup_splash": boiling_soup_splash()
		"pepper_bomb": pepper_bomb()
		"pot_block": pot_block()
		"spicy_steam": spicy_steam()
		"sous_chef_summon": sous_chef_summon()
		_: print("Unknown attack: " + attack_name)

# --- Unique Mechanics ---
func interact_with_station(_station):
	# Player messes up a station, chef rushes over, becomes vulnerable
	pass

func toss_ingredient(_ingredient):
	# Player tosses ingredient into pot, check for eruption combo
	pass

func catch_pepper_bomb(_bomb):
	# Player catches and throws back pepper bomb
	pass

func erupt_pot():
	# Pot erupts, stuns chef, damages minions
	pass

func _on_pot_lid_opened():
	set_vulnerable(true)
	await get_tree().create_timer(1.5).timeout
	set_vulnerable(false)
