extends "res://scripts/bosses/Boss.gd"

# Guppazuma the Idol King

func _ready():
	health = max_health
	start_phase(1)

func start_phase(new_phase):
	phase = new_phase
	emit_signal("phase_changed", phase)
	if phase == 1:
		start_attack("stone_piranha_swarm")
	elif phase == 2:
		start_attack("talent_show")

func check_phase_transition():
	if health <= max_health * 0.5 and phase == 1:
		start_phase(2)

func start_attack(attack_name):
   emit_signal("attack_started", attack_name)
   match attack_name:
	   "stone_piranha_swarm":
		   stone_piranha_swarm()
	   "talent_show":
		   talent_show()
	   "idol_fans":
		   idol_fans()
	   "spotlight":
		   spotlight()

func stone_piranha_swarm():
   # Summons or throws stone piranhas
   var piranha_scene = preload("res://scenes/arenas/StonePiranha.tscn")
   for i in range(5):
	   var piranha = piranha_scene.instance()
	   piranha.position = position + Vector2(randf_range(-100,100), -50)
	   piranha.linear_velocity = Vector2(randf_range(-150,150), 350)
	   get_parent().add_child(piranha)

func talent_show():
   # Performs a move that requires the player to “judge” or react
   var player = get_tree().get_root().find_node("Player", true, false)
   if player:
	   # Simulate a quick time event (QTE)
	   player.show_qte("applause")

func idol_fans():
   # Summons minion fans that buff or shield the boss
   var fan_scene = preload("res://scenes/arenas/IdolFan.tscn")
   for i in range(3):
	   var fan = fan_scene.instance()
	   fan.position = position + Vector2(randf_range(-120,120), randf_range(60,160))
	   get_parent().add_child(fan)

func spotlight():
   # Moves to different stage spots, changing attack patterns
   var stage_spots = [Vector2(200,200), Vector2(400,200), Vector2(600,200)]
   position = stage_spots[randi() % stage_spots.size()]

func _on_stunned():
	set_vulnerable(true)
	yield(get_tree().create_timer(2.0), "timeout")
	set_vulnerable(false)
