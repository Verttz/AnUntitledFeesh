extends CanvasLayer

# FishingHUD.gd — Visual fishing HUD with StyleBoxFlat graphics.
# Shows cast power, bobber wait, bite alert, tension meter, and catch results.
# All UI elements are built programmatically in _ready() for StyleBoxFlat styling.

@onready var result_timer: Timer = $ResultTimer

# Built in _ready()
var _panel: PanelContainer
var _location_label: Label
var _fish_count_label: Label
var _prompt_label: Label

# State sections (shown/hidden per fishing state)
var _idle_label: Label
var _cast_section: VBoxContainer
var _cast_bar: ProgressBar
var _cast_bar_fill_style: StyleBoxFlat
var _wait_label: Label
var _bite_label: Label
var _bite_overlay: ColorRect
var _reel_section: VBoxContainer
var _tension_bar_bg: ColorRect
var _tension_safe_zone: ColorRect
var _tension_indicator: ColorRect
var _reel_progress_bar: ProgressBar
var _reel_info_label: Label
var _result_label: Label

# Animation state
var _bite_flash_timer := 0.0
var _wait_dot_timer := 0.0
var _wait_dots := 0

const RARITY_NAMES := ["Common", "Uncommon", "Rare", "Legendary", "Mythic"]
const RARITY_COLORS := [
	Color(0.7, 0.7, 0.7),      # Common — gray
	Color(0.3, 0.9, 0.3),      # Uncommon — green
	Color(0.3, 0.5, 1.0),      # Rare — blue
	Color(1.0, 0.8, 0.2),      # Legendary — gold
	Color(0.9, 0.3, 0.9),      # Mythic — purple
]


func _ready():
	result_timer.timeout.connect(_on_result_timeout)
	_build_ui()
	_hide_all_sections()


func _process(delta):
	# Bite flash animation
	if _bite_label.visible:
		_bite_flash_timer += delta
		_bite_label.modulate.a = 1.0 if int(_bite_flash_timer * 6.0) % 2 == 0 else 0.5
		_bite_overlay.modulate.a = lerpf(_bite_overlay.modulate.a, 0.0, delta * 3.0)

	# Wait dots animation
	if _wait_label.visible:
		_wait_dot_timer += delta
		if _wait_dot_timer >= 0.5:
			_wait_dot_timer = 0.0
			_wait_dots = (_wait_dots + 1) % 4
			_wait_label.text = "Waiting for a bite" + ".".repeat(_wait_dots)


# ==========================================================================
# PUBLIC API — called each frame by the parent scene based on Player state
# ==========================================================================

func show_idle(location_name: String, habitat: String):
	_hide_all_sections()
	_location_label.text = "%s  (%s)" % [location_name, habitat]
	_idle_label.text = "<o)))><   Cast to fish!   <o)))><"
	_idle_label.visible = true
	_prompt_label.text = "SPACE or Click to cast  |  A/D to change spot"


func show_not_at_spot():
	_hide_all_sections()
	_location_label.text = ""
	_idle_label.text = "Walk to a fishing spot"
	_idle_label.visible = true
	_prompt_label.text = "Look for the blue circles"


func show_casting(power: float, direction: Vector2):
	_hide_all_sections()
	_cast_section.visible = true
	_cast_bar.value = power * 100.0
	# Color shifts orange → red as power increases
	var t = clampf(power, 0.0, 1.0)
	_cast_bar_fill_style.bg_color = Color(1.0, lerpf(0.7, 0.15, t), 0.1)
	var angle_deg = rad_to_deg(atan2(direction.y, direction.x))
	_prompt_label.text = "Release to cast  |  Power: %d%%  |  Aim: %.0f°" % [int(power * 100), angle_deg]


func show_waiting():
	_hide_all_sections()
	_wait_label.visible = true
	_prompt_label.text = "Watch the bobber..."


func show_bite(fish_name: String, rarity: int):
	_hide_all_sections()
	_bite_label.visible = true
	_bite_label.text = "! BITE !"
	_bite_overlay.visible = true
	_bite_overlay.modulate.a = 0.35
	_bite_flash_timer = 0.0
	_prompt_label.text = "PRESS SPACE or CLICK to hook!"


func show_reeling(fish_name: String, tension_val: float, safe_min: float, safe_max: float, reel_progress: float, phase: String):
	_hide_all_sections()
	_reel_section.visible = true

	# — Tension bar sizing —
	var bar_w = _tension_bar_bg.size.x
	if bar_w <= 0:
		bar_w = 600.0  # fallback before first layout
	var bar_h = _tension_bar_bg.size.y
	if bar_h <= 0:
		bar_h = 28.0

	# Safe zone overlay
	_tension_safe_zone.position = Vector2(safe_min * bar_w, 0)
	_tension_safe_zone.size = Vector2((safe_max - safe_min) * bar_w, bar_h)

	# Tension indicator (thin white/colored bar)
	var in_zone = tension_val >= safe_min and tension_val <= safe_max
	_tension_indicator.color = Color(0.2, 1.0, 0.3) if in_zone else Color(1.0, 0.25, 0.2)
	_tension_indicator.position = Vector2(clampf(tension_val * bar_w - 3.0, 0.0, bar_w - 6.0), 0)
	_tension_indicator.size = Vector2(6, bar_h)

	# Reel progress
	_reel_progress_bar.value = reel_progress * 100.0

	# Phase + fish info
	var phase_icon = {"calm": "~", "pull": ">>", "dart": "!?"}.get(phase, "~")
	var r = clampi(rarity_from_name(fish_name), 0, RARITY_COLORS.size() - 1)
	_reel_info_label.text = "%s  |  Phase: %s %s  |  Reel: %d%%" % [fish_name, phase_icon, phase.to_upper(), int(reel_progress * 100)]
	_prompt_label.text = "Hold SPACE to increase tension  |  Keep the marker in the green zone!"


func show_catch_result(success: bool, fish_name: String, rarity: int, fish_size: float):
	_hide_all_sections()
	if success:
		var r = clampi(rarity, 0, RARITY_NAMES.size() - 1)
		_result_label.text = "CAUGHT: %s!  [%s]  %.1fx size" % [fish_name, RARITY_NAMES[r], fish_size]
		_result_label.modulate = RARITY_COLORS[r]
	else:
		_result_label.text = "%s got away!" % fish_name if fish_name != "" else "Nothing on the line..."
		_result_label.modulate = Color(1.0, 0.5, 0.5)
	_result_label.visible = true
	result_timer.start(3.0)
	_prompt_label.text = ""


func update_inventory_display(fish_list: Array):
	_fish_count_label.text = "Fish: %d" % fish_list.size()


# Helper — not critical, used for reel info color (falls back gracefully)
func rarity_from_name(_fish_name: String) -> int:
	return 0


# ==========================================================================
# INTERNAL
# ==========================================================================

func _hide_all_sections():
	_idle_label.visible = false
	_cast_section.visible = false
	_wait_label.visible = false
	_bite_label.visible = false
	_bite_overlay.visible = false
	_reel_section.visible = false
	_result_label.visible = false


func _on_result_timeout():
	_result_label.visible = false
	_result_label.text = ""


# ==========================================================================
# UI BUILDER — creates all visual elements with StyleBoxFlat theming
# ==========================================================================

func _build_ui():
	# --- Full-screen bite overlay (yellow flash) ---
	_bite_overlay = ColorRect.new()
	_bite_overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	_bite_overlay.color = Color(1.0, 0.9, 0.15, 0.35)
	_bite_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_bite_overlay.visible = false
	add_child(_bite_overlay)

	# --- Bottom panel ---
	_panel = PanelContainer.new()
	_panel.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
	_panel.offset_top = -180.0
	var panel_style = StyleBoxFlat.new()
	panel_style.bg_color = Color(0.04, 0.05, 0.1, 0.92)
	panel_style.border_color = Color(0.25, 0.45, 0.75, 0.6)
	panel_style.border_width_top = 2
	panel_style.corner_radius_top_left = 12
	panel_style.corner_radius_top_right = 12
	panel_style.set_content_margin_all(14)
	_panel.add_theme_stylebox_override("panel", panel_style)
	add_child(_panel)

	var vbox = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 6)
	_panel.add_child(vbox)

	# — Row 1: Location + Fish count —
	var top_row = HBoxContainer.new()
	vbox.add_child(top_row)

	_location_label = Label.new()
	_location_label.add_theme_color_override("font_color", Color(0.65, 0.82, 1.0))
	_location_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	top_row.add_child(_location_label)

	_fish_count_label = Label.new()
	_fish_count_label.text = "Fish: 0"
	_fish_count_label.add_theme_color_override("font_color", Color(0.55, 0.8, 0.55))
	_fish_count_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	top_row.add_child(_fish_count_label)

	# — Separator —
	var sep = HSeparator.new()
	vbox.add_child(sep)

	# — Center content area (stacked sections, show/hide per state) —
	var center = Control.new()
	center.custom_minimum_size = Vector2(0, 80)
	center.size_flags_vertical = Control.SIZE_EXPAND_FILL
	vbox.add_child(center)

	# IDLE label
	_idle_label = Label.new()
	_idle_label.text = "<o)))><   Cast to fish!   <o)))><"
	_idle_label.set_anchors_preset(Control.PRESET_CENTER)
	_idle_label.grow_horizontal = Control.GROW_DIRECTION_BOTH
	_idle_label.add_theme_font_size_override("font_size", 18)
	_idle_label.add_theme_color_override("font_color", Color(0.55, 0.65, 0.8))
	_idle_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	center.add_child(_idle_label)

	# CAST section (power bar)
	_cast_section = VBoxContainer.new()
	_cast_section.set_anchors_preset(Control.PRESET_FULL_RECT)
	_cast_section.add_theme_constant_override("separation", 8)
	center.add_child(_cast_section)

	var cast_title = Label.new()
	cast_title.text = "CAST POWER"
	cast_title.add_theme_color_override("font_color", Color(1.0, 0.7, 0.2))
	cast_title.add_theme_font_size_override("font_size", 16)
	cast_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_cast_section.add_child(cast_title)

	_cast_bar = ProgressBar.new()
	_cast_bar.custom_minimum_size = Vector2(0, 26)
	_cast_bar.max_value = 100.0
	_cast_bar.show_percentage = false
	var cast_bg = StyleBoxFlat.new()
	cast_bg.bg_color = Color(0.12, 0.12, 0.18)
	cast_bg.set_corner_radius_all(6)
	_cast_bar.add_theme_stylebox_override("background", cast_bg)
	_cast_bar_fill_style = StyleBoxFlat.new()
	_cast_bar_fill_style.bg_color = Color(1.0, 0.7, 0.1)
	_cast_bar_fill_style.set_corner_radius_all(6)
	_cast_bar.add_theme_stylebox_override("fill", _cast_bar_fill_style)
	_cast_section.add_child(_cast_bar)

	# WAIT label
	_wait_label = Label.new()
	_wait_label.text = "Waiting for a bite..."
	_wait_label.set_anchors_preset(Control.PRESET_CENTER)
	_wait_label.grow_horizontal = Control.GROW_DIRECTION_BOTH
	_wait_label.add_theme_font_size_override("font_size", 20)
	_wait_label.add_theme_color_override("font_color", Color(0.45, 0.65, 0.9))
	_wait_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	center.add_child(_wait_label)

	# BITE label (big + flashing)
	_bite_label = Label.new()
	_bite_label.text = "! BITE !"
	_bite_label.set_anchors_preset(Control.PRESET_CENTER)
	_bite_label.grow_horizontal = Control.GROW_DIRECTION_BOTH
	_bite_label.add_theme_font_size_override("font_size", 36)
	_bite_label.add_theme_color_override("font_color", Color(1.0, 0.9, 0.1))
	_bite_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	center.add_child(_bite_label)

	# REEL section (tension bar + progress + info)
	_reel_section = VBoxContainer.new()
	_reel_section.set_anchors_preset(Control.PRESET_FULL_RECT)
	_reel_section.add_theme_constant_override("separation", 4)
	center.add_child(_reel_section)

	_reel_info_label = Label.new()
	_reel_info_label.add_theme_color_override("font_color", Color(0.9, 0.9, 1.0))
	_reel_info_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_reel_section.add_child(_reel_info_label)

	# Tension bar — custom layered ColorRects (bg + safe zone + indicator)
	var tension_container = Control.new()
	tension_container.custom_minimum_size = Vector2(0, 28)
	tension_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_reel_section.add_child(tension_container)

	_tension_bar_bg = ColorRect.new()
	_tension_bar_bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	_tension_bar_bg.color = Color(0.1, 0.1, 0.15)
	tension_container.add_child(_tension_bar_bg)

	# Danger zones (red edges)
	var danger_left = ColorRect.new()
	danger_left.set_anchors_preset(Control.PRESET_LEFT_WIDE)
	danger_left.offset_right = 20.0
	danger_left.color = Color(0.5, 0.1, 0.1, 0.4)
	danger_left.mouse_filter = Control.MOUSE_FILTER_IGNORE
	tension_container.add_child(danger_left)

	var danger_right = ColorRect.new()
	danger_right.set_anchors_preset(Control.PRESET_RIGHT_WIDE)
	danger_right.offset_left = -20.0
	danger_right.color = Color(0.5, 0.1, 0.1, 0.4)
	danger_right.mouse_filter = Control.MOUSE_FILTER_IGNORE
	tension_container.add_child(danger_right)

	_tension_safe_zone = ColorRect.new()
	_tension_safe_zone.color = Color(0.12, 0.45, 0.18, 0.55)
	_tension_safe_zone.mouse_filter = Control.MOUSE_FILTER_IGNORE
	tension_container.add_child(_tension_safe_zone)

	_tension_indicator = ColorRect.new()
	_tension_indicator.color = Color(1.0, 1.0, 1.0)
	_tension_indicator.mouse_filter = Control.MOUSE_FILTER_IGNORE
	tension_container.add_child(_tension_indicator)

	# Reel progress bar
	_reel_progress_bar = ProgressBar.new()
	_reel_progress_bar.custom_minimum_size = Vector2(0, 14)
	_reel_progress_bar.max_value = 100.0
	_reel_progress_bar.show_percentage = false
	var reel_bg = StyleBoxFlat.new()
	reel_bg.bg_color = Color(0.1, 0.1, 0.15)
	reel_bg.set_corner_radius_all(4)
	_reel_progress_bar.add_theme_stylebox_override("background", reel_bg)
	var reel_fill = StyleBoxFlat.new()
	reel_fill.bg_color = Color(0.2, 0.55, 1.0)
	reel_fill.set_corner_radius_all(4)
	_reel_progress_bar.add_theme_stylebox_override("fill", reel_fill)
	_reel_section.add_child(_reel_progress_bar)

	# RESULT label (catch/fail, shown temporarily)
	_result_label = Label.new()
	_result_label.set_anchors_preset(Control.PRESET_CENTER)
	_result_label.grow_horizontal = Control.GROW_DIRECTION_BOTH
	_result_label.add_theme_font_size_override("font_size", 22)
	_result_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_result_label.visible = false
	center.add_child(_result_label)

	# — Prompt label (bottom of vbox) —
	_prompt_label = Label.new()
	_prompt_label.add_theme_color_override("font_color", Color(0.45, 0.5, 0.6))
	_prompt_label.add_theme_font_size_override("font_size", 14)
	_prompt_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(_prompt_label)
