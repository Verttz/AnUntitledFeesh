extends Area2D

class_name Projectile

# Player-fired projectile used by CombatFish.
# Supports standard linear, boomerang (return to source), and lobbed (AoE on landing).

var direction: Vector2 = Vector2.RIGHT
var speed: float = 400.0
var damage: int = 10
var lifetime: float = 5.0
var _age: float = 0.0

# Boomerang mode
var is_boomerang: bool = false
var max_range: float = 200.0
var source: Node2D = null
var _travel_dist: float = 0.0
var _returning: bool = false

# Lobbed mode
var is_lobbed: bool = false
var target_position: Vector2 = Vector2.ZERO
var aoe_radius: float = 40.0


func _ready():
	add_to_group("player_bullet")
	# Create collision shape if missing
	if not get_node_or_null("CollisionShape2D"):
		var col = CollisionShape2D.new()
		var shape = CircleShape2D.new()
		shape.radius = 6.0
		col.shape = shape
		add_child(col)
	body_entered.connect(_on_body_entered)
	area_entered.connect(_on_area_entered)


func _physics_process(delta: float) -> void:
	_age += delta
	if _age > lifetime:
		queue_free()
		return

	if is_lobbed:
		_process_lobbed(delta)
	elif is_boomerang:
		_process_boomerang(delta)
	else:
		_process_linear(delta)


func _process_linear(delta: float) -> void:
	global_position += direction * speed * delta


func _process_boomerang(delta: float) -> void:
	if not _returning:
		global_position += direction * speed * delta
		_travel_dist += speed * delta
		if _travel_dist >= max_range:
			_returning = true
	else:
		if source and is_instance_valid(source):
			var to_src = (source.global_position - global_position).normalized()
			global_position += to_src * speed * delta
			if global_position.distance_to(source.global_position) < 20.0:
				queue_free()
		else:
			global_position += -direction * speed * delta
			_travel_dist -= speed * delta
			if _travel_dist <= 0:
				queue_free()


func _process_lobbed(delta: float) -> void:
	var to_target = target_position - global_position
	if to_target.length() < speed * delta:
		# Arrived — explode
		_explode_aoe()
		queue_free()
	else:
		global_position += to_target.normalized() * speed * delta


func _explode_aoe() -> void:
	for body in get_tree().get_nodes_in_group("boss"):
		if body.global_position.distance_to(global_position) <= aoe_radius:
			if body.has_method("take_damage"):
				body.take_damage(damage)


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("boss"):
		if body.has_method("take_damage"):
			body.take_damage(damage)
		if not is_boomerang:
			queue_free()


func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("boss"):
		if area.has_method("take_damage"):
			area.take_damage(damage)
		if not is_boomerang:
			queue_free()


func reflect() -> void:
	direction = -direction
	remove_from_group("player_bullet")
	add_to_group("boss_bullet")
