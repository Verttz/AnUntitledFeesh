func to_dict():
	# Returns a serializable dictionary of the inventory
	var data = {}
	for k in items.keys():
		var stackable = true
		if k in item_data.ITEM_DATA:
			stackable = item_data.ITEM_DATA[k].stackable
		if stackable:
			data[k] = items[k]
		else:
			# Deep copy to avoid reference issues
			data[k] = []
			for entry in items[k]:
				data[k].append(entry.duplicate(true))
	return data

func from_dict(data):
	# Loads inventory from a dictionary (as produced by to_dict)
	items.clear()
	for k in data.keys():
		var stackable = true
		if k in item_data.ITEM_DATA:
			stackable = item_data.ITEM_DATA[k].stackable
		if stackable:
			items[k] = data[k]
		else:
			items[k] = []
			for entry in data[k]:
				items[k].append(entry.duplicate(true))
func get_items_by_type(item_type: String):
	# Returns all items (with metadata) of a given type (e.g., "fish", "bait")
	var result = []
	for k in items.keys():
		var stackable = true
		if k in item_data.ITEM_DATA:
			stackable = item_data.ITEM_DATA[k].stackable
			var type = item_data.ITEM_DATA[k].type if "type" in item_data.ITEM_DATA[k] else "other"
		else:
			var type = "other"
		if type == item_type:
			if stackable:
				result.append({"name": k, "amount": items[k]})
			else:
				for entry in items[k]:
					result.append(entry)
	return result

func get_all_fish():
	return get_items_by_type("fish")

func sort_items(items: Array, by: String):
	# Sorts an array of items (dicts) by a metadata field (e.g., "rarity", "size", "name")
	items.sort_custom(func(a, b):
		if a.has(by) and b.has(by):
			return a[by] < b[by] ? -1 : (a[by] > b[by] ? 1 : 0)
		return 0
	)
	return items
# Inventory.gd
# Handles player inventory logic

extends Node

var items = {} # {item_name: count or array of unique items}
var max_slots = 20
var item_data = load("res://scripts/data/item_data.gd")

func add_item(item_name, amount := 1, metadata := null):
	var stackable = true
	if item_name in item_data.ITEM_DATA:
		stackable = item_data.ITEM_DATA[item_name].stackable
	var used_slots = get_slot_count()
	if stackable:
		if item_name in items:
			items[item_name] += amount
		else:
			if used_slots < max_slots:
				items[item_name] = amount
			else:
				print("Inventory full! Cannot add " + item_name)
	else:
		for i in range(amount):
			if used_slots < max_slots:
				var entry = metadata if metadata != null else {
					"name": item_name,
					"size": null,
					"rarity": null,
					"biome": null,
					"habitat": null,
					"catch_date": null,
					"custom_tags": [],
					"unique_id": str(OS.get_unix_time()) + "_" + str(randi())
				}
				if item_name in items:
					items[item_name].append(entry)
				else:
					items[item_name] = [entry]
				used_slots += 1
			else:
				print("Inventory full! Cannot add " + item_name)

func remove_item(item_name, amount := 1):
	var stackable = true
	if item_name in item_data.ITEM_DATA:
		stackable = item_data.ITEM_DATA[item_name].stackable
	if item_name in items:
		if stackable:
			items[item_name] -= amount
			if items[item_name] <= 0:
				items.erase(item_name)
		else:
			for i in range(amount):
				if items[item_name].size() > 0:
					items[item_name].pop_back()
				if items[item_name].size() == 0:
					items.erase(item_name)

func has_item(item_name, amount := 1):
	var stackable = true
	if item_name in item_data.ITEM_DATA:
		stackable = item_data.ITEM_DATA[item_name].stackable
	if item_name in items:
		if stackable:
			return items[item_name] >= amount
		else:
			return items[item_name].size() >= amount
	return false

func get_items():
	return items.duplicate()

func get_slot_count():
	var count = 0
	for k in items.keys():
		var stackable = true
		if k in item_data.ITEM_DATA:
			stackable = item_data.ITEM_DATA[k].stackable
		if stackable:
			count += 1
		else:
			count += items[k].size()
	return count

func print_inventory():
	print("Inventory:")
	for k in items.keys():
		var stackable = true
		if k in item_data.ITEM_DATA:
			stackable = item_data.ITEM_DATA[k].stackable
		if stackable:
			print("- %s x%d" % [k, items[k]])
		else:
			print("- %s x%d (non-stackable)" % [k, items[k].size()])
			for entry in items[k]:
				print("    - %s" % str(entry))
