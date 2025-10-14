extends Node2D

signal phase_changed(new_phase)
signal attack_started(attack_name)
signal vulnerable()
signal defeated()

export var max_health := 100
var health := 100
var phase := 1
var is_vulnerable := false

func _ready():
	health = max_health
	start_phase(1)

func start_phase(new_phase):
	phase = new_phase
	emit_signal("phase_changed", phase)
	# Override in child for phase-specific logic

func take_damage(amount):
	if is_vulnerable:
		health -= amount
		if health <= 0:
			health = 0
			emit_signal("defeated")
		else:
			check_phase_transition()

func check_phase_transition():
	# Override in child for custom phase logic
	pass

func start_attack(attack_name):
	emit_signal("attack_started", attack_name)
	# Override in child for attack logic

func set_vulnerable(state: bool):
	is_vulnerable = state
	if is_vulnerable:
		emit_signal("vulnerable")
