extends Node

# Handles upgrades purchased with fish sales

signal upgrade_available(upgrade_name)
signal upgrade_purchased(upgrade_name)

var available_upgrades := ["Rod1", "Rod2", "Boat", "BaitBag"]
var purchased_upgrades := []
var fish_currency := 0

func add_fish_currency(amount):
	fish_currency += amount

func can_purchase(upgrade_name, cost):
	return fish_currency >= cost and not purchased_upgrades.has(upgrade_name)

func purchase_upgrade(upgrade_name, cost):
	if can_purchase(upgrade_name, cost):
		fish_currency -= cost
		purchased_upgrades.append(upgrade_name)
		emit_signal("upgrade_purchased", upgrade_name)
		return true
	return false
