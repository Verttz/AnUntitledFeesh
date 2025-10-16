extends Control

# InventoryMenu.gd: Handles display and logic for Backpack and Tacklebox

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
    close_button.connect("pressed", self, "_on_close_pressed")
    visible = false

func _on_close_pressed():
    visible = false

func _populate_backpack():
    backpack_grid.clear()
    var items = backpack_inventory.get_items()
    var slot_count = 9 # Default 3x3
    var keys = items.keys()
    var i = 0
    for k in keys:
        if i >= slot_count:
            break
        var icon = _create_item_icon(k, items[k])
        backpack_grid.add_child(icon)
        i += 1
    # Fill empty slots
    for j in range(i, slot_count):
        backpack_grid.add_child(_create_empty_slot())

func _populate_tacklebox():
    # For each tab, clear and add items by type
    var lures_grid = tacklebox_tabs.get_node("Lures/LuresGrid")
    var bait_grid = tacklebox_tabs.get_node("Bait/BaitGrid")
    var rods_grid = tacklebox_tabs.get_node("Rods/RodsGrid")
    lures_grid.clear()
    bait_grid.clear()
    rods_grid.clear()
    var items = tacklebox_inventory.get_items()
    for k in items.keys():
        var item_type = _get_item_type(k)
        var icon = _create_item_icon(k, items[k])
        match item_type:
            "lure": lures_grid.add_child(icon)
            "bait": bait_grid.add_child(icon)
            "rod": rods_grid.add_child(icon)
            _: pass

func _create_item_icon(item_name, amount):
    var btn = Button.new()
    btn.text = str(item_name) + (amount > 1 ? " x" + str(amount) : "")
    btn.draggable = true
    btn.connect("gui_input", self, "_on_item_icon_gui_input", [item_name, amount, btn])
    btn.set_meta("item_name", item_name)
    btn.set_meta("amount", amount)
    # TODO: Set icon texture, tooltip, signals
    return btn

# Drag-and-drop logic for item icons
func _on_item_icon_gui_input(event, item_name, amount, btn):
    if event is InputEventMouseButton and event.button_index == BUTTON_LEFT and event.pressed:
        btn.grab_focus()
    if event is InputEventMouseMotion and btn.has_focus():
        var drag_data = {
            "item_name": item_name,
            "amount": amount
        }
        # If this is a fish, try to provide full metadata (for tribute)
        if backpack_inventory and backpack_inventory.has_method("get_all_fish"):
            var fish_list = backpack_inventory.get_all_fish()
            for fish in fish_list:
                if fish.has("name") and fish.name == item_name:
                    for k in fish.keys():
                        drag_data[k] = fish[k]
                    break
        btn.release_focus()
        set_drag_preview(btn.duplicate())
        set_drag_data(drag_data, btn)

func get_drag_data(position):
    # Called by Godot when a drag starts from this Control
    return get_viewport().gui_get_drag_data()

func can_drop_data(position, data):
    # Accept drops if data contains item_name
    return typeof(data) == TYPE_DICTIONARY and data.has("item_name")

func drop_data(position, data):
    # Handle item drop (move, swap, or use)
    # For now, just print what was dropped
    print("Dropped item:", data)

func _create_empty_slot():
    var slot = Panel.new()
    slot.rect_min_size = Vector2(64, 64)
    slot.modulate = Color(0.2, 0.2, 0.2, 0.3)
    return slot

func _get_item_type(item_name):
    # TODO: Use item_data or metadata to determine type
    if "lure" in item_name.lower():
        return "lure"
    if "bait" in item_name.lower():
        return "bait"
    if "rod" in item_name.lower():
        return "rod"
    return "other"
