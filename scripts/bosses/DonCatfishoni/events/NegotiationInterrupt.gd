extends Node

signal negotiation_started
signal negotiation_resolved(success)

func start_negotiation():
	negotiation_started.emit()
	# Pause boss attacks, show prompt for player action

func resolve_negotiation(success):
	negotiation_resolved.emit(success)
	# If success, open damage window or trigger mishap
