extends "res://scripts/bosses/Boss.gd"

# TestBoss.gd — A self-contained boss for the playtest scene.
# Uses only base Boss.gd bullet utilities (fire_arc, fire_circle, fire_aimed, fire_spiral).
# No external child-node or preload dependencies.
#
# Phase 1 (100-50% HP): Moderate patterns with pauses.
# Phase 2 (50-0% HP): Faster, denser patterns + spiral attacks.

const TEST_BOSS_HP := 5000

var attack_timer: float = 0.0
var attack_interval: float = 2.0
var attack_index: int = 0
var combat_fish_ref: Node2D = null  # Set by BossTestScene

# Phase 1 attack rotation
var phase1_attacks := ["aimed_burst", "circle_spread", "arc_sweep", "pause"]
# Phase 2 attack rotation
var phase2_attacks := ["spiral_storm", "aimed_burst_fast", "circle_spread_dense", "arc_sweep_wide", "aimed_volley"]


func _ready():
	max_health = TEST_BOSS_HP
	health = max_health
	bullet_scene = load("res://scenes/combat/BossBullet.tscn")
	add_to_group("boss")
	start_phase(1)


func _process(delta):
	super(delta)
	if is_stunned:
		return

	attack_timer += delta
	var interval = attack_interval if phase == 1 else (attack_interval * 0.65)
	if attack_timer >= interval:
		attack_timer = 0.0
		_execute_next_attack()


func _execute_next_attack():
	var attacks = phase1_attacks if phase == 1 else phase2_attacks
	var attack_name = attacks[attack_index % attacks.size()]
	attack_index += 1
	start_attack(attack_name)


func start_attack(attack_name, _fast = false):
	if is_stunned:
		return
	attack_started.emit(attack_name)

	var target_pos := Vector2(640, 400)
	if combat_fish_ref and is_instance_valid(combat_fish_ref):
		target_pos = combat_fish_ref.global_position

	match attack_name:
		"aimed_burst":
			# 3 aimed shots in quick succession
			fire_aimed(global_position, target_pos, 300.0)
			var offset1 = target_pos + Vector2(40, 30)
			var offset2 = target_pos + Vector2(-40, -30)
			fire_aimed(global_position, offset1, 280.0)
			fire_aimed(global_position, offset2, 280.0)

		"aimed_burst_fast":
			# 5 aimed shots, faster
			for i in range(5):
				var spread = Vector2(randf_range(-60, 60), randf_range(-60, 60))
				fire_aimed(global_position, target_pos + spread, 400.0)

		"circle_spread":
			# Ring of 12 bullets
			fire_circle(global_position, 12, 200.0)

		"circle_spread_dense":
			# Dense ring of 20
			fire_circle(global_position, 20, 250.0)

		"arc_sweep":
			# Aimed arc of 5 bullets, 60° spread
			var angle_to_target = (target_pos - global_position).angle()
			fire_arc(global_position, 5, 60.0, 280.0, rad_to_deg(angle_to_target))

		"arc_sweep_wide":
			# Wide arc of 9 bullets, 120° spread
			var angle_to_target = (target_pos - global_position).angle()
			fire_arc(global_position, 9, 120.0, 320.0, rad_to_deg(angle_to_target))

		"spiral_storm":
			# Spiral pattern — 24 bullets, 2 rotations
			fire_spiral(global_position, 24, 220.0, 2.0)

		"aimed_volley":
			# Rapid 7-shot volley directly at player
			for i in range(7):
				var spread = Vector2(randf_range(-30, 30), randf_range(-30, 30))
				fire_aimed(global_position, target_pos + spread, 350.0 + i * 20.0)

		"pause":
			# Breathing room — no bullets
			pass


func check_phase_transition():
	if health <= max_health * 0.5 and phase == 1:
		start_phase(2)


func start_phase(new_phase):
	phase = new_phase
	phase_changed.emit(phase)
	attack_index = 0
	attack_timer = 0.0
	if phase == 2:
		attack_interval = 1.5
