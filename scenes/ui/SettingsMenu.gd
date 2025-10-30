extends Control

# Simple settings menu for volume control

func _ready():
    $Panel/VBoxContainer/VolumeSlider.connect("value_changed", self, "_on_volume_changed")
    $Panel/VBoxContainer/BackButton.connect("pressed", self, "_on_back_pressed")
    $Panel/VBoxContainer/VolumeSlider.value = AudioServer.get_bus_volume_db(0)

func open():
    visible = true
    grab_focus()

func close():
    visible = false

func _on_volume_changed(value):
    # Set master bus volume (bus 0)
    AudioServer.set_bus_volume_db(0, linear2db(value))

func _on_back_pressed():
    close()

func linear2db(linear):
    if linear <= 0:
        return -80
    return 20 * log10(linear)
