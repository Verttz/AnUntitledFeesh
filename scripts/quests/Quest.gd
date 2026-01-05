
extends Resource

"""
Quest.gd
--------
Base quest resource for biome progression and quest tracking.
Defines quest type, biome, required fish, and completion logic.
"""

# --- Quest Properties ---
@export var quest_type: String # e.g., "catch", "deliver", "explore"
@export var biome: String # Biome this quest is associated with
@export var fish_required: Array[String] # List of fish required to complete the quest
@export var completed: bool = false # Completion state

func is_complete(fish_collected: Dictionary) -> bool:
	"""
	Checks if the quest is complete based on the player's collected fish.
	Returns true if all required fish are present in the correct amounts.
	"""
	for fish in fish_required:
		if not fish_collected.has(fish) or fish_collected[fish] <= 0:
			return false
	return true
