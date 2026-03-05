extends Node

var items = {} # {item_name: count or array of unique items}
var max_slots = 20
var item_data = load("res://scripts/data/item_data.gd")

# --- Helper ---

func _is_stackable(item_name: String) -> bool:
	if item_name in item_data.ITEM_DATA:
		return item_data.ITEM_DATA[item_name].stackable
	return true

func _get_item_type(item_name: String) -> String:
	if item_name in item_data.ITEM_DATA and "type" in item_data.ITEM_DATA[item_name]:
		return item_data.ITEM_DATA[item_name].type
	return "other"

# --- Core Operations ---

func add_item(item_name: String, amount := 1, metadata = null):
	var used_slots = get_slot_count()
	if _is_stackable(item_name):
		if item_name in items:
			items[item_name] += amount
		elif used_slots < max_slots:
			items[item_name] = amount
		else:
			print("Inventory full! Cannot add " + item_name)
	else:
		for i in range(amount):
			if used_slots < max_slots:
				var entry = metadata.duplicate(true) if metadata != null else {
					"name": item_name,
					"size": null,
					"rarity": null,
					"biome": null,
					"habitat": null,
					"catch_date": null,
					"custom_tags": [],
					"unique_id": str(Time.get_unix_time_from_system()) + "_" + str(randi())
				}
				if item_name in items:
					items[item_name].append(entry)
				else:
					items[item_name] = [entry]
				used_slots += 1
			else:
				print("Inventory full! Cannot add " + item_name)

func remove_item(item_name: String, amount := 1):
	if item_name not in items:
		return
	if _is_stackable(item_name):
		items[item_name] -= amount
		if items[item_name] <= 0:
			items.erase(item_name)
	else:
		for i in range(amount):
			if item_name in items and items[item_name].size() > 0:
				items[item_name].pop_back()
			if item_name in items and items[item_name].size() == 0:
				items.erase(item_name)

func has_item(item_name: String, amount := 1) -> bool:
	if item_name in items:
		if _is_stackable(item_name):
			return items[item_name] >= amount
		else:
			return items[item_name].size() >= amount
	return false

func get_items() -> Dictionary:
	return items.duplicate()

func get_slot_count() -> int:
	var count = 0
	for k in items.keys():
		if _is_stackable(k):
			count += 1
		else:
			count += items[k].size()
	return count

func move_item_to_slot(item_name: String, from_index: int, to_index: int):
	if _is_stackable(item_name):
		return
	if item_name not in items:
		return
	var arr = items[item_name]
	if from_index < 0 or from_index >= arr.size() or to_index < 0 or to_index > arr.size():
		return
	var entry = arr[from_index]
	arr.remove_at(from_index)
	if to_index >= arr.size():
		arr.append(entry)
	else:
		arr.insert(to_index, entry)

# --- Serialization ---

func to_dict() -> Dictionary:
	var data = {}
	for k in items.keys():
		if _is_stackable(k):
			data[k] = items[k]
		else:
			data[k] = []
			for entry in items[k]:
				data[k].append(entry.duplicate(true))
	return data

func from_dict(data: Dictionary):
	items.clear()
	for k in data.keys():
		if _is_stackable(k):
			items[k] = data[k]
		else:
			items[k] = []
			for entry in data[k]:
				items[k].append(entry.duplicate(true))

# --- Filtering & Sorting ---

func get_items_by_type(item_type: String) -> Array:
	var result = []
	for k in items.keys():
		var type = _get_item_type(k)
		if type == item_type:
			if _is_stackable(k):
				result.append({"name": k, "amount": items[k]})
			else:
				for entry in items[k]:
					result.append(entry)
	return result

func get_all_fish() -> Array:
	return get_items_by_type("fish")

func sort_items(item_list: Array, by: String) -> Array:
	item_list.sort_custom(func(a, b):
		if a.has(by) and b.has(by):
			return a[by] < b[by]
		return false
	)
	return item_list

# --- Fish-specific helpers (used by Quest.gd) ---

func count_fish(fish_name := "") -> int:
	if fish_name != "":
		if fish_name in items:
			if _is_stackable(fish_name):
				return items[fish_name]
			else:
				return items[fish_name].size()
		return 0
	# Count all fish
	var total = 0
	for k in items.keys():
		if _get_item_type(k) == "fish":
			if _is_stackable(k):
				total += items[k]
			else:
				total += items[k].size()
	return total

func get_total_weight(fish_name := "") -> float:
	var total = 0.0
	for k in items.keys():
		if _get_item_type(k) != "fish":
			continue
		if fish_name != "" and k != fish_name:
			continue
		if not _is_stackable(k) and items[k] is Array:
			for entry in items[k]:
				if entry is Dictionary and "size" in entry and entry["size"] != null:
					total += float(entry["size"])
	return total

func get_largest_size(fish_name := "") -> float:
	var largest = 0.0
	for k in items.keys():
		if _get_item_type(k) != "fish":
			continue
		if fish_name != "" and k != fish_name:
			continue
		if not _is_stackable(k) and items[k] is Array:
			for entry in items[k]:
				if entry is Dictionary and "size" in entry and entry["size"] != null:
					largest = max(largest, float(entry["size"]))
	return largest

func count_by_rarity(rarity) -> int:
	var count = 0
	for k in items.keys():
		if _get_item_type(k) != "fish":
			continue
		if not _is_stackable(k) and items[k] is Array:
			for entry in items[k]:
				if entry is Dictionary and "rarity" in entry and entry["rarity"] == rarity:
					count += 1
	return count

func remove_fish(fish_name: String, amount := 1):
	remove_item(fish_name, amount)

# --- Debug ---

func print_inventory():
	print("Inventory:")
	for k in items.keys():
		if _is_stackable(k):
			print("- %s x%d" % [k, items[k]])
		else:
			print("- %s x%d (non-stackable)" % [k, items[k].size()])
			for entry in items[k]:
				print("    - %s" % str(entry))
