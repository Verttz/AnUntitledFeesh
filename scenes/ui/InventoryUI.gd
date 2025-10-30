extends Control

# InventoryUI.gd: Handles displaying and interacting with the player's inventory

signal item_selected(item_name, item_data)

var inventory_ref = null # Reference to Inventory.gd instance

func _ready():
    $Panel/CloseButton.connect("pressed", self, "hide")
    hide()

func open(inventory):
    inventory_ref = inventory
    _populate_items()
    show()

func _populate_items():
    var grid = $Panel/ItemGrid
    grid.clear()
    if not inventory_ref:
        return
    var items = inventory_ref.get_items()
    for item_name in items.keys():
        var count = items[item_name]
        var btn = Button.new()
        btn.text = str(item_name) + (" x" + str(count) if typeof(count) == TYPE_INT else "")
        btn.connect("pressed", self, "_on_item_pressed", [item_name, count])
        grid.add_child(btn)

func _on_item_pressed(item_name, item_data):
    emit_signal("item_selected", item_name, item_data)
