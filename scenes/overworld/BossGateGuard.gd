extends Node2D

# BossGateGuard: Handles tribute logic and dialogue for boss gate

signal tribute_accepted
signal tribute_rejected


var required_fish_count := 3
var tribute_fish := []
var player_node := null
@onready var tribute_menu = $TributeMenu

func _ready():
    if tribute_menu:
        tribute_menu.visible = false
        tribute_menu.connect("tribute_changed", self, "_on_tribute_changed")

func interact(player):
    player_node = player
    var fish_list = player.get_fish_inventory()
    if fish_list.size() < required_fish_count:
        show_dialogue("You need to bring me 3 fish as tribute before you may face the guardian!")
        emit_signal("tribute_rejected")
        return
    # Show tribute selection UI
    if tribute_menu:
        tribute_menu.clear_slots()
        tribute_menu.visible = true
        show_dialogue("Drag 3 fish here as tribute.")
    else:
        show_dialogue("Error: Tribute UI not found.")
func _on_tribute_changed(selected_fish):
    # Only accept when all slots are filled
    if selected_fish.size() == required_fish_count and not selected_fish.has(null):
        tribute_fish = selected_fish.duplicate()
        tribute_menu.visible = false
        show_dialogue("You have brought the tribute. I will let you pass.")
        # Remove tribute fish from player inventory
        for fish in tribute_fish:
            player_node.remove_fish_from_inventory(fish)
        emit_signal("tribute_accepted", tribute_fish)

func show_dialogue(text):
    # TODO: Replace with actual dialogue UI
    print(text)
