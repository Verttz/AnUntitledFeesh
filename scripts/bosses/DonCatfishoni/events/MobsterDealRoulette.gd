extends Node

signal roulette_started
signal roulette_result(result)

var possible_results = ["extra_hazards", "minion_betrayal", "visual_gag"]

func start_roulette():
	roulette_started.emit()
	var result = possible_results[randi() % possible_results.size()]
	await get_tree().create_timer(1.0).timeout
	roulette_result.emit(result)
	# Implement result logic in boss or arena
