extends Node2D

# Base script for an overworld screen/area

signal screen_exit(direction)



var pause_menu = null
var save_notification = null
var player = null
var boss_guard = null
var inventory_menu_loader = null
var INTERACT_DISTANCE := 48

func _ready():
    # Add PauseMenu as child
    pause_menu = preload("res://scenes/ui/PauseMenu.tscn").instantiate()
    add_child(pause_menu)
    pause_menu.visible = false
    # Add SaveNotification as child
    save_notification = preload("res://scenes/ui/SaveNotification.tscn").instantiate()
    add_child(save_notification)
    save_notification.visible = false
    # Add Player as child (centered for demo)
    player = preload("res://scenes/Player.tscn").instantiate()
    player.position = Vector2(200, 200)
    add_child(player)
    # Add InventoryMenuLoader as child (hidden node)
    inventory_menu_loader = preload("res://scenes/ui/inventory/InventoryMenuLoader.gd").new()
    add_child(inventory_menu_loader)
    # Add BossGateGuard (with tribute UI) as child (for demo, place at x=400, y=200)
    boss_guard = preload("res://scenes/overworld/BossGateGuard_with_tribute.tscn").instantiate()
    boss_guard.position = Vector2(400, 200)
    add_child(boss_guard)
    boss_guard.connect("tribute_accepted", self, "_on_tribute_accepted")
    boss_guard.connect("tribute_rejected", self, "_on_tribute_rejected")

func _on_tribute_accepted(tribute_fish):
    print("Tribute accepted! Fish: %s" % [str(tribute_fish)])
    # TODO: Transition to boss screen/cutscene

func _on_tribute_rejected():
    print("Tribute rejected. Not enough fish.")

func show_save_notification():
    if save_notification:
        save_notification.show_notification()

func _unhandled_input(event):
    if event.is_action_pressed("ui_cancel") and not get_tree().paused:
        pause_menu.open()
    elif event.is_action_pressed("ui_cancel") and get_tree().paused:
        pause_menu.close()
    # Open inventory with 'i'
    elif event.is_action_just_pressed("inventory_menu") and player and inventory_menu_loader:
        inventory_menu_loader.show_inventory(player)
    # Player interaction with BossGateGuard
    elif event.is_action_just_pressed("ui_accept") and player and boss_guard:
        var dist = player.position.distance_to(boss_guard.position)
        if dist <= INTERACT_DISTANCE:
            boss_guard.interact(player)

func on_player_reach_edge(direction):
    emit_signal("screen_exit", direction)
