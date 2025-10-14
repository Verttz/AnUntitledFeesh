var tacklebox = preload("res://scripts/Inventory.gd").new() # For tackle
var backpack = preload("res://scripts/Inventory.gd").new() # For fish/items
var equipment = preload("res://scripts/Equipment.gd").new()
# Equipment management
func equip_item(slot, item_name):
	if tacklebox.has_item(item_name):
		var unequipped = equipment.unequip(slot)
		if unequipped:
			tacklebox.add_item(unequipped)
		equipment.equip(slot, item_name)
		tacklebox.remove_item(item_name)
	else:
		print("You don't have " + item_name + " in your tacklebox to equip.")

func unequip_item(slot):
	var item = equipment.unequip(slot)
	if item:
		tacklebox.add_item(item)
var player_gold = 50
# Reference to shop script
var shop_scene = preload("res://scripts/Shop.gd")
var shop_instance = null
extends CharacterBody2D

# Movement speed in pixels/sec
var speed := 150

# Fishing mechanic variables

# Player states
enum State { MOVE, FISHING_WAIT, FISHING_REEL }
var state = State.MOVE

# Fishing variables
var fishing_timer = 0.0
var fishing_bite_time = 0.0
var bobber_submerged = false
var bobber_reaction_window = 0.7 # seconds to react (set by fish)
var bobber_reaction_timer = 0.0
var fish_hooked = false
var current_fish = null # Fish resource for this attempt
var current_biome = "Lake" # Default biome, can be changed by player
var current_location = 0 # Index in biome's location list
var current_habitat = "lake" # Default habitat, set by location

# Load locations data
var locations_data = load("res://scripts/data/locations.gd")
func set_location(index):
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

# Reeling minigame variables
var tension = 0.5 # 0.0 = slack, 1.0 = snapped, 0.5 = ideal
var tension_speed = 0.0
var tension_safe_min = 0.3
var tension_safe_max = 0.7
var reeling_time = 2.5 # seconds to keep tension in safe zone (set by fish)
var reeling_timer = 0.0

# Fight pattern phase tracking
var fight_phase_index = 0
var fight_phase_timer = 0.0
var fight_phase_duration = 1.0 # seconds per phase (can randomize or set per fish)

func _physics_process(delta):
	match state:
		State.MOVE:
			_handle_movement(delta)
			if Input.is_action_just_pressed("ui_accept"): # Space to fish
				start_fishing()
			# TEMP: Print current location info
			var loc = locations_data.LOCATIONS[current_biome][current_location]
			if "type" in loc and loc.type == "shop":
				pass # Could show shop UI
			elif "type" in loc and loc.type == "boss_gate":
				pass # Could trigger boss fight
		State.FISHING_WAIT:
			# Waiting for bite
			fishing_timer += delta
			if not bobber_submerged and fishing_timer >= fishing_bite_time:
				bobber_submerged = true
				bobber_reaction_timer = 0.0
				# TODO: Animate bobber submerging, play sound
			if bobber_submerged:
				bobber_reaction_timer += delta
				if Input.is_action_just_pressed("ui_accept"):
					fish_hooked = true
					start_reeling()
				elif bobber_reaction_timer > bobber_reaction_window:
					finish_fishing(success=false) # Missed the hook
		State.FISHING_REEL:
			# Reeling minigame
			_handle_reeling(delta)

func _handle_movement(delta):
	var input_vector = Vector2.ZERO
	input_vector.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	input_vector.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	if input_vector.length() > 0:
		input_vector = input_vector.normalized()
		velocity = input_vector * speed
	else:
		velocity = Vector2.ZERO
	move_and_slide()

func start_fishing():
	# Load equipment stats
	var eq_stats = equipment.get_combined_stats()
	# Load fish data and filter by current biome, habitat, and depth if set
	var fish_data = load("res://scripts/data/fish_data.gd")
	var fish_list = []
	for fish in fish_data.FISH_LIST:
		var match = fish.biome == current_biome and ("habitat" in fish and fish.habitat == current_habitat)
		if eq_stats.depth:
			match = match and ("depth" in fish and fish.depth == eq_stats.depth)
		if match:
			fish_list.append(fish)
	if fish_list.size() == 0:
		print("No fish found for biome: " + current_biome + ", habitat: " + current_habitat)
		return
	var fish_dict = fish_list[randi() % fish_list.size()]
	# Convert dict to Fish resource
	var Fish = load("res://scripts/Fish.gd")
	current_fish = Fish.new(
		fish_dict.name,
		fish_dict.rarity,
		fish_dict.biome,
		fish_dict.bite_time_range,
		fish_dict.reaction_window,
		fish_dict.fight_pattern,
		fish_dict.preferred_baits,
		fish_dict.habitat
	)

	state = State.FISHING_WAIT
	fishing_timer = 0.0
	# Apply bite bonus from equipment
	var bite_min = current_fish.bite_time_range.x
	var bite_max = current_fish.bite_time_range.y
	if eq_stats.bite_bonus:
		bite_max = max(bite_min, bite_max - eq_stats.bite_bonus)
	fishing_bite_time = randf_range(bite_min, bite_max)
	bobber_submerged = false
	fish_hooked = false
	bobber_reaction_window = current_fish.reaction_window
	velocity = Vector2.ZERO
	# TODO: Show bobber UI/animation, display fish name for debug

func start_reeling():
	state = State.FISHING_REEL
	tension = 0.5
	reeling_timer = 0.0
	fight_phase_index = 0
	fight_phase_timer = 0.0
	fight_phase_duration = 1.0 # You can randomize or set per fish for more variety
	# Apply tension safe zone from equipment
	var eq_stats = equipment.get_combined_stats()
	if eq_stats.tension_safe_min != null:
		tension_safe_min = eq_stats.tension_safe_min
	if eq_stats.tension_safe_max != null:
		tension_safe_max = eq_stats.tension_safe_max
	# TODO: Show tension meter UI

func finish_fishing(success):
	if success:
		# Add caught fish to backpack
		if current_fish:
			backpack.add_item(current_fish.name)
		# TODO: Play success sound/animation
	else:
		# TODO: Play fail sound/animation
		pass
	state = State.MOVE
	# TODO: Hide fishing UI, reset variables

func _handle_reeling(delta):
	# Fight pattern phase logic
	if current_fish and current_fish.fight_pattern.size() > 0:
		var phase = current_fish.fight_pattern[fight_phase_index]
	else:
		var phase = "calm"

	# Set tension_speed based on phase
	var holding = Input.is_action_pressed("ui_accept")
	match phase:
		"calm":
			tension_speed = holding ? 0.3 : -0.2
		"pull":
			tension_speed = holding ? 0.7 : -0.5
		"dart":
			# Erratic: randomize tension speed, player must react quickly
			tension_speed = randf_range(-1.0, 1.0) * (holding ? 1.0 : 0.5)
		_:
			tension_speed = holding ? 0.3 : -0.2

	tension += tension_speed * delta
	tension = clamp(tension, 0.0, 1.0)

	# TODO: Update tension meter UI

	# Advance fight phase
	fight_phase_timer += delta
	if fight_phase_timer >= fight_phase_duration:
		fight_phase_timer = 0.0
		fight_phase_index += 1
		if current_fish and fight_phase_index >= current_fish.fight_pattern.size():
			fight_phase_index = current_fish.fight_pattern.size() - 1 # Stay on last phase

	if tension < tension_safe_min or tension > tension_safe_max:
		reeling_timer = 0.0 # Reset timer if out of safe zone
		# TODO: Flash warning, play sound
	else:
		reeling_timer += delta
		# TODO: Play reeling sound, animate fish

	if tension <= 0.0 or tension >= 1.0:
		finish_fishing(success=false) # Line snapped or too slack
	elif reeling_timer >= reeling_time:
		finish_fishing(success=true) # Fish caught!

func _input(event):
	# Enter shop if at shop location and Enter is pressed
	var loc = locations_data.LOCATIONS[current_biome][current_location]
	if "type" in loc and loc.type == "shop" and event.is_action_pressed("ui_accept"):
		open_shop(loc.name)
func open_shop(shop_name):
	var shop_data = load("res://scripts/data/shop_data.gd")
	if shop_name in shop_data.SHOPS:
		var shop_info = shop_data.SHOPS[shop_name]
		if not shop_instance:
			shop_instance = shop_scene.new()
			add_child(shop_instance)
		# Pass backpack for fish/items
		shop_instance.open(
			shop_info.shopkeeper,
			shop_info.items,
			shop_info.buy_prices,
			shop_info.sell_prices,
			shop_info.hints,
			backpack
		)
# Methods for shop to update inventory/gold
func add_item_to_inventory(item_name):
	backpack.add_item(item_name)

func remove_fish_from_inventory(fish_name):
	backpack.remove_item(fish_name)

func add_gold(amount):
	player_gold += amount

func spend_gold(amount):
	if player_gold >= amount:
		player_gold -= amount
		return true
	return false
	else:
		print("No shop data for " + shop_name)
	# Allow canceling fishing with Escape
	if state in [State.FISHING_WAIT, State.FISHING_REEL] and event.is_action_pressed("ui_cancel"):
		finish_fishing(success=false)
	# TEMP: Use Q/E to move between locations
	if event.is_action_pressed("ui_left"):
		prev_location()
	elif event.is_action_pressed("ui_right"):
		next_location()
