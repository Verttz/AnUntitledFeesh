extends Panel
class_name TributeSlot

# TributeSlot.gd: Accepts fish via drag-and-drop for tribute selection

signal fish_dropped(fish_data)

var slot_index := -1
var fish_data = null

func _can_drop_data(_at_position, data):
	# Accept only fish items
	return typeof(data) == TYPE_DICTIONARY and data.has("item_name") and _is_fish(data)

func _drop_data(_at_position, data):
	fish_data = data
	queue_redraw()
	fish_dropped.emit(data)

func _is_fish(data) -> bool:
	# Check type field first (set by item_data), fall back to name-based check
	if data.has("type"):
		return data["type"] == "fish"
	# Look up in item_data if available
	var item_name = data.get("item_name", "")
	if item_name != "" and has_node("/root/ItemData"):
		var item_db = get_node("/root/ItemData")
		if item_name in item_db.ITEM_DATA:
			return item_db.ITEM_DATA[item_name].get("type", "") == "fish"
	return false

func clear():
	fish_data = null
	queue_redraw()

func _draw():
	var font = get_theme_font("font", "Label")
	var font_size = get_theme_font_size("font_size", "Label")
	if fish_data:
		draw_rect(Rect2(Vector2.ZERO, size), Color(0.3, 0.7, 1.0, 0.5))
		draw_string(font, Vector2(8, size.y / 2), fish_data["item_name"], HORIZONTAL_ALIGNMENT_LEFT, -1, font_size)
	else:
		draw_rect(Rect2(Vector2.ZERO, size), Color(0.2, 0.2, 0.2, 0.2))
		draw_string(font, Vector2(8, size.y / 2), "Drop Fish Here", HORIZONTAL_ALIGNMENT_LEFT, -1, font_size)
