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

func enter_biome(biome_name):
	current_biome = biome_name
	if not unlocked_biomes.has(biome_name):
		unlocked_biomes.append(biome_name)
		emit_signal("biome_unlocked", biome_name)
	# Accept intro quest for bait unlock
	accept_quest("catch_fish_for_bait", biome_name)

func accept_quest(quest_type, biome_name):
	var quest = {"type": quest_type, "biome": biome_name}
	emit_signal("quest_accepted", quest)

func complete_quest(quest):
	completed_quests.append(quest)
	if quest["type"] == "catch_fish_for_bait":
		unlock_bait(quest["biome"])
	emit_signal("quest_completed", quest)

func unlock_bait(biome_name):
	var bait_name = biome_name + "_bait"
	if not unlocked_bait.has(bait_name):
		unlocked_bait.append(bait_name)
		emit_signal("bait_unlocked", bait_name)

func purchase_upgrade(upgrade_name):
	if not upgrades.has(upgrade_name):
		upgrades.append(upgrade_name)
		emit_signal("upgrade_purchased", upgrade_name)

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
		emit_signal("boss_fight_ready", current_biome)
		return true
	return false

func start_boss_fight():
	# Player chooses one fish to control for boss fight
	# (Selection logic handled elsewhere)
	pass

func on_boss_defeated():
	emit_signal("boss_defeated", current_biome)
	transition_to_next_biome()

func transition_to_next_biome():
	# Move to next biome in order
	var next_biome = get_next_biome()
	if next_biome != "":
		current_biome = next_biome
		emit_signal("biome_transitioned", next_biome)

func get_next_biome():
	# Updated biome order
	var biome_order = ["RiverLake", "Ocean", "JungleWetlands", "FrozenMountain", "Lava", "FishingSanctum"]
	var idx = biome_order.find(current_biome)
	if idx != -1 and idx < biome_order.size() - 1:
		return biome_order[idx + 1]
	return ""
