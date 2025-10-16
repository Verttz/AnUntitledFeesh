extends Panel

# TributeSlot.gd: Accepts fish via drag-and-drop for tribute selection

signal fish_dropped(fish_data)

var slot_index := -1
var fish_data := null

func can_drop_data(position, data):
    # Accept only fish items (must have 'item_name' and type 'fish')
    return typeof(data) == TYPE_DICTIONARY and data.has("item_name") and _is_fish(data)

func drop_data(position, data):
    fish_data = data
    update()
    emit_signal("fish_dropped", data)

func _is_fish(data):
    # TODO: Use item_data or metadata for robust check
    return "fish" in data["item_name"].to_lower()

func clear():
    fish_data = null
    update()

func _draw():
    if fish_data:
        draw_rect(Rect2(Vector2.ZERO, rect_size), Color(0.3, 0.7, 1.0, 0.5))
        draw_string(get_font("font"), Vector2(8, rect_size.y/2), fish_data["item_name"])
    else:
        draw_rect(Rect2(Vector2.ZERO, rect_size), Color(0.2, 0.2, 0.2, 0.2))
        draw_string(get_font("font"), Vector2(8, rect_size.y/2), "Drop Fish Here")
