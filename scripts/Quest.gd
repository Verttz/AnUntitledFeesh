"""
Quest.gd
--------
Data structure for a single quest.
Supports NPC quests and bounty board challenges with progress tracking.
"""

extends Resource

class_name Quest

enum QuestType {
	NPC_QUEST,      # Traditional quest from NPCs
	BOUNTY_BOARD    # Bounty board challenge
}

@export var id: String = ""
@export var title: String = ""
@export var description: String = ""
@export var quest_type: QuestType = QuestType.NPC_QUEST
@export var requirements: Array = [] # e.g. [{"type": "catch", "item": "Carp", "amount": 3}]
@export var rewards: Array = [] # e.g. [{"type": "gold", "amount": 50}, {"type": "hint", "text": "Try fishing at dawn"}]
@export var is_completed: bool = false
@export var is_active: bool = false
@export var can_abandon: bool = true

# Progress tracking
var progress: Dictionary = {}

func _init():
	"""
	Initialize progress tracking for all requirements.
	"""
	_initialize_progress()

func _initialize_progress():
	"""
	Sets up progress dictionary for tracking requirement completion.
	"""
	progress.clear()
	for i in range(requirements.size()):
		var req = requirements[i]
		match req.type:
			"catch":
				progress[i] = {"current": 0, "target": req.get("amount", 1)}
			"catch_weight":
				progress[i] = {"current": 0.0, "target": req.get("weight", 10.0)}
			"catch_size":
				progress[i] = {"current": 0.0, "target": req.get("size", 10.0)}
			"catch_rarity":
				progress[i] = {"current": 0, "target": req.get("amount", 1)}

func update_progress(player):
	"""
	Updates quest progress based on current player state.
	Call this when fish are caught or relevant events occur.
	"""
	if is_completed:
		return
	
	for i in range(requirements.size()):
		var req = requirements[i]
		match req.type:
			"catch":
				# Count how many of the required fish the player has
				if player.backpack.has_method("count_fish"):
					var count = player.backpack.count_fish(req.item)
					progress[i].current = min(count, progress[i].target)
			"catch_weight":
				# Track cumulative weight of caught fish
				if player.backpack.has_method("get_total_weight"):
					var weight = player.backpack.get_total_weight(req.get("item", ""))
					progress[i].current = min(weight, progress[i].target)
			"catch_size":
				# Track largest fish caught
				if player.backpack.has_method("get_largest_size"):
					var size = player.backpack.get_largest_size(req.get("item", ""))
					progress[i].current = min(size, progress[i].target)
			"catch_rarity":
				# Count fish of specific rarity
				if player.backpack.has_method("count_by_rarity"):
					var count = player.backpack.count_by_rarity(req.get("rarity", 2))
					progress[i].current = min(count, progress[i].target)

func get_progress_string(requirement_index: int = 0) -> String:
	"""
	Returns a formatted string showing progress for a specific requirement.
	Example: "2/3" or "5.5/10 lbs"
	"""
	if requirement_index >= requirements.size():
		return ""
	
	if requirement_index not in progress:
		return "0/?"
	
	var prog = progress[requirement_index]
	var req = requirements[requirement_index]
	
	match req.type:
		"catch":
			return "%d/%d" % [prog.current, prog.target]
		"catch_weight":
			return "%.1f/%.1f lbs" % [prog.current, prog.target]
		"catch_size":
			return "%.1f/%.1f inches" % [prog.current, prog.target]
		"catch_rarity":
			return "%d/%d" % [prog.current, prog.target]
	
	return ""

func get_overall_progress_percent() -> float:
	"""
	Returns overall quest completion as a percentage (0.0 to 1.0).
	"""
	if requirements.is_empty():
		return 1.0
	
	var total_progress = 0.0
	for i in range(requirements.size()):
		if i in progress:
			var prog = progress[i]
			if prog.target > 0:
				total_progress += float(prog.current) / float(prog.target)
	
	return total_progress / float(requirements.size())

func check_complete(player) -> bool:
	"""
	Checks if all requirements are met.
	Updates progress before checking.
	"""
	if is_completed:
		return true
	
	update_progress(player)
	
	for i in range(requirements.size()):
		if i not in progress:
			return false
		var prog = progress[i]
		if prog.current < prog.target:
			return false
	
	return true

func grant_rewards(player):
	"""
	Grants all quest rewards to the player.
	Removes quest fish from inventory if they were turned in.
	"""
	for reward in rewards:
		match reward.type:
			"gold":
				player.add_gold(reward.amount)
			"item":
				player.backpack.add_item(reward.item, reward.amount)
			"hint":
				# Display hint to player (could use HUD or notification system)
				if player.has_method("show_hint"):
					player.show_hint(reward.text)
				print("Hint: ", reward.text)
			"bait":
				player.backpack.add_item(reward.bait_type, reward.amount)
	
	# Remove quest fish from inventory
	for req in requirements:
		if req.type == "catch":
			if player.backpack.has_method("remove_fish"):
				player.backpack.remove_fish(req.item, req.amount)
	
	is_completed = true
	is_active = false

func to_dict() -> Dictionary:
	"""
	Serializes quest state for saving.
	"""
	return {
		"id": id,
		"is_completed": is_completed,
		"is_active": is_active,
		"progress": progress
	}

func from_dict(data: Dictionary):
	"""
	Deserializes quest state from saved data.
	"""
	if "is_completed" in data:
		is_completed = data.is_completed
	if "is_active" in data:
		is_active = data.is_active
	if "progress" in data:
		progress = data.progress

