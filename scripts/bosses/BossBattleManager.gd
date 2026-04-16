extends Node

# Handles boss battle flow: tribute selection, fish spawning/swapping,
# boss lifecycle, victory/defeat, and fish consumption.

signal boss_spawned(boss)
signal boss_defeated(boss)
signal battle_started()
signal battle_ended(victory: bool)
signal fish_died(fish_index: int)
signal fish_swapped(new_fish_index: int)
signal tribute_consumed(fish_list: Array)
signal swap_ui_requested(remaining_fish: Array)

enum BattleState { INACTIVE, TRIBUTE_SELECT, FIGHTING, FISH_SWAP, PAUSED, VICTORY, DEFEAT }

var state: int = BattleState.INACTIVE

var boss_scene: PackedScene
var boss_instance: Node = null
var arena_scene: PackedScene
var arena_instance: Node = null

# Tribute fish (3 Fish resources selected by player)
var tribute_fish: Array = []     # Array[Fish] — the 3 chosen fish
var current_fish_index: int = -1
var combat_fish_instance: CombatFish = null

@export var combat_fish_scene: PackedScene  # CombatFish.tscn
var fish_spawn_position: Vector2 = Vector2(400, 300)  # Default, set by arena

# Mapping of boss names to their scene and arena paths
# boss_script: path to the boss .gd script (instantiated at runtime)
# arena_scene: path to the arena .tscn (contains environment, hazards, spawn markers)
var boss_data = {
	"TheGreatFisherduck": {
		"boss_script": "res://scripts/bosses/TheGreatFisherduck/TheGreatFisherduck.gd",
		"arena_scene": "res://scenes/arenas/TheGreatFisherduckArena.tscn"
	},
	"DonCatfishoni": {
		"boss_script": "res://scripts/bosses/DonCatfishoni/DonCatfishoni.gd",
		"arena_scene": "res://scenes/arenas/DonCatfishoniArena.tscn"
	},
	"CaptainPinchbeard": {
		"boss_script": "res://scripts/bosses/CaptainPinchbeard/CaptainPinchbeard.gd",
		"arena_scene": "res://scenes/arenas/CaptainPinchbeardArena.tscn"
	},
	"FinDiesel": {
		"boss_script": "res://scripts/bosses/FinDiesel/FinDiesel.gd",
		"arena_scene": "res://scenes/arenas/FinDieselArena.tscn"
	},
	"Guppazuma": {
		"boss_script": "res://scripts/bosses/Guppazuma/Guppazuma.gd",
		"arena_scene": "res://scenes/arenas/GuppazumaArena.tscn"
	},
	"CroakKing": {
		"boss_script": "res://scripts/bosses/CroakKing/CroakKing.gd",
		"arena_scene": "res://scenes/arenas/CroakKingArena.tscn"
	},
	"AbominableSnowbass": {
		"boss_script": "res://scripts/bosses/AbominableSnowbass/AbominableSnowbass.gd",
		"arena_scene": "res://scenes/arenas/AbominableSnowbassArena.tscn"
	},
	"FrostbiteMaestro": {
		"boss_script": "res://scripts/bosses/FrostbiteMaestro/FrostbiteMaestro.gd",
		"arena_scene": "res://scenes/arenas/FrostbiteMaestroArena.tscn"
	},
	"MagmaChef": {
		"boss_script": "res://scripts/bosses/MagmaChef/MagmaChef.gd",
		"arena_scene": "res://scenes/arenas/MagmaChefArena.tscn"
	},
	"PranksterPoppo": {
		"boss_script": "res://scripts/bosses/PranksterPoppo/PranksterPoppo.gd",
		"arena_scene": "res://scenes/arenas/PranksterPoppoArena.tscn"
	}
}


# ==========================================================================
# TRIBUTE SELECTION
# ==========================================================================

func begin_tribute_selection(boss_name: String, available_fish: Array) -> void:
	if not boss_data.has(boss_name):
		push_error("Unknown boss: %s" % boss_name)
		return
	state = BattleState.TRIBUTE_SELECT
	# UI calls confirm_tribute() once the player picks 3

func confirm_tribute(boss_name: String, selected_fish: Array) -> void:
	if selected_fish.size() != 3:
		push_error("Must select exactly 3 fish as tribute")
		return
	tribute_fish = selected_fish
	_start_battle(boss_name)


# ==========================================================================
# BATTLE LIFECYCLE
# ==========================================================================

func _start_battle(boss_name: String) -> void:
	var data = boss_data[boss_name]

	# Load arena
	arena_scene = load(data["arena_scene"])
	arena_instance = arena_scene.instantiate()
	add_child(arena_instance)

	# Find spawn position marker if arena has one
	var spawn_marker = arena_instance.find_child("FishSpawn", true, false)
	if spawn_marker:
		fish_spawn_position = spawn_marker.global_position

	# Load boss (arena .tscn should contain the boss node, or instantiate from script)
	var boss_node = arena_instance.find_child("Boss", true, false)
	if boss_node:
		boss_instance = boss_node
	else:
		# Fallback: check for any node in "boss" group
		for child in arena_instance.get_children():
			if child.is_in_group("boss"):
				boss_instance = child
				break

	# If no boss found in arena, instantiate from boss_script
	if boss_instance == null and data.has("boss_script"):
		var script = load(data["boss_script"])
		if script:
			boss_instance = CharacterBody2D.new()
			boss_instance.set_script(script)
			boss_instance.add_to_group("boss")
			arena_instance.add_child(boss_instance)

	if boss_instance:
		boss_instance.defeated.connect(_on_boss_defeated)
		boss_spawned.emit(boss_instance)

	state = BattleState.FIGHTING
	battle_started.emit()

	# Spawn first fish — player picks which of the 3 to start
	swap_ui_requested.emit(tribute_fish)


func spawn_fish(fish_index: int) -> void:
	if fish_index < 0 or fish_index >= tribute_fish.size():
		return
	var fish: Fish = tribute_fish[fish_index]
	if fish == null:
		return  # Already dead

	current_fish_index = fish_index

	if combat_fish_instance:
		combat_fish_instance.queue_free()

	if combat_fish_scene:
		combat_fish_instance = combat_fish_scene.instantiate()
	else:
		combat_fish_instance = CombatFish.new()

	combat_fish_instance.global_position = fish_spawn_position
	combat_fish_instance.setup(fish)
	combat_fish_instance.died.connect(_on_fish_died)
	add_child(combat_fish_instance)

	state = BattleState.FIGHTING
	fish_swapped.emit(fish_index)


# ==========================================================================
# FISH DEATH & SWAP
# ==========================================================================

func _on_fish_died() -> void:
	state = BattleState.FISH_SWAP
	fish_died.emit(current_fish_index)

	# Mark this fish as dead (null it out)
	tribute_fish[current_fish_index] = null

	# Clear bullets from the arena
	_clear_bullets()

	# Check if any fish remain
	var remaining := _get_remaining_fish()
	if remaining.is_empty():
		_on_defeat()
		return

	# Pause boss, show swap UI
	if boss_instance and boss_instance.has_method("set_physics_process"):
		boss_instance.set_physics_process(false)
	swap_ui_requested.emit(remaining)


func select_swap_fish(fish_index: int) -> void:
	# Called by swap UI when player picks their next fish
	if boss_instance and boss_instance.has_method("set_physics_process"):
		boss_instance.set_physics_process(true)
	spawn_fish(fish_index)


func _get_remaining_fish() -> Array:
	var remaining := []
	for i in tribute_fish.size():
		if tribute_fish[i] != null:
			remaining.append(i)
	return remaining


func _clear_bullets() -> void:
	for bullet in get_tree().get_nodes_in_group("boss_bullet"):
		bullet.queue_free()


# ==========================================================================
# VICTORY / DEFEAT
# ==========================================================================

func _on_boss_defeated() -> void:
	state = BattleState.VICTORY
	if combat_fish_instance:
		combat_fish_instance.set_physics_process(false)
	boss_defeated.emit(boss_instance)
	_consume_tribute()
	end_boss_battle(true)


func _on_defeat() -> void:
	state = BattleState.DEFEAT
	_consume_tribute()
	end_boss_battle(false)


func _consume_tribute() -> void:
	# All 3 fish are consumed win or lose
	tribute_consumed.emit(tribute_fish)


func end_boss_battle(victory: bool) -> void:
	state = BattleState.INACTIVE
	if combat_fish_instance:
		combat_fish_instance.queue_free()
		combat_fish_instance = null
	if boss_instance and is_instance_valid(boss_instance):
		boss_instance.queue_free()
		boss_instance = null
	if arena_instance:
		arena_instance.queue_free()
		arena_instance = null
	battle_ended.emit(victory)


# ==========================================================================
# LEGACY API (kept for compatibility)
# ==========================================================================

func start_boss_battle_by_name(boss_name: String) -> void:
	if boss_data.has(boss_name):
		begin_tribute_selection(boss_name, [])
	else:
		push_error("Unknown boss name: %s" % boss_name)
