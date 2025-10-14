func get_combined_stats():
	var stats = {
		"cast_distance": 0,
		"tension_safe_min": null,
		"tension_safe_max": null,
		"depth": null,
		"bite_bonus": 0.0,
		"bonus": {}
	}
	for slot in slots.keys():
		var item = slots[slot]
		if item and item in item_data.ITEM_DATA:
			var data = item_data.ITEM_DATA[item]
			if "cast_distance" in data:
				stats["cast_distance"] = max(stats["cast_distance"], data["cast_distance"])
			if "tension_safe_min" in data:
				stats["tension_safe_min"] = data["tension_safe_min"]
			if "tension_safe_max" in data:
				stats["tension_safe_max"] = data["tension_safe_max"]
			if "depth" in data:
				stats["depth"] = data["depth"]
			if "bite_bonus" in data:
				stats["bite_bonus"] += data["bite_bonus"]
			if "bonus" in data:
				for k in data["bonus"].keys():
					stats["bonus"][k] = data["bonus"][k]
	return stats
# Equipment.gd
# Handles fisher's equipment slots

extends Node

var slots = {
    "pole": null,
    "line": null,
    "bobber": null,
    "sink": null,
    "bait": null,
    "clothes": null
}
var item_data = load("res://scripts/data/item_data.gd")

func equip(slot, item_name):
	if slot in slots:
		var valid = false
		if item_name in item_data.ITEM_DATA:
			var data = item_data.ITEM_DATA[item_name]
			if "equip_slot" in data and data.equip_slot == slot:
				valid = true
		if valid:
			slots[slot] = item_name
			print("Equipped %s to %s" % [item_name, slot])
		else:
			print("%s cannot be equipped to %s" % [item_name, slot])
	else:
		print("Invalid equipment slot: " + slot)

func unequip(slot):
	if slot in slots and slots[slot] != null:
		var item = slots[slot]
		slots[slot] = null
		print("Unequipped %s from %s" % [item, slot])
		return item
	return null

func get_equipped(slot):
	if slot in slots:
		return slots[slot]
	return null

func print_equipment():
	print("Equipment:")
	for k in slots.keys():
		print("- %s: %s" % [k.capitalize(), slots[k] if slots[k] != null else "(empty)"])
