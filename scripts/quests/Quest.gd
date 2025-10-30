
extends Resource

"""
Quest.gd
--------
Base quest resource for biome progression and quest tracking.
Defines quest type, biome, required fish, and completion logic.
"""

# --- Quest Properties ---
export(String) var quest_type # e.g., "catch", "deliver", "explore"
export(String) var biome # Biome this quest is associated with
export(Array, String) var fish_required # List of fish required to complete the quest
export(bool) var completed = false # Completion state

func is_complete(fish_collected: Dictionary) -> bool:
	"""
	Checks if the quest is complete based on the player's collected fish.
	Returns true if all required fish are present in the correct amounts.
	"""
	for fish in fish_required:
		if not fish_collected.has(fish) or fish_collected[fish] <= 0:
			return false
	return true
