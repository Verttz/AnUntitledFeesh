
"""
QuestManager.gd
---------------
Handles quest tracking, activation, and completion for the player.
Manages lists of all quests, active quests, and completed quests. 
Provides methods to add quests, check for completion, and grant rewards.
Supports NPC quests and bounty board challenges with progress tracking.
"""

extends Node

# --- Quest State ---
var quests = [] # Array of all Quest resources
var active_quests = [] # Currently active quests
var completed_quests = [] # Completed quests
var available_quests = [] # Quests available but not yet activated
var player = null # Reference to player node

signal quest_added(quest: Quest)
signal quest_activated(quest: Quest)
signal quest_completed(quest: Quest)
signal quest_abandoned(quest: Quest)
signal quest_progress_updated(quest: Quest)

func _ready():
	"""
	Initializes the quest manager.
	"""
	# Load available quests (could be loaded from data files or created here)
	# For demo, we can add sample quests
	pass

func make_quest_available(quest_id: String):
	"""
	Makes a quest available to the player (shows exclamation mark on NPC).
	Uses QuestFactory to create the quest from its ID.
	"""
	var quest = QuestFactory.create_quest(quest_id)
	if quest and not _has_quest(quest.id):
		available_quests.append(quest)
		quests.append(quest)
		quest_added.emit(quest)

func activate_quest(quest: Quest):
	"""
	Activates an available quest (player accepts it).
	"""
	if quest in available_quests:
		available_quests.erase(quest)
	
	if not quest in active_quests:
		quest.is_active = true
		quest._initialize_progress()
		active_quests.append(quest)
		quest_activated.emit(quest)

func add_quest(quest: Quest):
	"""
	Adds a quest to the quest list and activates it immediately.
	Legacy method - prefer make_quest_available() + activate_quest().
	"""
	if not _has_quest(quest.id):
		quests.append(quest)
		quest.is_active = true
		quest._initialize_progress()
		active_quests.append(quest)
		quest_activated.emit(quest)

func abandon_quest(quest: Quest):
	"""
	Abandons an active quest if it can be abandoned.
	"""
	if not quest.can_abandon:
		push_warning("Cannot abandon quest: %s" % quest.title)
		return
	
	if quest in active_quests:
		quest.is_active = false
		active_quests.erase(quest)
		# Optionally move back to available quests
		if not quest in available_quests:
			available_quests.append(quest)
		quest_abandoned.emit(quest)

func update_quest_progress():
	"""
	Updates progress for all active quests.
	Call this when fish are caught or relevant events occur.
	"""
	if not player:
		return
	
	for quest in active_quests:
		quest.update_progress(player)
		quest_progress_updated.emit(quest)

func check_quests():
	"""
	Checks all active quests for completion. 
	Grants rewards and moves completed quests to completed_quests.
	"""
	if not player:
		return
	
	for quest in active_quests.duplicate(): # Duplicate to avoid modification during iteration
		if quest.check_complete(player):
			quest.grant_rewards(player)
			active_quests.erase(quest)
			completed_quests.append(quest)
			quest_completed.emit(quest)

func can_turn_in_quest(quest: Quest) -> bool:
	"""
	Checks if a quest can be turned in (all requirements met).
	"""
	if not player:
		return false
	return quest.check_complete(player)

func turn_in_quest(quest: Quest):
	"""
	Turns in a completed quest for rewards.
	"""
	if not can_turn_in_quest(quest):
		push_warning("Cannot turn in incomplete quest: %s" % quest.title)
		return
	
	quest.grant_rewards(player)
	active_quests.erase(quest)
	completed_quests.append(quest)
	quest_completed.emit(quest)

func set_player(p):
    """
    Sets the player reference for quest progress and reward handling.
    """
    player = p

func get_active_quests() -> Array:
	"""
	Returns the list of currently active quests.
	"""
	return active_quests

func get_active_npc_quests() -> Array:
	"""
	Returns only active NPC quests (excludes bounty board challenges).
	"""
	return active_quests.filter(func(q): return q.quest_type == Quest.QuestType.NPC_QUEST)

func get_active_bounties() -> Array:
	"""
	Returns only active bounty board challenges.
	"""
	return active_quests.filter(func(q): return q.quest_type == Quest.QuestType.BOUNTY_BOARD)

func get_available_quests() -> Array:
	"""
	Returns quests that are available but not yet activated.
	"""
	return available_quests

func get_completed_quests() -> Array:
	"""
	Returns the list of completed quests.
	"""
	return completed_quests

func is_quest_active(quest_id: String) -> bool:
	"""
	Checks if a quest with the given ID is currently active.
	"""
	for quest in active_quests:
		if quest.id == quest_id:
			return true
	return false

func is_quest_completed(quest_id: String) -> bool:
	"""
	Checks if a quest with the given ID has been completed.
	"""
	for quest in completed_quests:
		if quest.id == quest_id:
			return true
	return false

func get_quest_by_id(quest_id: String) -> Quest:
	"""
	Returns a quest by its ID, or null if not found.
	"""
	for quest in quests:
		if quest.id == quest_id:
			return quest
	return null

func _has_quest(quest_id: String) -> bool:
	"""
	Internal helper to check if a quest ID is already registered.
	"""
	for quest in quests:
		if quest.id == quest_id:
			return true
	return false

func to_dict() -> Dictionary:
	"""
	Serializes the quest manager state to a dictionary for saving.
	Saves active and completed quest IDs with their progress.
	"""
	var data = {
		"active_quests": [],
		"completed_quests": [],
		"available_quests": []
	}
	
	# Save active quests with progress
	for quest in active_quests:
		data["active_quests"].append(quest.to_dict())
	
	# Save completed quests
	for quest in completed_quests:
		data["completed_quests"].append(quest.to_dict())
	
	# Save available quests
	for quest in available_quests:
		data["available_quests"].append(quest.id)
	
	return data

func from_dict(data: Dictionary):
	"""
	Deserializes the quest manager state from a dictionary for loading.
	Reconstructs active and completed quests from saved data using QuestFactory.
	"""
	if typeof(data) != TYPE_DICTIONARY:
		return
	
	# Clear current state
	active_quests.clear()
	completed_quests.clear()
	available_quests.clear()
	quests.clear()
	
	# Restore available quests
	if "available_quests" in data:
		for quest_id in data["available_quests"]:
			make_quest_available(quest_id)
	
	# Restore active quests with progress
	if "active_quests" in data:
		for quest_data in data["active_quests"]:
			if "id" in quest_data:
				var quest = QuestFactory.create_quest(quest_data.id)
				if quest:
					quest.from_dict(quest_data)
					if not quest in quests:
						quests.append(quest)
					active_quests.append(quest)
	
	# Restore completed quests
	if "completed_quests" in data:
		for quest_data in data["completed_quests"]:
			if "id" in quest_data:
				var quest = QuestFactory.create_quest(quest_data.id)
				if quest:
					quest.from_dict(quest_data)
					if not quest in quests:
						quests.append(quest)
					completed_quests.append(quest)


