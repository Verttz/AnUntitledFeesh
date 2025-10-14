extends "res://scripts/bosses/Boss.gd"

# Magma Chef

func _ready():
	health = max_health
	start_phase(1)

func start_phase(new_phase):
	phase = new_phase
	emit_signal("phase_changed", phase)
	if phase == 1:
		start_attack("boiling_broth")
	elif phase == 2:
		start_attack("spicy_meatball")

func check_phase_transition():
	if health <= max_health * 0.5 and phase == 1:
		start_phase(2)

func start_attack(attack_name):
	emit_signal("attack_started", attack_name)
	# Placeholder for attack logic

func _on_pot_lid_opened():
	set_vulnerable(true)
	yield(get_tree().create_timer(1.5), "timeout")
	set_vulnerable(false)
