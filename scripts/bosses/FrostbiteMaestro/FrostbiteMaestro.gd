extends "res://scripts/bosses/Boss.gd"


# The Frostbite Maestro (Arctic/Ice Biome Boss)
# Stationary conductor boss with music-driven bullet hell patterns, tempo/volume control, and audience reactions.

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
signal maestro_defeated


func _ready():
	max_health = 75000
	health = max_health
	setup_audience()
	setup_chandeliers()
	start_phase(1)

func setup_audience():
	# Initialize frozen audience visuals
	audience_state = "neutral"
	audience_reacted.emit(audience_state)

func setup_chandeliers():
	# Place icicle chandeliers above arena
	for i in range(3):
		var chandelier_scene = preload("res://scenes/arenas/FrostbiteMaestroChandelier.tscn")
		var chandelier = chandelier_scene.instantiate()
		chandelier.position = Vector2(200 + i*200, 60)
		chandelier.shattered.connect(func(): on_chandelier_shattered(i))
		get_parent().add_child(chandelier)


func start_phase(new_phase):
	phase = new_phase
	phase_changed.emit(phase)
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
	if health <= max_health * 0.3 and phase == 1:
		start_phase(2)


func start_attack(attack_name):
	attack_started.emit(attack_name)
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
	attack_started.emit("icicle_crescendo")
	telegraph_attack("icicle_crescendo")
	for beat in range(4):
		spawn_icicle_pattern(beat)
		await get_tree().create_timer(0.4 / tempo).timeout
	audience_react("gasp")
	await get_tree().create_timer(0.8 / tempo).timeout
	next_attack()

func blizzard_waltz():
	attack_started.emit("blizzard_waltz")
	telegraph_attack("blizzard_waltz")
	# Apply wind force, spawn snow projectiles in a waltz rhythm
	for bar in range(3):
		spawn_blizzard_arc(bar)
		await get_tree().create_timer(0.6 / tempo).timeout
	audience_react("applaud")
	await get_tree().create_timer(0.8 / tempo).timeout
	next_attack()

func chorus_of_minnows():
	attack_started.emit("chorus_of_minnows")
	telegraph_attack("chorus_of_minnows")
	for harmony in range(2):
		spawn_minnow_wave(harmony)
		await get_tree().create_timer(0.7 / tempo).timeout
	audience_react("cheer")
	await get_tree().create_timer(0.8 / tempo).timeout
	next_attack()

func sheet_music_shred():
	attack_started.emit("sheet_music_shred")
	telegraph_attack("sheet_music_shred")
	for page in range(3):
		spawn_sheet_music(page)
		await get_tree().create_timer(0.5 / tempo).timeout
	audience_react("gasp")
	await get_tree().create_timer(0.8 / tempo).timeout
	next_attack()

func encore_slam():
	attack_started.emit("encore_slam")
	telegraph_attack("encore_slam")
	spawn_ice_pillar_starburst()
	audience_react("applaud")
	await get_tree().create_timer(1.2 / tempo).timeout
	next_attack()

func fuse_attacks():
	attack_fused.emit()
	telegraph_attack("attack_fusion")
	await get_tree().create_timer(0.5 / tempo).timeout
	# Run attacks without calling next_attack() to avoid recursion
	for beat in range(4):
		spawn_icicle_pattern(beat)
		await get_tree().create_timer(0.4 / tempo).timeout
	for bar in range(3):
		spawn_blizzard_arc(bar)
		await get_tree().create_timer(0.6 / tempo).timeout
	for harmony in range(2):
		spawn_minnow_wave(harmony)
		await get_tree().create_timer(0.7 / tempo).timeout
	for page in range(3):
		spawn_sheet_music(page)
		await get_tree().create_timer(0.5 / tempo).timeout
	spawn_ice_pillar_starburst()
	audience_react("wild")
	await get_tree().create_timer(1.2 / tempo).timeout
	next_attack()
func telegraph_attack(name):
	# Visual/audio telegraph: baton glow, music cue, lighting
	$Baton.play_telegraph(name)
	$Cape.glow_for_attack(name)
	$ArenaLighting.set_attack_color(name)
	$MusicPlayer.cue_attack(name)
func spawn_icicle_pattern(beat):
	# Spawn icicles in a musical pattern
	var icicle_scene = preload("res://scenes/arenas/FrostbiteIcicle.tscn")
	for i in range(3):
		var icicle = icicle_scene.instantiate()
		icicle.position = Vector2(180 + i*180, 80 + beat*40)
		get_parent().add_child(icicle)
func spawn_blizzard_arc(bar):
	# Spawn snow projectiles in a waltz arc
	var snow_scene = preload("res://scenes/arenas/FrostbiteSnow.tscn")
	for i in range(8):
		var snow = snow_scene.instantiate()
		snow.position = global_position + Vector2.RIGHT.rotated(deg_to_rad(i*45 + bar*10)) * 220
		snow.linear_velocity = Vector2.RIGHT.rotated(deg_to_rad(i*45 + bar*10)) * 180 * tempo
		get_parent().add_child(snow)
func spawn_minnow_wave(harmony):
	# Spawn minnow projectiles in musical arcs
	var minnow_scene = preload("res://scenes/arenas/FrostbiteMinnow.tscn")
	for i in range(6):
		var minnow = minnow_scene.instantiate()
		minnow.position = global_position + Vector2.RIGHT.rotated(deg_to_rad(i*60 + harmony*15)) * 160
		minnow.linear_velocity = Vector2.RIGHT.rotated(deg_to_rad(i*60 + harmony*15)) * 200 * tempo
		get_parent().add_child(minnow)
func spawn_sheet_music(page):
	# Spawn ricocheting sheet music
	var sheet_scene = preload("res://scenes/arenas/FrostbiteSheetMusic.tscn")
	var sheet = sheet_scene.instantiate()
	sheet.position = global_position + Vector2(randf_range(-120,120), -40 + page*30)
	sheet.linear_velocity = Vector2(randf_range(-1,1), 1).normalized() * 260 * tempo
	get_parent().add_child(sheet)
func spawn_ice_pillar_starburst():
	# Spawn ice pillars in a starburst pattern
	var pillar_scene = preload("res://scenes/arenas/FrostbiteIcePillar.tscn")
	for i in range(8):
		var pillar = pillar_scene.instantiate()
		pillar.position = global_position + Vector2.RIGHT.rotated(deg_to_rad(i*45)) * 180
		get_parent().add_child(pillar)

# --- Tempo & Volume Control ---
func set_tempo(new_tempo):
	tempo = new_tempo
	tempo_changed.emit(tempo)

func set_volume(new_volume):
	volume = new_volume
	volume_changed.emit(volume)

# --- Audience Reactions ---
func audience_react(reaction):
	audience_state = reaction
	audience_reacted.emit(audience_state)

# --- Chandelier Interactivity ---
func shatter_chandelier(index):
	chandelier_shattered.emit(index)
	# Spawn falling icicles, freeze floor pattern
	for i in range(3):
		var icicle_scene = preload("res://scenes/arenas/FrostbiteIcicle.tscn")
		var icicle = icicle_scene.instantiate()
		icicle.position = Vector2(200 + index*200, 100 + i*40)
		get_parent().add_child(icicle)
	$ArenaFloor.freeze_pattern(index)

# --- Baton Disruption ---
func on_baton_attacked():
	vulnerable = true
	baton_disrupted.emit()
	maestro_vulnerable.emit()
	$Baton.fumble()
	$Cape.dull()
	$ArenaLighting.set_attack_color("vulnerable")
	await get_tree().create_timer(2.0).timeout
	vulnerable = false
	$Cape.restore_glow()

# --- Phase 2 Frantic Finale ---
func on_phase2_frantic():
	# Music/attacks become wild and discordant
	set_tempo(2.0)
	set_volume(1.5)
	audience_react("wild")
	$ArenaLighting.set_attack_color("frantic")
func on_chandelier_shattered(index):
	# Audience gasps, floor freezes, Maestro critiques
	audience_react("gasp")
	$MaestroSprite.play("critique")
func on_maestro_defeated():
	# Victory flair: baton shatters, music stops, audience erupts, Maestro bows
	maestro_defeated.emit()
	$Baton.shatter()
	$MusicPlayer.stop_music()
	$ArenaLighting.set_attack_color("victory")
	$MaestroSprite.play("final_bow")
	$AudienceSprite.play("applause_shatter")

func _on_rhythm_win():
	set_vulnerable(true)
	await get_tree().create_timer(2.0).timeout
	set_vulnerable(false)
