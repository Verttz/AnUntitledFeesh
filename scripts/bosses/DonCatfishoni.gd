extends "res://scripts/bosses/Boss.gd"


# Don Catfishoni (The Catfish Mobster)

var goon_timer = null
var pearl_bomb_timer = null
var protection_racket_timer = null
var smoke_timer = null
var bribe_timer = null
var sitdown_timer = null
var enraged = false

func _ready():
	health = max_health
	start_phase(1)

func start_phase(new_phase):
	phase = new_phase
	emit_signal("phase_changed", phase)
	if phase == 1:
		start_attack("goonswarm")
		goon_timer = _start_timer(3.0, "_goonswarm")
		pearl_bomb_timer = _start_timer(4.5, "_pearl_bomb")
		protection_racket_timer = _start_timer(8.0, "_protection_racket")
		smoke_timer = _start_timer(10.0, "_cigar_smoke")
		bribe_timer = _start_timer(12.0, "_bribe_break")
		sitdown_timer = _start_timer(18.0, "_sitdown_minigame")
		enraged = false
	elif phase == 2:
		start_attack("goonswarm")
		goon_timer = _start_timer(2.0, "_goonswarm", true)
		pearl_bomb_timer = _start_timer(3.0, "_pearl_bomb", true)
		protection_racket_timer = _start_timer(6.0, "_protection_racket", true)
		smoke_timer = _start_timer(8.0, "_cigar_smoke", true)
		bribe_timer = _start_timer(10.0, "_bribe_break", true)
		sitdown_timer = _start_timer(14.0, "_sitdown_minigame", true)
		enraged = true

func check_phase_transition():
	if health <= max_health * 0.5 and phase == 1:
		# Phase 2: Buff up, more aggressive
		start_phase(2)

func start_attack(attack_name):
	emit_signal("attack_started", attack_name)
	# Attack logic handled by timers and methods below

# --- Attack Patterns ---
func _goonswarm():
	emit_signal("attack_started", "goonswarm")
	# Summon goon fish (some shoot, some grab)
	# (Instantiate goon nodes, set their behavior)
	# If in phase 2, summon elite goons
	if enraged:
		# Summon elite goons (e.g., Tommy-gun, shield goons)
		pass

func _pearl_bomb():
	emit_signal("attack_started", "pearl_bomb")
	# Spit bouncing pearls that explode after a delay
	# In phase 2, leave sticky cement puddles
	if enraged:
		# Spawn cement puddle on explosion
		pass

func _protection_racket():
	emit_signal("attack_started", "protection_racket")
	# Demand tribute: spawn coins in arena
	# If player doesn't collect enough, Don attacks faster for a short time
	pass

func _cigar_smoke():
	emit_signal("attack_started", "cigar_smoke")
	# Obscure part of the arena with smoke, hide goons/hazards
	pass

func _concrete_shoes():
	emit_signal("attack_started", "concrete_shoes")
	# Slam ground, concrete shoes rise, trap player if not dodged
	pass

func _bribe_break():
	emit_signal("attack_started", "bribe_break")
	# Toss money bag: if collected, buff player but summon more goons
	pass

func _sitdown_minigame():
	emit_signal("attack_started", "sitdown_minigame")
	# Quick negotiation minigame: bluff, pay, or threaten for effects
	pass

func _offer_you_cant_refuse():
	emit_signal("attack_started", "offer_you_cant_refuse")
	# Surprise attack if player stands still too long
	pass

# --- Unique Mechanic: Turn goons against Don ---
func on_goon_stunned(goon):
	# If goon is pushed into Don, deal bonus damage and fluster
	pass

# --- Timer Utility ---
func _start_timer(time, method, repeat := false):
	var timer = Timer.new()
	timer.wait_time = time
	timer.one_shot = not repeat
	timer.connect("timeout", self, method)
	add_child(timer)
	timer.start()
	return timer
