extends Node2D

# --- Bullet Hell & Movement Utilities ---
export (PackedScene) var bullet_scene
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
		var bullet = bullet_scene.instance()
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
		var angle = deg2rad(start_angle + i*step)
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
