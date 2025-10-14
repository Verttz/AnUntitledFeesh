extends "res://scripts/bosses/Boss.gd"


# The Frostbite Maestro (Arctic/Ice Biome Boss)
# Stationary conductor boss with music-driven bullet hell patterns, tempo/volume control, and audience reactions.

var phase = 1
var tempo = 1.0 # Controls bullet speed
var volume = 1.0 # Controls attack damage
var audience_state = "neutral"
var attack_queue = []
var attack_index = 0
var attack_fusion = false
var vulnerable = false

signal tempo_changed
signal volume_changed
signal audience_reacted
signal chandelier_shattered
signal baton_disrupted
signal attack_fused
signal maestro_vulnerable


func _ready():
	health = max_health
	setup_audience()
	setup_chandeliers()
	start_phase(1)

func setup_audience():
	# Initialize frozen audience visuals
	audience_state = "neutral"
	emit_signal("audience_reacted", audience_state)

func setup_chandeliers():
	# Place icicle chandeliers above arena
	pass


func start_phase(new_phase):
	phase = new_phase
	emit_signal("phase_changed", phase)
	if phase == 1:
		attack_queue = ["icicle_crescendo", "blizzard_waltz", "chorus_of_minnows", "sheet_music_shred", "encore_slam"]
		attack_index = 0
		attack_fusion = false
		next_attack()
	elif phase == 2:
		attack_queue = ["icicle_crescendo", "blizzard_waltz", "chorus_of_minnows", "sheet_music_shred", "encore_slam", "attack_fusion"]
		attack_index = 0
		attack_fusion = true
		next_attack()


func check_phase_transition():
	if health <= max_health * 0.5 and phase == 1:
		start_phase(2)


func start_attack(attack_name):
	emit_signal("attack_started", attack_name)
	match attack_name:
		"icicle_crescendo":
			icicle_crescendo()
		"blizzard_waltz":
			blizzard_waltz()
		"chorus_of_minnows":
			chorus_of_minnows()
		"sheet_music_shred":
			sheet_music_shred()
		"encore_slam":
			encore_slam()
		"attack_fusion":
			fuse_attacks()

func next_attack():
	if attack_index >= attack_queue.size():
		attack_index = 0
	var attack_name = attack_queue[attack_index]
	attack_index += 1
	start_attack(attack_name)

# --- Attack Implementations ---
func icicle_crescendo():
	# Conducts a flurry of falling icicles in musical patterns
	# Visual/audio cues match the beat
	emit_signal("attack_started", "icicle_crescendo")
	# ...spawn icicles, sync to music
	audience_react("gasp")
	yield(get_tree().create_timer(2.0 / tempo), "timeout")
	next_attack()

func blizzard_waltz():
	# Swirling snow/wind pushes player in a circle
	emit_signal("attack_started", "blizzard_waltz")
	# ...apply wind force, spawn snow projectiles
	audience_react("applaud")
	yield(get_tree().create_timer(2.0 / tempo), "timeout")
	next_attack()

func chorus_of_minnows():
	# Choir of snow minnows emits sound waves in arcs
	emit_signal("attack_started", "chorus_of_minnows")
	# ...spawn minnow projectiles, sync to melody
	audience_react("cheer")
	yield(get_tree().create_timer(2.0 / tempo), "timeout")
	next_attack()

func sheet_music_shred():
	# Throws frozen sheet music that ricochets
	emit_signal("attack_started", "sheet_music_shred")
	# ...spawn sheet music projectiles
	audience_react("gasp")
	yield(get_tree().create_timer(2.0 / tempo), "timeout")
	next_attack()

func encore_slam():
	# Slam causes ice pillars to erupt in starburst pattern
	emit_signal("attack_started", "encore_slam")
	# ...spawn pillars, sync to musical climax
	audience_react("applaud")
	yield(get_tree().create_timer(2.0 / tempo), "timeout")
	next_attack()

func fuse_attacks():
	# Combine two or more attacks for phase 2 finale
	emit_signal("attack_fused")
	icicle_crescendo()
	blizzard_waltz()
	# ...add more fusion as desired
	next_attack()

# --- Tempo & Volume Control ---
func set_tempo(new_tempo):
	tempo = new_tempo
	emit_signal("tempo_changed", tempo)

func set_volume(new_volume):
	volume = new_volume
	emit_signal("volume_changed", volume)

# --- Audience Reactions ---
func audience_react(reaction):
	audience_state = reaction
	emit_signal("audience_reacted", audience_state)

# --- Chandelier Interactivity ---
func shatter_chandelier(index):
	emit_signal("chandelier_shattered", index)
	# ...spawn falling icicles, freeze floor pattern

# --- Baton Disruption ---
func on_baton_attacked():
	vulnerable = true
	emit_signal("baton_disrupted")
	emit_signal("maestro_vulnerable")
	yield(get_tree().create_timer(2.0), "timeout")
	vulnerable = false

# --- Phase 2 Frantic Finale ---
func on_phase2_frantic():
	# Music/attacks become wild and discordant
	set_tempo(2.0)
	set_volume(1.5)
	audience_react("wild")

func _on_rhythm_win():
	set_vulnerable(true)
	yield(get_tree().create_timer(2.0), "timeout")
	set_vulnerable(false)
