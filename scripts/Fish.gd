
extends Resource

class_name Fish

"""
Fish.gd
-------
Defines the Fish resource, used for all catchable fish in the game.
Includes fishing properties (bite timing, fight pattern, baits) and
combat properties (hp, attack, defense, speed, weapon, special).
"""

# Fish rarity levels
enum Rarity { COMMON, UNCOMMON, RARE, LEGENDARY, MYTHIC }

# Weapon classes for combat
enum WeaponClass {
	# Melee
	SLASH,        # Arc swing, short range, 90° arc
	HEAVY_SLASH,  # Wide devastating swing, 140° arc
	THRUST,       # Straight-line lunge, narrow, med-long range
	SMASH,        # Overhead slam, small AoE on impact
	WHIP,         # Medium-range thin sweep
	# Ranged
	SINGLE_SHOT,  # Hold to charge, release to fire
	BOOMERANG,    # Thrown + returns, hits twice
	BLASTER,      # Standard aimed projectile
	BEAM,         # Continuous line, 2s on / 1s recharge
	RAPID_FIRE,   # Spray of weak projectiles
	LOBBED,       # Arced throw, explodes on landing (AoE)
}

# --- Fishing Properties ---
var fish_name: String = "Fish"
var rarity: int = Rarity.COMMON
var biome: String = "Forest"
var habitat: Array = []        # Array of sub-biome location strings
var bite_time_range: Vector2 = Vector2(1.0, 3.0)
var reaction_window: float = 0.7
var fight_pattern: Array = []  # Array of string phases: "calm", "pull", "dart"
var preferred_baits: Array = []

# --- Combat Properties ---
var hp: int = 300
var speed: int = 5
var attack: int = 60
var defense: int = 20
var weapon: String = ""
var weapon_class: int = WeaponClass.SLASH
var special: String = ""       # "" = no special, otherwise ability name
var rarity_multiplier: float = 1.0

# Weapon name → WeaponClass lookup
const WEAPON_CLASS_MAP: Dictionary = {
	# SLASH
	"toothpick sword": WeaponClass.SLASH,
	"spork": WeaponClass.SLASH,
	"egg whisk": WeaponClass.SLASH,
	"cookie cutter": WeaponClass.SLASH,
	"axe": WeaponClass.SLASH,
	"fillet knife": WeaponClass.SLASH,
	"egg slicer": WeaponClass.SLASH,
	"feather blade": WeaponClass.SLASH,
	"pizza cutter": WeaponClass.SLASH,
	"dual daggers": WeaponClass.SLASH,
	"parrot beak": WeaponClass.SLASH,
	"machete": WeaponClass.SLASH,
	"fan blade": WeaponClass.SLASH,
	"hatchet": WeaponClass.SLASH,
	"leaf blade": WeaponClass.SLASH,
	"glass sword": WeaponClass.SLASH,
	"glacier blade": WeaponClass.SLASH,
	"crystal sword": WeaponClass.SLASH,
	"pyro claw": WeaponClass.SLASH,
	"ashfin slap": WeaponClass.SLASH,
	# HEAVY_SLASH
	"greatsword": WeaponClass.HEAVY_SLASH,
	"spectral scythe": WeaponClass.HEAVY_SLASH,
	"crab claw": WeaponClass.HEAVY_SLASH,
	"snowflake axe": WeaponClass.HEAVY_SLASH,
	"obsidian crush": WeaponClass.HEAVY_SLASH,
	# THRUST
	"fork spear": WeaponClass.THRUST,
	"harpoon": WeaponClass.THRUST,
	"dagger": WeaponClass.THRUST,
	"rapier": WeaponClass.THRUST,
	"trident": WeaponClass.THRUST,
	"neptune's trident": WeaponClass.THRUST,
	"sword": WeaponClass.THRUST,
	"narwhal lance": WeaponClass.THRUST,
	"spear": WeaponClass.THRUST,
	"ice pick": WeaponClass.THRUST,
	"ice dagger": WeaponClass.THRUST,
	"frost spear": WeaponClass.THRUST,
	"hotdog skewer": WeaponClass.THRUST,
	"lamprey bite": WeaponClass.THRUST,
	"salamander dash": WeaponClass.THRUST,
	"dragonbone spear": WeaponClass.THRUST,
	# SMASH
	"frying pan": WeaponClass.SMASH,
	"corncob club": WeaponClass.SMASH,
	"warhammer": WeaponClass.SMASH,
	"tambourine": WeaponClass.SMASH,
	"plunger": WeaponClass.SMASH,
	"boot dropkick": WeaponClass.SMASH,
	"deepsea lantern club": WeaponClass.SMASH,
	"blob slam": WeaponClass.SMASH,
	"boot kick": WeaponClass.SMASH,
	"club": WeaponClass.SMASH,
	"yeti club": WeaponClass.SMASH,
	"ice mallet": WeaponClass.SMASH,
	"frost boot bash": WeaponClass.SMASH,
	"snow shovel": WeaponClass.SMASH,
	"ice drum mallet": WeaponClass.SMASH,
	"avalanche hammer": WeaponClass.SMASH,
	"molten slam": WeaponClass.SMASH,
	"boot stomp": WeaponClass.SMASH,
	"jungle boot punt": WeaponClass.SMASH,
	# WHIP
	"nunchaku": WeaponClass.WHIP,
	"purse whip": WeaponClass.WHIP,
	"electric lash": WeaponClass.WHIP,
	"taser": WeaponClass.WHIP,
	"cat tail": WeaponClass.WHIP,
	"tongue lash": WeaponClass.WHIP,
	"eel whip": WeaponClass.WHIP,
	"frost lantern flail": WeaponClass.WHIP,
	"ember lash": WeaponClass.WHIP,
	# SINGLE_SHOT
	"fish bone bow": WeaponClass.SINGLE_SHOT,
	"cannon": WeaponClass.SINGLE_SHOT,
	# BOOMERANG
	"boomerang fin": WeaponClass.BOOMERANG,
	"moon boomerang": WeaponClass.BOOMERANG,
	"banana boomerang": WeaponClass.BOOMERANG,
	"chakram": WeaponClass.BOOMERANG,
	"peacock fan": WeaponClass.BOOMERANG,
	"boomerang": WeaponClass.BOOMERANG,
	"star boomerang": WeaponClass.BOOMERANG,
	"penguin flipper": WeaponClass.BOOMERANG,
	# BLASTER
	"slingshot": WeaponClass.BLASTER,
	"ink blaster": WeaponClass.BLASTER,
	"icicle dart": WeaponClass.BLASTER,
	"charred pebble shot": WeaponClass.BLASTER,
	"volcano pebble shot": WeaponClass.BLASTER,
	# BEAM
	"radioactive raygun": WeaponClass.BEAM,
	"bubble wand": WeaponClass.BEAM,
	"inferno breath": WeaponClass.BEAM,
	"firefly beam": WeaponClass.BEAM,
	# RAPID_FIRE
	"mini-gun": WeaponClass.RAPID_FIRE,
	"dart gun": WeaponClass.RAPID_FIRE,
	"banana gun": WeaponClass.RAPID_FIRE,
	"magma spit": WeaponClass.RAPID_FIRE,
	"pepper spray": WeaponClass.RAPID_FIRE,
	# LOBBED
	"mud bomb": WeaponClass.LOBBED,
	"snowball launcher": WeaponClass.LOBBED,
	"cinder toss": WeaponClass.LOBBED,
	"lava lantern bomb": WeaponClass.LOBBED,
	"soot cloud": WeaponClass.LOBBED,
}

# Stat inflation multiplier for combat display/gameplay
const STAT_INFLATION: int = 10

# Melee weapon classes get +15% HP bonus in combat
const MELEE_HP_BONUS: float = 0.15
const MELEE_CLASSES: Array = [
	WeaponClass.SLASH, WeaponClass.HEAVY_SLASH,
	WeaponClass.THRUST, WeaponClass.SMASH, WeaponClass.WHIP
]

func _init():
	pass

static func from_dict(data: Dictionary) -> Fish:
	"""
	Creates a Fish resource from a fish_data.gd dictionary entry.
	Applies x10 stat inflation to hp, attack, and defense.
	"""
	var fish = Fish.new()
	fish.fish_name = data.get("name", "Fish")
	fish.rarity = data.get("rarity", Rarity.COMMON)
	fish.biome = data.get("biome", "Forest")
	fish.habitat = data.get("habitat", [])
	fish.bite_time_range = data.get("bite_time_range", Vector2(1.0, 3.0))
	fish.reaction_window = data.get("reaction_window", 0.7)
	fish.fight_pattern = data.get("fight_pattern", [])
	fish.preferred_baits = data.get("preferred_baits", [])
	# Combat stats — inflated x10
	fish.hp = data.get("hp", 30) * STAT_INFLATION
	fish.speed = data.get("speed", 5)  # Speed stays raw (movement multiplier)
	fish.attack = data.get("attack", 6) * STAT_INFLATION
	fish.defense = data.get("defense", 2) * STAT_INFLATION
	fish.weapon = data.get("weapon", "")
	fish.special = data.get("special", "") if data.get("special") != null else ""
	fish.rarity_multiplier = data.get("rarity_multiplier", 1.0)
	# Resolve weapon class from lookup
	fish.weapon_class = WEAPON_CLASS_MAP.get(fish.weapon, WeaponClass.SLASH)
	return fish

func is_melee() -> bool:
	return weapon_class in MELEE_CLASSES

func get_combat_hp() -> int:
	"""Returns HP with melee bonus applied if applicable."""
	if is_melee():
		return int(hp * (1.0 + MELEE_HP_BONUS))
	return hp

func has_special() -> bool:
	return special != ""
