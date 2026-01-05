extends Control

"""
SaveLoadMenu.gd
---------------
UI menu for save/load functionality. Provides buttons and feedback for saving, loading, and deleting save files.
Can be used as a standalone menu or integrated into a pause menu.
"""

signal save_completed
signal load_completed
signal save_deleted

@onready var save_button = $VBoxContainer/SaveButton
@onready var load_button = $VBoxContainer/LoadButton
@onready var delete_button = $VBoxContainer/DeleteButton
@onready var info_label = $VBoxContainer/InfoLabel
@onready var save_info_label = $VBoxContainer/SaveInfoLabel

func _ready():
	# Connect button signals
	if save_button:
		save_button.pressed.connect(_on_save_pressed)
	if load_button:
		load_button.pressed.connect(_on_load_pressed)
	if delete_button:
		delete_button.pressed.connect(_on_delete_pressed)
	
	# Update UI state
	update_ui()

func update_ui():
	"""
	Updates the UI to reflect the current save file state.
	Enables/disables buttons based on whether a save file exists.
	"""
	var has_save = SaveManager.has_save_file()
	
	if load_button:
		load_button.disabled = not has_save
	
	if delete_button:
		delete_button.disabled = not has_save
	
	# Display save file info if available
	if save_info_label:
		if has_save:
			var info = SaveManager.get_save_info()
			var info_text = "Save File Info:\n"
			if "biome" in info:
				info_text += "Biome: " + str(info["biome"]) + "\n"
			if "gold" in info:
				info_text += "Gold: " + str(info["gold"]) + "\n"
			if "fish_caught" in info:
				info_text += "Fish Caught: " + str(info["fish_caught"]) + "\n"
			save_info_label.text = info_text
		else:
			save_info_label.text = "No save file found."

func _on_save_pressed():
	"""
	Handles the save button press. Saves the current game state.
	"""
	if info_label:
		info_label.text = "Saving..."
	
	var success = SaveManager.save_game()
	
	if success:
		if info_label:
			info_label.text = "Game saved successfully!"
		emit_signal("save_completed")
	else:
		if info_label:
			info_label.text = "Failed to save game."
	
	update_ui()
	
	# Clear message after a delay
	await get_tree().create_timer(2.0).timeout
	if info_label:
		info_label.text = ""

func _on_load_pressed():
	"""
	Handles the load button press. Loads the saved game state.
	"""
	if info_label:
		info_label.text = "Loading..."
	
	var success = SaveManager.load_game()
	
	if success:
		if info_label:
			info_label.text = "Game loaded successfully!"
		emit_signal("load_completed")
	else:
		if info_label:
			info_label.text = "Failed to load game."
	
	update_ui()
	
	# Clear message after a delay
	await get_tree().create_timer(2.0).timeout
	if info_label:
		info_label.text = ""

func _on_delete_pressed():
	"""
	Handles the delete button press. Deletes the save file after confirmation.
	"""
	# TODO: Add confirmation dialog
	if info_label:
		info_label.text = "Deleting save file..."
	
	var success = SaveManager.delete_save()
	
	if success:
		if info_label:
			info_label.text = "Save file deleted."
		emit_signal("save_deleted")
	else:
		if info_label:
			info_label.text = "Failed to delete save file."
	
	update_ui()
	
	# Clear message after a delay
	await get_tree().create_timer(2.0).timeout
	if info_label:
		info_label.text = ""

func show_menu():
	"""
	Shows the save/load menu and updates the UI.
	"""
	visible = true
	update_ui()

func hide_menu():
	"""
	Hides the save/load menu.
	"""
	visible = false
