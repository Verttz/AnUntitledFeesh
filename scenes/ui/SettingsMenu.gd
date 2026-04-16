extends Control

# Simple settings menu for volume control

func _ready():
    $Panel/VBoxContainer/VolumeSlider.value_changed.connect(_on_volume_changed)
    $Panel/VBoxContainer/BackButton.pressed.connect(_on_back_pressed)
    $Panel/VBoxContainer/VolumeSlider.min_value = 0.0
    $Panel/VBoxContainer/VolumeSlider.max_value = 1.0
    $Panel/VBoxContainer/VolumeSlider.step = 0.01
    $Panel/VBoxContainer/VolumeSlider.value = db_to_linear(AudioServer.get_bus_volume_db(0))

func open():
    visible = true
    grab_focus()

func close():
    visible = false

func _on_volume_changed(value):
    # Set master bus volume (bus 0)
    AudioServer.set_bus_volume_db(0, linear_to_db(value))

func _on_back_pressed():
    close()
