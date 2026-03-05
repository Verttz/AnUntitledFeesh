extends Node

signal lockdown_started
signal lockdown_ended

func start_lockdown():
	lockdown_started.emit()
	# Implement stall closing, barrier spawning, and hazard escalation here

func end_lockdown():
	lockdown_ended.emit()
	# Implement stall opening and barrier removal here
