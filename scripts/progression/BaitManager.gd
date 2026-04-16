extends Node

# BaitManager.gd — Thin facade delegating to ProgressionManager.

signal bait_unlocked(bait_name)

var unlocked_bait: Array:
	get:
		var pm = get_node_or_null("/root/ProgressionManager")
		return pm.unlocked_bait if pm else []
	set(v):
		var pm = get_node_or_null("/root/ProgressionManager")
		if pm: pm.unlocked_bait = v

func unlock_bait(bait_name):
	var pm = get_node_or_null("/root/ProgressionManager")
	if pm:
		pm.unlock_bait(bait_name)
	bait_unlocked.emit(bait_name)

func has_bait(bait_name):
	return unlocked_bait.has(bait_name)
