
# locations.gd
# Example structure for locations, including shops

LOCATIONS = {
	"Lake": [
		{
			"name": "Fisher's Dock",
			"type": "shop",
			"shopkeeper": "Old Man Gill",
			"items_for_sale": ["Basic Rod", "Worm Bait", "Float Lure"],
			"buy_prices": {"Basic Rod": 50, "Worm Bait": 5, "Float Lure": 15},
			"sell_prices": {"Carp": 8, "Minnow": 2, "Bass": 12},
			"notice_board_hints": [
				"Biggest catch this week: 2.1kg Carp!",
				"Try fishing at dawn for rare bites."
			]
		},
		{
			"name": "Shady Cove",
			"type": "fishing_spot",
			"habitat": "lake"
		},
		{
			"name": "Gate to River",
			"type": "boss_gate",
			"next_biome": "River"
		}
	],
	"River": [
		{
			"name": "Riverbank Shop",
			"type": "shop",
			"shopkeeper": "Maggie",
			"items_for_sale": ["River Rod", "Cricket Bait", "Spinner Lure"],
			"buy_prices": {"River Rod": 120, "Cricket Bait": 10, "Spinner Lure": 30},
			"sell_prices": {"Trout": 18, "Minnow": 2, "Catfish": 25},
			"notice_board_hints": [
				"Catfish bite best at night!"
			]
		},
		{
			"name": "Rapid Run",
			"type": "fishing_spot",
			"habitat": "river"
		},
		{
			"name": "Gate to Marsh",
			"type": "boss_gate",
			"next_biome": "Marsh"
		}
	]
}
