extends Node

# UpgradeManager.gd — Thin facade delegating to ProgressionManager.

signal upgrade_available(upgrade_name)
signal upgrade_purchased(upgrade_name)

var available_upgrades: Array:
	get:
		var pm = get_node_or_null("/root/ProgressionManager")
		return pm.available_upgrades if pm else []

var purchased_upgrades: Array:
	get:
		var pm = get_node_or_null("/root/ProgressionManager")
		return pm.upgrades if pm else []
	set(v):
		var pm = get_node_or_null("/root/ProgressionManager")
		if pm: pm.upgrades = v

var fish_currency: int:
	get:
		var pm = get_node_or_null("/root/ProgressionManager")
		return pm.fish_currency if pm else 0
	set(v):
		var pm = get_node_or_null("/root/ProgressionManager")
		if pm: pm.fish_currency = v

func add_fish_currency(amount):
	var pm = get_node_or_null("/root/ProgressionManager")
	if pm: pm.add_fish_currency(amount)

func can_purchase(upgrade_name, cost):
	var pm = get_node_or_null("/root/ProgressionManager")
	if pm: return pm.can_purchase(upgrade_name, cost)
	return false

func purchase_upgrade(upgrade_name, cost):
	if can_purchase(upgrade_name, cost):
		fish_currency -= cost
		var pm = get_node_or_null("/root/ProgressionManager")
		if pm: pm.purchase_upgrade(upgrade_name)
		upgrade_purchased.emit(upgrade_name)
		return true
	return false
