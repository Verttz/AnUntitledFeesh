extends Node

# Handles biome order, entry, and transitions

signal biome_entered(biome_name)
signal biome_completed(biome_name)

var biome_order := ["RiverLake", "Ocean", "JungleWetlands", "FrozenMountain", "Lava", "FishingSanctum"]
var current_biome := ""

func enter_biome(biome_name):
	current_biome = biome_name
	emit_signal("biome_entered", biome_name)

func complete_biome(biome_name):
	emit_signal("biome_completed", biome_name)

func get_next_biome():
	var idx = biome_order.find(current_biome)
	if idx != -1 and idx < biome_order.size() - 1:
		return biome_order[idx + 1]
	return ""
