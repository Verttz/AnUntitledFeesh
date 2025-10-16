extends Node

signal negotiation_started
signal negotiation_resolved(success)

func start_negotiation():
	emit_signal("negotiation_started")
	# Pause boss attacks, show prompt for player action

func resolve_negotiation(success):
	emit_signal("negotiation_resolved", success)
	# If success, open damage window or trigger mishap
