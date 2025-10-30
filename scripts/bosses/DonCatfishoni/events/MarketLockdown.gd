extends Node

signal lockdown_started
signal lockdown_ended

func start_lockdown():
	emit_signal("lockdown_started")
	# Implement stall closing, barrier spawning, and hazard escalation here

func end_lockdown():
	emit_signal("lockdown_ended")
	# Implement stall opening and barrier removal here
