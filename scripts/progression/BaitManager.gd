extends Node

# Handles bait unlocks and usage per biome

signal bait_unlocked(bait_name)

var unlocked_bait := []

func unlock_bait(bait_name):
	if not unlocked_bait.has(bait_name):
		unlocked_bait.append(bait_name)
		emit_signal("bait_unlocked", bait_name)

func has_bait(bait_name):
	return unlocked_bait.has(bait_name)
