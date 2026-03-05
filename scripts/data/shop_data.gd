# shop_data.gd
# Centralized shop inventory definitions per biome.
# Each biome's shop has items for sale, buy/sell prices, and upgrade unlocks.
# locations.gd defines *where* shops are; this defines *what* they stock.
# Referenced by: ShopMenu.gd, Shop.gd

# Items available at each biome's shop, with buy prices.
# Sell prices for fish come from item_data.gd (sell_price field),
# multiplied by BiomeData.get_sell_multiplier() for the current biome.
const SHOP_INVENTORY = {
	"Forest": {
		"items": [
			"Basic Rod", "Worm Bait", "Minnow Bait", "Roe Bait",
			"Fly Bait", "Stinkbait", "Corn Bait", "Bread Bait",
			"Float Lure", "Basic Line", "Basic Sinker",
		],
		"upgrades": [],
	},
	"Ocean": {
		"items": [
			"Sea Rod", "Shrimp Bait", "Squid Bait", "Seaweed Bait",
			"Crab Bait", "Chum Bucket",
			"Spinner Lure", "Basic Line",
		],
		"upgrades": ["Tackle Box Expansion I"],
	},
	"Jungle": {
		"items": [
			"Jungle Rod", "Meat Bait", "Fruit Bait", "Banana Bait",
			"Grub Bait", "Bow-Fishing Kit",
			"Fly Lure", "Heavy Sinker",
		],
		"upgrades": ["Tackle Box Expansion II"],
	},
	"FrozenMountain": {
		"items": [
			"Ice Rod", "Glowworm Bait", "Ice Worm Bait",
			"Ice Shrimp Bait", "Ice Jig", "Thermal Line",
		],
		"upgrades": ["Insulated Tackle Box"],
	},
	"Lava": {
		"items": [
			"Lava Rod", "Magma Bait", "Fire Worm Bait",
			"Ember Shrimp Bait", "Lava Minnow Bait",
			"Hotdog Bait", "Hot Pepper Bait",
			"Obsidian Lure", "Heatproof Line",
		],
		"upgrades": ["Fireproof Tackle Box"],
	},
	"FishingSanctum": {
		"items": [
			"Mystery Bait", "Legendary Bait",
		],
		"upgrades": [],
	},
}

# Upgrade definitions — unlockable perks sold at shops.
const UPGRADES = {
	"Tackle Box Expansion I": {
		"display_name": "Tackle Box Expansion I",
		"description": "Adds 5 extra inventory slots.",
		"buy_price": 200,
		"effect": {"max_slots_bonus": 5},
	},
	"Tackle Box Expansion II": {
		"display_name": "Tackle Box Expansion II",
		"description": "Adds 5 more inventory slots.",
		"buy_price": 500,
		"effect": {"max_slots_bonus": 5},
	},
	"Insulated Tackle Box": {
		"display_name": "Insulated Tackle Box",
		"description": "Bait lasts twice as long in cold biomes.",
		"buy_price": 400,
		"effect": {"bait_duration_mult": 2.0, "biome": "FrozenMountain"},
	},
	"Fireproof Tackle Box": {
		"display_name": "Fireproof Tackle Box",
		"description": "Bait lasts twice as long in lava biomes.",
		"buy_price": 600,
		"effect": {"bait_duration_mult": 2.0, "biome": "Lava"},
	},
}

# Helper: get all buyable items for a biome (items + upgrades)
static func get_shop_items(biome: String) -> Array:
	if biome in SHOP_INVENTORY:
		return SHOP_INVENTORY[biome]["items"]
	return []

static func get_shop_upgrades(biome: String) -> Array:
	if biome in SHOP_INVENTORY:
		return SHOP_INVENTORY[biome]["upgrades"]
	return []

static func get_upgrade_data(upgrade_name: String) -> Dictionary:
	if upgrade_name in UPGRADES:
		return UPGRADES[upgrade_name]
	return {}
