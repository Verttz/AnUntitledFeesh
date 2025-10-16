extends Node

# Singleton for save/load and autosave
var save_path := "user://savegame.dat"

# Data to save
var save_data = {
    "player": {},
    "world": {},
    "progress": {}
}

func save_game():
    # Save player inventory (backpack and tacklebox) if player exists
    var player = get_tree().get_root().find_node("Player", true, false)
    if player:
        save_data["player"]["backpack"] = player.backpack.to_dict()
        save_data["player"]["tacklebox"] = player.tacklebox.to_dict()
        save_data["player"]["player_gold"] = player.player_gold
    var file = FileAccess.open(save_path, FileAccess.WRITE)
    if file:
        file.store_var(save_data)
        file.close()
        print("Game saved.")

func load_game():
    if not FileAccess.file_exists(save_path):
        print("No save file found.")
        return false
    var file = FileAccess.open(save_path, FileAccess.READ)
    if file:
        save_data = file.get_var()
        file.close()
        # Restore player inventory if player exists
        var player = get_tree().get_root().find_node("Player", true, false)
        if player and "player" in save_data:
            if "backpack" in save_data["player"]:
                player.backpack.from_dict(save_data["player"]["backpack"])
            if "tacklebox" in save_data["player"]:
                player.tacklebox.from_dict(save_data["player"]["tacklebox"])
            if "player_gold" in save_data["player"]:
                player.player_gold = save_data["player"]["player_gold"]
        print("Game loaded.")
        return true
    return false

func autosave():
    save_game()

func can_save(state):
    # Only allow saving in exploration mode
    return state == "exploration"

func request_save(state):
    if can_save(state):
        save_game()
        return true
    print("Cannot save in current state: " + str(state))
    return false

# Example usage of SaveManager in Player.gd or main game script:
# To autosave:
#   SaveManager.autosave()
# To request manual save:
#   SaveManager.request_save(current_state)
# To load:
#   SaveManager.load_game()

# Make sure to add SaveManager.gd as an autoload singleton in your project settings.
