extends Area2D

# BossBullet.gd — Projectiles fired by bosses.
# Auto-destroys off-screen or after lifetime. Damages CombatFish on contact.

var velocity: Vector2 = Vector2.ZERO
var bullet_type: String = "default"
var damage: float = 50.0
var lifetime: float = 8.0
var _age: float = 0.0


func _ready():
	add_to_group("boss_bullet")
	# Create collision shape if missing
	if not get_node_or_null("CollisionShape2D"):
		var col = CollisionShape2D.new()
		var shape = CircleShape2D.new()
		shape.radius = 5.0
		col.shape = shape
		add_child(col)
	body_entered.connect(_on_body_entered)
	area_entered.connect(_on_area_entered)


func _physics_process(delta: float) -> void:
	global_position += velocity * delta
	_age += delta
	if _age > lifetime:
		queue_free()
		return
	# Cull if far off-screen
	if global_position.x < -200 or global_position.x > 1500 or global_position.y < -200 or global_position.y > 1000:
		queue_free()


func _on_body_entered(body: Node2D) -> void:
	if body is CombatFish:
		if body.try_reflect_bullet(self):
			return
		body.take_damage(damage)
		queue_free()


func _on_area_entered(area: Area2D) -> void:
	pass


func reflect() -> void:
	velocity = -velocity
	damage *= 1.5
	remove_from_group("boss_bullet")
	add_to_group("player_bullet")
