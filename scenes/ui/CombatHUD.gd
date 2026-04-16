extends CanvasLayer

# CombatHUD.gd — Boss fight UI overlay.
# Shows fish HP, boss HP, weapon/special info, fish swap panel, and victory/defeat.

signal fish_swap_selected(fish_index: int)

@onready var fish_hp_bar = $BottomPanel/FishHPBar
@onready var fish_hp_label = $BottomPanel/FishHPLabel
@onready var fish_name_label = $BottomPanel/FishNameLabel
@onready var weapon_label = $BottomPanel/WeaponLabel
@onready var special_label = $BottomPanel/SpecialLabel
@onready var special_cd_bar = $BottomPanel/SpecialCDBar

@onready var boss_hp_bar = $TopPanel/BossHPBar
@onready var boss_hp_label = $TopPanel/BossHPLabel
@onready var boss_name_label = $TopPanel/BossNameLabel
@onready var boss_phase_label = $TopPanel/BossPhaseLabel

@onready var swap_panel = $SwapPanel

@onready var result_panel = $ResultPanel
@onready var result_label = $ResultPanel/ResultLabel

@onready var info_label = $InfoLabel

var tribute_fish: Array = []  # Reference to the 3 Fish objects


func _ready():
	swap_panel.fish_selected.connect(_on_swap_fish_selected)
	swap_panel.visible = false
	result_panel.visible = false
	special_cd_bar.visible = false
	info_label.text = "WASD: Move | Mouse: Aim | Click: Attack | Right-Click: Special | R: Restart"


func setup_tribute(fish_list: Array):
	tribute_fish = fish_list
	swap_panel.setup(fish_list)


func update_fish_hp(current: int, max_hp: int):
	fish_hp_bar.max_value = max_hp
	fish_hp_bar.value = current
	fish_hp_label.text = "%d / %d" % [current, max_hp]
	# Color the bar
	var ratio = float(current) / max_hp if max_hp > 0 else 0.0
	if ratio > 0.5:
		fish_hp_bar.modulate = Color(0.3, 1.0, 0.3)
	elif ratio > 0.25:
		fish_hp_bar.modulate = Color(1.0, 0.8, 0.2)
	else:
		fish_hp_bar.modulate = Color(1.0, 0.3, 0.3)


func update_fish_info(fish: Fish):
	fish_name_label.text = fish.fish_name
	var wc_name = _weapon_class_name(fish.weapon_class)
	weapon_label.text = "%s (%s)" % [fish.weapon, wc_name]
	if fish.has_special():
		special_label.text = "Special: %s" % fish.special.capitalize()
		special_cd_bar.visible = true
	else:
		special_label.text = "Special: None"
		special_cd_bar.visible = false


func update_special_cooldown(cd_remaining: float, cd_max: float):
	if cd_max <= 0:
		special_cd_bar.visible = false
		return
	special_cd_bar.visible = true
	special_cd_bar.max_value = cd_max
	special_cd_bar.value = cd_max - cd_remaining
	if cd_remaining <= 0:
		special_cd_bar.modulate = Color(0.3, 1.0, 0.8)
	else:
		special_cd_bar.modulate = Color(0.5, 0.5, 0.5)


func update_boss_hp(current: int, max_hp: int):
	boss_hp_bar.max_value = max_hp
	boss_hp_bar.value = current
	boss_hp_label.text = "%d / %d" % [current, max_hp]
	var ratio = float(current) / max_hp if max_hp > 0 else 0.0
	if ratio > 0.5:
		boss_hp_bar.modulate = Color(0.8, 0.2, 0.2)
	else:
		boss_hp_bar.modulate = Color(1.0, 0.4, 0.1)


func update_boss_info(boss_name: String, phase_num: int):
	boss_name_label.text = boss_name
	boss_phase_label.text = "Phase %d" % phase_num


func show_swap_ui(remaining_indices: Array):
	swap_panel.show_selection(remaining_indices, "Your fish fell! Pick your next fighter:")


func hide_swap_ui():
	swap_panel.hide_selection()


func show_victory():
	result_panel.visible = true
	result_label.text = "VICTORY!\nBoss defeated!\n\nPress R to restart"
	result_label.modulate = Color(1.0, 0.85, 0.2)


func show_defeat():
	result_panel.visible = true
	result_label.text = "DEFEAT\nAll fish consumed...\n\nPress R to restart"
	result_label.modulate = Color(1.0, 0.3, 0.3)


func hide_result():
	result_panel.visible = false


func _on_swap_fish_selected(index: int):
	fish_swap_selected.emit(index)


func _weapon_class_name(wc: int) -> String:
	match wc:
		Fish.WeaponClass.SLASH: return "Slash"
		Fish.WeaponClass.HEAVY_SLASH: return "Heavy Slash"
		Fish.WeaponClass.THRUST: return "Thrust"
		Fish.WeaponClass.SMASH: return "Smash"
		Fish.WeaponClass.WHIP: return "Whip"
		Fish.WeaponClass.SINGLE_SHOT: return "Single Shot"
		Fish.WeaponClass.BOOMERANG: return "Boomerang"
		Fish.WeaponClass.BLASTER: return "Blaster"
		Fish.WeaponClass.BEAM: return "Beam"
		Fish.WeaponClass.RAPID_FIRE: return "Rapid Fire"
		Fish.WeaponClass.LOBBED: return "Lobbed"
		_: return "Unknown"
