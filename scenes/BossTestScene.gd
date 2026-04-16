extends Node2D

# BossTestScene.gd — Self-contained boss fight playtest.
# Pre-selects 3 diverse fish, spawns a TestBoss with bullet hell patterns,
# manages the full battle flow: fish swap on death, victory, defeat, restart.

@onready var boss_node: Node2D = $Boss
@onready var combat_hud = $CombatHUD
@onready var arena_bounds_rect = $ArenaBounds

var fish_data_ref = load("res://scripts/data/fish_data.gd")

# Tribute fish (3 Fish resources)
var tribute_fish: Array = []
var current_fish_index: int = -1
var combat_fish: CombatFish = null
var projectile_scene: PackedScene = preload("res://scenes/combat/Projectile.tscn")

enum BattleState { PICKING, FIGHTING, SWAPPING, VICTORY, DEFEAT }
var state: int = BattleState.PICKING

# Arena rect for clamping
var arena_rect := Rect2(Vector2(40, 70), Vector2(1200, 570))

# Pre-selected fish names (melee slash, ranged rapid-fire, special heal)
const TEST_FISH_NAMES := ["Largemouth Bass", "Salmon", "Pizza Fish"]


func _ready():
	_build_tribute_fish()
	combat_hud.setup_tribute(tribute_fish)
	combat_hud.fish_swap_selected.connect(_on_swap_selected)

	# Set up boss
	boss_node.combat_fish_ref = null
	boss_node.defeated.connect(_on_boss_defeated)
	boss_node.phase_changed.connect(_on_boss_phase_changed)
	boss_node.set_physics_process(false)  # Pause until first fish is picked

	combat_hud.update_boss_hp(boss_node.health, boss_node.max_health)
	combat_hud.update_boss_info("Test Boss", 1)

	# Show swap UI to pick first fish
	_show_initial_pick()


func _show_initial_pick():
	state = BattleState.PICKING
	var indices := [0, 1, 2]
	combat_hud.swap_panel.show_selection(indices, "Choose your first fighter:")


func _build_tribute_fish():
	for fish_name in TEST_FISH_NAMES:
		var data = _find_fish_data(fish_name)
		if data:
			tribute_fish.append(Fish.from_dict(data))
		else:
			# Fallback: pick a random Forest fish
			var fallback = fish_data_ref.FISH_LIST[randi() % fish_data_ref.FISH_LIST.size()]
			tribute_fish.append(Fish.from_dict(fallback))


func _find_fish_data(fish_name: String) -> Dictionary:
	for entry in fish_data_ref.FISH_LIST:
		if entry["name"] == fish_name:
			return entry
	return {}


func _spawn_combat_fish(fish_index: int):
	if combat_fish and is_instance_valid(combat_fish):
		combat_fish.queue_free()

	var fish: Fish = tribute_fish[fish_index]
	if fish == null:
		return

	current_fish_index = fish_index
	combat_fish = CombatFish.new()
	combat_fish.projectile_scene = projectile_scene
	combat_fish.global_position = Vector2(640, 500)
	combat_fish.setup(fish)
	combat_fish.died.connect(_on_fish_died)
	combat_fish.health_changed.connect(_on_fish_hp_changed)
	combat_fish.special_used.connect(_on_special_used)
	combat_fish.special_ready.connect(_on_special_ready)

	# Give it a collision shape
	var col = CollisionShape2D.new()
	var shape = CircleShape2D.new()
	shape.radius = 12.0
	col.shape = shape
	combat_fish.add_child(col)

	# Visual placeholder (green square)
	var sprite = ColorRect.new()
	sprite.size = Vector2(24, 24)
	sprite.position = Vector2(-12, -12)
	sprite.color = Color(0.2, 0.9, 0.3)
	combat_fish.add_child(sprite)

	add_child(combat_fish)

	# Tell boss about the fish
	boss_node.combat_fish_ref = combat_fish

	# Update HUD
	combat_hud.update_fish_info(fish)
	combat_hud.update_fish_hp(combat_fish.current_hp, combat_fish.max_hp)
	combat_hud.hide_swap_ui()
	combat_hud.hide_result()

	state = BattleState.FIGHTING
	boss_node.set_physics_process(true)


func _process(delta):
	if state == BattleState.FIGHTING:
		# Update boss HP (boss takes damage via direct take_damage calls)
		combat_hud.update_boss_hp(boss_node.health, boss_node.max_health)

		# Update special cooldown
		if combat_fish and is_instance_valid(combat_fish) and combat_fish.fish_data:
			combat_hud.update_special_cooldown(combat_fish.special_cooldown, combat_fish.special_cooldown_max)

		# Clamp fish to arena
		if combat_fish and is_instance_valid(combat_fish):
			combat_fish.global_position.x = clampf(combat_fish.global_position.x, arena_rect.position.x, arena_rect.end.x)
			combat_fish.global_position.y = clampf(combat_fish.global_position.y, arena_rect.position.y, arena_rect.end.y)

	# Restart with R
	if Input.is_key_pressed(KEY_R) and state in [BattleState.VICTORY, BattleState.DEFEAT]:
		_restart()


func _unhandled_input(event: InputEvent):
	if not event is InputEventKey or not event.pressed:
		return

	# R to restart
	if event.keycode == KEY_R and state in [BattleState.VICTORY, BattleState.DEFEAT]:
		_restart()


# === Signal handlers ===

func _on_swap_selected(fish_index: int):
	if fish_index < tribute_fish.size() and tribute_fish[fish_index] != null:
		_spawn_combat_fish(fish_index)


func _on_fish_hp_changed(current: int, max_hp: int):
	combat_hud.update_fish_hp(current, max_hp)


func _on_fish_died():
	state = BattleState.SWAPPING
	boss_node.set_physics_process(false)

	# Mark this fish as dead
	tribute_fish[current_fish_index] = null

	# Clear boss bullets
	for bullet in get_tree().get_nodes_in_group("boss_bullet"):
		bullet.queue_free()

	# Check remaining
	var remaining: Array = []
	for i in tribute_fish.size():
		if tribute_fish[i] != null:
			remaining.append(i)

	if remaining.is_empty():
		_on_defeat()
	else:
		combat_hud.show_swap_ui(remaining)


func _on_boss_defeated():
	state = BattleState.VICTORY
	if combat_fish and is_instance_valid(combat_fish):
		combat_fish.set_physics_process(false)

	# Clear all bullets
	for bullet in get_tree().get_nodes_in_group("boss_bullet"):
		bullet.queue_free()
	for bullet in get_tree().get_nodes_in_group("player_bullet"):
		bullet.queue_free()

	combat_hud.show_victory()


func _on_defeat():
	state = BattleState.DEFEAT
	for bullet in get_tree().get_nodes_in_group("boss_bullet"):
		bullet.queue_free()
	for bullet in get_tree().get_nodes_in_group("player_bullet"):
		bullet.queue_free()

	combat_hud.show_defeat()


func _on_boss_phase_changed(new_phase: int):
	combat_hud.update_boss_info("Test Boss", new_phase)


func _on_special_used(ability_name: String):
	pass


func _on_special_ready(ability_name: String):
	pass


func _restart():
	# Reload the scene
	get_tree().reload_current_scene()
