extends Node2D

# Ceremony Interaction Logic for Croak King

var ceremony_active := false
var minion := null
var hazard := null
var ceremony_timer := 3.0

func start_ceremony(minion_instance, hazard_instance):
	ceremony_active = true
	minion = minion_instance
	hazard = hazard_instance
	play_fanfare("start")
	# King ribbits, ceremony zone highlighted
	start_timer()

func start_timer():
	yield(get_tree().create_timer(ceremony_timer), "timeout")
	if ceremony_active:
		knight_minion()

func interrupt_by_player():
	if ceremony_active:
		minion.convert()
		play_fanfare("deflated")
		end_ceremony()

func interrupt_by_hazard():
	if ceremony_active:
		minion.convert()
		play_fanfare("deflated")
		end_ceremony()

func knight_minion():
	if ceremony_active:
		minion.empower()
		play_fanfare("success")
		end_ceremony()

func kill_minion():
	if ceremony_active:
		minion.die()
		end_ceremony()

func end_ceremony():
	ceremony_active = false
	# Cleanup, remove hazard, visuals, etc.
	if hazard and is_instance_valid(hazard):
		hazard.queue_free()
	pass

func play_fanfare(type):
	# Play audio cue: "start", "success", or "deflated"
	pass
