extends Node

"""
SaveLoadTest.gd
---------------
Test script for the save/load system. Run this to verify save/load functionality.
Can be attached to a test scene or run from the command line.
"""

func _ready():
	print("=== Save/Load System Test ===")
	run_tests()

func run_tests():
	"""
	Runs a series of tests to verify save/load functionality.
	"""
	print("\n--- Test 1: Save Manager Exists ---")
	test_save_manager_exists()
	
	print("\n--- Test 2: Save File Creation ---")
	test_save_creation()
	
	print("\n--- Test 3: Save File Loading ---")
	test_save_loading()
	
	print("\n--- Test 4: Save Info ---")
	test_save_info()
	
	print("\n--- Test 5: Player Data Persistence ---")
	test_player_data()
	
	print("\n--- Test 6: Progression Data Persistence ---")
	test_progression_data()
	
	print("\n=== All Tests Complete ===")

func test_save_manager_exists():
	"""
	Test that SaveManager is properly loaded as an autoload.
	"""
	if has_node("/root/SaveManager"):
		print("✓ SaveManager exists")
		return true
	else:
		print("✗ SaveManager not found!")
		return false

func test_save_creation():
	"""
	Test that a save file can be created.
	"""
	var success = SaveManager.save_game()
	if success:
		print("✓ Save file created successfully")
		return true
	else:
		print("✗ Failed to create save file")
		return false

func test_save_loading():
	"""
	Test that a save file can be loaded.
	"""
	if not SaveManager.has_save_file():
		print("✗ No save file to load")
		return false
	
	var success = SaveManager.load_game()
	if success:
		print("✓ Save file loaded successfully")
		return true
	else:
		print("✗ Failed to load save file")
		return false

func test_save_info():
	"""
	Test that save file info can be retrieved.
	"""
	if not SaveManager.has_save_file():
		print("✗ No save file for info test")
		return false
	
	var info = SaveManager.get_save_info()
	if typeof(info) == TYPE_DICTIONARY:
		print("✓ Save info retrieved:")
		for key in info.keys():
			print("  - " + str(key) + ": " + str(info[key]))
		return true
	else:
		print("✗ Failed to get save info")
		return false

func test_player_data():
	"""
	Test that world state is saved and restored correctly.
	"""
	var player = get_tree().get_root().find_child("Player", true, false)
	if not player:
		print("⚠ No Player node found, creating mock data")
		# Create mock player data for testing
		SaveManager.save_data["player"] = {
			"player_gold": 100,
			"current_biome": "TestBiome"
		}
		SaveManager.save_game()
		
		# Load and verify
		SaveManager.load_game()
		if SaveManager.save_data["player"]["player_gold"] == 100:
			print("✓ Mock player data persisted")
			return true
		else:
			print("✗ Mock player data not persisted")
			return false
	else:
		# Test with actual player
		var original_gold = player.player_gold
		player.player_gold = 999
		
		SaveManager.save_game()
		
		# Reset and load
		player.player_gold = 0
		SaveManager.load_game()
		
		if player.player_gold == 999:
			print("✓ Player gold persisted correctly")
			player.player_gold = original_gold  # Restore
			return true
		else:
			print("✗ Player gold not persisted")
			return false

func test_progression_data():
	"""
	Test that progression data is saved and restored correctly.
	"""
	if not has_node("/root/ProgressionManager"):
		print("⚠ No ProgressionManager found")
		return false
	
	var prog = get_node("/root/ProgressionManager")
	var original_biome = prog.current_biome
	
	# Set test data
	prog.current_biome = "TestBiome"
	prog.unlocked_biomes = ["Biome1", "Biome2"]
	prog.fish_collected = {"test_fish": 5}
	
	# Save
	SaveManager.save_game()
	
	# Reset
	prog.current_biome = ""
	prog.unlocked_biomes.clear()
	prog.fish_collected.clear()
	
	# Load
	SaveManager.load_game()
	
	# Verify
	var success = true
	if prog.current_biome != "TestBiome":
		print("✗ Current biome not restored")
		success = false
	if prog.unlocked_biomes.size() != 2:
		print("✗ Unlocked biomes not restored")
		success = false
	if not "test_fish" in prog.fish_collected:
		print("✗ Fish collected not restored")
		success = false
	
	if success:
		print("✓ Progression data persisted correctly")
	
	# Restore original
	prog.current_biome = original_biome
	
	return success

func test_equipment_persistence():
	"""
	Test that equipment is saved and restored correctly.
	"""
	var player = get_tree().get_root().find_child("Player", true, false)
	if not player:
		print("⚠ No Player node for equipment test")
		return false
	
	# Set test equipment
	player.equipment.slots["pole"] = "test_pole"
	player.equipment.slots["bait"] = "test_bait"
	
	# Save
	SaveManager.save_game()
	
	# Reset
	player.equipment.slots["pole"] = null
	player.equipment.slots["bait"] = null
	
	# Load
	SaveManager.load_game()
	
	# Verify
	if player.equipment.slots["pole"] == "test_pole" and player.equipment.slots["bait"] == "test_bait":
		print("✓ Equipment persisted correctly")
		return true
	else:
		print("✗ Equipment not persisted")
		return false

func cleanup_test_data():
	"""
	Cleans up test data and restores original state.
	"""
	print("\n--- Cleaning Up Test Data ---")
	# Optionally delete the test save file
	# SaveManager.delete_save()
	print("✓ Cleanup complete")

# Optionally call cleanup on exit
func _exit_tree():
	# Uncomment to auto-cleanup
	# cleanup_test_data()
	pass
