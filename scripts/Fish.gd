
extends Resource

class_name Fish

"""
Fish.gd
-------
Defines the Fish resource, used for all catchable fish in the game.
Properties include rarity, biome, habitat, bite timing, fight pattern, and preferred baits.
"""

# Fish rarity levels
enum Rarity { COMMON, UNCOMMON, RARE, LEGENDARY }

# --- Fish Properties ---
var name: String # Name of the fish
var rarity: int = Rarity.COMMON # Rarity enum value
var biome: String = "Lake" # Biome where fish is found
var habitat: String = "lake" # e.g., lake, river, pond, mouth, puddle, etc.
var bite_time_range: Vector2 = Vector2(1.0, 3.0) # Min/max seconds before bite
var reaction_window: float = 0.7 # Time to hook after bite
var fight_pattern: Array = [] # Array of string phases: "calm", "pull", "dart", etc.
var preferred_baits: Array = [] # List of bait names this fish prefers

func _init(_name: String = "Fish", _rarity: int = Rarity.COMMON, _biome: String = "Lake", _habitat: String = "lake", _bite_time_range: Vector2 = Vector2(1.0,3.0), _reaction_window: float = 0.7, _fight_pattern: Array = [], _preferred_baits: Array = []):
	"""
	Constructor for Fish resource. Sets all fish properties.
	"""
	name = _name
	rarity = _rarity
	biome = _biome
	habitat = _habitat
	bite_time_range = _bite_time_range
	reaction_window = _reaction_window
	fight_pattern = _fight_pattern
	preferred_baits = _preferred_baits
