extends CharacterBody2D

# Minion.gd — Base class for boss minion enemies.
# Provides common state (player reference, health, group membership)
# and a shared interface for damage and death.

signal died()

var player: Node2D = null
var max_health := 100
var health := 100


func _ready():
	add_to_group("minion")
	health = max_health
	# Find the CombatFish in the scene (player-controlled fighter)
	var fish_nodes = get_tree().get_nodes_in_group("combat_fish")
	if fish_nodes.size() > 0:
		player = fish_nodes[0]
	else:
		# Fallback: search for any CombatFish node
		player = get_tree().get_root().find_child("CombatFish", true, false)


func take_damage(amount: int) -> void:
	health -= amount
	if health <= 0:
		health = 0
		die()


func die() -> void:
	died.emit()
	queue_free()
