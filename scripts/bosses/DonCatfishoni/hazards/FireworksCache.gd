extends Area2D

signal fireworks_launched

func launch_fireworks():
	emit_signal("fireworks_launched")
	# Spawn bullet patterns or area-of-effect blasts
	queue_free()
