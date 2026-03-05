"""
Example quest definitions to add to QuestFactory.gd

Copy these examples into QuestFactory.gd's _static_init() and add the corresponding
creation functions at the bottom of the file.
"""

# =============================================================================
# LAKE AREA QUESTS
# =============================================================================

# Tutorial Quest
static func _create_tutorial_bait_lake() -> Quest:
	var quest = Quest.new()
	quest.id = "tutorial_bait_lake"
	quest.title = "Local Bait Knowledge"
	quest.description = "Talk to the Bait Selling Woman to learn about the best bait for lake fishing."
	quest.quest_type = Quest.QuestType.NPC_QUEST
	quest.requirements = []  # Just talking to NPC completes it
	quest.rewards = [
		{"type": "gold", "amount": 25},
		{"type": "bait", "bait_type": "worm", "amount": 10}
	]
	quest.can_abandon = false  # Tutorial quests can't be abandoned
	return quest

# NPC Quest
static func _create_catch_5_bluegill() -> Quest:
	var quest = Quest.new()
	quest.id = "catch_5_bluegill"
	quest.title = "Bluegill Bounty"
	quest.description = "A local fisherman wants 5 Bluegill for his restaurant."
	quest.quest_type = Quest.QuestType.NPC_QUEST
	quest.requirements = [
		{"type": "catch", "item": "Bluegill", "amount": 5}
	]
	quest.rewards = [
		{"type": "gold", "amount": 75}
	]
	return quest

# Bounty Board Quest
static func _create_bounty_lake_weight() -> Quest:
	var quest = Quest.new()
	quest.id = "bounty_lake_weight"
	quest.title = "Heavy Catch Challenge"
	quest.description = "Catch fish with a combined weight of 50 lbs from the lake."
	quest.quest_type = Quest.QuestType.BOUNTY_BOARD
	quest.requirements = [
		{"type": "catch_weight", "weight": 50.0}
	]
	quest.rewards = [
		{"type": "gold", "amount": 150},
		{"type": "hint", "text": "The Golden Duck appears at dawn near lily pads. Use bread as bait."}
	]
	return quest

static func _create_bounty_lake_rare() -> Quest:
	var quest = Quest.new()
	quest.id = "bounty_lake_rare"
	quest.title = "Rare Specimens"
	quest.description = "Catch 3 rare or better fish from the lake."
	quest.quest_type = Quest.QuestType.BOUNTY_BOARD
	quest.requirements = [
		{"type": "catch_rarity", "rarity": 2, "amount": 3}  # Rarity 2 = Rare
	]
	quest.rewards = [
		{"type": "gold", "amount": 200},
		{"type": "hint", "text": "The Radioactive Carp only bites during storms. Try using glow worms as bait."}
	]
	return quest

static func _create_bounty_lake_legendary() -> Quest:
	var quest = Quest.new()
	quest.id = "bounty_lake_legendary"
	quest.title = "Legendary Hunt"
	quest.description = "Catch a legendary fish from the lake."
	quest.quest_type = Quest.QuestType.BOUNTY_BOARD
	quest.requirements = [
		{"type": "catch_rarity", "rarity": 3, "amount": 1}  # Rarity 3 = Legendary
	]
	quest.rewards = [
		{"type": "gold", "amount": 500},
		{"type": "hint", "text": "Rubber Boot? Really? They say it's in puddles after rain... good luck."}
	]
	return quest

# =============================================================================
# OCEAN AREA QUESTS
# =============================================================================

static func _create_tutorial_bait_ocean() -> Quest:
	var quest = Quest.new()
	quest.id = "tutorial_bait_ocean"
	quest.title = "Saltwater Secrets"
	quest.description = "Learn about ocean fishing and the best baits for saltwater catches."
	quest.quest_type = Quest.QuestType.NPC_QUEST
	quest.requirements = []
	quest.rewards = [
		{"type": "gold", "amount": 25},
		{"type": "bait", "bait_type": "shrimp", "amount": 10}
	]
	quest.can_abandon = false
	return quest

static func _create_catch_10_clownfish() -> Quest:
	var quest = Quest.new()
	quest.id = "catch_10_clownfish"
	quest.title = "Finding Nemo's Cousins"
	quest.description = "Collect 10 Clownfish for the local aquarium."
	quest.quest_type = Quest.QuestType.NPC_QUEST
	quest.requirements = [
		{"type": "catch", "item": "Clownfish", "amount": 10}
	]
	quest.rewards = [
		{"type": "gold", "amount": 100}
	]
	return quest

static func _create_bounty_ocean_weight() -> Quest:
	var quest = Quest.new()
	quest.id = "bounty_ocean_weight"
	quest.title = "Deep Sea Haul"
	quest.description = "Catch fish with a combined weight of 100 lbs from the ocean."
	quest.quest_type = Quest.QuestType.BOUNTY_BOARD
	quest.requirements = [
		{"type": "catch_weight", "weight": 100.0}
	]
	quest.rewards = [
		{"type": "gold", "amount": 200},
		{"type": "hint", "text": "King Neptune's Beardfish swims in the deepest waters at midnight. Legendary bait required."}
	]
	return quest

# =============================================================================
# TO ADD TO QuestFactory._static_init():
# =============================================================================
"""
register_quest("tutorial_bait_lake", _create_tutorial_bait_lake)
register_quest("catch_5_bluegill", _create_catch_5_bluegill)
register_quest("bounty_lake_weight", _create_bounty_lake_weight)
register_quest("bounty_lake_rare", _create_bounty_lake_rare)
register_quest("bounty_lake_legendary", _create_bounty_lake_legendary)
register_quest("tutorial_bait_ocean", _create_tutorial_bait_ocean)
register_quest("catch_10_clownfish", _create_catch_10_clownfish)
register_quest("bounty_ocean_weight", _create_bounty_ocean_weight)
"""
