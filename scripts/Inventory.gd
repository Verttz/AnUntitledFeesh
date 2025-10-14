# Inventory.gd
# Handles player inventory logic

extends Node

var items = {} # {item_name: count or array of unique items}
var max_slots = 20
var item_data = load("res://scripts/data/item_data.gd")

func add_item(item_name, amount := 1):
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
				if item_name in items:
					items[item_name].append({})
				else:
					items[item_name] = [{}]
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
