
extends CharacterBody2D

signal fish_caught(catch_data: Dictionary)
signal fish_lost(fish_name: String)
signal fishing_state_changed(new_state: int)
signal casting_started
signal cast_released(power: float, direction: Vector2, target_pos: Vector2)
signal bite_occurred(fish_name: String, rarity: int)
signal reel_started(fish_name: String, rarity: int)

# --- Inventory Management ---
var tacklebox = preload("res://scripts/Inventory.gd").new()
var backpack = preload("res://scripts/Inventory.gd").new()

func get_fish_inventory():
	return backpack.get_all_fish()

func remove_fish_from_inventory(fish_entry):
	var item_name = fish_entry.get("name", null)
	if item_name == null:
		return
	var stackable = true
	if item_name in backpack.item_data.ITEM_DATA:
		stackable = backpack.item_data.ITEM_DATA[item_name].stackable
	if stackable:
		backpack.remove_item(item_name, fish_entry.get("amount", 1))
	else:
		if item_name in backpack.items:
			var found_idx = -1
			for i in range(backpack.items[item_name].size()):
				var entry = backpack.items[item_name][i]
				if entry.has("unique_id") and fish_entry.has("unique_id") and entry.unique_id == fish_entry.unique_id:
					found_idx = i
					break
			if found_idx != -1:
				backpack.items[item_name].remove_at(found_idx)
				if backpack.items[item_name].size() == 0:
					backpack.items.erase(item_name)

# --- Equipment Management ---
var equipment = preload("res://scripts/Equipment.gd").new()

func equip_item(slot: String, item_name: String):
	if tacklebox.has_item(item_name):
		var unequipped = equipment.unequip(slot)
		if unequipped:
			tacklebox.add_item(unequipped)
		equipment.equip(slot, item_name)
		tacklebox.remove_item(item_name)
	else:
		print("You don't have " + item_name + " in your tacklebox to equip.")

func unequip_item(slot: String):
	var item = equipment.unequip(slot)
	if item:
		tacklebox.add_item(item)

# --- Shop & Currency ---
var player_gold := 50
var shop_scene = preload("res://scripts/Shop.gd")
var shop_instance = null

func add_gold(amount: int):
	player_gold += amount

func spend_gold(amount: int) -> bool:
	if player_gold >= amount:
		player_gold -= amount
		return true
	return false

func add_item_to_inventory(item_name: String, amount := 1):
	backpack.add_item(item_name, amount)

# --- Movement & State ---
var speed := 150

enum State { MOVE, CASTING, WAITING, BITING, REELING }
var state = State.MOVE

# Fishing variables
var fishing_timer := 0.0
var fishing_bite_time := 0.0
var bobber_submerged := false
var bobber_reaction_window := 0.7
var bobber_reaction_timer := 0.0
var fish_hooked := false
var current_fish = null
var current_biome := "Forest"
var current_location := 0
var current_habitat := "lake"

# Data references
var locations_data = load("res://scripts/data/locations.gd")
var fish_data = load("res://scripts/data/fish_data.gd")

# Reeling minigame
var tension := 0.5
var tension_speed := 0.0
var tension_safe_min := 0.3
var tension_safe_max := 0.7
var reeling_time := 2.5
var reeling_timer := 0.0

# Fight pattern tracking
var fight_phase_index := 0
var fight_phase_timer := 0.0
var fight_phase_duration := 1.0

# Free-aim cast variables
var cast_power := 0.0
var cast_power_min := 0.2
var cast_power_max := 1.0
var cast_power_speed := 0.7
var is_charging_cast := false
var cast_direction := Vector2.RIGHT
var bobber_target := Vector2.ZERO


# =============================================================================
# Location Management
# =============================================================================

func set_location(index: int):
	var biome_locations = locations_data.LOCATIONS[current_biome]
	if index >= 0 and index < biome_locations.size():
		current_location = index
		var loc = biome_locations[index]
		if "habitat" in loc:
			current_habitat = loc.habitat
		if "type" in loc and loc.type == "shop":
			print("At shop: " + loc.shopkeeper)
		elif "type" in loc and loc.type == "boss_gate":
			print("At boss gate to: " + loc.next_biome)
		else:
			print("At fishing spot: " + loc.name + " (" + current_habitat + ")")

func next_location():
	set_location((current_location + 1) % locations_data.LOCATIONS[current_biome].size())

func prev_location():
	set_location((current_location - 1 + locations_data.LOCATIONS[current_biome].size()) % locations_data.LOCATIONS[current_biome].size())

# External override for fishing spot check (set by test scenes)
var fishing_spot_override: Callable = Callable()

func _is_at_fishing_spot() -> bool:
	if fishing_spot_override.is_valid():
		return fishing_spot_override.call()
	var loc = locations_data.LOCATIONS[current_biome][current_location]
	return loc.get("type", "") == "fishing_spot"


# =============================================================================
# Core Loop
# =============================================================================

func _physics_process(delta):
	match state:
		State.MOVE:
			_handle_movement(delta)
			if Input.is_action_just_pressed("ui_accept") and _is_at_fishing_spot():
				_start_casting()
		State.CASTING:
			_handle_casting(delta)
			if Input.is_action_just_released("ui_accept"):
				_release_cast()
		State.WAITING:
			_handle_waiting(delta)
		State.BITING:
			_handle_biting(delta)
		State.REELING:
			_handle_reeling(delta)

func _handle_movement(delta):
	var input_vector = Vector2.ZERO
	input_vector.x = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	input_vector.y = Input.get_action_strength("move_down") - Input.get_action_strength("move_up")
	if input_vector.length() > 0:
		input_vector = input_vector.normalized()
		velocity = input_vector * speed
	else:
		velocity = Vector2.ZERO
	move_and_slide()


# =============================================================================
# Cast System — MOVE → CASTING → WAITING → BITING → REELING
# =============================================================================

func _start_casting():
	state = State.CASTING
	cast_power = cast_power_min
	is_charging_cast = true
	velocity = Vector2.ZERO
	_update_cast_direction()
	casting_started.emit()
	fishing_state_changed.emit(State.CASTING)

func _handle_casting(_delta):
	cast_power = clampf(cast_power + cast_power_speed * _delta, cast_power_min, cast_power_max)
	_update_cast_direction()
	_show_cast_preview()

func _release_cast():
	is_charging_cast = false
	_hide_cast_preview()

	var eq_stats = equipment.get_combined_stats()
	var base_distance := lerpf(100.0, 400.0, (cast_power - cast_power_min) / (cast_power_max - cast_power_min))
	if eq_stats.cast_distance > 0:
		base_distance = maxf(base_distance, float(eq_stats.cast_distance))
	bobber_target = global_position + cast_direction * base_distance

	# Pre-select fish (determines bite timing); revealed to player at bite
	var selected = _select_fish(eq_stats)
	if selected == null:
		print("No fish here for habitat: %s" % current_habitat)
		state = State.MOVE
		fishing_state_changed.emit(State.MOVE)
		return
	current_fish = Fish.from_dict(selected)
	_consume_bait()

	state = State.WAITING
	fishing_timer = 0.0
	bobber_submerged = false
	fish_hooked = false
	bobber_reaction_timer = 0.0

	# Apply bite bonus from equipment
	var bite_min = current_fish.bite_time_range.x
	var bite_max = current_fish.bite_time_range.y
	if eq_stats.bite_bonus:
		bite_max = max(bite_min, bite_max - eq_stats.bite_bonus)
	fishing_bite_time = randf_range(bite_min, bite_max)
	bobber_reaction_window = current_fish.reaction_window

	cast_released.emit(cast_power, cast_direction, bobber_target)
	fishing_state_changed.emit(State.WAITING)

func _handle_waiting(delta):
	fishing_timer += delta
	if fishing_timer >= fishing_bite_time:
		_enter_biting()

func _enter_biting():
	state = State.BITING
	bobber_submerged = true
	bobber_reaction_timer = 0.0
	bite_occurred.emit(current_fish.fish_name, current_fish.rarity)
	fishing_state_changed.emit(State.BITING)

func _handle_biting(delta):
	bobber_reaction_timer += delta
	if Input.is_action_just_pressed("ui_accept"):
		fish_hooked = true
		_start_reeling()
	elif bobber_reaction_timer > bobber_reaction_window:
		_finish_fishing(false)


# =============================================================================
# Fish Selection — weighted by rarity, boosted by matching bait
# =============================================================================

func _select_fish(eq_stats: Dictionary):
	# Filter candidates by biome + habitat
	var candidates = []
	for fish in fish_data.FISH_LIST:
		if fish.biome != current_biome:
			continue
		if not ("habitat" in fish and current_habitat in fish.habitat):
			continue
		candidates.append(fish)
	if candidates.size() == 0:
		return null

	# Build weighted pool
	var equipped_bait = equipment.get_equipped("bait")
	var bait_type := ""
	if equipped_bait:
		var item_db = load("res://scripts/data/item_data.gd")
		if equipped_bait in item_db.ITEM_DATA and "bait_type" in item_db.ITEM_DATA[equipped_bait]:
			bait_type = item_db.ITEM_DATA[equipped_bait].bait_type
	var weights: Array[float] = []
	var total_weight := 0.0
	for fish in candidates:
		# Base weight: inverse of rarity_multiplier (common fish appear more often)
		var w := 1.0 / maxf(fish.rarity_multiplier, 0.1)
		# Bait bonus: matching preferred bait increases chance
		if bait_type != "" and "preferred_baits" in fish:
			if bait_type in fish.preferred_baits:
				w *= 2.5
		# Apply equipment bonus dict (e.g. {"rare_boost": 0.5} from lures)
		if eq_stats.bonus.has("rare_boost") and fish.rarity >= 2:
			w *= (1.0 + eq_stats.bonus["rare_boost"])
		total_weight += w
		weights.append(w)

	# Weighted random selection
	var roll := randf() * total_weight
	var cumulative := 0.0
	for i in range(candidates.size()):
		cumulative += weights[i]
		if roll <= cumulative:
			return candidates[i]
	return candidates[candidates.size() - 1]


# =============================================================================
# Bait Consumption
# =============================================================================

func _consume_bait():
	var bait_name = equipment.get_equipped("bait")
	if bait_name == null:
		return
	# The equipped bait unit is consumed; auto-re-equip from tacklebox stock
	equipment.slots["bait"] = null
	if tacklebox.has_item(bait_name):
		equipment.slots["bait"] = bait_name
		tacklebox.remove_item(bait_name, 1)


# =============================================================================
# Reeling Minigame
# =============================================================================

# Reel-time by rarity tier: Common, Uncommon, Rare, Epic, Legendary+
const REEL_TIME_BY_RARITY := [2.0, 3.0, 4.0, 5.5, 7.0]

func _start_reeling():
	state = State.REELING
	tension = 0.5
	reeling_timer = 0.0
	fight_phase_index = 0
	fight_phase_timer = 0.0

	# Scale difficulty by fish rarity
	var r := clampi(current_fish.rarity, 0, REEL_TIME_BY_RARITY.size() - 1)
	reeling_time = REEL_TIME_BY_RARITY[r]

	# Spread fight pattern evenly across reeling time
	var pattern_len := current_fish.fight_pattern.size() if current_fish else 1
	fight_phase_duration = reeling_time / maxf(float(pattern_len), 1.0)

	# Apply tension safe zone from equipment
	var eq_stats = equipment.get_combined_stats()
	tension_safe_min = eq_stats.tension_safe_min if eq_stats.tension_safe_min != null else 0.3
	tension_safe_max = eq_stats.tension_safe_max if eq_stats.tension_safe_max != null else 0.7
	reel_started.emit(current_fish.fish_name, current_fish.rarity)
	fishing_state_changed.emit(State.REELING)

func _handle_reeling(delta):
	# Determine current fight phase
	var phase := "calm"
	if current_fish and current_fish.fight_pattern.size() > 0:
		phase = current_fish.fight_pattern[fight_phase_index]

	# Tension changes based on phase + player input
	var holding := Input.is_action_pressed("ui_accept")
	match phase:
		"calm":
			tension_speed = 0.3 if holding else -0.2
		"pull":
			tension_speed = 0.7 if holding else -0.5
		"dart":
			tension_speed = randf_range(-1.0, 1.0) * (1.0 if holding else 0.5)
		_:
			tension_speed = 0.3 if holding else -0.2

	tension += tension_speed * delta
	tension = clampf(tension, 0.0, 1.0)
	# TODO: Update tension meter UI

	# Advance fight phase (loops through pattern)
	fight_phase_timer += delta
	if fight_phase_timer >= fight_phase_duration:
		fight_phase_timer = 0.0
		if current_fish and current_fish.fight_pattern.size() > 0:
			fight_phase_index = (fight_phase_index + 1) % current_fish.fight_pattern.size()

	# Track cumulative time in safe zone
	if tension < tension_safe_min or tension > tension_safe_max:
		reeling_timer = 0.0
	else:
		reeling_timer += delta

	# Win / lose checks
	if tension <= 0.0 or tension >= 1.0:
		_finish_fishing(false)
	elif reeling_timer >= reeling_time:
		_finish_fishing(true)


# =============================================================================
# Finish Fishing — success/fail + full state reset
# =============================================================================

func _finish_fishing(success: bool):
	var caught_fish_name := ""
	var caught_rarity := 0
	var caught_size := 0.0
	if success and current_fish:
		caught_size = randf_range(0.5, 2.0)
		var catch_data = {
			"name": current_fish.fish_name,
			"biome": current_fish.biome,
			"rarity": current_fish.rarity,
			"size": caught_size,
			"catch_date": Time.get_datetime_string_from_system(),
			"unique_id": str(randi()) + "_" + str(Time.get_ticks_msec()),
		}
		caught_fish_name = current_fish.fish_name
		caught_rarity = current_fish.rarity
		backpack.add_item(current_fish.fish_name, 1, catch_data)
		print("Caught: %s (rarity %d, size %.1fx)" % [current_fish.fish_name, current_fish.rarity, caught_size])
		fish_caught.emit(catch_data)
		# Notify QuestManager autoload
		var qm = get_node_or_null("/root/QuestManager")
		if qm and qm.has_method("check_quests"):
			qm.check_quests()
	else:
		caught_fish_name = current_fish.fish_name if current_fish else ""
		if current_fish:
			print("Lost: %s got away!" % current_fish.fish_name)
		fish_lost.emit(caught_fish_name)

	# Cache for HUD before reset
	var _was_success = success
	var _fish_name = caught_fish_name
	var _rarity = caught_rarity
	var _size = caught_size

	# Full state reset
	state = State.MOVE
	bobber_submerged = false
	fish_hooked = false
	current_fish = null
	fishing_timer = 0.0
	fishing_bite_time = 0.0
	bobber_reaction_timer = 0.0
	reeling_timer = 0.0
	tension = 0.5
	tension_speed = 0.0
	fight_phase_index = 0
	fight_phase_timer = 0.0
	is_charging_cast = false
	cast_power = 0.0

	fishing_state_changed.emit(State.MOVE)

	# Autosave
	if has_node("/root/SaveManager") and SaveManager.can_save("exploration"):
		SaveManager.autosave()
		var parent = get_parent()
		if parent and parent.has_method("show_save_notification"):
			parent.show_save_notification()


# =============================================================================
# Input (discrete events: mouse cast, shop enter, cancel fishing)
# =============================================================================

func _input(event):
	# Cancel fishing with Escape
	if state in [State.CASTING, State.WAITING, State.BITING, State.REELING] and event.is_action_pressed("ui_cancel"):
		_finish_fishing(false)
		return

	# Mouse-based cast (click to start charging, release to cast)
	if state == State.MOVE and _is_at_fishing_spot():
		if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			_start_casting()
	if state == State.CASTING:
		if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and not event.pressed:
			_release_cast()
		elif event is InputEventMouseMotion:
			_update_cast_direction()

	# Hook fish with mouse click during BITING
	if state == State.BITING:
		if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			fish_hooked = true
			_start_reeling()

	# Enter shop if at shop location
	if state == State.MOVE:
		var loc = locations_data.LOCATIONS[current_biome][current_location]
		if loc.get("type", "") == "shop" and event.is_action_pressed("ui_accept"):
			open_shop(loc)

func open_shop(shop_data: Dictionary):
	if shop_instance:
		shop_instance.queue_free()
	shop_instance = shop_scene.new()
	add_child(shop_instance)
	shop_instance.open(
		shop_data.get("shopkeeper", "Shopkeeper"),
		shop_data.get("items_for_sale", []),
		shop_data.get("buy_prices", {}),
		shop_data.get("sell_prices", {}),
		shop_data.get("notice_board_hints", []),
		backpack
	)


# =============================================================================
# Mouse Cast Helpers
# =============================================================================

func _process(_delta):
	if state == State.MOVE:
		_check_screen_edges()

func _check_screen_edges():
	var screen_rect = get_viewport_rect()
	var margin := 8
	var parent = get_parent()
	if not parent or not parent.has_method("on_player_reach_edge"):
		return
	if position.x < margin:
		parent.on_player_reach_edge("left")
	elif position.x > screen_rect.size.x - margin:
		parent.on_player_reach_edge("right")
	elif position.y < margin:
		parent.on_player_reach_edge("up")
	elif position.y > screen_rect.size.y - margin:
		parent.on_player_reach_edge("down")

func _update_cast_direction():
	var mouse_pos = get_global_mouse_position()
	cast_direction = (mouse_pos - global_position).normalized()

func _show_cast_preview():
	# TODO: Visualize cast arc/line
	pass

func _hide_cast_preview():
	# TODO: Hide cast preview
	pass


