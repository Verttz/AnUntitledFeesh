# InventoryMenuLoader.gd
# Helper to load and show the inventory menu from anywhere
extends Node

var inventory_menu = null

func show_inventory(player):
    if not inventory_menu:
        inventory_menu = preload("res://scenes/ui/inventory/InventoryMenu.tscn").instantiate()
        get_tree().get_root().add_child(inventory_menu)
    inventory_menu.open(player.backpack, player.tacklebox)
    inventory_menu.raise_()
    inventory_menu.visible = true

func hide_inventory():
    if inventory_menu:
        inventory_menu.visible = false
