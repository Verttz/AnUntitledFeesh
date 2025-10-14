extends Resource

# Base quest resource for biome progression

export(String) var quest_type
export(String) var biome
export(Array, String) var fish_required
export(bool) var completed = false

func is_complete(fish_collected: Dictionary) -> bool:
	for fish in fish_required:
		if not fish_collected.has(fish) or fish_collected[fish] <= 0:
			return false
	return true
