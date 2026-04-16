extends Node

# BiomeManager.gd — Thin facade that delegates biome state to ProgressionManager.
# Kept for backward compatibility. Biome definitions live in BiomeData.

signal biome_entered(biome_name)
signal biome_completed(biome_name)

var biome_order := BiomeData.BIOME_ORDER

var current_biome: String:
	get:
		var pm = get_node_or_null("/root/ProgressionManager")
		return pm.current_biome if pm else ""
	set(v):
		var pm = get_node_or_null("/root/ProgressionManager")
		if pm: pm.current_biome = v

func enter_biome(biome_name: String) -> void:
	if biome_name not in biome_order:
		push_warning("Unknown biome: " + biome_name)
		return
	current_biome = biome_name
	var pm = get_node_or_null("/root/ProgressionManager")
	if pm:
		pm.enter_biome(biome_name)
	biome_entered.emit(biome_name)

func complete_biome(biome_name: String) -> void:
	biome_completed.emit(biome_name)

func get_next_biome() -> String:
	return BiomeData.get_next_biome(current_biome)

func get_biome_display_name(biome_id: String) -> String:
	return BiomeData.get_display_name(biome_id)

func get_sub_biomes(biome_id: String) -> Array:
	return BiomeData.get_sub_biomes(biome_id)
