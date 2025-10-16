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
    # Spawn falling ice chunks and icicles in telegraphed patterns
    var fall_positions = _get_random_fall_positions()
    for pos in fall_positions:
        if randi() % 2 == 0:
            _spawn_ice_chunk(pos)
        else:
            _spawn_icicle(pos)

func _spawn_ice_chunk(pos):
    # Instance and drop an ice chunk at pos; on impact, break ice tile (create water hazard)
    _telegraph_attack("ice_chunk", pos)
    yield(get_tree().create_timer(0.5), "timeout")
    if has_node("../Arena"):
        get_node("../Arena").break_ice_tile(pos)

func _spawn_icicle(pos):
    # Instance and drop an icicle at pos; on impact, create spike hazard
    _telegraph_attack("icicle", pos)
    yield(get_tree().create_timer(0.5), "timeout")
    if has_node("../Arena"):
        get_node("../Arena").spawn_spike_hazard(pos)

func _get_random_fall_positions():
    # Placeholder: return a list of positions above the arena
    return [Vector2(200,0), Vector2(400,0), Vector2(600,0)]

func _snowboulder_toss():
    start_attack("snowboulder_toss")
    # Hurl snowballs that roll and shatter into smaller projectiles
    var lanes = [150, 300, 450]
    for y in lanes:
        _spawn_snowboulder(Vector2(0, y))

func _spawn_snowboulder(pos):
    # Instance and launch a snowboulder; on break, spawn projectiles/minions/powerups
    _telegraph_attack("snowboulder", pos)
    yield(get_tree().create_timer(0.5), "timeout")
    if has_node("../Arena"):
        get_node("../Arena").spawn_snowboulder(pos)

func _stompquake():
    start_attack("stompquake")
    # Remove all floor hazards (spikes, ice chunks) from arena
    if has_node("../Arena"):
        get_node("../Arena").clear_floor_hazards()
    # Send out shockwaves that can stun players
    if has_node("../Arena"):
        get_node("../Arena").spawn_shockwaves(global_position)

func _frosty_breath():
    start_attack("frosty_breath")
    # Emit icy cone; freeze player if hit
    if has_node("../Arena"):
        get_node("../Arena").emit_frosty_breath(global_position, rotation)

func _minion_mayhem():
    start_attack("minion_mayhem")
    # Summon snow hare minions that skate, drop snowballs, or repair ice
    if has_node("../Arena"):
        get_node("../Arena").summon_snow_hare_minions()

func _showboat_moment():
    start_attack("showboat")
    # Pause to sign autographs, pose, or interact with audience
    set_vulnerable(true)
    $SnowbassSprite.play("showboat_pose")
    $AudienceSprite.play("applause")
    var interrupted = false
    var timer = Timer.new()
    timer.wait_time = 2.5
    timer.one_shot = true
    timer.connect("timeout", self, "_on_showboat_end", [interrupted])
    add_child(timer)
    timer.start()
    yield(self, "showboat_ended")
    set_vulnerable(false)

func on_player_interrupt_showboat():
    # Player interrupts showboat for bonus
    if is_vulnerable:
        $SnowbassSprite.play("showboat_interrupted")
        $AudienceSprite.play("gasp")
        emit_signal("showboat_interrupted")
        take_damage(2)
        emit_signal("showboat_ended")

func _on_showboat_end(interrupted):
    if not interrupted:
        $SnowbassSprite.play("showboat_bow")
        $AudienceSprite.play("applause")
    emit_signal("showboat_ended")

func _pratfall_gag():
    start_attack("pratfall")
    # Slips, falls, or gets stuck in snow; player can counterattack
    set_vulnerable(true)
    $SnowbassSprite.play("pratfall")
    $AudienceSprite.play("laughter")
    yield(get_tree().create_timer(2.0), "timeout")
    set_vulnerable(false)

# --- Phase 2: Spotlight Showdown ---
func _start_phase2_spotlight_showdown():
    spotlight_state = "init"
    if is_melee_player:
        # Single large spotlight follows both player and boss
        start_attack("spotlight_melee")
        spotlight_timer = _start_timer(8.0, "_spotlight_melee_logic")
    else:
        # Two small spotlights: one for player, one for boss
        start_attack("spotlight_ranged")
        spotlight_timer = _start_timer(8.0, "_spotlight_ranged_logic")

func _spotlight_melee_logic():
    # Move spotlight, check player/boss positions, apply debuffs if outside
    if has_node("../Arena"):
        get_node("../Arena").update_spotlight_melee()

func _spotlight_ranged_logic():
    # Move spotlights, periodically snuff out player spotlight, apply debuffs
    if has_node("../Arena"):
        get_node("../Arena").update_spotlight_ranged()

func _on_ice_cracked():
    set_vulnerable(true)
    yield(get_tree().create_timer(2.0), "timeout")
    set_vulnerable(false)

# Optionally, override take_damage to add dramatic reactions
func take_damage(amount):
    if is_vulnerable:
        health -= amount
        # Play dramatic animation, maybe trigger pratfall
        if randi() % 5 == 0:
            _pratfall_gag()
        if health <= 0:
            health = 0
            on_snowbass_defeated()
        else:
            check_phase_transition()
func _telegraph_attack(type, pos):
    # Visual/audio telegraph for attack at pos
    $ArenaTelegraph.show_telegraph(type, pos)
    $SnowbassSprite.play("telegraph_" + type)
    $AudienceSprite.play("gasp")
func on_snowbass_defeated():
    # Finale spectacle: slip, spin, crash through ice, crowd celebration
    emit_signal("snowbass_defeated")
    $SnowbassSprite.play("finale_slip_spin")
    yield(get_tree().create_timer(1.2), "timeout")
    $SnowbassSprite.play("finale_crash")
    $AudienceSprite.play("applause")