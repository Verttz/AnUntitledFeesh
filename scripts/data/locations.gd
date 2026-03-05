
# locations.gd
# Location data for each biome: shops, fishing spots, and boss gates.
# Biome keys must match BiomeData.BIOME_ORDER in biomes.gd.
# Fishing spot habitats must match fish habitat arrays in fish_data.gd.

const LOCATIONS = {
	"Forest": [
		{
			"name": "Fisher's Dock",
			"type": "shop",
			"shopkeeper": "Old Man Gill",
			"items_for_sale": ["Basic Rod", "Worm Bait", "Minnow Bait", "Roe Bait", "Fly Bait", "Stinkbait", "Corn Bait", "Float Lure"],
			"buy_prices": {"Basic Rod": 50, "Worm Bait": 5, "Minnow Bait": 8, "Roe Bait": 12, "Fly Bait": 8, "Stinkbait": 7, "Corn Bait": 3, "Float Lure": 15},
			"sell_prices": {"Bluegill": 5, "Perch": 6, "Trout": 10, "Largemouth Bass": 15, "Catfish": 18, "Salmon": 25, "Pike": 22},
			"notice_board_hints": [
				"Biggest catch this week: 2.1kg Carp!",
				"Try fishing at dawn for rare bites.",
				"The Muskellunge lurks in the deep lake...",
			],
		},
		{
			"name": "Shady Cove",
			"type": "fishing_spot",
			"habitat": "lake",
		},
		{
			"name": "Rocky Shoreline",
			"type": "fishing_spot",
			"habitat": "lake_shore",
		},
		{
			"name": "The Deep End",
			"type": "fishing_spot",
			"habitat": "lake_deep",
		},
		{
			"name": "Whispering Creek",
			"type": "fishing_spot",
			"habitat": "creek",
		},
		{
			"name": "Deep Pond",
			"type": "fishing_spot",
			"habitat": "pond",
		},
		{
			"name": "Rushing River",
			"type": "fishing_spot",
			"habitat": "river",
		},
		{
			"name": "River's Mouth",
			"type": "fishing_spot",
			"habitat": "river_mouth",
		},
		{
			"name": "The Abyss",
			"type": "fishing_spot",
			"habitat": "river_deep",
		},
		{
			"name": "Muddy Puddle",
			"type": "fishing_spot",
			"habitat": "puddle",
		},
		{
			"name": "Gate to Ocean",
			"type": "boss_gate",
			"next_biome": "Ocean",
		},
	],
	"Ocean": [
		{
			"name": "Pier Market",
			"type": "shop",
			"shopkeeper": "Captain Sal",
			"items_for_sale": ["Sea Rod", "Shrimp Bait", "Squid Bait", "Seaweed Bait", "Crab Bait", "Spinner Lure", "Chum Bucket"],
			"buy_prices": {"Sea Rod": 120, "Shrimp Bait": 10, "Squid Bait": 15, "Seaweed Bait": 5, "Crab Bait": 15, "Spinner Lure": 30, "Chum Bucket": 25},
			"sell_prices": {"Clownfish": 8, "Tuna": 30, "Swordfish": 50, "Marlin": 60, "Barracuda": 20},
			"notice_board_hints": [
				"Swordfish spotted near the shipwreck!",
				"Chum attracts bigger fish in open sea.",
				"Something ancient sleeps in the kelp forest...",
			],
		},
		{
			"name": "Coral Reef",
			"type": "fishing_spot",
			"habitat": "reef",
		},
		{
			"name": "Open Waters",
			"type": "fishing_spot",
			"habitat": "open_sea",
		},
		{
			"name": "Kelp Forest",
			"type": "fishing_spot",
			"habitat": "kelp_forest",
		},
		{
			"name": "The Deep",
			"type": "fishing_spot",
			"habitat": "deep_sea",
		},
		{
			"name": "Sunken Ship",
			"type": "fishing_spot",
			"habitat": "shipwreck",
		},
		{
			"name": "Tidal Pools",
			"type": "fishing_spot",
			"habitat": "tidepool",
		},
		{
			"name": "Fishing Boat",
			"type": "fishing_spot",
			"habitat": "boat",
		},
		{
			"name": "Sandy Shore",
			"type": "fishing_spot",
			"habitat": "shore",
		},
		{
			"name": "Gate to Jungle",
			"type": "boss_gate",
			"next_biome": "Jungle",
		},
	],
	"Jungle": [
		{
			"name": "Canopy Trading Post",
			"type": "shop",
			"shopkeeper": "Vine Vicky",
			"items_for_sale": ["Jungle Rod", "Meat Bait", "Fruit Bait", "Banana Bait", "Grub Bait", "Fly Lure", "Bow-Fishing Kit"],
			"buy_prices": {"Jungle Rod": 200, "Meat Bait": 12, "Fruit Bait": 10, "Banana Bait": 10, "Grub Bait": 15, "Fly Lure": 40, "Bow-Fishing Kit": 150},
			"sell_prices": {"Piranha": 10, "Electric Eel": 25, "Arapaima": 45, "Peacock Bass": 30, "Frogfish": 28},
			"notice_board_hints": [
				"Careful in the swamp — piranhas bite back!",
				"Rare fish hide behind the waterfall.",
				"The Rainbow Dartfish only appears in the streams...",
			],
		},
		{
			"name": "Murky Swamp",
			"type": "fishing_spot",
			"habitat": "swamp",
		},
		{
			"name": "Jungle Stream",
			"type": "fishing_spot",
			"habitat": "jungle_stream",
		},
		{
			"name": "Lily Pad Lagoon",
			"type": "fishing_spot",
			"habitat": "floating_plants",
		},
		{
			"name": "Serpent's Bend",
			"type": "fishing_spot",
			"habitat": "river_bend",
		},
		{
			"name": "Flooded Ruins",
			"type": "fishing_spot",
			"habitat": "flooded_forest",
		},
		{
			"name": "Mangrove Roots",
			"type": "fishing_spot",
			"habitat": "mangrove",
		},
		{
			"name": "Gate to Frozen Mountain",
			"type": "boss_gate",
			"next_biome": "FrozenMountain",
		},
	],
	"FrozenMountain": [
		{
			"name": "Summit Supply",
			"type": "shop",
			"shopkeeper": "Frosty Fergus",
			"items_for_sale": ["Ice Rod", "Glowworm Bait", "Ice Worm Bait", "Ice Shrimp Bait", "Ice Jig", "Thermal Line"],
			"buy_prices": {"Ice Rod": 300, "Glowworm Bait": 20, "Ice Worm Bait": 18, "Ice Shrimp Bait": 22, "Ice Jig": 50, "Thermal Line": 100},
			"sell_prices": {"Arctic Char": 20, "Ice Perch": 18, "Frostfin Pike": 40, "Glacier Salmon": 50},
			"notice_board_hints": [
				"Ice holes freeze over fast — keep moving!",
				"The glacier lake holds the biggest catches.",
				"Something ancient lurks beneath the ice cave...",
			],
		},
		{
			"name": "Glacier Lake",
			"type": "fishing_spot",
			"habitat": "glacier_lake",
		},
		{
			"name": "Ice Cave Pool",
			"type": "fishing_spot",
			"habitat": "ice_cave",
		},
		{
			"name": "Snowmelt Stream",
			"type": "fishing_spot",
			"habitat": "snowmelt_stream",
		},
		{
			"name": "Frozen Pond",
			"type": "fishing_spot",
			"habitat": "frozen_pond",
		},
		{
			"name": "Icy River",
			"type": "fishing_spot",
			"habitat": "icy_river",
		},
		{
			"name": "Gate to Lava",
			"type": "boss_gate",
			"next_biome": "Lava",
		},
	],
	"Lava": [
		{
			"name": "Magma Mart",
			"type": "shop",
			"shopkeeper": "Ember Eddie",
			"items_for_sale": ["Lava Rod", "Magma Bait", "Fire Worm Bait", "Ember Shrimp Bait", "Lava Minnow Bait", "Hotdog Bait", "Hot Pepper Bait", "Obsidian Lure", "Heatproof Line"],
			"buy_prices": {"Lava Rod": 500, "Magma Bait": 30, "Fire Worm Bait": 25, "Ember Shrimp Bait": 28, "Lava Minnow Bait": 30, "Hotdog Bait": 10, "Hot Pepper Bait": 20, "Obsidian Lure": 75, "Heatproof Line": 150},
			"sell_prices": {"Magma Carp": 30, "Molten Bass": 40, "Ember Eel": 50, "Inferno Dragonfish": 100},
			"notice_board_hints": [
				"Fish near geysers for the rarest catches!",
				"The caldera is off-limits... unless you're brave.",
				"Volcanic streams hold the most variety.",
			],
		},
		{
			"name": "Lava Pool",
			"type": "fishing_spot",
			"habitat": "lava_pool",
		},
		{
			"name": "Volcanic Stream",
			"type": "fishing_spot",
			"habitat": "volcanic_stream",
		},
		{
			"name": "Fire Cave",
			"type": "fishing_spot",
			"habitat": "fire_cave",
		},
		{
			"name": "Ash Shore",
			"type": "fishing_spot",
			"habitat": "ash_shore",
		},
		{
			"name": "Geyser Basin",
			"type": "fishing_spot",
			"habitat": "geyser",
		},
		{
			"name": "Caldera Edge",
			"type": "fishing_spot",
			"habitat": "caldera",
		},
		{
			"name": "Magma Vent",
			"type": "fishing_spot",
			"habitat": "magma_vent",
		},
		{
			"name": "Gate to Fishing Sanctum",
			"type": "boss_gate",
			"next_biome": "FishingSanctum",
		},
	],
	"FishingSanctum": [
		{
			"name": "The Sanctum",
			"type": "fishing_spot",
			"habitat": "sanctum",
		},
	],
}
