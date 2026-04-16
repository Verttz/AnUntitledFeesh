extends "res://scripts/bosses/Boss.gd"


# Captain Pinchbeard – Pirate Crab Boss (Ferry Arena)

var parrotfish_active = false
var ferry_crew_help_timer = null
var pinchbeard_greedy = false
var lifeboat_escape = false

signal cannonball_fired
signal parrotfish_called
signal treasure_tossed
signal ferry_crew_helped
signal pinchbeard_stunned
signal lifeboat_escape_started
signal pinchbeard_defeated


var _attack_queue := []
var _attack_index := 0
var _rotation_timer: Timer = null

func _ready():
	max_health = 35000
	health = max_health
	setup_ferry_arena()
	start_phase(1)

func setup_ferry_arena():
	# Initialize ferry deck, railings, and visual elements
	# ...setup benches, life preservers, background visuals
	pass


func start_phase(new_phase):
	phase = new_phase
	phase_changed.emit(phase)
	if _rotation_timer:
		_rotation_timer.stop()
		_rotation_timer.queue_free()
		_rotation_timer = null
	if phase == 1:
		_attack_queue = ["cannonball_salvo", "pinch_and_plunder", "parrotfish_call", "treasure_toss"]
		_attack_index = 0
		_start_rotation(3.5)
		start_ferry_crew_help_timer()
	elif phase == 2:
		_attack_queue = ["cannonball_salvo", "pinch_and_plunder", "parrotfish_call", "treasure_toss", "pirate_crew"]
		_attack_index = 0
		_start_rotation(2.5)
		start_lifeboat_escape()

func _start_rotation(interval: float) -> void:
	_rotation_timer = Timer.new()
	_rotation_timer.wait_time = interval
	_rotation_timer.one_shot = false
	_rotation_timer.timeout.connect(_next_queued_attack)
	add_child(_rotation_timer)
	_rotation_timer.start()
	_next_queued_attack()

func _next_queued_attack() -> void:
	if _attack_queue.is_empty():
		return
	var attack_name = _attack_queue[_attack_index]
	_attack_index = (_attack_index + 1) % _attack_queue.size()
	start_attack(attack_name, phase == 2)


func check_phase_transition():
	if health <= max_health * 0.3 and phase == 1:
		start_phase(2)


func start_attack(attack_name, fast=false):
	attack_started.emit(attack_name)
	match attack_name:
		"cannonball_salvo":
			cannonball_salvo(fast)
		"pinch_and_plunder":
			pinch_and_plunder(fast)
		"parrotfish_call":
			parrotfish_call(fast)
		"treasure_toss":
			treasure_toss(fast)
		"pirate_crew":
			pirate_crew()

func cannonball_salvo(fast=false):
	# Fires bouncing/rolling cannonballs
	# Player can reflect cannonballs for extra damage
	var cannonball_scene = preload("res://scenes/arenas/Cannonball.tscn")
	var count = 5 if fast else 3
	for i in range(count):
		 var cannonball = cannonball_scene.instantiate()
		 cannonball.position = position + Vector2(randf_range(-100,100), -50)
		 cannonball.linear_velocity = Vector2(randf_range(-200,200), 400)
		 get_parent().add_child(cannonball)
		 cannonball_fired.emit(cannonball)

func pinch_and_plunder(fast=false):
	# Charges and, if grabbing the player, slams them down for damage
	var player = get_tree().get_root().find_child("Player", true, false)
	if player and (player.position - position).length() < 300:
		 # Simulate grab and slam
		 player.take_damage(2 if fast else 1)
		 pinchbeard_stunned.emit()

func parrotfish_call(fast=false):
	# Parrotfish sidekick swoops in to attack or drop water bombs
	# Can be bribed for a bonus
	var parrotfish_scene = preload("res://scenes/arenas/Parrotfish.tscn")
	var parrotfish = parrotfish_scene.instantiate()
	parrotfish.position = position + Vector2(150, -100)
	get_parent().add_child(parrotfish)
	parrotfish_called.emit(parrotfish)
	# If bribed, drop bonus
	if fast and randi() % 2 == 0:
		 parrotfish.drop_bonus()

func treasure_toss(fast=false):
	# Pinchbeard and ferry crew throw coins/gems onto the deck
	# Tempts player near edges, lures Pinchbeard to break pattern
	var coin_scene = preload("res://scenes/arenas/Coin.tscn")
	var count = 8 if fast else 4
	for i in range(count):
		 var coin = coin_scene.instantiate()
		 coin.position = position + Vector2(randf_range(-200,200), randf_range(-50,50))
		 get_parent().add_child(coin)
		 treasure_tossed.emit(coin)

func pirate_crew():
	# Summon pirate crab minions with swords/hats
	var minion_scene = preload("res://scenes/arenas/PirateCrab.tscn")
	for i in range(3):
		 var minion = minion_scene.instantiate()
		 minion.position = position + Vector2(randf_range(-120,120), randf_range(50,150))
		 get_parent().add_child(minion)
		 ferry_crew_helped.emit(minion)

func start_ferry_crew_help_timer():
	# Ferry crew occasionally throws helpful treasure/items
	var crew_timer = Timer.new()
	crew_timer.wait_time = 6.0
	crew_timer.one_shot = false
	crew_timer.timeout.connect(_on_ferry_crew_help)
	add_child(crew_timer)
	crew_timer.start()

func _on_ferry_crew_help():
	var item_scene = preload("res://scenes/arenas/CrewItem.tscn")
	var item = item_scene.instantiate()
	item.position = position + Vector2(randf_range(-180,180), -60)
	get_parent().add_child(item)
	ferry_crew_helped.emit(item)

func on_player_near_edge():
	# If player falls overboard, damage and teleport to safe spot
	var player = get_tree().get_root().find_child("Player", true, false)
	if player:
		player.take_damage(1)
		player.global_position = Vector2(400, 300) # Example safe spot

func on_cannonball_reflected():
	# Extra damage to Pinchbeard
	take_damage(3)
	pinchbeard_stunned.emit()

func on_parrotfish_bribed():
	# Parrotfish drops a bonus
	var bonus_scene = preload("res://scenes/arenas/Bonus.tscn")
	var bonus = bonus_scene.instantiate()
	bonus.position = position + Vector2(randf_range(-100,100), -80)
	get_parent().add_child(bonus)

func start_lifeboat_escape():
	lifeboat_escape = true
	lifeboat_escape_started.emit()
	# Pinchbeard tries to escape, boat springs a leak, big damage window
	var ferry = get_tree().get_root().find_child("CaptainPinchbeardArena", true, false)
	if ferry and ferry.has_method("swerve_and_tilt"):
		ferry.swerve_and_tilt()
	set_vulnerable(true)
	await get_tree().create_timer(2.5).timeout
	set_vulnerable(false)

func on_pinchbeard_defeated():
	pinchbeard_defeated.emit()
	# Pinchbeard is flung overboard, parrotfish squawks, ferry captain thanks player
	$VictoryEffect.show()
	$VictoryEffect.play("victory")
	$Sprite.play("fling_overboard")
	var parrotfish = get_tree().get_root().find_child("Parrotfish", true, false)
	if parrotfish:
		parrotfish.squawk_and_follow()
	var ferry = get_tree().get_root().find_child("CaptainPinchbeardArena", true, false)
	if ferry and ferry.has_method("resume_journey"):
		ferry.resume_journey()



