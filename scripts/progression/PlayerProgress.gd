extends Node

# PlayerProgress.gd — Thin facade that delegates to ProgressionManager.
# Kept for backward compatibility. All state lives in ProgressionManager.

func _get_pm():
	return get_node_or_null("/root/ProgressionManager")

var current_biome: String:
	get: return _get_pm().current_biome if _get_pm() else "Forest"
	set(v):
		if _get_pm(): _get_pm().current_biome = v

var unlocked_bait: Array:
	get: return _get_pm().unlocked_bait if _get_pm() else []
	set(v):
		if _get_pm(): _get_pm().unlocked_bait = v

var completed_quests: Array:
	get: return _get_pm().completed_quests if _get_pm() else []
	set(v):
		if _get_pm(): _get_pm().completed_quests = v

var upgrades: Array:
	get: return _get_pm().upgrades if _get_pm() else []
	set(v):
		if _get_pm(): _get_pm().upgrades = v

var fish_collected: Dictionary:
	get: return _get_pm().fish_collected if _get_pm() else {}
	set(v):
		if _get_pm(): _get_pm().fish_collected = v

func reset_progress():
	if _get_pm():
		_get_pm().current_biome = "Forest"
		_get_pm().unlocked_bait.clear()
		_get_pm().completed_quests.clear()
		_get_pm().upgrades.clear()
		_get_pm().fish_collected.clear()

func save_progress():
	if has_node("/root/SaveManager"):
		get_node("/root/SaveManager").save_game()

func load_progress():
	if has_node("/root/SaveManager"):
		get_node("/root/SaveManager").load_game()

func to_dict() -> Dictionary:
	var pm = _get_pm()
	if not pm:
		return {}
	return {
		"current_biome": pm.current_biome,
		"unlocked_bait": pm.unlocked_bait.duplicate(),
		"completed_quests": pm.completed_quests.duplicate(),
		"upgrades": pm.upgrades.duplicate(),
		"fish_collected": pm.fish_collected.duplicate()
	}

func from_dict(data: Dictionary):
	var pm = _get_pm()
	if not pm or typeof(data) != TYPE_DICTIONARY:
		return
	if "current_biome" in data: pm.current_biome = data["current_biome"]
	if "unlocked_bait" in data: pm.unlocked_bait = data["unlocked_bait"].duplicate()
	if "completed_quests" in data: pm.completed_quests = data["completed_quests"].duplicate()
	if "upgrades" in data: pm.upgrades = data["upgrades"].duplicate()
	if "fish_collected" in data: pm.fish_collected = data["fish_collected"].duplicate()

