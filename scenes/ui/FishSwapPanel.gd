extends PanelContainer

# FishSwapPanel.gd — Visual fish-card selection panel for boss fights.
# Shows remaining tribute fish as styled cards with stats.
# Emits fish_selected(index) when the player picks one.

signal fish_selected(fish_index: int)

@onready var title_label: Label = $VBox/TitleLabel
@onready var card_container: HBoxContainer = $VBox/CardContainer

var _fish_list: Array = []  # Array[Fish] — full tribute list (nulls = dead)


func _ready():
	visible = false
	# Dim background
	_apply_panel_style()


func setup(tribute_fish: Array) -> void:
	_fish_list = tribute_fish


func show_selection(remaining_indices: Array, prompt: String = "Choose your next fighter:") -> void:
	title_label.text = prompt

	# Clear old cards
	for child in card_container.get_children():
		child.queue_free()

	# Build a card for each remaining fish
	for idx in remaining_indices:
		if idx < _fish_list.size() and _fish_list[idx] != null:
			var card = _build_fish_card(_fish_list[idx], idx)
			card_container.add_child(card)

	visible = true


func hide_selection() -> void:
	visible = false


# ==========================================================================
# CARD BUILDER
# ==========================================================================

func _build_fish_card(fish: Fish, index: int) -> PanelContainer:
	var card = PanelContainer.new()
	card.custom_minimum_size = Vector2(220, 260)
	card.size_flags_horizontal = Control.SIZE_EXPAND_FILL

	# Card background style
	var style = StyleBoxFlat.new()
	style.bg_color = _rarity_color(fish.rarity).darkened(0.6)
	style.border_color = _rarity_color(fish.rarity)
	style.set_border_width_all(2)
	style.set_corner_radius_all(8)
	style.set_content_margin_all(10)
	card.add_theme_stylebox_override("panel", style)

	var vbox = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 4)
	card.add_child(vbox)

	# --- Rarity banner ---
	var rarity_label = Label.new()
	rarity_label.text = _rarity_name(fish.rarity)
	rarity_label.add_theme_color_override("font_color", _rarity_color(fish.rarity))
	rarity_label.add_theme_font_size_override("font_size", 11)
	rarity_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(rarity_label)

	# --- Fish name ---
	var name_label = Label.new()
	name_label.text = fish.fish_name
	name_label.add_theme_font_size_override("font_size", 16)
	name_label.add_theme_color_override("font_color", Color.WHITE)
	name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	name_label.autowrap_mode = TextServer.AUTOWRAP_WORD
	vbox.add_child(name_label)

	# --- Fish portrait placeholder ---
	var portrait = ColorRect.new()
	portrait.custom_minimum_size = Vector2(80, 60)
	portrait.color = _rarity_color(fish.rarity).darkened(0.3)
	portrait.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	vbox.add_child(portrait)

	# Fish silhouette icon (text placeholder)
	var icon_label = Label.new()
	icon_label.text = "<o)))><"
	icon_label.add_theme_font_size_override("font_size", 18)
	icon_label.add_theme_color_override("font_color", Color.WHITE)
	icon_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	portrait.add_child(icon_label)
	icon_label.set_anchors_and_offsets_preset(Control.PRESET_CENTER)

	# --- Separator ---
	var sep = HSeparator.new()
	sep.add_theme_color_override("separator", _rarity_color(fish.rarity).lightened(0.3))
	vbox.add_child(sep)

	# --- Stats grid ---
	var stats = GridContainer.new()
	stats.columns = 2
	stats.add_theme_constant_override("h_separation", 8)
	stats.add_theme_constant_override("v_separation", 2)
	vbox.add_child(stats)

	_add_stat_row(stats, "HP", str(fish.get_combat_hp()))
	_add_stat_row(stats, "ATK", str(fish.attack))
	_add_stat_row(stats, "DEF", str(fish.defense))
	_add_stat_row(stats, "SPD", str(fish.speed))

	# --- Weapon ---
	var weapon_label = Label.new()
	weapon_label.text = fish.weapon if fish.weapon != "" else "Unarmed"
	weapon_label.add_theme_font_size_override("font_size", 11)
	weapon_label.add_theme_color_override("font_color", Color(0.8, 0.85, 1.0))
	weapon_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	weapon_label.autowrap_mode = TextServer.AUTOWRAP_WORD
	vbox.add_child(weapon_label)

	# --- Special ability ---
	if fish.has_special():
		var special_label = Label.new()
		special_label.text = "Special: %s" % fish.special.capitalize()
		special_label.add_theme_font_size_override("font_size", 11)
		special_label.add_theme_color_override("font_color", Color(1.0, 0.85, 0.3))
		special_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		vbox.add_child(special_label)

	# --- Select button ---
	var btn = Button.new()
	btn.text = "SELECT"
	btn.custom_minimum_size = Vector2(0, 32)
	var btn_style = StyleBoxFlat.new()
	btn_style.bg_color = _rarity_color(fish.rarity).darkened(0.2)
	btn_style.set_corner_radius_all(4)
	btn_style.set_content_margin_all(4)
	btn.add_theme_stylebox_override("normal", btn_style)
	var btn_hover = StyleBoxFlat.new()
	btn_hover.bg_color = _rarity_color(fish.rarity).lightened(0.1)
	btn_hover.set_corner_radius_all(4)
	btn_hover.set_content_margin_all(4)
	btn.add_theme_stylebox_override("hover", btn_hover)
	var btn_pressed = StyleBoxFlat.new()
	btn_pressed.bg_color = _rarity_color(fish.rarity).lightened(0.3)
	btn_pressed.set_corner_radius_all(4)
	btn_pressed.set_content_margin_all(4)
	btn.add_theme_stylebox_override("pressed", btn_pressed)
	btn.pressed.connect(func(): fish_selected.emit(index))
	vbox.add_child(btn)

	# Hover highlight
	card.mouse_entered.connect(func(): style.border_color = Color.WHITE; card.add_theme_stylebox_override("panel", style))
	card.mouse_exited.connect(func(): style.border_color = _rarity_color(fish.rarity); card.add_theme_stylebox_override("panel", style))

	return card


func _add_stat_row(grid: GridContainer, stat_name: String, stat_value: String) -> void:
	var lbl_name = Label.new()
	lbl_name.text = stat_name + ":"
	lbl_name.add_theme_font_size_override("font_size", 12)
	lbl_name.add_theme_color_override("font_color", Color(0.7, 0.7, 0.7))
	grid.add_child(lbl_name)

	var lbl_val = Label.new()
	lbl_val.text = stat_value
	lbl_val.add_theme_font_size_override("font_size", 12)
	lbl_val.add_theme_color_override("font_color", Color.WHITE)
	grid.add_child(lbl_val)


# ==========================================================================
# STYLING
# ==========================================================================

func _apply_panel_style() -> void:
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.08, 0.08, 0.12, 0.92)
	style.border_color = Color(0.3, 0.35, 0.5)
	style.set_border_width_all(2)
	style.set_corner_radius_all(12)
	style.set_content_margin_all(16)
	add_theme_stylebox_override("panel", style)


func _rarity_color(rarity: int) -> Color:
	match rarity:
		Fish.Rarity.COMMON:    return Color(0.6, 0.6, 0.6)
		Fish.Rarity.UNCOMMON:  return Color(0.3, 0.85, 0.3)
		Fish.Rarity.RARE:      return Color(0.3, 0.5, 1.0)
		Fish.Rarity.LEGENDARY: return Color(0.8, 0.4, 1.0)
		Fish.Rarity.MYTHIC:    return Color(1.0, 0.65, 0.1)
		_:                     return Color(0.5, 0.5, 0.5)


func _rarity_name(rarity: int) -> String:
	match rarity:
		Fish.Rarity.COMMON:    return "COMMON"
		Fish.Rarity.UNCOMMON:  return "UNCOMMON"
		Fish.Rarity.RARE:      return "RARE"
		Fish.Rarity.LEGENDARY: return "LEGENDARY"
		Fish.Rarity.MYTHIC:    return "MYTHIC"
		_:                     return "???"
