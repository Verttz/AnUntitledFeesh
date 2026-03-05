"""
BountyBoard.gd
--------------
Manages bounty board challenges in each area's shop.
Bounties are fishing challenges that reward hints about rare/legendary fish.
Each area has a limited set of bounties tied to its rare fish.
"""

extends Node

class_name BountyBoard

signal bounty_posted(bounty: Quest)
signal bounty_completed(bounty: Quest)

@export var area_name: String = ""
@export var max_active_bounties: int = 3

var available_bounties: Array = []
var posted_bounties: Array = []
var completed_bounties: Array = []
var quest_manager: Node = null
var total_bounties: int = 0  # Fixed total for accurate percentage

func _ready():
	"""
	Initialize the bounty board for this area.
	"""
	quest_manager = get_node("/root/QuestManager") if has_node("/root/QuestManager") else null

func set_area(area: String):
	"""
	Sets the area and loads appropriate bounties.
	"""
	area_name = area
	_load_area_bounties()

func _load_area_bounties():
	"""
	Loads all available bounties for this area from QuestFactory.
	Bounties are identified by area-specific IDs.
	"""
	available_bounties.clear()
	
	# Get all bounty IDs for this area
	var bounty_ids = _get_bounty_ids_for_area(area_name)
	
	for bounty_id in bounty_ids:
		var bounty = QuestFactory.create_quest(bounty_id)
		if bounty and bounty.quest_type == Quest.QuestType.BOUNTY_BOARD:
			available_bounties.append(bounty)
	
	# Post initial bounties
	total_bounties = available_bounties.size()
	_post_bounties()

func _get_bounty_ids_for_area(area: String) -> Array:
	"""
	Returns bounty quest IDs for a specific area.
	These should be registered in QuestFactory.
	"""
	var bounty_map = {
		"Forest": ["bounty_forest_weight", "bounty_forest_rare", "bounty_forest_legendary"],
		"Ocean": ["bounty_ocean_weight", "bounty_ocean_rare", "bounty_ocean_legendary"],
		"Jungle": ["bounty_jungle_weight", "bounty_jungle_rare", "bounty_jungle_legendary"],
		"FrozenMountain": ["bounty_frozenmountain_weight", "bounty_frozenmountain_rare", "bounty_frozenmountain_legendary"],
		"Lava": ["bounty_lava_weight", "bounty_lava_rare", "bounty_lava_legendary"]
	}
	
	return bounty_map.get(area, [])

func _post_bounties():
	"""
	Posts bounties to the board up to max_active_bounties.
	"""
	while posted_bounties.size() < max_active_bounties and not available_bounties.is_empty():
		var bounty = available_bounties.pop_front()
		posted_bounties.append(bounty)
		bounty_posted.emit(bounty)

func get_posted_bounties() -> Array:
	"""
	Returns all currently posted bounties.
	"""
	return posted_bounties

func accept_bounty(bounty: Quest):
	"""
	Player accepts a bounty from the board.
	Adds it to QuestManager as an active quest.
	"""
	if not bounty in posted_bounties:
		push_warning("Bounty not on board: %s" % bounty.title)
		return
	
	if quest_manager:
		quest_manager.activate_quest(bounty)
		# Keep bounty posted so others can see it, but mark as taken
		# Or remove from board if you want exclusive bounties:
		# posted_bounties.erase(bounty)

func complete_bounty(bounty: Quest):
	"""
	Marks a bounty as completed and posts a new one if available.
	"""
	if bounty in posted_bounties:
		posted_bounties.erase(bounty)
	
	if not bounty in completed_bounties:
		completed_bounties.append(bounty)
	
	bounty_completed.emit(bounty)
	
	# Post next bounty if available
	_post_bounties()

func is_bounty_completed(bounty_id: String) -> bool:
	"""
	Checks if a bounty has been completed.
	"""
	for bounty in completed_bounties:
		if bounty.id == bounty_id:
			return true
	return false

func get_completion_percentage() -> float:
	if total_bounties == 0:
		return 0.0
	return float(completed_bounties.size()) / float(total_bounties)

func get_hints_unlocked() -> Array:
	"""
	Returns all hints unlocked from completed bounties.
	"""
	var hints = []
	for bounty in completed_bounties:
		for reward in bounty.rewards:
			if reward.type == "hint":
				hints.append(reward.text)
	return hints

func to_dict() -> Dictionary:
	"""
	Serializes bounty board state for saving.
	"""
	return {
		"area_name": area_name,
		"completed_bounties": completed_bounties.map(func(b): return b.id),
		"posted_bounties": posted_bounties.map(func(b): return b.id)
	}

func from_dict(data: Dictionary):
	"""
	Deserializes bounty board state from saved data.
	"""
	if "area_name" in data:
		area_name = data.area_name
	
	_load_area_bounties()
	
	# Mark completed bounties
	if "completed_bounties" in data:
		for bounty_id in data.completed_bounties:
			for bounty in available_bounties:
				if bounty.id == bounty_id:
					available_bounties.erase(bounty)
					completed_bounties.append(bounty)
			for bounty in posted_bounties:
				if bounty.id == bounty_id:
					posted_bounties.erase(bounty)
					completed_bounties.append(bounty)
