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
    close_button.pressed.connect(_on_close_pressed)
    visible = false

func _on_close_pressed():
    visible = false

func _populate_shop():
    for child in shop_grid.get_children():
        child.queue_free()
    for item in shop_inventory:
        var icon = _create_item_icon(item, buy_prices.get(item, 0), true)
        shop_grid.add_child(icon)

func _populate_player():
    for child in player_grid.get_children():
        child.queue_free()
    var items = player_inventory.get_items()
    for k in items.keys():
        var icon = _create_item_icon(k, sell_prices.get(k, 0), false)
        player_grid.add_child(icon)

func _create_item_icon(item_name, price, is_shop):
    var slot = _ShopSlot.new()
    slot.item_name = item_name
    slot.price = price
    slot.is_shop = is_shop
    slot.shop_menu = self
    slot.custom_minimum_size = Vector2(64, 64)
    var label = Label.new()
    label.text = str(item_name) + (" (" + str(price) + "g)" if price > 0 else "")
    label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
    slot.add_child(label)
    return slot

func _can_drop_data(_at_position, data):
    return typeof(data) == TYPE_DICTIONARY and data.has("item_name")

func _drop_data(_at_position, data):
    if data.get("is_shop", false):
        item_bought.emit(data["item_name"])
    else:
        item_sold.emit(data["item_name"])


# Inner class: draggable shop item slot using Godot 4 API
class _ShopSlot extends Panel:
    var item_name: String = ""
    var price: int = 0
    var is_shop: bool = false
    var shop_menu = null

    func _get_drag_data(_at_position):
        var data = {"item_name": item_name, "price": price, "is_shop": is_shop}
        var preview = Label.new()
        preview.text = item_name
        set_drag_preview(preview)
        return data

    func _can_drop_data(_at_position, data):
        return typeof(data) == TYPE_DICTIONARY and data.has("item_name")

    func _drop_data(_at_position, data):
        if shop_menu:
            shop_menu._drop_data(_at_position, data)
