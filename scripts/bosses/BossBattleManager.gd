extends Node

# Handles boss battle flow, arena setup, and player/boss state

signal boss_spawned(boss)
signal boss_defeated(boss)
signal battle_started()
signal battle_ended(victory: bool)

var boss_scene : PackedScene
var boss_instance : Node = null
var arena_scene : PackedScene
var arena_instance : Node = null

# Mapping of boss names to their scene and arena paths
var boss_data = {
	"DonCatfishoni": {
		"boss_scene": "res://scripts/bosses/DonCatfishoni.gd",
		"arena_scene": "res://scenes/arenas/DonCatfishoniArena.tscn"
	},
	"FinDiesel": {
		"boss_scene": "res://scripts/bosses/FinDiesel.gd",
		"arena_scene": "res://scenes/arenas/FinDieselArena.tscn"
	},
	"Guppazuma": {
		"boss_scene": "res://scripts/bosses/Guppazuma.gd",
		"arena_scene": "res://scenes/arenas/GuppazumaArena.tscn"
	},
	"FrostbiteMaestro": {
		"boss_scene": "res://scripts/bosses/FrostbiteMaestro.gd",
		"arena_scene": "res://scenes/arenas/FrostbiteMaestroArena.tscn"
	},
	"PranksterPoppo": {
		"boss_scene": "res://scripts/bosses/PranksterPoppo.gd",
		"arena_scene": "res://scenes/arenas/PranksterPoppoArena.tscn"
	},
	"TheGreatFisherduck": {
		"boss_scene": "res://scripts/bosses/TheGreatFisherduck.gd",
		"arena_scene": "res://scenes/arenas/TheGreatFisherduckArena.tscn"
	},
	"CaptainPinchbeard": {
		"boss_scene": "res://scripts/bosses/CaptainPinchbeard.gd",
		"arena_scene": "res://scenes/arenas/CaptainPinchbeardArena.tscn"
	},
	"CroakKing": {
		"boss_scene": "res://scripts/bosses/CroakKing.gd",
		"arena_scene": "res://scenes/arenas/CroakKingArena.tscn"
	},
	"AbominableSnowbass": {
		"boss_scene": "res://scripts/bosses/AbominableSnowbass.gd",
		"arena_scene": "res://scenes/arenas/AbominableSnowbassArena.tscn"
	},
	"MagmaChef": {
		"boss_scene": "res://scripts/bosses/MagmaChef.gd",
		"arena_scene": "res://scenes/arenas/MagmaChefArena.tscn"
	}
}

func start_boss_battle_by_name(boss_name: String):
	if boss_data.has(boss_name):
		var boss_scene_path = boss_data[boss_name]["boss_scene"]
		var arena_scene_path = boss_data[boss_name]["arena_scene"]
		start_boss_battle(boss_scene_path, arena_scene_path)
	else:
		push_error("Unknown boss name: %s" % boss_name)

func start_boss_battle(boss_scene_path: String, arena_scene_path: String):
	# Load and instance arena
	arena_scene = load(arena_scene_path)
	arena_instance = arena_scene.instance()
	add_child(arena_instance)

	# Load and instance boss
	boss_scene = load(boss_scene_path)
	boss_instance = boss_scene.instance()
	add_child(boss_instance)

	boss_instance.connect("defeated", self, "_on_boss_defeated")
	emit_signal("boss_spawned", boss_instance)
	emit_signal("battle_started")

func _on_boss_defeated():
	emit_signal("boss_defeated", boss_instance)
	end_boss_battle(true)

func end_boss_battle(victory: bool):
	if boss_instance:
		boss_instance.queue_free()
	if arena_instance:
		arena_instance.queue_free()
	emit_signal("battle_ended", victory)
