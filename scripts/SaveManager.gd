
extends Node

"""
SaveManager.gd
--------------
Singleton for save/load and autosave functionality. Handles serialization of player, world, and progress data.
"""

# --- Save Data Structure ---
var save_path := "user://savegame.dat" # Path to save file
var save_data = {
    "player": {},   # Player inventory, gold, equipment, position
    "world": {},    # World state (biomes, bosses, etc.)
    "progress": {}, # Quest and unlock progress
    "quests": {},   # Quest state
    "settings": {}  # Player settings/preferences
}

func save_game():
    """
    Saves the current game state to disk. Serializes all player data, world state, and progression.
    """
    # Save player data
    var player = get_tree().get_root().find_child("Player", true, false)
    if player:
        save_data["player"]["backpack"] = player.backpack.to_dict()
        save_data["player"]["tacklebox"] = player.tacklebox.to_dict()
        save_data["player"]["player_gold"] = player.player_gold
        save_data["player"]["equipment"] = player.equipment.to_dict()
        save_data["player"]["position"] = {"x": player.position.x, "y": player.position.y}
        save_data["player"]["current_biome"] = player.current_biome
        save_data["player"]["current_location"] = player.current_location
    
    # Save progression data
    if has_node("/root/ProgressionManager"):
        var prog = get_node("/root/ProgressionManager")
        save_data["progress"]["current_biome"] = prog.current_biome
        save_data["progress"]["unlocked_biomes"] = prog.unlocked_biomes.duplicate()
        save_data["progress"]["unlocked_bait"] = prog.unlocked_bait.duplicate()
        save_data["progress"]["completed_quests"] = prog.completed_quests.duplicate()
        save_data["progress"]["upgrades"] = prog.upgrades.duplicate()
        save_data["progress"]["fish_collected"] = prog.fish_collected.duplicate()
    
    # Save quest data
    if has_node("/root/QuestManager"):
        var qm = get_node("/root/QuestManager")
        save_data["quests"] = qm.to_dict()
    
    # Save world state (boss defeats, etc.)
    if has_node("/root/BiomeManager"):
        var bm = get_node("/root/BiomeManager")
        save_data["world"]["current_biome"] = bm.current_biome
    
    # Write to file
    var file = FileAccess.open(save_path, FileAccess.WRITE)
    if file:
        file.store_var(save_data)
        file.close()
        print("Game saved successfully.")
        return true
    else:
        push_error("Failed to open save file for writing.")
        return false

func load_game():
    """
    Loads the game state from disk. Restores all player data, world state, and progression.
    Returns true if successful, false otherwise.
    """
    if not FileAccess.file_exists(save_path):
        print("No save file found.")
        return false
    
    var file = FileAccess.open(save_path, FileAccess.READ)
    if not file:
        push_error("Failed to open save file for reading.")
        return false
    
    save_data = file.get_var()
    file.close()
    
    if save_data == null or typeof(save_data) != TYPE_DICTIONARY:
        push_error("Invalid save data.")
        return false
    
    # Restore player data
    var player = get_tree().get_root().find_child("Player", true, false)
    if player and "player" in save_data:
        if "backpack" in save_data["player"]:
            player.backpack.from_dict(save_data["player"]["backpack"])
        if "tacklebox" in save_data["player"]:
            player.tacklebox.from_dict(save_data["player"]["tacklebox"])
        if "player_gold" in save_data["player"]:
            player.player_gold = save_data["player"]["player_gold"]
        if "equipment" in save_data["player"]:
            player.equipment.from_dict(save_data["player"]["equipment"])
        if "position" in save_data["player"]:
            player.position = Vector2(save_data["player"]["position"]["x"], save_data["player"]["position"]["y"])
        if "current_biome" in save_data["player"]:
            player.current_biome = save_data["player"]["current_biome"]
        if "current_location" in save_data["player"]:
            player.current_location = save_data["player"]["current_location"]
    
    # Restore progression data
    if has_node("/root/ProgressionManager") and "progress" in save_data:
        var prog = get_node("/root/ProgressionManager")
        if "current_biome" in save_data["progress"]:
            prog.current_biome = save_data["progress"]["current_biome"]
        if "unlocked_biomes" in save_data["progress"]:
            prog.unlocked_biomes = save_data["progress"]["unlocked_biomes"].duplicate()
        if "unlocked_bait" in save_data["progress"]:
            prog.unlocked_bait = save_data["progress"]["unlocked_bait"].duplicate()
        if "completed_quests" in save_data["progress"]:
            prog.completed_quests = save_data["progress"]["completed_quests"].duplicate()
        if "upgrades" in save_data["progress"]:
            prog.upgrades = save_data["progress"]["upgrades"].duplicate()
        if "fish_collected" in save_data["progress"]:
            prog.fish_collected = save_data["progress"]["fish_collected"].duplicate()
    
    # Restore quest data
    if has_node("/root/QuestManager") and "quests" in save_data:
        var qm = get_node("/root/QuestManager")
        qm.from_dict(save_data["quests"])
    
    # Restore world state
    if has_node("/root/BiomeManager") and "world" in save_data:
        var bm = get_node("/root/BiomeManager")
        if "current_biome" in save_data["world"]:
            bm.current_biome = save_data["world"]["current_biome"]
    
    print("Game loaded successfully.")
    return true

func autosave():
    """
    Triggers an autosave of the current game state.
    """
    save_game()

func can_save(state):
    """
    Returns true if saving is allowed in the given state (e.g., only in exploration mode).
    """
    return state == "exploration"

func request_save(state):
    """
    Attempts to save the game if allowed in the current state. Returns true if saved, false otherwise.
    """
    if can_save(state):
        return save_game()
    print("Cannot save in current state: " + str(state))
    return false

func has_save_file() -> bool:
    """
    Returns true if a save file exists.
    """
    return FileAccess.file_exists(save_path)

func delete_save():
    """
    Deletes the current save file. Use with caution!
    """
    if FileAccess.file_exists(save_path):
        DirAccess.remove_absolute(save_path)
        print("Save file deleted.")
        return true
    print("No save file to delete.")
    return false

func get_save_info() -> Dictionary:
    """
    Returns basic info about the save file without fully loading it.
    Useful for displaying save file details on a load screen.
    """
    if not has_save_file():
        return {}
    
    var file = FileAccess.open(save_path, FileAccess.READ)
    if not file:
        return {}
    
    var data = file.get_var()
    file.close()
    
    if data == null or typeof(data) != TYPE_DICTIONARY:
        return {}
    
    var info = {}
    if "player" in data and "player_gold" in data["player"]:
        info["gold"] = data["player"]["player_gold"]
    if "progress" in data and "current_biome" in data["progress"]:
        info["biome"] = data["progress"]["current_biome"]
    if "progress" in data and "fish_collected" in data["progress"]:
        var total_fish = 0
        for count in data["progress"]["fish_collected"].values():
            total_fish += count
        info["fish_caught"] = total_fish
    
    return info

# Example usage of SaveManager in Player.gd or main game script:
# To autosave:
#   SaveManager.autosave()
# To request manual save:
#   SaveManager.request_save(current_state)
# To load:
#   SaveManager.load_game()
# To check if save exists:
#   SaveManager.has_save_file()
# To get save info:
#   SaveManager.get_save_info()

# Make sure to add SaveManager.gd as an autoload singleton in your project settings.
