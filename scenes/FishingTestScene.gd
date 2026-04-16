extends Node2D

# FishingTestScene.gd — Self-contained playable fishing test.
# Player walks around, approaches fishing spots, casts, reels, catches fish.

@onready var player = $Player
@onready var fishing_hud = $FishingHUD
@onready var spot_container = $FishingSpots

var fishing_spots: Array = []
var active_spot = null
const INTERACT_RADIUS := 60.0

func _ready():
	# Set up player collision shape if missing
	var col = player.get_node_or_null("CollisionShape2D")
	if col and col.shape == null:
		var shape = CircleShape2D.new()
		shape.radius = 12.0
		col.shape = shape

	# Collect all fishing spot markers and set their metadata
	for child in spot_container.get_children():
		fishing_spots.append(child)

	# Set habitat metadata for each spot
	if spot_container.has_node("LakeSpot"):
		spot_container.get_node("LakeSpot").set_meta("habitat", "lake")
		spot_container.get_node("LakeSpot").set_meta("spot_name", "Sunlit Lake")
	if spot_container.has_node("PondSpot"):
		spot_container.get_node("PondSpot").set_meta("habitat", "pond")
		spot_container.get_node("PondSpot").set_meta("spot_name", "Lily Pond")
	if spot_container.has_node("RiverSpot"):
		spot_container.get_node("RiverSpot").set_meta("habitat", "river")
		spot_container.get_node("RiverSpot").set_meta("spot_name", "Rushing River")
	if spot_container.has_node("CreekSpot"):
		spot_container.get_node("CreekSpot").set_meta("habitat", "creek")
		spot_container.get_node("CreekSpot").set_meta("spot_name", "Quiet Creek")

	# Give player starting equipment
	player.equipment.slots["pole"] = "Basic Rod"
	player.current_biome = "Forest"
	player.set_location(0)

	# Override the fishing spot check to use proximity
	player.fishing_spot_override = Callable(self, "_override_player_fishing_check")

	# Connect player signals
	player.fish_caught.connect(_on_fish_caught)
	player.fish_lost.connect(_on_fish_lost)

	_update_hud_inventory()

func _process(_delta):
	# Check proximity to fishing spots
	var nearest = _get_nearest_spot()
	if player.state == player.State.MOVE:
		if nearest:
			active_spot = nearest
			var loc_data = _get_location_for_spot(nearest)
			player.current_habitat = loc_data.get("habitat", "lake")
			fishing_hud.show_idle(loc_data.get("name", nearest.name), loc_data.get("habitat", "lake"))
		else:
			active_spot = null
			fishing_hud.show_not_at_spot()

	# Feed HUD based on player state
	match player.state:
		player.State.CASTING:
			fishing_hud.show_casting(player.cast_power, player.cast_direction)
		player.State.WAITING:
			fishing_hud.show_waiting()
		player.State.BITING:
			fishing_hud.show_bite(
				player.current_fish.fish_name if player.current_fish else "???",
				player.current_fish.rarity if player.current_fish else 0
			)
		player.State.REELING:
			var phase_name = "calm"
			if player.current_fish and player.current_fish.fight_pattern.size() > 0:
				phase_name = player.current_fish.fight_pattern[player.fight_phase_index]
			var reel_progress = player.reeling_timer / player.reeling_time if player.reeling_time > 0 else 0.0
			fishing_hud.show_reeling(
				player.current_fish.fish_name if player.current_fish else "???",
				player.tension,
				player.tension_safe_min,
				player.tension_safe_max,
				reel_progress,
				phase_name
			)

func _get_nearest_spot():
	var best = null
	var best_dist = INTERACT_RADIUS
	for spot in fishing_spots:
		var dist = player.global_position.distance_to(spot.global_position)
		if dist < best_dist:
			best = spot
			best_dist = dist
	return best

func _get_location_for_spot(spot: Node2D) -> Dictionary:
	# Map spot node metadata to location data
	var habitat = spot.get_meta("habitat", "lake")
	var spot_name = spot.get_meta("spot_name", spot.name)
	return {"name": spot_name, "habitat": habitat, "type": "fishing_spot"}

# Override Player's _is_at_fishing_spot to use proximity instead of location index
func _override_player_fishing_check():
	return active_spot != null

func _on_fish_caught(catch_data: Dictionary):
	fishing_hud.show_catch_result(true, catch_data.get("name", "???"), catch_data.get("rarity", 0), catch_data.get("size", 1.0))
	_update_hud_inventory()

func _on_fish_lost(fish_name: String):
	fishing_hud.show_catch_result(false, fish_name, 0, 0.0)

func on_player_reach_edge(_dir: String):
	# Clamp player inside the test area
	var bounds = Rect2(Vector2(32, 32), Vector2(960, 540))
	player.position.x = clampf(player.position.x, bounds.position.x, bounds.end.x)
	player.position.y = clampf(player.position.y, bounds.position.y, bounds.end.y)

func show_save_notification():
	pass  # No save in test mode

func _update_hud_inventory():
	var fish_list = player.backpack.get_all_fish()
	fishing_hud.update_inventory_display(fish_list)
