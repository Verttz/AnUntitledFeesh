extends Node

signal roulette_started
signal roulette_result(result)

var possible_results = ["extra_hazards", "minion_betrayal", "visual_gag"]

func start_roulette():
	emit_signal("roulette_started")
	var result = possible_results[randi() % possible_results.size()]
	yield(get_tree().create_timer(1.0), "timeout")
	emit_signal("roulette_result", result)
	# Implement result logic in boss or arena
