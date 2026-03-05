"""
QuestFactory.gd
---------------
Factory class for creating quest instances from quest IDs.
Handles quest recreation for save/load system and quest registration.
"""

extends Node

class_name QuestFactory

# Registry of all available quests by ID
static var quest_registry = {}

static func _static_init():
	"""
	Initialize the quest registry with all available quests.
	"""
	# --- NPC Quests ---
	register_quest("catch_3_carp", _create_catch_3_carp)
	register_quest("catch_5_bluegill", _create_catch_5_bluegill)
	register_quest("catch_trout_and_bass", _create_catch_trout_and_bass)
	register_quest("ocean_tuna_run", _create_ocean_tuna_run)
	register_quest("jungle_piranha_hunt", _create_jungle_piranha_hunt)
	register_quest("frozen_char_challenge", _create_frozen_char_challenge)
	register_quest("lava_magma_carp", _create_lava_magma_carp)

	# --- Forest Bounties ---
	register_quest("bounty_forest_weight", _create_bounty_forest_weight)
	register_quest("bounty_forest_rare", _create_bounty_forest_rare)
	register_quest("bounty_forest_legendary", _create_bounty_forest_legendary)

	# --- Ocean Bounties ---
	register_quest("bounty_ocean_weight", _create_bounty_ocean_weight)
	register_quest("bounty_ocean_rare", _create_bounty_ocean_rare)
	register_quest("bounty_ocean_legendary", _create_bounty_ocean_legendary)

	# --- Jungle Bounties ---
	register_quest("bounty_jungle_weight", _create_bounty_jungle_weight)
	register_quest("bounty_jungle_rare", _create_bounty_jungle_rare)
	register_quest("bounty_jungle_legendary", _create_bounty_jungle_legendary)

	# --- Frozen Mountain Bounties ---
	register_quest("bounty_frozenmountain_weight", _create_bounty_frozenmountain_weight)
	register_quest("bounty_frozenmountain_rare", _create_bounty_frozenmountain_rare)
	register_quest("bounty_frozenmountain_legendary", _create_bounty_frozenmountain_legendary)

	# --- Lava Bounties ---
	register_quest("bounty_lava_weight", _create_bounty_lava_weight)
	register_quest("bounty_lava_rare", _create_bounty_lava_rare)
	register_quest("bounty_lava_legendary", _create_bounty_lava_legendary)

static func register_quest(quest_id: String, creation_func: Callable):
	quest_registry[quest_id] = creation_func

static func create_quest(quest_id: String) -> Quest:
	if quest_id in quest_registry:
		return quest_registry[quest_id].call()
	else:
		push_error("QuestFactory: Unknown quest ID '%s'" % quest_id)
		return null

static func get_all_quest_ids() -> Array:
	return quest_registry.keys()


# =============================================================================
# NPC Quest Creators
# =============================================================================

static func _create_catch_3_carp() -> Quest:
	var quest = Quest.new()
	quest.id = "catch_3_carp"
	quest.title = "Carp Collector"
	quest.description = "Catch 3 Carp and show your fishing prowess."
	quest.quest_type = Quest.QuestType.NPC_QUEST
	quest.requirements = [{"type": "catch", "item": "Carp", "amount": 3}]
	quest.rewards = [{"type": "gold", "amount": 50}]
	return quest

static func _create_catch_5_bluegill() -> Quest:
	var quest = Quest.new()
	quest.id = "catch_5_bluegill"
	quest.title = "Bluegill Bonanza"
	quest.description = "The lake is teeming with Bluegill. Catch 5 of them!"
	quest.quest_type = Quest.QuestType.NPC_QUEST
	quest.requirements = [{"type": "catch", "item": "Bluegill", "amount": 5}]
	quest.rewards = [{"type": "gold", "amount": 30}]
	return quest

static func _create_catch_trout_and_bass() -> Quest:
	var quest = Quest.new()
	quest.id = "catch_trout_and_bass"
	quest.title = "River vs. Lake"
	quest.description = "Catch a Trout from the river and a Largemouth Bass from the lake."
	quest.quest_type = Quest.QuestType.NPC_QUEST
	quest.requirements = [
		{"type": "catch", "item": "Trout", "amount": 1},
		{"type": "catch", "item": "Largemouth Bass", "amount": 1}
	]
	quest.rewards = [{"type": "gold", "amount": 75}, {"type": "bait", "bait_type": "Minnow Bait", "amount": 5}]
	return quest

static func _create_ocean_tuna_run() -> Quest:
	var quest = Quest.new()
	quest.id = "ocean_tuna_run"
	quest.title = "Tuna Run"
	quest.description = "The Tuna are running! Catch 3 before they move on."
	quest.quest_type = Quest.QuestType.NPC_QUEST
	quest.requirements = [{"type": "catch", "item": "Tuna", "amount": 3}]
	quest.rewards = [{"type": "gold", "amount": 100}]
	return quest

static func _create_jungle_piranha_hunt() -> Quest:
	var quest = Quest.new()
	quest.id = "jungle_piranha_hunt"
	quest.title = "Piranha Problem"
	quest.description = "The piranhas are getting aggressive. Catch 4 to thin the population."
	quest.quest_type = Quest.QuestType.NPC_QUEST
	quest.requirements = [{"type": "catch", "item": "Piranha", "amount": 4}]
	quest.rewards = [{"type": "gold", "amount": 80}, {"type": "hint", "text": "Rainbow Dartfish only appear in jungle streams at dawn."}]
	return quest

static func _create_frozen_char_challenge() -> Quest:
	var quest = Quest.new()
	quest.id = "frozen_char_challenge"
	quest.title = "Arctic Char Challenge"
	quest.description = "The mountain guides need proof you can fish in the cold. Catch 3 Arctic Char."
	quest.quest_type = Quest.QuestType.NPC_QUEST
	quest.requirements = [{"type": "catch", "item": "Arctic Char", "amount": 3}]
	quest.rewards = [{"type": "gold", "amount": 90}, {"type": "bait", "bait_type": "Ice Worm Bait", "amount": 3}]
	return quest

static func _create_lava_magma_carp() -> Quest:
	var quest = Quest.new()
	quest.id = "lava_magma_carp"
	quest.title = "Magma Fishing 101"
	quest.description = "Catch 3 Magma Carp to prove you can handle the heat."
	quest.quest_type = Quest.QuestType.NPC_QUEST
	quest.requirements = [{"type": "catch", "item": "Magma Carp", "amount": 3}]
	quest.rewards = [{"type": "gold", "amount": 100}, {"type": "bait", "bait_type": "Fire Worm Bait", "amount": 3}]
	return quest


# =============================================================================
# Forest Bounty Creators
# =============================================================================

static func _create_bounty_forest_weight() -> Quest:
	var quest = Quest.new()
	quest.id = "bounty_forest_weight"
	quest.title = "Forest Haul"
	quest.description = "Catch a combined 15 lbs of fish from the Forest."
	quest.quest_type = Quest.QuestType.BOUNTY_BOARD
	quest.requirements = [{"type": "catch_weight", "weight": 15.0}]
	quest.rewards = [{"type": "gold", "amount": 75}, {"type": "hint", "text": "The Golden Duck only bites on bread bait in the lake."}]
	quest.can_abandon = true
	return quest

static func _create_bounty_forest_rare() -> Quest:
	var quest = Quest.new()
	quest.id = "bounty_forest_rare"
	quest.title = "Forest Trophy"
	quest.description = "Catch a Salmon or Muskellunge from the deep Forest waters."
	quest.quest_type = Quest.QuestType.BOUNTY_BOARD
	quest.requirements = [{"type": "catch_rarity", "rarity": 2, "amount": 1}]
	quest.rewards = [{"type": "gold", "amount": 120}, {"type": "hint", "text": "Ghost Fish haunt the river at night — use Mystery Bait."}]
	quest.can_abandon = true
	return quest

static func _create_bounty_forest_legendary() -> Quest:
	var quest = Quest.new()
	quest.id = "bounty_forest_legendary"
	quest.title = "Forest Legend"
	quest.description = "Catch any Legendary fish from the Forest. Only the best can manage this."
	quest.quest_type = Quest.QuestType.BOUNTY_BOARD
	quest.requirements = [{"type": "catch_rarity", "rarity": 3, "amount": 1}]
	quest.rewards = [{"type": "gold", "amount": 250}, {"type": "hint", "text": "The Radioactive Carp glows at the bottom of the lake — use Glow Worm Bait."}]
	quest.can_abandon = true
	return quest


# =============================================================================
# Ocean Bounty Creators
# =============================================================================

static func _create_bounty_ocean_weight() -> Quest:
	var quest = Quest.new()
	quest.id = "bounty_ocean_weight"
	quest.title = "Ocean Haul"
	quest.description = "Catch a combined 20 lbs of fish from the Ocean."
	quest.quest_type = Quest.QuestType.BOUNTY_BOARD
	quest.requirements = [{"type": "catch_weight", "weight": 20.0}]
	quest.rewards = [{"type": "gold", "amount": 100}, {"type": "hint", "text": "Treasure Chestfish lurk in shipwrecks — try Gold Coin bait."}]
	quest.can_abandon = true
	return quest

static func _create_bounty_ocean_rare() -> Quest:
	var quest = Quest.new()
	quest.id = "bounty_ocean_rare"
	quest.title = "Ocean Trophy"
	quest.description = "Catch a Marlin, Swordfish, or Octopus from the deep Ocean."
	quest.quest_type = Quest.QuestType.BOUNTY_BOARD
	quest.requirements = [{"type": "catch_rarity", "rarity": 2, "amount": 1}]
	quest.rewards = [{"type": "gold", "amount": 150}, {"type": "hint", "text": "King Neptune's Beardfish only bites on Legendary Bait in the kelp forest."}]
	quest.can_abandon = true
	return quest

static func _create_bounty_ocean_legendary() -> Quest:
	var quest = Quest.new()
	quest.id = "bounty_ocean_legendary"
	quest.title = "Ocean Legend"
	quest.description = "Catch any Legendary fish from the Ocean. Prepare for a real fight."
	quest.quest_type = Quest.QuestType.BOUNTY_BOARD
	quest.requirements = [{"type": "catch_rarity", "rarity": 3, "amount": 1}]
	quest.rewards = [{"type": "gold", "amount": 300}, {"type": "hint", "text": "The Angry Hermit Crab Shell in the tidepool needs no bait — just skill."}]
	quest.can_abandon = true
	return quest


# =============================================================================
# Jungle Bounty Creators
# =============================================================================

static func _create_bounty_jungle_weight() -> Quest:
	var quest = Quest.new()
	quest.id = "bounty_jungle_weight"
	quest.title = "Jungle Haul"
	quest.description = "Catch a combined 18 lbs of fish from the Jungle."
	quest.quest_type = Quest.QuestType.BOUNTY_BOARD
	quest.requirements = [{"type": "catch_weight", "weight": 18.0}]
	quest.rewards = [{"type": "gold", "amount": 90}, {"type": "hint", "text": "Rainbow Dartfish only show in jungle streams — use Fruit bait."}]
	quest.can_abandon = true
	return quest

static func _create_bounty_jungle_rare() -> Quest:
	var quest = Quest.new()
	quest.id = "bounty_jungle_rare"
	quest.title = "Jungle Trophy"
	quest.description = "Catch an Arapaima, Peacock Bass, or Frogfish from the Jungle."
	quest.quest_type = Quest.QuestType.BOUNTY_BOARD
	quest.requirements = [{"type": "catch_rarity", "rarity": 2, "amount": 1}]
	quest.rewards = [{"type": "gold", "amount": 130}, {"type": "hint", "text": "The Banana Eater hides among floating plants — only Banana bait works."}]
	quest.can_abandon = true
	return quest

static func _create_bounty_jungle_legendary() -> Quest:
	var quest = Quest.new()
	quest.id = "bounty_jungle_legendary"
	quest.title = "Jungle Legend"
	quest.description = "Catch any Legendary fish from the Jungle."
	quest.quest_type = Quest.QuestType.BOUNTY_BOARD
	quest.requirements = [{"type": "catch_rarity", "rarity": 3, "amount": 1}]
	quest.rewards = [{"type": "gold", "amount": 275}, {"type": "hint", "text": "The Amazonian Starfish floats among the floating plants at twilight."}]
	quest.can_abandon = true
	return quest


# =============================================================================
# Frozen Mountain Bounty Creators
# =============================================================================

static func _create_bounty_frozenmountain_weight() -> Quest:
	var quest = Quest.new()
	quest.id = "bounty_frozenmountain_weight"
	quest.title = "Mountain Haul"
	quest.description = "Catch a combined 15 lbs of fish from the Frozen Mountain."
	quest.quest_type = Quest.QuestType.BOUNTY_BOARD
	quest.requirements = [{"type": "catch_weight", "weight": 15.0}]
	quest.rewards = [{"type": "gold", "amount": 100}, {"type": "hint", "text": "Ice Cave fish are the rarest — bring Ice Shrimp or Ice Worm bait."}]
	quest.can_abandon = true
	return quest

static func _create_bounty_frozenmountain_rare() -> Quest:
	var quest = Quest.new()
	quest.id = "bounty_frozenmountain_rare"
	quest.title = "Mountain Trophy"
	quest.description = "Catch a Frostfin Pike, Glacier Salmon, or Frostbite Eel."
	quest.quest_type = Quest.QuestType.BOUNTY_BOARD
	quest.requirements = [{"type": "catch_rarity", "rarity": 2, "amount": 1}]
	quest.rewards = [{"type": "gold", "amount": 150}, {"type": "hint", "text": "The Yeti Fish dwells deep in the ice cave — Mystery Bait is the only way."}]
	quest.can_abandon = true
	return quest

static func _create_bounty_frozenmountain_legendary() -> Quest:
	var quest = Quest.new()
	quest.id = "bounty_frozenmountain_legendary"
	quest.title = "Mountain Legend"
	quest.description = "Catch any Legendary fish from the Frozen Mountain."
	quest.quest_type = Quest.QuestType.BOUNTY_BOARD
	quest.requirements = [{"type": "catch_rarity", "rarity": 3, "amount": 1}]
	quest.rewards = [{"type": "gold", "amount": 300}, {"type": "hint", "text": "Penguinfish flip around the ice cave entrance — use Mystery Bait at night."}]
	quest.can_abandon = true
	return quest


# =============================================================================
# Lava Bounty Creators
# =============================================================================

static func _create_bounty_lava_weight() -> Quest:
	var quest = Quest.new()
	quest.id = "bounty_lava_weight"
	quest.title = "Lava Haul"
	quest.description = "Catch a combined 20 lbs of fish from the Lava biome."
	quest.quest_type = Quest.QuestType.BOUNTY_BOARD
	quest.requirements = [{"type": "catch_weight", "weight": 20.0}]
	quest.rewards = [{"type": "gold", "amount": 120}, {"type": "hint", "text": "The Phoenix Fish only appears during volcanic eruptions — watch the sky."}]
	quest.can_abandon = true
	return quest

static func _create_bounty_lava_rare() -> Quest:
	var quest = Quest.new()
	quest.id = "bounty_lava_rare"
	quest.title = "Lava Trophy"
	quest.description = "Catch a rare fish from the Lava biome's volcanic waters."
	quest.quest_type = Quest.QuestType.BOUNTY_BOARD
	quest.requirements = [{"type": "catch_rarity", "rarity": 2, "amount": 1}]
	quest.rewards = [{"type": "gold", "amount": 160}, {"type": "hint", "text": "Obsidian Swordfish circle the caldera — use Lava Minnow Bait."}]
	quest.can_abandon = true
	return quest

static func _create_bounty_lava_legendary() -> Quest:
	var quest = Quest.new()
	quest.id = "bounty_lava_legendary"
	quest.title = "Lava Legend"
	quest.description = "Catch any Legendary fish from the Lava biome. Only fire-proof anglers need apply."
	quest.quest_type = Quest.QuestType.BOUNTY_BOARD
	quest.requirements = [{"type": "catch_rarity", "rarity": 3, "amount": 1}]
	quest.rewards = [{"type": "gold", "amount": 350}, {"type": "hint", "text": "The Magma Dragon Fish sleeps in the deepest magma vent — Legendary Bait only."}]
	quest.can_abandon = true
	return quest
