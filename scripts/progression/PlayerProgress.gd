extends Node

# Tracks player progression state

var current_biome := "Forest"
var unlocked_bait := []
var completed_quests := []
var upgrades := []
var fish_collected := {}

func reset_progress():
	current_biome = "Forest"
	unlocked_bait.clear()
	completed_quests.clear()
	upgrades.clear()
	fish_collected.clear()

func save_progress():
	"""
	Saves player progression to the SaveManager.
	This is called by SaveManager when saving the game.
	"""
	if has_node("/root/SaveManager"):
		get_node("/root/SaveManager").save_game()
	else:
		push_warning("SaveManager not found. Cannot save progress.")

func load_progress():
	"""
	Loads player progression from the SaveManager.
	This is called by SaveManager when loading the game.
	"""
	if has_node("/root/SaveManager"):
		get_node("/root/SaveManager").load_game()
	else:
		push_warning("SaveManager not found. Cannot load progress.")

func to_dict() -> Dictionary:
	"""
	Serializes the player progress to a dictionary for saving.
	"""
	return {
		"current_biome": current_biome,
		"unlocked_bait": unlocked_bait.duplicate(),
		"completed_quests": completed_quests.duplicate(),
		"upgrades": upgrades.duplicate(),
		"fish_collected": fish_collected.duplicate()
	}

func from_dict(data: Dictionary):
	"""
	Deserializes the player progress from a dictionary for loading.
	"""
	if typeof(data) != TYPE_DICTIONARY:
		return
	
	if "current_biome" in data:
		current_biome = data["current_biome"]
	if "unlocked_bait" in data:
		unlocked_bait = data["unlocked_bait"].duplicate()
	if "completed_quests" in data:
		completed_quests = data["completed_quests"].duplicate()
	if "upgrades" in data:
		upgrades = data["upgrades"].duplicate()
	if "fish_collected" in data:
		fish_collected = data["fish_collected"].duplicate()

