
class_name BiomeData

# Central biome definitions - single source of truth for all biome/sub-biome data.
# All other systems should reference this for biome names and structure.

const BIOME_ORDER := ["Forest", "Ocean", "Jungle", "FrozenMountain", "Lava", "FishingSanctum"]

const BIOMES := {
	"Forest": {
		"display_name": "Forest",
		"description": "A lush forest filled with rivers, lakes, and hidden ponds. The perfect place to learn the art of fishing.",
		"sub_biomes": ["lake", "lake_deep", "lake_shore", "pond", "puddle", "river", "river_mouth", "river_deep", "creek"],
		"bosses": ["TheGreatFisherduck", "DonCatfishoni"],
		"sell_multiplier": 1.0,
	},
	"Ocean": {
		"display_name": "Ocean",
		"description": "Sun-drenched beaches and endless open water. Saltwater challenges and quirky seafaring NPCs await.",
		"sub_biomes": ["reef", "open_sea", "tidepool", "deep_sea", "shipwreck", "kelp_forest", "shore", "dock", "boat"],
		"bosses": ["FinDiesel", "CaptainPinchbeard"],
		"sell_multiplier": 2.0,
	},
	"Jungle": {
		"display_name": "Jungle",
		"description": "Dense jungle canopy and winding wetlands. New fishing techniques, natural hazards, and exotic wildlife.",
		"sub_biomes": ["swamp", "floating_plants", "jungle_stream", "flooded_forest", "river_bend", "mangrove", "waterfall"],
		"bosses": ["Guppazuma", "CroakKing"],
		"sell_multiplier": 2.5,
	},
	"FrozenMountain": {
		"display_name": "Frozen Mountain",
		"description": "Frigid peaks and icy waters. Treacherous terrain, tough locals, and dramatic encounters.",
		"sub_biomes": ["glacier_lake", "icy_river", "ice_cave", "frozen_pond", "snowmelt_stream", "ice_hole"],
		"bosses": ["AbominableSnowbass", "FrostbiteMaestro"],
		"sell_multiplier": 3.0,
	},
	"Lava": {
		"display_name": "Lava",
		"description": "An active volcano where fish swim in molten rock. Over-the-top guardians and the truth draws near.",
		"sub_biomes": ["lava_pool", "magma_vent", "fire_cave", "ash_shore", "volcanic_stream", "geyser", "caldera"],
		"bosses": ["MagmaChef", "PranksterPoppo"],
		"sell_multiplier": 4.0,
	},
	"FishingSanctum": {
		"display_name": "Fishing Sanctum",
		"description": "A mysterious post-game zone. Its secrets have yet to be revealed.",
		"sub_biomes": [],
		"bosses": [],
		"sell_multiplier": 5.0,
	},
}

static func get_biome_at(index: int) -> String:
	if index >= 0 and index < BIOME_ORDER.size():
		return BIOME_ORDER[index]
	return ""

static func get_sub_biomes(biome_id: String) -> Array:
	if BIOMES.has(biome_id):
		return BIOMES[biome_id]["sub_biomes"]
	return []

static func get_display_name(biome_id: String) -> String:
	if BIOMES.has(biome_id):
		return BIOMES[biome_id]["display_name"]
	return biome_id

static func get_next_biome(current: String) -> String:
	var idx = BIOME_ORDER.find(current)
	if idx != -1 and idx < BIOME_ORDER.size() - 1:
		return BIOME_ORDER[idx + 1]
	return ""

static func get_bosses(biome_id: String) -> Array:
	if BIOMES.has(biome_id):
		return BIOMES[biome_id]["bosses"]
	return []

static func get_sell_multiplier(biome_id: String) -> float:
	if BIOMES.has(biome_id):
		return BIOMES[biome_id]["sell_multiplier"]
	return 1.0
