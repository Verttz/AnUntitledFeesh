extends Control

# ShopMenu.gd: Modern shop UI with drag-and-drop for buying/selling

signal item_bought(item_name)
signal item_sold(item_name)

@onready var shop_grid = $ShopPanel/ShopGrid
@onready var player_grid = $PlayerPanel/PlayerGrid
@onready var close_button = $CloseButton
@onready var gold_label = $GoldLabel
@onready var shopkeeper_label = $ShopkeeperLabel

var shop_inventory = []
var player_inventory = null
var buy_prices = {}
var sell_prices = {}
var player_gold = 0
var shopkeeper = ""

func open(shopkeeper_name, items_for_sale, buy_prices_dict, sell_prices_dict, player_inv, player_gold_amount):
    shopkeeper = shopkeeper_name
    shop_inventory = items_for_sale
    buy_prices = buy_prices_dict
    sell_prices = sell_prices_dict
    player_inventory = player_inv
    player_gold = player_gold_amount
    shopkeeper_label.text = shopkeeper
    gold_label.text = "Gold: %d" % player_gold
    visible = true
    _populate_shop()
    _populate_player()

func _ready():
    close_button.connect("pressed", self, "_on_close_pressed")
    visible = false

func _on_close_pressed():
    visible = false

func _populate_shop():
    shop_grid.clear()
    for item in shop_inventory:
        var icon = _create_item_icon(item, buy_prices.get(item, 0), true)
        shop_grid.add_child(icon)

func _populate_player():
    player_grid.clear()
    var items = player_inventory.get_items()
    for k in items.keys():
        var icon = _create_item_icon(k, sell_prices.get(k, 0), false)
        player_grid.add_child(icon)

func _create_item_icon(item_name, price, is_shop):
    var btn = Button.new()
    btn.text = str(item_name) + (price > 0 ? " (" + str(price) + ")" : "")
    btn.draggable = true
    btn.set_meta("item_name", item_name)
    btn.set_meta("is_shop", is_shop)
    btn.connect("gui_input", self, "_on_item_icon_gui_input", [item_name, price, is_shop, btn])
    return btn

func _on_item_icon_gui_input(event, item_name, price, is_shop, btn):
    if event is InputEventMouseButton and event.button_index == BUTTON_LEFT and event.pressed:
        btn.grab_focus()
    if event is InputEventMouseMotion and btn.has_focus():
        var drag_data = {
            "item_name": item_name,
            "price": price,
            "is_shop": is_shop
        }
        btn.release_focus()
        set_drag_preview(btn.duplicate())
        set_drag_data(drag_data, btn)

func can_drop_data(position, data):
    return typeof(data) == TYPE_DICTIONARY and data.has("item_name")

func drop_data(position, data):
    # Determine if buying or selling
    if data.is_shop:
        emit_signal("item_bought", data.item_name)
    else:
        emit_signal("item_sold", data.item_name)
