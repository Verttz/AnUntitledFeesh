extends Control

# TributeMenu.gd: UI for selecting tribute fish via drag-and-drop

const TributeSlotScene = preload("res://scenes/ui/inventory/TributeSlot.gd")

signal tribute_changed

@export var slot_count := 3
var slots := []

var tribute_fish := [] # Array of fish dicts

func _ready():
	_create_slots()

func _create_slots():
	for i in range(slot_count):
		var slot = TributeSlotScene.new()
		slot.custom_minimum_size = Vector2(120, 60)
		slot.slot_index = i
		slot.fish_dropped.connect(_on_fish_dropped.bind(i))
		add_child(slot)
		slots.append(slot)

func _on_fish_dropped(fish_data, slot_index):
	# Set the fish in the slot and update tribute_fish
	tribute_fish.resize(slot_count)
	tribute_fish[slot_index] = fish_data
	tribute_changed.emit(tribute_fish)

# Helper to get current tribute selection
func get_tribute_fish():
	return tribute_fish.duplicate()

# Helper to clear all slots
func clear_slots():
	for slot in slots:
		slot.clear()
	tribute_fish.clear()
