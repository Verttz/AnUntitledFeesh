extends Area2D

signal crate_broken

var loot_type = "coin"
var is_explosive = false

func break_crate():
	emit_signal("crate_broken")
	if is_explosive:
		# Spawn explosion effect and damage nearby entities
		pass
	else:
		# Drop loot
		pass
	queue_free()
