extends Node

# Handles biome progression, quest flow, bait unlocks, upgrades, and boss transitions

signal biome_unlocked(biome_name)
signal quest_accepted(quest)
signal quest_completed(quest)
signal bait_unlocked(bait_name)
signal upgrade_purchased(upgrade_name)
signal boss_fight_ready(biome_name)
signal boss_defeated(biome_name)
signal biome_transitioned(new_biome)

var current_biome := ""
var unlocked_biomes := []
var unlocked_bait := []
var completed_quests := []
var upgrades := []
var fish_collected := {}
var fish_currency := 0
var available_upgrades := ["Rod1", "Rod2", "Boat", "BaitBag"]

func add_fish_currency(amount: int) -> void:
	fish_currency += amount

func can_purchase(upgrade_name: String, cost: int) -> bool:
	return fish_currency >= cost and not upgrades.has(upgrade_name)

func enter_biome(biome_name):
	current_biome = biome_name
	if not unlocked_biomes.has(biome_name):
		unlocked_biomes.append(biome_name)
		biome_unlocked.emit(biome_name)
	# Accept intro quest for bait unlock
	accept_quest("catch_fish_for_bait", biome_name)

func accept_quest(quest_type, biome_name):
	var quest = {"type": quest_type, "biome": biome_name}
	quest_accepted.emit(quest)

func complete_quest(quest):
	completed_quests.append(quest)
	if quest["type"] == "catch_fish_for_bait":
		unlock_bait(quest["biome"])
	quest_completed.emit(quest)

func unlock_bait(biome_name):
	var bait_name = biome_name + "_bait"
	if not unlocked_bait.has(bait_name):
		unlocked_bait.append(bait_name)
		bait_unlocked.emit(bait_name)

func purchase_upgrade(upgrade_name):
	if not upgrades.has(upgrade_name):
		upgrades.append(upgrade_name)
		upgrade_purchased.emit(upgrade_name)

func collect_fish(fish_name):
	if not fish_collected.has(fish_name):
		fish_collected[fish_name] = 0
	fish_collected[fish_name] += 1

func check_boss_fight_ready():
	# Player must bring 3 fish to transition location
	var fish_count = 0
	for fish in fish_collected.values():
		fish_count += fish
	if fish_count >= 3:
		boss_fight_ready.emit(current_biome)
		return true
	return false

func start_boss_fight():
	# Player chooses one fish to control for boss fight
	# (Selection logic handled elsewhere)
	pass

func on_boss_defeated():
	boss_defeated.emit(current_biome)
	transition_to_next_biome()

func transition_to_next_biome():
	# Move to next biome in order
	var next_biome = get_next_biome()
	if next_biome != "":
		current_biome = next_biome
		biome_transitioned.emit(next_biome)

func get_next_biome():
	# Updated biome order
	var biome_order = ["Forest", "Ocean", "Jungle", "FrozenMountain", "Lava", "FishingSanctum"]
	var idx = biome_order.find(current_biome)
	if idx != -1 and idx < biome_order.size() - 1:
		return biome_order[idx + 1]
	return ""
