extends Area2D

signal fireworks_launched

func launch_fireworks():
	fireworks_launched.emit()
	# Spawn bullet patterns or area-of-effect blasts
	queue_free()
