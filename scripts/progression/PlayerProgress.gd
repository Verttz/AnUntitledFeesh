extends Node

# Tracks player progression state

var current_biome := "Pond"
var unlocked_bait := []
var completed_quests := []
var upgrades := []
var fish_collected := {}

func reset_progress():
	current_biome = "Pond"
	unlocked_bait.clear()
	completed_quests.clear()
	upgrades.clear()
	fish_collected.clear()

func save_progress():
	# Implement save logic here
	pass

func load_progress():
	# Implement load logic here
	pass
