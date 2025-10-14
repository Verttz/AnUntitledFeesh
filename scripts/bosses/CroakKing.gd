extends "res://scripts/bosses/Boss.gd"

# Croak King

func _ready():
	health = max_health
	start_phase(1)

func start_phase(new_phase):
	phase = new_phase
	emit_signal("phase_changed", phase)
	if phase == 1:
		start_attack("lily_pad_barrage")
	elif phase == 2:
		start_attack("royal_croak")

func check_phase_transition():
	if health <= max_health * 0.5 and phase == 1:
		start_phase(2)

func start_attack(attack_name):
   emit_signal("attack_started", attack_name)
   match attack_name:
	   "lily_pad_barrage":
		   lily_pad_barrage()
	   "royal_croak":
		   royal_croak()
	   "tongue_grab":
		   tongue_grab()
	   "minion_frogs":
		   minion_frogs()

func lily_pad_barrage():
   # Launches lily pads as projectiles/platforms
   var pad_scene = preload("res://scenes/arenas/LilyPad.tscn")
   for i in range(4):
	   var pad = pad_scene.instance()
	   pad.position = position + Vector2(randf_range(-100,100), -50)
	   pad.linear_velocity = Vector2(randf_range(-100,100), 300)
	   get_parent().add_child(pad)

func royal_croak():
   # Emits a shockwave or stuns player
   var player = get_tree().get_root().find_node("Player", true, false)
   if player and (player.position - position).length() < 400:
	   player.stun(1.5)

func tongue_grab():
   # Tries to grab and pull player in
   var player = get_tree().get_root().find_node("Player", true, false)
   if player and (player.position - position).length() < 350:
	   player.pull_to(position)
	   player.take_damage(1)

func minion_frogs():
   # Summons smaller frogs to assist
   var minion_scene = preload("res://scenes/arenas/MinionFrog.tscn")
   for i in range(2):
	   var minion = minion_scene.instance()
	   minion.position = position + Vector2(randf_range(-80,80), randf_range(40,120))
	   get_parent().add_child(minion)

func _on_tongue_grabbed():
	set_vulnerable(true)
	yield(get_tree().create_timer(1.5), "timeout")
	set_vulnerable(false)
