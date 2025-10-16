# Shop.gd
# Handles shop logic for buying/selling and notice board hints

extends Node


var shopkeeper = ""
var inventory = [] # Items for sale
var player_inventory = [] # Reference to player's inventory
var player_node = null # Reference to player node for gold/inventory
var buy_prices = {} # {item_name: price}
var sell_prices = {} # {fish_name: price}
var notice_board_hints = []
var shop_menu = null

func open(shopkeeper_name, items_for_sale, buy_prices_dict, sell_prices_dict, hints, player_inv):
	shopkeeper = shopkeeper_name
	inventory = items_for_sale
	buy_prices = buy_prices_dict
	sell_prices = sell_prices_dict
	notice_board_hints = hints
	player_inventory = player_inv
	player_node = get_parent() # Assumes Player is parent
	print("Welcome to the shop! I am " + shopkeeper)
	# Show new ShopMenu UI
	var ShopMenu = preload("res://scenes/ui/shop/ShopMenu.tscn")
	shop_menu = ShopMenu.instantiate()
	add_child(shop_menu)
	shop_menu.open(shopkeeper, inventory, buy_prices, sell_prices, player_inventory, player_node.player_gold)
	shop_menu.connect("item_bought", self, "_on_item_bought")
	shop_menu.connect("item_sold", self, "_on_item_sold")
func _on_item_bought(item_name):
	buy_item(item_name)
	if shop_menu:
		shop_menu.visible = false
func _on_item_sold(item_name):
	sell_fish(item_name)
	if shop_menu:
		shop_menu.visible = false

func buy_item(item_name):
	if item_name in buy_prices:
		var price = buy_prices[item_name]
		if player_node and player_node.spend_gold(price):
			player_node.add_item_to_inventory(item_name)
			print("Bought " + item_name + " for " + str(price) + " gold.")
		else:
			print("Not enough gold to buy " + item_name)
	else:
		print("Item not for sale: " + item_name)

func sell_fish(fish_name):
	if fish_name in sell_prices:
		var price = sell_prices[fish_name]
		if player_node:
			if fish_name in player_inventory:
				player_node.remove_fish_from_inventory(fish_name)
				player_node.add_gold(price)
				print("Sold " + fish_name + " for " + str(price) + " gold.")
			else:
				print("You don't have a " + fish_name + " to sell.")
		else:
			print("No player node reference.")
	else:
		print("Shop does not buy: " + fish_name)

func show_notice_board():
	print("Notice Board:")
	for hint in notice_board_hints:
		print("- " + hint)
