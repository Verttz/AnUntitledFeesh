# Save/Load System Documentation

## Overview

The save/load system for AnUntitledFeesh provides comprehensive state persistence across game sessions. It saves all player progress, inventory, equipment, quests, world state, and progression data.

## Architecture

### Core Components

1. **SaveManager.gd** (Autoload Singleton)
   - Central hub for all save/load operations
   - Handles file I/O and data serialization
   - Manages autosave and manual save requests
   - Location: `/root/SaveManager`

2. **PlayerProgress.gd**
   - Tracks player progression state (biomes, bait, quests, upgrades)
   - Provides serialization methods

3. **Equipment.gd**
   - Manages equipped items
   - Provides serialization methods

4. **QuestManager.gd** (Autoload Singleton)
   - Manages quest state
   - Provides serialization methods

5. **SaveLoadMenu.gd**
   - UI component for save/load operations
   - Displays save file information
   - Handles user interactions

## What Gets Saved

### Player Data
- Inventory (backpack and tacklebox)
- Gold/currency
- Equipped items (all equipment slots)
- Player position
- Current biome and location

### Progression Data
- Current biome
- Unlocked biomes
- Unlocked bait
- Completed quests
- Purchased upgrades
- Fish collection statistics

### Quest Data
- Active quests
- Completed quests
- Quest progress (TODO: needs implementation per quest)

### World State
- Current biome state
- Boss defeat status (TODO: needs implementation)

## Usage

### Saving the Game

```gdscript
# Autosave (from anywhere)
SaveManager.autosave()

# Manual save with state check
SaveManager.request_save("exploration")  # Returns true if saved

# Direct save
SaveManager.save_game()  # Returns true if successful
```

### Loading the Game

```gdscript
# Check if save file exists
if SaveManager.has_save_file():
    SaveManager.load_game()  # Returns true if successful
```

### Getting Save Info

```gdscript
# Get basic info without full load
var info = SaveManager.get_save_info()
# Returns: {"gold": 150, "biome": "Ocean", "fish_caught": 42}
```

### Deleting Save

```gdscript
SaveManager.delete_save()  # Use with caution!
```

## Save File Structure

The save file (`user://savegame.dat`) contains a nested dictionary structure:

```gdscript
{
    "player": {
        "backpack": {...},       # Inventory items
        "tacklebox": {...},      # Tackle items
        "player_gold": 150,
        "equipment": {...},      # Equipped items
        "position": {"x": 100, "y": 200},
        "current_biome": "Ocean",
        "current_location": 0
    },
    "progress": {
        "current_biome": "Ocean",
        "unlocked_biomes": ["RiverLake", "Ocean"],
        "unlocked_bait": ["worm", "minnow"],
        "completed_quests": [...],
        "upgrades": [...],
        "fish_collected": {"bass": 5, "trout": 3}
    },
    "quests": {
        "active_quests": [...],
        "completed_quests": [...]
    },
    "world": {
        "current_biome": "Ocean"
    }
}
```

## Integration Points

### Player.gd
Already integrated with autosave:
```gdscript
# After fishing ends
if typeof(SaveManager) != TYPE_NIL and SaveManager.can_save("exploration"):
    SaveManager.autosave()
```

### Game Start/Main Menu
Add load functionality:
```gdscript
func _ready():
    if SaveManager.has_save_file():
        # Show "Continue" option
        continue_button.show()
```

### Pause Menu
Add save/load menu:
```gdscript
var save_menu = preload("res://scripts/ui/SaveLoadMenu.gd").new()
add_child(save_menu)
```

## Project Setup

### 1. Add SaveManager as Autoload

In Project Settings → Autoload:
- Path: `res://scripts/SaveManager.gd`
- Node Name: `SaveManager`
- Enable: ✓

### 2. Add Other Managers (if not already)

- QuestManager: `res://scripts/QuestManager.gd`
- ProgressionManager: `res://scripts/progression/ProgressionManager.gd`
- BiomeManager: `res://scripts/progression/BiomeManager.gd`

## TODO / Future Enhancements

### High Priority
- [ ] Implement quest recreation in QuestManager.from_dict()
- [ ] Add boss defeat tracking to save data
- [ ] Implement settings/preferences saving
- [ ] Add multiple save slot support

### Medium Priority
- [ ] Add save file versioning for backward compatibility
- [ ] Implement cloud save integration
- [ ] Add save file encryption for security
- [ ] Create save file backup system

### Low Priority
- [ ] Add screenshot to save file
- [ ] Save playtime statistics
- [ ] Implement save file export/import
- [ ] Add save file repair/recovery tools

## Testing Checklist

- [ ] Save creates file at correct location
- [ ] Load restores all player data correctly
- [ ] Inventory items are preserved (stackable and unique)
- [ ] Equipment slots are restored correctly
- [ ] Position and biome are restored
- [ ] Progression data is accurate
- [ ] Autosave triggers at appropriate times
- [ ] Multiple save/load cycles work correctly
- [ ] Delete removes save file completely
- [ ] Save info displays correct data
- [ ] UI buttons enable/disable appropriately
- [ ] Error handling works for corrupted saves

## Known Issues

1. Quest recreation needs custom implementation per quest type
2. Boss defeat status not yet tracked
3. No confirmation dialog for delete operation
4. No backup system for save corruption

## Performance Notes

- Save operation is synchronous and may cause brief frame drop
- Consider calling save during transition screens
- Autosave should only trigger during safe states
- Load operation rebuilds all game state, use loading screen

## Security Considerations

- Save file is stored in plain text (Godot's `store_var`)
- Consider encryption for competitive/online features
- Validate save data before loading to prevent exploits
- Implement checksum for save file integrity

## Examples

### Example: Adding a New Saveable Component

```gdscript
# In your new component script:
func to_dict() -> Dictionary:
    return {
        "my_data": my_value,
        "my_array": my_array.duplicate()
    }

func from_dict(data: Dictionary):
    if "my_data" in data:
        my_value = data["my_data"]
    if "my_array" in data:
        my_array = data["my_array"].duplicate()

# In SaveManager.save_game():
if has_node("/root/MyComponent"):
    var comp = get_node("/root/MyComponent")
    save_data["my_component"] = comp.to_dict()

# In SaveManager.load_game():
if has_node("/root/MyComponent") and "my_component" in save_data:
    var comp = get_node("/root/MyComponent")
    comp.from_dict(save_data["my_component"])
```

### Example: Save on Boss Defeat

```gdscript
# In boss script:
func _on_boss_defeated():
    emit_signal("boss_defeated")
    if SaveManager.can_save("boss_victory"):
        SaveManager.autosave()
```

### Example: Load Game on Continue

```gdscript
# In main menu:
func _on_continue_pressed():
    if SaveManager.load_game():
        get_tree().change_scene_to_file("res://scenes/Game.tscn")
    else:
        show_error("Failed to load save file!")
```

## Support

For issues or questions about the save/load system:
1. Check this documentation
2. Review SaveManager.gd comments
3. Test with debug prints
4. Check Godot's file system documentation
