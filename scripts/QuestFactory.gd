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
	Add new quest types here as they are created.
	"""
	register_quest("catch_3_carp", _create_catch_3_carp)
	# Add more quest registrations here as new quests are created
	# register_quest("tutorial_bait_lake", _create_tutorial_bait_lake)
	# register_quest("tutorial_bait_ocean", _create_tutorial_bait_ocean)

static func register_quest(quest_id: String, creation_func: Callable):
	"""
	Register a quest ID with its creation function.
	"""
	quest_registry[quest_id] = creation_func

static func create_quest(quest_id: String) -> Quest:
	"""
	Create a quest instance from its ID.
	Returns null if quest ID is not registered.
	"""
	if quest_id in quest_registry:
		return quest_registry[quest_id].call()
	else:
		push_error("QuestFactory: Unknown quest ID '%s'" % quest_id)
		return null

static func get_all_quest_ids() -> Array:
	"""
	Returns an array of all registered quest IDs.
	"""
	return quest_registry.keys()

# Quest Creation Functions
# Add new quest creation functions here

static func _create_catch_3_carp() -> Quest:
	"""
	Creates the Catch 3 Carp quest.
	"""
	var quest = Quest.new()
	quest.id = "catch_3_carp"
	quest.title = "Carp Collector"
	quest.description = "Catch 3 Carp and show your fishing prowess."
	quest.quest_type = Quest.QuestType.NPC_QUEST
	quest.requirements = [
		{"type": "catch", "item": "Carp", "amount": 3}
	]
	quest.rewards = [
		{"type": "gold", "amount": 50}
	]
	return quest

# Add more quest creation functions below
# Example template:
# static func _create_my_quest() -> Quest:
#     var quest = Quest.new()
#     quest.id = "my_quest_id"
#     quest.title = "My Quest Title"
#     quest.description = "Quest description here"
#     quest.quest_type = Quest.QuestType.NPC_QUEST
#     quest.requirements = [{"type": "catch", "item": "Bass", "amount": 5}]
#     quest.rewards = [{"type": "gold", "amount": 100}]
#     return quest
