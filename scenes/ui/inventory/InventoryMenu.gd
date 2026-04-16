extends Control

# InventoryMenu.gd: Handles display and logic for Backpack and Tacklebox
# Uses Godot 4 drag-and-drop API: _get_drag_data / _can_drop_data / _drop_data

@onready var backpack_grid = $BackpackPanel/BackpackGrid
@onready var tacklebox_tabs = $TackleboxPanel/TackleboxTabs
@onready var close_button = $CloseButton

var backpack_inventory = null # Set to Player.backpack
var tacklebox_inventory = null # Set to Player.tacklebox

# Called to open the inventory menu and populate grids
func open(backpack, tacklebox):
    backpack_inventory = backpack
    tacklebox_inventory = tacklebox
    visible = true
    _populate_backpack()
    _populate_tacklebox()

func _ready():
    close_button.pressed.connect(_on_close_pressed)
    visible = false

func _on_close_pressed():
    visible = false

func _populate_backpack():
    for child in backpack_grid.get_children():
        child.queue_free()
    var items = backpack_inventory.get_items()
    var slot_count = 9 # Default 3x3
    var keys = items.keys()
    var i = 0
    for k in keys:
        if i >= slot_count:
            break
        var icon = _create_item_slot(k, items[k])
        backpack_grid.add_child(icon)
        i += 1
    # Fill empty slots
    for j in range(i, slot_count):
        backpack_grid.add_child(_create_empty_slot())

func _populate_tacklebox():
    var lures_grid = tacklebox_tabs.get_node("Lures/LuresGrid")
    var bait_grid = tacklebox_tabs.get_node("Bait/BaitGrid")
    var rods_grid = tacklebox_tabs.get_node("Rods/RodsGrid")
    for child in lures_grid.get_children():
        child.queue_free()
    for child in bait_grid.get_children():
        child.queue_free()
    for child in rods_grid.get_children():
        child.queue_free()
    var items = tacklebox_inventory.get_items()
    for k in items.keys():
        var item_type = _get_item_type(k)
        var icon = _create_item_slot(k, items[k])
        match item_type:
            "lure": lures_grid.add_child(icon)
            "bait": bait_grid.add_child(icon)
            "rod": rods_grid.add_child(icon)
            _: pass

func _create_item_slot(item_name: String, amount) -> Control:
    # ItemSlot is a Panel that implements Godot 4 drag-and-drop virtuals
    var slot = _ItemSlot.new()
    slot.item_name = item_name
    slot.amount = amount
    slot.inventory_menu = self
    slot.custom_minimum_size = Vector2(64, 64)
    var label = Label.new()
    label.text = str(item_name) + (" x" + str(amount) if amount is int and amount > 1 else "")
    label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
    slot.add_child(label)
    return slot

func _create_empty_slot():
    var slot = Panel.new()
    slot.custom_minimum_size = Vector2(64, 64)
    slot.modulate = Color(0.2, 0.2, 0.2, 0.3)
    return slot

# --- Godot 4 drop target on backpack grid area ---
func _can_drop_data(_at_position, data):
    return typeof(data) == TYPE_DICTIONARY and data.has("item_name")

func _drop_data(at_position, data):
    var slot_size = Vector2(64, 64)
    var grid_pos = backpack_grid.get_global_position()
    var local_pos = at_position - (grid_pos - get_global_position())
    var col = int(local_pos.x / slot_size.x)
    var row = int(local_pos.y / slot_size.y)
    var slot_index = clampi(row * 3 + col, 0, 8)

    var item_name = data["item_name"]
    if backpack_inventory.has_method("move_item_to_slot"):
        var from_index = data.get("from_index", 0)
        backpack_inventory.move_item_to_slot(item_name, from_index, slot_index)
    _populate_backpack()

func _get_item_type(item_name):
    if "lure" in item_name.to_lower():
        return "lure"
    if "bait" in item_name.to_lower():
        return "bait"
    if "rod" in item_name.to_lower():
        return "rod"
    return "other"


# Inner class: draggable item slot using Godot 4 virtual overrides
class _ItemSlot extends Panel:
    var item_name: String = ""
    var amount = 1
    var inventory_menu = null

    func _get_drag_data(_at_position):
        var data = {"item_name": item_name, "amount": amount}
        # Build preview
        var preview = Label.new()
        preview.text = item_name
        set_drag_preview(preview)
        return data

    func _can_drop_data(_at_position, data):
        return typeof(data) == TYPE_DICTIONARY and data.has("item_name")

    func _drop_data(_at_position, data):
        if inventory_menu:
            inventory_menu._drop_data(_at_position + get_global_position(), data)
