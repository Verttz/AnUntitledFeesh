extends Node2D

# --- Bullet Hell & Movement Utilities ---
@export var bullet_scene: PackedScene
var move_speed := 200
var move_target := null
var move_tolerance := 8
var move_callback := null

func move_to(target_pos: Vector2, speed := -1, callback := null):
	move_target = target_pos
	move_speed = speed if speed > 0 else move_speed
	move_callback = callback
	set_physics_process(true)

func _physics_process(delta):
	if move_target:
		var dir = (move_target - global_position).normalized()
		var dist = global_position.distance_to(move_target)
		if dist > move_tolerance:
			global_position += dir * move_speed * delta
		else:
			global_position = move_target
			move_target = null
			set_physics_process(false)
			if move_callback:
				move_callback.call()

# --- Bullet Spawning & Patterns ---
func spawn_bullet(pos: Vector2, velocity: Vector2, bullet_type: String = "default"):
	if bullet_scene:
		var bullet = bullet_scene.instantiate()
		bullet.global_position = pos
		bullet.velocity = velocity
		bullet.bullet_type = bullet_type
		get_parent().add_child(bullet)
		return bullet
	return null

func fire_arc(origin: Vector2, count: int, spread_deg: float, speed: float, angle_offset: float = 0.0):
	# Fire bullets in an arc pattern
	var start_angle = angle_offset - spread_deg/2
	var step = spread_deg / max(count-1,1)
	for i in range(count):
		var angle = deg_to_rad(start_angle + i*step)
		var vel = Vector2(cos(angle), sin(angle)) * speed
		spawn_bullet(origin, vel)

func fire_circle(origin: Vector2, count: int, speed: float, angle_offset: float = 0.0):
	# Fire bullets in a full circle
	for i in range(count):
		var angle = angle_offset + i * (TAU / count)
		var vel = Vector2(cos(angle), sin(angle)) * speed
		spawn_bullet(origin, vel)

func fire_aimed(origin: Vector2, target: Vector2, speed: float):
	var dir = (target - origin).normalized()
	spawn_bullet(origin, dir * speed)

func fire_spiral(origin: Vector2, count: int, speed: float, rotations: float = 1.0, angle_offset: float = 0.0):
	# Fire bullets in a spiral pattern
	for i in range(count):
		var t = float(i) / count
		var angle = angle_offset + t * TAU * rotations
		var vel = Vector2(cos(angle), sin(angle)) * speed
		spawn_bullet(origin, vel)

signal phase_changed(new_phase)
signal attack_started(attack_name)
signal vulnerable()
signal defeated()
signal stunned()

@export var max_health := 100
var health := 100
var phase := 1
var is_vulnerable := false

# --- Armor system ---
var is_armored := false
var armor_timer := 0.0
const ARMOR_DAMAGE_MULT := 0.5  # halved damage when armored

# --- Status effects ---
var is_stunned := false
var stun_timer := 0.0
var stun_cooldown := 0.0
const STUN_INTERNAL_CD := 5.0

var bleed_stacks: Array = []   # Array of { dps, remaining_time }
var burn_dps := 0.0
var burn_timer := 0.0
var poison_dps := 0.0
var poison_timer := 0.0
var is_poisoned := false
const POISON_SLOW := 0.15

func _ready():
	add_to_group("boss")
	health = max_health
	# Children call start_phase() in their own _ready()

func _process(delta):
	_process_stun(delta)
	_process_dot(delta)
	_process_armor(delta)

func _process_stun(delta: float) -> void:
	if stun_cooldown > 0:
		stun_cooldown -= delta
	if is_stunned:
		stun_timer -= delta
		if stun_timer <= 0:
			is_stunned = false

func _process_dot(delta: float) -> void:
	var dot_damage := 0.0
	# Bleed stacks
	var i := bleed_stacks.size() - 1
	while i >= 0:
		bleed_stacks[i]["remaining"] -= delta
		if bleed_stacks[i]["remaining"] <= 0:
			bleed_stacks.remove_at(i)
		else:
			dot_damage += bleed_stacks[i]["dps"] * delta
		i -= 1
	# Burn
	if burn_timer > 0:
		burn_timer -= delta
		dot_damage += burn_dps * delta
	# Poison
	if poison_timer > 0:
		poison_timer -= delta
		dot_damage += poison_dps * delta
		is_poisoned = true
	else:
		is_poisoned = false

	if dot_damage > 0:
		_apply_dot_damage(int(max(1, dot_damage)))

func _process_armor(delta: float) -> void:
	if armor_timer > 0:
		armor_timer -= delta
		if armor_timer <= 0:
			is_armored = false

func _apply_dot_damage(amount: int) -> void:
	health -= amount
	if health <= 0:
		health = 0
		defeated.emit()
	else:
		check_phase_transition()

func start_phase(new_phase):
	phase = new_phase
	phase_changed.emit(phase)
	# Override in child for phase-specific logic

func take_damage(amount: int) -> void:
	# Armor halves damage (unless pierce — handled by caller)
	if is_armored:
		amount = int(amount * ARMOR_DAMAGE_MULT)
	if is_vulnerable or not _requires_vulnerability():
		health -= amount
		if health <= 0:
			health = 0
			defeated.emit()
		else:
			check_phase_transition()

func _requires_vulnerability() -> bool:
	# Override in children that need explicit vulnerability windows
	return false

func check_phase_transition():
	# Override in child for custom phase logic
	pass

func start_attack(attack_name):
	if is_stunned:
		return
	attack_started.emit(attack_name)
	# Override in child for attack logic

func set_vulnerable(state: bool):
	is_vulnerable = state
	if is_vulnerable:
		vulnerable.emit()

# --- Armor management ---
func set_armored(armored: bool, duration := 0.0) -> void:
	is_armored = armored
	if duration > 0:
		armor_timer = duration

func strip_armor(duration := 5.0) -> void:
	is_armored = false
	armor_timer = 0.0
	# Prevent re-arming for duration
	await get_tree().create_timer(duration).timeout

# --- Status effect application (called by CombatFish) ---
func apply_stun(duration: float) -> void:
	if stun_cooldown > 0:
		return
	is_stunned = true
	stun_timer = duration
	stun_cooldown = STUN_INTERNAL_CD
	stunned.emit()

func apply_bleed(dps: float, duration: float) -> void:
	# Max 3 stacks
	if bleed_stacks.size() >= 3:
		bleed_stacks[0] = { "dps": dps, "remaining": duration }
	else:
		bleed_stacks.append({ "dps": dps, "remaining": duration })

func apply_burn(dps: float, duration: float) -> void:
	# Refreshes on re-application
	burn_dps = dps
	burn_timer = duration

func apply_poison(dps: float, duration: float) -> void:
	poison_dps = dps
	poison_timer = duration

func get_move_speed_multiplier() -> float:
	if is_poisoned:
		return 1.0 - POISON_SLOW
	return 1.0
