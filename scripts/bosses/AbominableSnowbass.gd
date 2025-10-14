extends "res://scripts/bosses/Boss.gd"

# Abominable Snowbass

var attack_timers = {}
var minion_timer = null
var showboat_timer = null
var pratfall_timer = null
var spotlight_timer = null
var spotlight_state = null
var is_melee_player = true # This should be set based on player fish type

func _ready():
    health = max_health
    start_phase(1)

func start_phase(new_phase):
    phase = new_phase
    emit_signal("phase_changed", phase)
    if phase == 1:
        _start_phase1_attacks()
    elif phase == 2:
        _start_phase2_spotlight_showdown()

func check_phase_transition():
    if health <= max_health * 0.5 and phase == 1:
        _cleanup_phase1_timers()
        start_phase(2)

# --- Phase 1: Signature Attacks ---
func _start_phase1_attacks():
    attack_timers["avalanche"] = _start_timer(5.0, "_avalanche_roar")
    attack_timers["snowboulder"] = _start_timer(7.0, "_snowboulder_toss")
    attack_timers["stompquake"] = _start_timer(10.0, "_stompquake")
    attack_timers["frosty_breath"] = _start_timer(12.0, "_frosty_breath")
    minion_timer = _start_timer(15.0, "_minion_mayhem")
    showboat_timer = _start_timer(18.0, "_showboat_moment")
    pratfall_timer = _start_timer(20.0, "_pratfall_gag")

func _cleanup_phase1_timers():
    for t in attack_timers.values():
        if t: t.stop()
    attack_timers.clear()
    if minion_timer: minion_timer.stop()
    if showboat_timer: showboat_timer.stop()
    if pratfall_timer: pratfall_timer.stop()

func _start_timer(time, method, repeat=true):
    var timer = Timer.new()
    timer.wait_time = time
    timer.one_shot = not repeat
    timer.connect("timeout", self, method)
    add_child(timer)
    timer.start()
    return timer

func _avalanche_roar():
    start_attack("avalanche_roar")
    # TODO: Spawn falling snow, break ice tiles

func _snowboulder_toss():
    start_attack("snowboulder_toss")
    # TODO: Hurl snowballs, spawn minions/powerups

func _stompquake():
    start_attack("stompquake")
    # TODO: Crack ice, send shockwaves

func _frosty_breath():
    start_attack("frosty_breath")
    # TODO: Freeze player in cone

func _minion_mayhem():
    start_attack("minion_mayhem")
    # TODO: Summon snow hare minions

func _showboat_moment():
    start_attack("showboat")
    # TODO: Pause, pose, can be interrupted for bonus

func _pratfall_gag():
    start_attack("pratfall")
    set_vulnerable(true)
    yield(get_tree().create_timer(2.0), "timeout")
    set_vulnerable(false)
    # TODO: Play pratfall animation

# --- Phase 2: Spotlight Showdown ---
func _start_phase2_spotlight_showdown():
    spotlight_state = "init"
    if is_melee_player:
        # Single large spotlight
        start_attack("spotlight_melee")
        spotlight_timer = _start_timer(8.0, "_spotlight_melee_logic")
    else:
        # Two small spotlights, extra challenge
        start_attack("spotlight_ranged")
        spotlight_timer = _start_timer(8.0, "_spotlight_ranged_logic")

func _spotlight_melee_logic():
    # TODO: Move spotlight, check player/boss positions, apply debuffs if outside
    pass

func _spotlight_ranged_logic():
    # TODO: Move spotlights, periodically snuff out player spotlight, apply debuffs
    pass

func _on_ice_cracked():
    set_vulnerable(true)
    yield(get_tree().create_timer(2.0), "timeout")
    set_vulnerable(false)

# Optionally, override take_damage to add dramatic reactions
func take_damage(amount):
    if is_vulnerable:
        health -= amount
        # TODO: Play dramatic animation, maybe trigger pratfall
        if health <= 0:
            health = 0
            emit_signal("defeated")
        else:
            check_phase_transition()