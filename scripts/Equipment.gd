
extends Node

"""
Equipment.gd
------------
Handles fisher's equipment slots, equipping/unequipping items, and calculating combined stat bonuses.
Each slot (pole, line, bobber, sink, bait, clothes) can hold one item. Items provide stat bonuses and may have slot restrictions.
"""

# --- Equipment Slots ---
var slots = {
	"pole": null,    # Fishing pole
	"line": null,    # Fishing line
	"bobber": null,  # Bobber/float
	"sink": null,    # Sink/weight
	"bait": null,    # Bait
	"clothes": null  # Clothing/cosmetic
}

# Reference to item data (defines stats, slot restrictions, etc.)
var item_data = load("res://scripts/data/item_data.gd")

func get_combined_stats():
	"""
	Calculates the combined stats from all equipped items.
	Returns a dictionary with stat totals (cast distance, tension, depth, bonuses, etc.).
	"""
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

func equip(slot, item_name):
	"""
	Equips an item to the specified slot if valid.
	Only items with a matching 'equip_slot' in item_data can be equipped.
	"""
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
	"""
	Unequips the item from the specified slot and returns its name, or null if empty.
	"""
	if slot in slots and slots[slot] != null:
		var item = slots[slot]
		slots[slot] = null
		print("Unequipped %s from %s" % [item, slot])
		return item
	return null

func get_equipped(slot):
	"""
	Returns the item equipped in the specified slot, or null if empty.
	"""
	if slot in slots:
		return slots[slot]
	return null

func print_equipment():
	"""
	Prints a summary of all equipped items to the output.
	"""
	print("Equipment:")
	for k in slots.keys():
		print("- %s: %s" % [k.capitalize(), slots[k] if slots[k] != null else "(empty)"])
