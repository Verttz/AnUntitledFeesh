extends "res://scripts/bosses/Boss.gd"


# Captain Pinchbeard – Pirate Crab Boss (Ferry Arena)

var phase = 1
var parrotfish_active = false
var ferry_crew_help_timer = null
var pinchbeard_greedy = false
var lifeboat_escape = false

signal cannonball_fired
signal parrotfish_called
signal treasure_tossed
signal ferry_crew_helped
signal pinchbeard_stunned
signal phase_changed
signal lifeboat_escape_started
signal pinchbeard_defeated


func _ready():
	health = max_health
	setup_ferry_arena()
	start_phase(1)

func setup_ferry_arena():
	# Initialize ferry deck, railings, and visual elements
	# ...setup benches, life preservers, background visuals
	pass


func start_phase(new_phase):
	phase = new_phase
	emit_signal("phase_changed", phase)
	if phase == 1:
		start_attack("cannonball_salvo")
		start_attack("pinch_and_plunder")
		start_attack("parrotfish_call")
		start_attack("treasure_toss")
		start_ferry_crew_help_timer()
	elif phase == 2:
		start_attack("cannonball_salvo", fast=true)
		start_attack("pinch_and_plunder", fast=true)
		start_attack("parrotfish_call", fast=true)
		start_attack("treasure_toss", fast=true)
		start_attack("pirate_crew")
		start_lifeboat_escape()


func check_phase_transition():
	   if health <= max_health * 0.3 and phase == 1:
		   start_phase(2)


func start_attack(attack_name, fast=false):
	emit_signal("attack_started", attack_name)
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
	var count = fast ? 5 : 3
	for i in range(count):
		 var cannonball = cannonball_scene.instance()
		 cannonball.position = position + Vector2(randf_range(-100,100), -50)
		 cannonball.linear_velocity = Vector2(randf_range(-200,200), 400)
		 get_parent().add_child(cannonball)
		 emit_signal("cannonball_fired", cannonball)

func pinch_and_plunder(fast=false):
	# Charges and, if grabbing the player, slams them down for damage
	var player = get_tree().get_root().find_node("Player", true, false)
	if player and (player.position - position).length() < 300:
		 # Simulate grab and slam
		 player.take_damage(fast ? 2 : 1)
		 emit_signal("pinchbeard_stunned")

func parrotfish_call(fast=false):
	# Parrotfish sidekick swoops in to attack or drop water bombs
	# Can be bribed for a bonus
	var parrotfish_scene = preload("res://scenes/arenas/Parrotfish.tscn")
	var parrotfish = parrotfish_scene.instance()
	parrotfish.position = position + Vector2(150, -100)
	get_parent().add_child(parrotfish)
	emit_signal("parrotfish_called", parrotfish)
	# If bribed, drop bonus
	if fast and randi() % 2 == 0:
		 parrotfish.drop_bonus()

func treasure_toss(fast=false):
	# Pinchbeard and ferry crew throw coins/gems onto the deck
	# Tempts player near edges, lures Pinchbeard to break pattern
	var coin_scene = preload("res://scenes/arenas/Coin.tscn")
	var count = fast ? 8 : 4
	for i in range(count):
		 var coin = coin_scene.instance()
		 coin.position = position + Vector2(randf_range(-200,200), randf_range(-50,50))
		 get_parent().add_child(coin)
		 emit_signal("treasure_tossed", coin)

func pirate_crew():
	# Summon pirate crab minions with swords/hats
	var minion_scene = preload("res://scenes/arenas/PirateCrab.tscn")
	for i in range(3):
		 var minion = minion_scene.instance()
		 minion.position = position + Vector2(randf_range(-120,120), randf_range(50,150))
		 get_parent().add_child(minion)
		 emit_signal("ferry_crew_helped", minion)

func start_ferry_crew_help_timer():
	# Ferry crew occasionally throws helpful treasure/items
	var crew_timer = Timer.new()
	crew_timer.wait_time = 6.0
	crew_timer.one_shot = false
	crew_timer.connect("timeout", self, "_on_ferry_crew_help")
	add_child(crew_timer)
	crew_timer.start()

func _on_ferry_crew_help():
	var item_scene = preload("res://scenes/arenas/CrewItem.tscn")
	var item = item_scene.instance()
	item.position = position + Vector2(randf_range(-180,180), -60)
	get_parent().add_child(item)
	emit_signal("ferry_crew_helped", item)

func on_player_near_edge():
	# If player falls overboard, damage and teleport to safe spot
	var player = get_tree().get_root().find_node("Player", true, false)
	if player:
		player.take_damage(1)
		player.global_position = Vector2(400, 300) # Example safe spot

func on_cannonball_reflected():
	# Extra damage to Pinchbeard
	take_damage(3)
	emit_signal("pinchbeard_stunned")

func on_parrotfish_bribed():
	# Parrotfish drops a bonus
	var bonus_scene = preload("res://scenes/arenas/Bonus.tscn")
	var bonus = bonus_scene.instance()
	bonus.position = position + Vector2(randf_range(-100,100), -80)
	get_parent().add_child(bonus)

func start_lifeboat_escape():
	lifeboat_escape = true
	emit_signal("lifeboat_escape_started")
	# Pinchbeard tries to escape, boat springs a leak, big damage window
	var ferry = get_tree().get_root().find_node("CaptainPinchbeardArena", true, false)
	if ferry and ferry.has_method("swerve_and_tilt"):
		ferry.swerve_and_tilt()
	set_vulnerable(true)
	yield(get_tree().create_timer(2.5), "timeout")
	set_vulnerable(false)

func on_pinchbeard_defeated():
	emit_signal("pinchbeard_defeated")
	# Pinchbeard is flung overboard, parrotfish squawks, ferry captain thanks player
	$VictoryEffect.show()
	$VictoryEffect.play("victory")
	$Sprite.play("fling_overboard")
	var parrotfish = get_tree().get_root().find_node("Parrotfish", true, false)
	if parrotfish:
		parrotfish.squawk_and_follow()
	var ferry = get_tree().get_root().find_node("CaptainPinchbeardArena", true, false)
	if ferry and ferry.has_method("resume_journey"):
		ferry.resume_journey()



