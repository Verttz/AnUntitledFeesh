extends CharacterBody2D

class_name CombatFish

# The player-controlled fish in boss arenas.
# Twin-stick: WASD moves, mouse aims, click fires weapon.

signal died()
signal health_changed(current_hp: int, max_hp: int)
signal special_used(ability_name: String)
signal special_ready(ability_name: String)

# --- Fish data (set via setup()) ---
var fish_data: Fish = null
var current_hp: int = 0
var max_hp: int = 0

# --- Weapon state ---
var weapon_timer: float = 0.0
var can_fire: bool = true
var beam_active: bool = false
var beam_timer: float = 0.0
const BEAM_ON_TIME: float = 2.0
const BEAM_OFF_TIME: float = 1.0

# --- i-frames ---
var invulnerable: bool = false
var iframe_timer: float = 0.0
const IFRAME_DURATION: float = 1.0
var flash_timer: float = 0.0
const FLASH_INTERVAL: float = 0.1

# --- Special ability ---
var special_cooldown: float = 0.0
var special_cooldown_max: float = 0.0
var special_active: bool = false
var special_duration_timer: float = 0.0
var berserk_active: bool = false
var reflect_active: bool = false

# --- Movement ---
const BASE_MOVE_SPEED: float = 200.0
var move_speed: float = 200.0
var aim_direction: Vector2 = Vector2.RIGHT

# --- Last move tracking (for boss mimicry, etc.) ---
var last_move_type: String = "idle"
var last_move_direction: Vector2 = Vector2.RIGHT

# --- Projectile scene (assign in editor or from BossBattleManager) ---
@export var projectile_scene: PackedScene

# --- Weapon class constants (from design doc) ---
# { weapon_class: { fire_rate, modifier, ... } }
const WEAPON_STATS: Dictionary = {
	Fish.WeaponClass.SLASH:       { "fire_rate": 2.5, "modifier": 1.0,  "range": 50.0,  "arc_deg": 90.0 },
	Fish.WeaponClass.HEAVY_SLASH: { "fire_rate": 1.5, "modifier": 1.5,  "range": 65.0,  "arc_deg": 140.0 },
	Fish.WeaponClass.THRUST:      { "fire_rate": 2.0, "modifier": 1.1,  "range": 90.0,  "arc_deg": 15.0 },
	Fish.WeaponClass.SMASH:       { "fire_rate": 1.3, "modifier": 1.5,  "range": 40.0,  "aoe_radius": 30.0 },
	Fish.WeaponClass.WHIP:        { "fire_rate": 2.0, "modifier": 0.9,  "range": 90.0,  "arc_deg": 30.0 },
	Fish.WeaponClass.SINGLE_SHOT: { "fire_rate": 1.2, "modifier": 1.8,  "range": 9999.0 },
	Fish.WeaponClass.BOOMERANG:   { "fire_rate": 1.5, "modifier": 0.6,  "range": 200.0 },
	Fish.WeaponClass.BLASTER:     { "fire_rate": 2.5, "modifier": 0.6,  "range": 9999.0 },
	Fish.WeaponClass.BEAM:        { "fire_rate": 8.0, "modifier": 0.25, "range": 9999.0 },
	Fish.WeaponClass.RAPID_FIRE:  { "fire_rate": 9.0, "modifier": 0.13, "range": 9999.0 },
	Fish.WeaponClass.LOBBED:      { "fire_rate": 1.0, "modifier": 1.3,  "range": 250.0, "aoe_radius": 40.0 },
}

# Special ability cooldowns (seconds)
const SPECIAL_COOLDOWNS: Dictionary = {
	"berserk": 20.0, "charge": 8.0, "reflect": 15.0, "heal": 25.0,
	"summon": 30.0, "firestorm": 45.0, "dash": 3.0, "armor_break": 18.0,
}

# Special ability durations (seconds, 0 = instant)
const SPECIAL_DURATIONS: Dictionary = {
	"berserk": 5.0, "charge": 0.0, "reflect": 3.0, "heal": 0.0,
	"summon": 10.0, "firestorm": 0.0, "dash": 0.0, "armor_break": 5.0,
}

# --- Passive ability state ---
var bleed_stacks: int = 0
var armor_break_hits_remaining: int = 0


func setup(fish: Fish) -> void:
	fish_data = fish
	max_hp = fish.get_combat_hp()
	current_hp = max_hp
	move_speed = BASE_MOVE_SPEED + fish.speed * 10.0
	# Set special cooldown max
	if fish.has_special() and SPECIAL_COOLDOWNS.has(fish.special):
		special_cooldown_max = SPECIAL_COOLDOWNS[fish.special]
	special_cooldown = 0.0
	health_changed.emit(current_hp, max_hp)


func _physics_process(delta: float) -> void:
	_handle_movement(delta)
	_handle_aiming()
	_handle_weapon(delta)
	_handle_iframes(delta)
	_handle_special_cooldown(delta)
	_handle_special_duration(delta)
	_handle_beam_cycle(delta)


# ==========================================================================
# MOVEMENT
# ==========================================================================

func _handle_movement(_delta: float) -> void:
	var input_dir := Vector2.ZERO
	if Input.is_action_pressed("move_left"):
		input_dir.x -= 1
	if Input.is_action_pressed("move_right"):
		input_dir.x += 1
	if Input.is_action_pressed("move_up"):
		input_dir.y -= 1
	if Input.is_action_pressed("move_down"):
		input_dir.y += 1

	if input_dir != Vector2.ZERO:
		input_dir = input_dir.normalized()
		last_move_direction = input_dir
		last_move_type = "dash"

	velocity = input_dir * move_speed
	move_and_slide()


func _handle_aiming() -> void:
	var mouse_pos := get_global_mouse_position()
	aim_direction = (mouse_pos - global_position).normalized()


func get_last_move_type() -> String:
	return last_move_type


func get_last_move_direction() -> Vector2:
	return last_move_direction


# ==========================================================================
# WEAPON FIRING
# ==========================================================================

func _handle_weapon(delta: float) -> void:
	if weapon_timer > 0:
		weapon_timer -= delta
		if weapon_timer <= 0:
			can_fire = true

	if fish_data == null:
		return

	var wc: int = fish_data.weapon_class
	var stats: Dictionary = WEAPON_STATS.get(wc, WEAPON_STATS[Fish.WeaponClass.SLASH])
	var fire_rate: float = stats["fire_rate"]

	# Berserk doubles attack speed
	if berserk_active:
		fire_rate *= 2.0

	# BEAM class: continuous fire with on/off cycle
	if wc == Fish.WeaponClass.BEAM:
		if beam_active and Input.is_action_pressed("attack"):
			_fire_beam_tick(stats)
		return

	# All other weapons: fire on press/hold
	if Input.is_action_pressed("attack") and can_fire:
		_fire_weapon(wc, stats)
		can_fire = false
		weapon_timer = 1.0 / fire_rate


func _fire_weapon(wc: int, stats: Dictionary) -> void:
	var damage := _calc_damage(stats)
	last_move_direction = aim_direction

	match wc:
		Fish.WeaponClass.SLASH, Fish.WeaponClass.HEAVY_SLASH, Fish.WeaponClass.WHIP:
			last_move_type = "circle"
			_do_melee_arc(stats, damage)
		Fish.WeaponClass.THRUST:
			last_move_type = "dash"
			_do_melee_thrust(stats, damage)
		Fish.WeaponClass.SMASH:
			last_move_type = "circle"
			_do_melee_smash(stats, damage)
		Fish.WeaponClass.SINGLE_SHOT, Fish.WeaponClass.BLASTER, Fish.WeaponClass.RAPID_FIRE:
			last_move_type = "ranged"
			_do_ranged_projectile(stats, damage)
		Fish.WeaponClass.BOOMERANG:
			last_move_type = "ranged"
			_do_boomerang(stats, damage)
		Fish.WeaponClass.LOBBED:
			last_move_type = "ranged"
			_do_lobbed(stats, damage)


func _calc_damage(stats: Dictionary) -> int:
	var base_atk: float = fish_data.attack
	var modifier: float = stats["modifier"]
	if berserk_active:
		modifier *= 1.5
	if armor_break_hits_remaining > 0:
		modifier *= 2.0
		armor_break_hits_remaining -= 1
	return int(base_atk * modifier)


# --- Melee attacks ---

func _do_melee_arc(stats: Dictionary, damage: int) -> void:
	# Detect enemies in arc area
	var hit_range: float = stats["range"]
	var arc_deg: float = stats.get("arc_deg", 90.0)
	var half_arc: float = deg_to_rad(arc_deg / 2.0)
	var aim_angle: float = aim_direction.angle()

	# Find all boss bodies in range and within arc
	for body in _get_hittable_bodies():
		var to_body: Vector2 = body.global_position - global_position
		var dist: float = to_body.length()
		var angle_diff: float = abs(wrapf(to_body.angle() - aim_angle, -PI, PI))
		if dist <= hit_range and angle_diff <= half_arc:
			_apply_hit(body, damage)

	if fish_data.special == "multi_shot":
		# Duplicate the arc 70% damage - slight offset
		for body in _get_hittable_bodies():
			var to_body: Vector2 = body.global_position - global_position
			var dist: float = to_body.length()
			var angle_diff: float = abs(wrapf(to_body.angle() - aim_angle, -PI, PI))
			if dist <= hit_range and angle_diff <= half_arc:
				_apply_hit(body, int(damage * 0.7))


func _do_melee_thrust(stats: Dictionary, damage: int) -> void:
	var hit_range: float = stats["range"]
	var half_arc: float = deg_to_rad(7.5)  # Narrow 15° cone
	var aim_angle: float = aim_direction.angle()

	for body in _get_hittable_bodies():
		var to_body: Vector2 = body.global_position - global_position
		var dist: float = to_body.length()
		var angle_diff: float = abs(wrapf(to_body.angle() - aim_angle, -PI, PI))
		if dist <= hit_range and angle_diff <= half_arc:
			_apply_hit(body, damage)


func _do_melee_smash(stats: Dictionary, damage: int) -> void:
	var hit_range: float = stats["range"]
	var aoe_radius: float = stats.get("aoe_radius", 30.0)
	# Smash at the point in front
	var smash_pos: Vector2 = global_position + aim_direction * hit_range

	for body in _get_hittable_bodies():
		var dist: float = body.global_position.distance_to(smash_pos)
		if dist <= aoe_radius:
			_apply_hit(body, damage)


# --- Ranged attacks ---

func _do_ranged_projectile(stats: Dictionary, damage: int) -> void:
	if projectile_scene == null:
		return
	var proj = projectile_scene.instantiate()
	proj.global_position = global_position
	proj.direction = aim_direction
	proj.damage = damage
	proj.speed = 400.0
	_apply_passive_to_projectile(proj)
	get_parent().add_child(proj)

	if fish_data.special == "multi_shot":
		var proj2 = projectile_scene.instantiate()
		proj2.global_position = global_position
		proj2.direction = aim_direction.rotated(deg_to_rad(8))
		proj2.damage = int(damage * 0.7)
		proj2.speed = 400.0
		_apply_passive_to_projectile(proj2)
		get_parent().add_child(proj2)


func _do_boomerang(stats: Dictionary, damage: int) -> void:
	if projectile_scene == null:
		return
	var proj = projectile_scene.instantiate()
	proj.global_position = global_position
	proj.direction = aim_direction
	proj.damage = damage
	proj.speed = 350.0
	proj.is_boomerang = true
	proj.max_range = stats["range"]
	proj.source = self
	_apply_passive_to_projectile(proj)
	get_parent().add_child(proj)


func _do_lobbed(stats: Dictionary, damage: int) -> void:
	if projectile_scene == null:
		return
	var proj = projectile_scene.instantiate()
	# Lobbed travels to mouse cursor position, then explodes
	proj.global_position = global_position
	proj.target_position = get_global_mouse_position()
	proj.damage = damage
	proj.is_lobbed = true
	proj.aoe_radius = stats.get("aoe_radius", 40.0)
	_apply_passive_to_projectile(proj)
	get_parent().add_child(proj)


func _fire_beam_tick(stats: Dictionary) -> void:
	if not beam_active:
		return
	var damage := _calc_damage(stats)
	# Beam: raycast from fish toward aim direction
	for body in _get_hittable_bodies():
		# Simple line check: project body position onto aim line
		var to_body: Vector2 = body.global_position - global_position
		var proj_len: float = to_body.dot(aim_direction)
		if proj_len > 0:
			var perp_dist: float = abs(to_body.cross(aim_direction))
			if perp_dist < 20.0:  # Beam width tolerance
				_apply_hit(body, damage)


func _handle_beam_cycle(delta: float) -> void:
	if fish_data == null or fish_data.weapon_class != Fish.WeaponClass.BEAM:
		return
	beam_timer += delta
	if beam_active:
		if beam_timer >= BEAM_ON_TIME:
			beam_active = false
			beam_timer = 0.0
	else:
		if beam_timer >= BEAM_OFF_TIME:
			beam_active = true
			beam_timer = 0.0


# ==========================================================================
# DAMAGE & HIT APPLICATION
# ==========================================================================

func _apply_hit(body: Node2D, damage: int) -> void:
	if body.has_method("take_damage"):
		body.take_damage(damage)
	_apply_passive_on_hit(body, damage)


func _apply_passive_on_hit(body: Node2D, damage: int) -> void:
	if fish_data == null or not fish_data.has_special():
		return
	match fish_data.special:
		"stun":
			# 15% chance, 0.5s freeze, 5s internal cooldown (handled by boss)
			if randf() < 0.15 and body.has_method("apply_stun"):
				body.apply_stun(0.5)
		"bleed":
			if body.has_method("apply_bleed"):
				body.apply_bleed(fish_data.attack * 0.1, 3.0)
		"burn":
			if body.has_method("apply_burn"):
				body.apply_burn(fish_data.attack * 0.15, 4.0)
		"poison":
			if body.has_method("apply_poison"):
				body.apply_poison(fish_data.attack * 0.1, 5.0)
		"pierce":
			pass  # Handled at damage calculation level (ignores armor)


func _apply_passive_to_projectile(proj: Node) -> void:
	if fish_data == null:
		return
	proj.set_meta("special", fish_data.special)
	proj.set_meta("fish_attack", fish_data.attack)


func _get_hittable_bodies() -> Array:
	# Returns all boss and minion nodes in the arena that can be hit
	return get_tree().get_nodes_in_group("boss") + get_tree().get_nodes_in_group("minion")


# ==========================================================================
# TAKING DAMAGE
# ==========================================================================

func take_damage(bullet_base_damage: float) -> void:
	if invulnerable:
		return

	# Defense formula: effective_damage = base × (100 / (100 + defense))
	var effective_damage: int = max(1, int(bullet_base_damage * (100.0 / (100.0 + fish_data.defense))))

	# Berserk penalty: take 30% more damage
	if berserk_active:
		effective_damage = int(effective_damage * 1.3)

	current_hp -= effective_damage
	health_changed.emit(current_hp, max_hp)

	if current_hp <= 0:
		current_hp = 0
		_on_death()
	else:
		_start_iframes()


func _start_iframes() -> void:
	invulnerable = true
	iframe_timer = IFRAME_DURATION
	flash_timer = 0.0


func _handle_iframes(delta: float) -> void:
	if not invulnerable:
		return
	iframe_timer -= delta
	flash_timer += delta

	# Flash effect during i-frames
	if flash_timer >= FLASH_INTERVAL:
		flash_timer -= FLASH_INTERVAL
		visible = !visible

	if iframe_timer <= 0:
		invulnerable = false
		visible = true


func _on_death() -> void:
	set_physics_process(false)
	died.emit()


# ==========================================================================
# SPECIAL ABILITIES
# ==========================================================================

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("special_ability"):
		_try_use_special()


func _try_use_special() -> void:
	if fish_data == null or not fish_data.has_special():
		return
	# Passive abilities don't have an active trigger
	if fish_data.special in ["stun", "bleed", "burn", "poison", "pierce", "multi_shot"]:
		return
	if special_cooldown > 0:
		return
	_activate_special(fish_data.special)


func _activate_special(ability: String) -> void:
	special_cooldown = special_cooldown_max
	special_used.emit(ability)

	var duration: float = SPECIAL_DURATIONS.get(ability, 0.0)
	if duration > 0:
		special_active = true
		special_duration_timer = duration

	match ability:
		"berserk":
			berserk_active = true
		"charge":
			_do_charge()
		"reflect":
			reflect_active = true
		"heal":
			var heal_amount := int(max_hp * 0.2)
			current_hp = min(current_hp + heal_amount, max_hp)
			health_changed.emit(current_hp, max_hp)
		"summon":
			_do_summon()
		"firestorm":
			_do_firestorm()
		"dash":
			_do_dash()
		"armor_break":
			armor_break_hits_remaining = 3


func _handle_special_cooldown(delta: float) -> void:
	if special_cooldown > 0:
		special_cooldown -= delta
		if special_cooldown <= 0:
			special_cooldown = 0.0
			if fish_data != null and fish_data.has_special():
				special_ready.emit(fish_data.special)


func _handle_special_duration(delta: float) -> void:
	if not special_active:
		return
	special_duration_timer -= delta
	if special_duration_timer <= 0:
		special_active = false
		_end_special_effect()


func _end_special_effect() -> void:
	berserk_active = false
	reflect_active = false


# --- Active ability implementations ---

func _do_charge() -> void:
	# Dash lunge dealing 3x attack, brief i-frames
	var charge_distance := 150.0
	var charge_damage := fish_data.attack * 3
	_start_iframes()
	# Move instantly in aim direction, clamped to arena bounds
	var target_pos := global_position + aim_direction * charge_distance
	global_position = _clamp_to_arena(target_pos)
	# Damage anything at destination
	for body in _get_hittable_bodies():
		if body.global_position.distance_to(global_position) < 60.0:
			_apply_hit(body, charge_damage)


func _do_summon() -> void:
	# Spawn ally fish that auto-attacks (50% of atk) for 10s
	# The ally is a simple scene — placeholder for now
	pass


func _do_firestorm() -> void:
	# Screen-wide AoE burst dealing 5x attack
	var firestorm_damage := fish_data.attack * 5
	for body in _get_hittable_bodies():
		_apply_hit(body, firestorm_damage)


func _do_dash() -> void:
	# Invulnerable dash in move direction, 150px
	var dash_dir := velocity.normalized() if velocity.length() > 0 else aim_direction
	_start_iframes()
	global_position = _clamp_to_arena(global_position + dash_dir * 150.0)


# --- Reflect (called by boss bullets) ---

func try_reflect_bullet(bullet: Node2D) -> bool:
	if not reflect_active:
		return false
	# Reverse the bullet back at the boss
	if bullet.has_method("reflect"):
		bullet.reflect()
	return true


# ==========================================================================
# ARENA BOUNDARY CLAMPING
# ==========================================================================

func _clamp_to_arena(pos: Vector2) -> Vector2:
	var arena_rect := _get_arena_rect()
	pos.x = clampf(pos.x, arena_rect.position.x, arena_rect.end.x)
	pos.y = clampf(pos.y, arena_rect.position.y, arena_rect.end.y)
	return pos

func _get_arena_rect() -> Rect2:
	# Try to find an arena bounds node, fall back to viewport
	var arena = get_parent()
	if arena and arena.has_method("get_arena_rect"):
		return arena.get_arena_rect()
	return get_viewport_rect()
