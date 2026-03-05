# An Untitled Feesh — Codebase Issues & Required Work

*Generated from full codebase audit — March 2026*

---

## Table of Contents

1. [Fatal Issues (Game Won't Run)](#1-fatal-issues-game-wont-run)
2. [Critical Runtime Bugs (Crashes on Execution)](#2-critical-runtime-bugs-crashes-on-execution)
3. [High-Severity Issues (Broken Features)](#3-high-severity-issues-broken-features)
4. [Medium-Severity Issues (Code Smells & Conflicts)](#4-medium-severity-issues-code-smells--conflicts)
5. [Low-Severity Issues (Dead Code & Cleanup)](#5-low-severity-issues-dead-code--cleanup)
6. [Missing Systems (Must Build to Ship)](#6-missing-systems-must-build-to-ship)
7. [Missing Content & Assets](#7-missing-content--assets)
8. [Per-File Status Summary](#8-per-file-status-summary)

---

## 1. Fatal Issues (Game Won't Run)

These must be fixed before the project can even load in Godot.

### ~~1.1 — `project.godot` is nearly empty~~
**File:** `project.godot`

The project configuration has almost nothing:
- No autoloads registered (SaveManager, SettingsManager, ProgressionManager, etc.)
- No custom input actions defined (move_left, move_right, attack, special_ability, inventory_menu, zoom_in, zoom_out, etc.)
- No main scene set (`config/main_scene` is absent)
- No audio bus layout configured
- Contains Godot 3 setting `quality/intended_usage=0` which Godot 4 ignores
- Empty icon path

Every script that references a global singleton (`SaveManager`, `SettingsManager`, `ProgressionManager`) will crash at compile time.

---

### ~~1.2 — `Inventory.gd` has two class definitions~~
**File:** `scripts/Inventory.gd`

The file contains two separate `extends Node` blocks concatenated together. A GDScript file can only have one `extends`. Godot will refuse to parse this file entirely. Additionally:
- `move_item_to_slot()` appears before the first `extends`
- `var items = {}` is declared twice
- The second half redefines methods from the first half

Must be consolidated into a single class.

---

### ~~1.3 — Empty data files~~
**Files:** `scripts/data/item_data.gd`, `scripts/data/shop_data.gd`

Both files contain only a comment (`# (moved) Item data / ...existing code...`). No actual data.
- `InventoryMenu.gd` references `backpack_inventory.item_data.ITEM_DATA` — crashes immediately
- `ShopMenu.gd` depends on shop data that doesn't exist

---

### ~~1.4 — `locations.gd` syntax error~~
**File:** `scripts/data/locations.gd`

The `LOCATIONS` variable is declared without `var` or `const` keyword — GDScript 2.0 syntax error. Additionally, it only covers "Lake" and "River" (old biome names), not the canonical biomes.

---

## 2. Critical Runtime Bugs (Crashes on Execution)

These will crash the game when the affected code path is reached.

### ~~2.1 — `Player.gd` variable scoping bug (fishing phase)~~
**File:** `scripts/Player.gd`, lines ~281-288

```gdscript
if current_fish and current_fish.fight_pattern.size() > 0:
    var phase = current_fish.fight_pattern[fight_phase_index]
else:
    var phase = "calm"
# 'phase' is undefined here — block-scoped in GDScript 2.0
match phase:
```
`var` inside `if/else` branches is block-scoped. The `match phase:` references an undefined variable and will crash.

---

### ~~2.2 — `Player.gd` misplaced code inside `open_shop()`~~
**File:** `scripts/Player.gd`, lines ~361-368

Fishing cancel (`ui_cancel`) and location navigation (`ui_left`/`ui_right`) logic references `event`, but it's inside the `open_shop()` function where `event` doesn't exist as a parameter. This code was clearly meant to be inside `_input()` but got displaced, likely during a merge.

---

### ~~2.3 — `Player.gd` references nonexistent `FishDatabase`~~
**File:** `scripts/Player.gd`, line ~434

`_select_fish_for_spot()` calls `FishDatabase.get_random_fish(...)` but no `FishDatabase` class or autoload exists anywhere in the project.

---

### ~~2.4 — `Inventory.gd` variable scoping bug (item filtering)~~
**File:** `scripts/Inventory.gd`, lines ~82-89

Same pattern as Player.gd:
```gdscript
if k in item_data.ITEM_DATA:
    var type = item_data.ITEM_DATA[k].type
else:
    var type = "other"
if type == item_type:  # 'type' is undefined here
```

---

### ~~2.5 — `DonCatfishoni.gd` undefined variable in `start_phase()`~~
**File:** `scripts/bosses/DonCatfishoni/DonCatfishoni.gd`, line ~133

`start_phase()` calls `telegraph_and_attack(attack_name)` but `attack_name` is not a parameter of `start_phase()` — it's a parameter of `start_attack()`. Will crash with "Identifier not found."

---

### ~~2.6 — `DonCatfishoni.gd` indentation error in phase transition~~
**File:** `scripts/bosses/DonCatfishoni/DonCatfishoni.gd`, lines ~153-155

`check_phase_transition()` has broken indentation — `start_phase(2)` runs unconditionally before the `if health <= max_health * 0.3` check. Phase 2 triggers immediately on any damage.

---

### ~~2.7 — `CroakKing.gd` `.emit()` called on a bool variable~~
**File:** `scripts/bosses/CroakKing/CroakKing.gd`, line ~89

`throne_destroyed.emit()` — but `throne_destroyed` is declared as a `bool` variable, not a signal. Will crash with "Invalid call. Nonexistent function 'emit' in base 'bool'."

---

### ~~2.8 — `CroakKing.gd` method name / signal name clash~~
**File:** `scripts/bosses/CroakKing/CroakKing.gd`

`throne_hop()` is a method, but somewhere in the code `throne_hop.emit()` is called, treating it as a signal. Will crash.

---

### ~~2.9 — `FinDiesel.gd` invalid list comprehension~~
**File:** `scripts/bosses/FinDiesel/FinDiesel.gd`, `setup_arena()`

```gdscript
velvet_ropes = [create_velvet_rope(pos) for pos in get_rope_positions()]
```
List comprehensions (`[x for x in y]`) are **not valid GDScript syntax**. Must use a loop or `Array.map()`.

---

### ~~2.10 — `preload()` with dynamic strings (multiple files)~~
**Files:** `TheGreatFisherduck.gd`, `DonCatfishoni.gd`, `FinDiesel.gd`, `PranksterPoppo.gd`

GDScript's `preload()` requires a **compile-time constant string literal**. These files pass variables or string concatenation to `preload()`, which causes a parse-time error. Must use `load()` instead.

---

### ~~2.11 — `Quest.gd` calls methods that don't exist~~
**File:** `scripts/Quest.gd`, lines ~48-62 and ~110-119

`update_progress()` calls:
- `player.backpack.count_fish()` — not on Inventory
- `player.backpack.get_total_weight()` — not on Inventory
- `player.backpack.get_largest_size()` — not on Inventory
- `player.backpack.count_by_rarity()` — not on Inventory

`grant_rewards()` calls:
- `player.add_gold()` — not on Player
- `player.backpack.remove_fish()` — not on Inventory

All will crash when any quest tries to update or complete.

---

### ~~2.12 — `Shop.gd` calls methods that don't exist on Player~~
**File:** `scripts/Shop.gd`, line ~52+

Calls `player_node.spend_gold()`, `player_node.add_gold()`, `player_node.add_item_to_inventory()` — none of these methods exist on Player.gd. Player has `player_gold` as a raw int but no accessor methods.

---

### ~~2.13 — `AbominableSnowbass.gd` awaits nonexistent signal~~
**File:** `scripts/bosses/AbominableSnowBass/AbominableSnowbass.gd`

`await showboat_ended` — but `showboat_ended` is never declared as a signal. The `await` will hang forever or error.

---

### ~~2.14 — `Guppazuma.gd` calls undefined method~~
**File:** `scripts/bosses/Guppazuma/Guppazuma.gd`

`_update_crowd_feedback()` is called but never defined. Will crash when the crowd favor system triggers.

---

### ~~2.15 — `TributeMenu.gd` references undefined class~~
**File:** `scenes/ui/inventory/TributeMenu.gd`

`TributeSlot.new()` — requires `TributeSlot.gd` to have `class_name TributeSlot`. It doesn't (it only has `extends Panel`). Will crash with "Identifier not found."

---

## 3. High-Severity Issues (Broken Features)

These won't crash immediately but cause features to not work.

### ~~3.1 — `Boss.gd` stun blocks damage~~
**File:** `scripts/bosses/Boss.gd`, line ~142

`take_damage()` returns early if `is_stunned` is true. The comment says "stunned bosses ARE vulnerable" but the code makes stunned bosses **invincible**. Contradicts design intent.

---

### ~~3.2 — Godot 3 API in `TributeSlot.gd`~~
**File:** `scenes/ui/inventory/TributeSlot.gd`

Full of Godot 3 API that was renamed in Godot 4:
- `rect_size` → should be `size`
- `get_font("font")` → should be `get_theme_font("font")`
- `update()` → should be `queue_redraw()`
- `draw_string(font, pos, text)` → signature changed (needs `font_size` parameter)
- `can_drop_data` / `drop_data` → should be `_can_drop_data()` / `_drop_data()` (virtual overrides)

---

### 3.3 — Drag-and-drop API broken across all UI
**Files:** `ShopMenu.gd`, `InventoryMenu.gd`, `TributeSlot.gd`

All three files use a Godot 3 drag-and-drop approach:
- `set_drag_data()` — does not exist in Godot 4
- `btn.draggable = true` — not a real property
- `can_drop_data` / `drop_data` as regular methods — should be `_can_drop_data()` / `_drop_data()` virtual overrides
- `set_drag_preview()` — must be moved to `_get_drag_data()` override

None of the drag-and-drop interactions work.

---

### 3.4 — `GridContainer.clear()` called throughout UI
**Files:** `InventoryUI.gd`, `InventoryMenu.gd`, `ShopMenu.gd`

`clear()` is a method on `ItemList`, not `GridContainer`. If these nodes are GridContainers, every call fails. Must free children manually with a loop.

---

### 3.5 — `InventoryMenu.gd` uses renamed property
**File:** `scenes/ui/inventory/InventoryMenu.gd`, line ~112

`slot.rect_min_size` — renamed to `custom_minimum_size` in Godot 4. Will error.

---

### 3.6 — `ObliqueCamera2D.gd` uses deprecated properties
**File:** `scenes/overworld/ObliqueCamera2D.gd`

- `smoothing_enabled` → `position_smoothing_enabled` in Godot 4
- `smoothing_speed` → `position_smoothing_speed` in Godot 4
- Zoom direction is inverted: "zoom_in" action decreases zoom (zooms out in Godot 4)
- No actual camera following code despite being named "follows player"

---

### 3.7 — Biome name mismatch in `ProgressionManager.gd`
**File:** `scripts/progression/ProgressionManager.gd`, line ~76

`biome_order` uses `["RiverLake", "Ocean", "JungleWetlands", "FrozenMountain", "Lava", "FishingSanctum"]`. Every other file in the project uses `["Forest", "Ocean", "Jungle", "FrozenMountain", "Lava", "FishingSanctum"]`. Biome lookups, transitions, and fish filtering will all silently fail.

---

### ~~3.8 — Bounty board is completely non-functional~~
**File:** `scripts/BountyBoard.gd`

All 15 bounty IDs (`bounty_forest_weight`, `bounty_ocean_rare`, etc.) referenced in `_get_bounty_ids_for_area()` are not registered in QuestFactory. Every `QuestFactory.create_quest()` call returns `null`. The null-check filters them all out. The bounty board produces zero bounties in every area.

---

### ~~3.9 — `TributeSlot.gd` rejects most fish~~
**File:** `scenes/ui/inventory/TributeSlot.gd`

`_is_fish()` check relies on `"fish"` being in the item name. Fish like "Bluegill", "Tuna", "Piranha", "Marlin", "Barracuda", "Walleye", etc. don't contain "fish" — the majority of the 102 fish will be rejected as invalid tribute.

---

### ~~3.10 — `Inventory.gd` uses Godot 3 Array API~~
**File:** `scripts/Inventory.gd`

`Array.remove(index)` was renamed to `Array.remove_at(index)` in Godot 4. Multiple calls will fail silently or error.

---

### ~~3.11 — `Inventory.gd` sort_custom return value~~
**File:** `scripts/Inventory.gd`, line ~109

Godot 4's `sort_custom()` expects the callback to return `bool` (true if a < b). The callback returns `-1/0/1` (Godot 3 style). Sorting will produce incorrect results.

---

### ~~3.12 — `SettingsManager.gd` never loads settings~~
**File:** `scripts/SettingsManager.gd`

No `_ready()` call to `load_settings()`. Settings are never loaded on startup — defaults are always used.

---

### ~~3.13 — `SettingsManager.gd` destroys keys on load~~
**File:** `scripts/SettingsManager.gd`, line ~39

`load_settings()` completely replaces the `settings` dictionary. If the saved file is from an older version missing new keys (e.g., `"colorblind"`), those keys vanish instead of falling back to defaults.

---

### ~~3.14 — `QuestLogMenu.gd` data contract mismatch~~
**File:** `scenes/ui/QuestLogMenu.gd`

References `quest.title` and `quest.description`, but ProgressionManager stores quests as plain dicts with `"type"` and `"biome"` keys. Will crash with "Invalid get index 'title'."

---

### 3.15 — `SettingsMenu.gd` volume slider in dB
**File:** `scenes/ui/SettingsMenu.gd`

Sets slider value to `AudioServer.get_bus_volume_db(0)` — a negative dB value. Slider likely expects 0.0–1.0 linear. Should use `db_to_linear()`.

---

### 3.16 — Missing `Minion.gd` base class
**Files:** `scripts/bosses/DonCatfishoni/minions/TommyGunMinion.gd`, `BrassKnuckleMinion.gd`

Both extend `res://scripts/bosses/Minion.gd` which does not exist in the project. Additionally, both call `move_and_slide()` with a direct argument — Godot 4's `move_and_slide()` takes no arguments (uses the `velocity` property).

---

## 4. Medium-Severity Issues (Code Smells & Conflicts)

### 4.1 — Five overlapping progression systems
**Files:** `PlayerProgress.gd`, `BiomeManager.gd`, `UpgradeManager.gd`, `BaitManager.gd`, `ProgressionManager.gd`

All five scripts track overlapping state (current biome, unlocked bait, completed quests, upgrades, fish collected). There is no clear owner. This needs to be consolidated into one authoritative system.

---

### ~~4.2 — Two conflicting Quest classes~~
**Files:** `scripts/Quest.gd` (161 lines, full-featured) vs `scripts/quests/Quest.gd` (22 lines, minimal stub)

The main Quest.gd has `class_name Quest`, progress tracking, serialization, and rewards. The quests/ version is a completely different Resource with an incompatible API. Any code using the wrong one will break. Additionally, `Catch3CarpQuest.gd` extends `Resource` directly (not `Quest`), making it useless as a quest.

---

### ~~4.3 — Duplicate methods in boss scripts~~
| File | Method | Issue |
|---|---|---|
| `DonCatfishoni.gd` | `on_goon_stunned()` | Defined twice; second overrides first |
| `FinDiesel.gd` | `_on_stunned()` | Defined twice; second overrides first |

---

### ~~4.4 — Shadowed `phase` variable in boss scripts~~
**Files:** `CaptainPinchbeard.gd`, `FinDiesel.gd`, `FrostbiteMaestro.gd`, `PranksterPoppo.gd`

All declare `var phase = 1` which shadows `Boss.gd`'s `var phase`. The base class `phase` is never updated — `phase_changed` signal and `check_phase_transition()` reference the base class copy while the child uses its own. Phase tracking becomes inconsistent.

---

### ~~4.5 — Re-declared signals in boss scripts~~
**File:** `CaptainPinchbeard.gd`, lines ~13-14

Re-declares `signal phase_changed` which already exists in `Boss.gd`. May cause parse errors or signal routing confusion in Godot 4.

---

### ~~4.6 — Undeclared signals across boss scripts~~
Multiple boss scripts emit signals that are never declared with the `signal` keyword:

| File | Undeclared Signals |
|---|---|
| `Guppazuma.gd` | `cheer_wave_player`, `confetti_safe_zones`, `confetti_hazard`, `idol_vote_player`, `idol_vote_guppazuma`, `idol_vote_tie` |
| `CroakKing.gd` | `ceremony_started`, `arena_flooded`, `finale_wild_enrage`, `finale_composed_enrage`, `croak_king_defeated` |
| `AbominableSnowbass.gd` | `showboat_ended`, `showboat_interrupted`, `snowbass_defeated` |
| `FrostbiteMaestro.gd` | `maestro_defeated` (has `maestro_vulnerable` but not `maestro_defeated`) |
| `CroakKingCeremony.gd` | `minion_converted`, `minion_knighted`, `ceremony_interrupted` |

---

### ~~4.7 — Double `start_phase(1)` call on boss init~~
**File:** `scripts/bosses/Boss.gd` `_ready()` + every child boss `_ready()`

The base `Boss._ready()` calls `add_to_group("boss")` then `start_phase(1)`. Every child class also calls `start_phase(1)` in their own `_ready()`. Since child `_ready()` runs after parent `_ready()`, phase 1 is initialized twice — potentially triggering double attack spawns or signal emissions.

---

### 4.8 — Boss attack scheduling issue
**Files:** `TheGreatFisherduck.gd`, `DonCatfishoni.gd`, others

Most bosses call ALL attacks simultaneously in `start_phase()` with no delay or timer system. Attacks should cycle with timers. Only Guppazuma and AbominableSnowbass have proper timer-based cycling.

---

### ~~4.9 — `FrostbiteMaestro.gd` potential infinite recursion~~
**File:** `scripts/bosses/FrostbiteMaestro/FrostbiteMaestro.gd`

`fuse_attacks()` calls all 5 attack methods, each of which calls `next_attack()` at the end. `next_attack()` advances an index and calls `start_attack()` — which may call `fuse_attacks()` again. This creates cascading attack chains that could stack overflow.

---

### ~~4.10 — `typeof(X) != TYPE_NIL` pattern for autoload checking~~
**Files:** ~~`Player.gd`~~, ~~`OverworldManager.gd`~~, ~~`PauseMenu.gd`~~, ~~`SettingsMenuV2.gd`~~

`typeof(SaveManager) != TYPE_NIL` is not how to check if an autoload exists. If `SaveManager` isn't registered as an autoload, referencing it is a **compile-time error**, not a nil. Should use `has_node("/root/SaveManager")` or just ensure autoloads are properly registered.

---

### ~~4.11 — Security: `get_var()` without `allow_objects=false`~~
**Files:** `SaveManager.gd`, `SettingsManager.gd`

`file.get_var()` on untrusted save data can instantiate arbitrary Godot objects — a deserialization vulnerability. Should use `get_var(true)` to disable object construction, or switch to JSON serialization.

---

### ~~4.12 — `Quest.gd` duplicate variable declaration~~
**File:** `scripts/Quest.gd`, lines ~26-27

`var progress: Dictionary = {}` appears twice in the same class. Godot may accept it but it's confusing and indicates a copy-paste error.

---

### 4.13 — `SaveManager.gd` fragile node lookups
**File:** `scripts/SaveManager.gd`, lines ~28-38 and ~52-56

- `find_child("Player", true, false)` — if Player isn't named exactly "Player", save silently skips all player data
- Expects `/root/ProgressionManager` and `/root/BiomeManager` as autoloads — not registered

---

### 4.14 — No save format versioning
**File:** `scripts/SaveManager.gd`

Save files have no version field. Future format changes will silently corrupt old saves with no migration path.

---

### ~~4.15 — `Player.gd` has two fishing start paths~~
**File:** `scripts/Player.gd`

`start_fishing()` (line ~183) has full equipment/biome filtering. `_start_fishing_at()` (line ~406) is a separate stub calling undefined `_start_fish_biting_logic()`. Two codepaths for the same feature = inconsistent behavior.

---

### 4.16 — `BossBattleManager.gd` boss_data maps boss_scene to arena
**File:** `scripts/bosses/BossBattleManager.gd`

In the `boss_data` dictionary, both `boss_scene` and `arena_scene` point to the same arena `.tscn` path for every boss. The code then searches for a "Boss" child node in the arena — if not found, boss_instance is null and the fight starts with no boss.

---

### 4.17 — `CombatFish.gd` can leave arena bounds
**File:** `scripts/combat/CombatFish.gd`

No boundary clamping on the fish's position. `_do_charge()` and `_do_dash()` teleport the fish without collision checks — can end up inside walls or outside the arena.

---

### 4.18 — `CombatFish.gd` can only hit bosses
**File:** `scripts/combat/CombatFish.gd`

`_get_hittable_bodies()` only returns nodes in group `"boss"`. Minions, environmental hazards, and destructible objects are not targetable.

---

### 4.19 — `Guppazuma.gd` mimicry calls nonexistent player methods
**File:** `scripts/bosses/Guppazuma/Guppazuma.gd`

`mimicry_attack()` calls `player.get_last_move_type()` and `player.get_last_move_direction()` — neither method exists on Player.gd or CombatFish.gd.

---

### 4.20 — `CroakKing.gd` take_damage bypasses base class
**File:** `scripts/bosses/CroakKing/CroakKing.gd`

`take_damage()` override doesn't call `super()` and doesn't check vulnerability or armor — completely bypasses the base class damage system including status effects.

---

### ~~4.21 — `BountyBoard.gd` completion percentage is wrong~~
**File:** `scripts/BountyBoard.gd`, line ~118

Denominator is `available + posted + completed`, but bounties move between these lists. As they complete, the total shrinks, making percentages jump unexpectedly. Should track a fixed total.

---

### ~~4.22 — `WeatherSystem.gd` can spam re-rolls~~
**File:** `scripts/WeatherSystem.gd`, line ~26

`set_random_weather()` can pick the same weather as current. The `!= guard` skips the update but `weather_duration` stays negative, causing immediate re-rolls on the next tick until a different weather is randomly chosen.

---

## 5. Low-Severity Issues (Dead Code & Cleanup)

### 5.1 — Dead / empty files that should be removed
| File | Reason |
|---|---|
| `biomes.gd` (top-level) | Empty file. Superseded by `scripts/data/biomes.gd` |
| `scenes/ui/SettingsMenu.gd` | Superseded by `SettingsMenuV2.gd`. MainMenu and PauseMenu both use V2 |
| `scenes/ui/InventoryUI.gd` | Superseded by `scenes/ui/inventory/InventoryMenu.gd` |
| `scripts/quests/Quest.gd` | ~~Incompatible stub that conflicts with the main `scripts/Quest.gd`~~ — gutted, marked deprecated |
| `scripts/quests/Catch3CarpQuest.gd` | ~~Duplicates QuestFactory's `_create_catch_3_carp()`. Extends Resource, not Quest~~ — gutted, marked deprecated |

### 5.2 — `TheGreatFisherduck.gd` duplicate disarm methods
**File:** `scripts/bosses/TheGreatFisherduck/TheGreatFisherduck.gd`

`_on_disarmed()` and `on_player_hooks_disarm()` do the same thing — dead code duplication.

### 5.3 — `SaveLoadTest.gd` has untested method
**File:** `scripts/tests/SaveLoadTest.gd`

`test_equipment_persistence()` is defined but never called from `run_tests()`.

### 5.4 — `OverworldScreen.gd` undeclared property assignment
**File:** `scenes/overworld/OverworldScreen.gd`, line ~39

`self.daynight_weather_manager = daynight_weather_manager` assigns to an undeclared property. Works due to GDScript's dynamic nature but is a code smell.

### 5.5 — `InventoryMenuLoader.gd` uses removed method
**File:** `scenes/ui/inventory/InventoryMenuLoader.gd`, line ~10

`inventory_menu.raise_()` — `raise_()` was removed in Godot 4. Use `move_to_front()` instead.

### ~~5.6 — `QuestFactory.gd` only has 1 quest registered~~
**File:** `scripts/QuestFactory.gd`

Only `catch_3_carp` is registered. The bounty board references 15 bounty IDs, none of which exist. QuestFactory needs all quest definitions.

---

## 6. Missing Systems (Must Build to Ship)

| System | Current State | What's Needed |
|---|---|---|
| **Fishing HUD** | Nothing | Cast power bar, tension meter, bite indicator, catch result popup |
| **Boss Battle HUD** | Nothing | Fish HP bar, boss HP bar, special cooldown indicator, swap selection UI |
| **Dialogue System** | `print()` stubs | Textbox UI, speaker portraits, typewriter text effect, branching support |
| **Projectile Scenes** | Nothing | Boss bullets (velocity, damage, `boss_bullet` group, collision), player weapon projectiles (direction, damage, boomerang/lobbed/beam variants) |
| **Boss Attack Timer System** | Most bosses fire all attacks at once | Timer-based attack cycle with telegraph → execute → cooldown pattern |
| **50+ Sub-Scenes** | Nothing | All boss minions, projectiles, hazards, and effects referenced but not created |
| **Overworld Navigation** | Single-screen scaffold | Multi-screen maps per biome, screen transitions, fast travel, NPC placement |
| **NPC Interaction System** | Nothing | Dialogue triggers, quest pickup/turnin, shop interaction, exclamation mark indicators |
| **Area-Specific Fishing** | Nothing | Jungle bow-fishing, depth fishing, weather-affected catches |
| **Finishing Move** | Nothing | "Fin-ish Him" text with Phoenix Wright "Objection" style animation |
| **Fish Swap UI** | Signal wired, no UI | Visual fish selection panel during boss fight pause |
| **Tribute Selection UI** | TributeMenu framework only | Drag-and-drop fish selection from inventory to 3 tribute slots |
| **Arena Boundary System** | Nothing | Keep CombatFish inside arena bounds, wall collision |
| **Minion Base Class** | Missing | `Minion.gd` referenced by TommyGunMinion and BrassKnuckleMinion but doesn't exist |
| **Endgame / Fishing Sanctum** | Nothing | Final area after all bosses defeated |
| **Secret Ending** | Nothing | Clue system about sentient fish mystery |

---

## 7. Missing Content & Assets

### Art & Sprites
- 102 fish sprites (one per fish in the database)
- 10 boss sprites with phase-change animations
- 10 arena tilesets/backgrounds
- 5 overworld biome tilesets
- Player character with fishing/movement/combat animations
- NPC sprites (Host, Gate Guard, 5 shopkeepers, quest givers)
- UI elements (health bars, tension meter, inventory icons, quest log)
- Projectile and effect sprites (bullets, slashes, explosions, status effects)

### Audio
- Music tracks per biome (5 exploration + 10 boss themes)
- Fishing SFX (cast, splash, bite, reel, tension, catch, fail)
- Combat SFX (weapon swings, projectile impacts, abilities, boss attacks)
- UI SFX (menu navigation, button clicks, quest complete)
- Ambient audio per biome

### Scene Files (referenced but don't exist)
**TheGreatFisherduck:** MiniFisherduck.tscn, Duckling.tscn, GoldenDuckling.tscn, Junk_*.tscn, BootPrint.tscn
**DonCatfishoni:** TommyGunMinion scene, BrassKnuckleMinion scene, all hazard/event scenes
**CaptainPinchbeard:** Cannonball.tscn, Parrotfish.tscn, Coin.tscn, PirateCrab.tscn, CrewItem.tscn, Bonus.tscn
**FinDiesel:** RuffianMinion.tscn, CrowdItem_*.tscn
**Guppazuma:** Fruit.tscn, StoneProjectile.tscn, BananaPeel.tscn, RottenFruit.tscn, WildAnimal.tscn, BooBomb.tscn, StonePiranha.tscn, IdolBeam.tscn
**CroakKing:** All minion scenes exist but their scripts are stubs with `pass`
**AbominableSnowbass:** ArenaTelegraph, SnowbassSprite, AudienceSprite (expected as child nodes)
**FrostbiteMaestro:** FrostbiteMaestroChandelier.tscn, FrostbiteIcicle.tscn, FrostbiteSnow.tscn, FrostbiteMinnow.tscn, FrostbiteSheetMusic.tscn, FrostbiteIcePillar.tscn
**MagmaChef:** All attack and mechanic implementations (entire script is `pass` stubs)
**PranksterPoppo:** PoppoDecoy.tscn, PoppoProjectile_*.tscn

---

## 8. Per-File Status Summary

### Core Scripts
| File | Lines | Status | Blockers |
|---|---|---|---|
| `Player.gd` | ~480 | ✅ Done | ~~3 crash bugs~~, fishing rewritten, ~~Shop/Quest integration~~ done |
| `Fish.gd` | ~171 | ✅ Done | Clean, no issues |
| `Inventory.gd` | ~213 | ✅ Done | ~~Two `extends`, scoping bug, Godot 3 API~~ — consolidated & fixed |
| `Equipment.gd` | ~98 | ✅ Done | ~~Minor stat merging issue~~ — tension stacking fixed |
| `Shop.gd` | ~95 | ✅ Done | ~~Calls nonexistent Player methods~~ — uses spend_gold/add_gold/add_item_to_inventory; preload→load |
| `SaveManager.gd` | ~176 | � Mostly Done | ~~Security issue~~ (get_var(true)); fragile lookups and no versioning remain |
| `SettingsManager.gd` | ~55 | ✅ Done | ~~Never loads, key destruction on load~~ — _ready() loads, merge-with-defaults |
| `Quest.gd` | ~158 | ✅ Done | ~~Calls nonexistent Inventory/Player methods~~ — all methods exist, duplicate var removed |
| `QuestManager.gd` | ~230 | ✅ Done | ~~Mixed indentation~~ fixed; auto player lookup via _find_player() |
| `QuestFactory.gd` | ~290 | ✅ Done | ~~Only 1 quest~~ — 22 quests registered (7 NPC + 15 bounties) |
| `BountyBoard.gd` | ~155 | ✅ Done | ~~All bounty creation returns null~~ — all 15 bounties in QuestFactory; fixed total percentage |
| `DayNightSystem.gd` | ~53 | ✅ Done | Clean |
| `WeatherSystem.gd` | ~55 | ✅ Done | ~~Re-roll spam issue~~ — always assigns duration |
| `DayNightWeatherManager.gd` | ~43 | ✅ Done | Clean |

### Data Scripts
| File | Lines | Status | Blockers |
|---|---|---|---|
| `data/fish_data.gd` | ~1200+ | 🟢 Mostly Done | No helpers; biome mismatch with ProgressionManager |
| `data/biomes.gd` | ~80 | ✅ Done | Clean, well-structured |
| `data/item_data.gd` | ~400+ | ✅ Done | ~~Empty~~ — 6 rods, 24 baits, 5 lures, 3 lines, 2 sinkers, 100+ fish, 1 kit |
| `data/shop_data.gd` | ~90+ | ✅ Done | ~~Empty~~ — per-biome shop inventories + upgrades |
| `data/locations.gd` | ~300+ | ✅ Done | ~~Syntax error, wrong biome names~~ — 6 biomes, 40+ spots, all habitats covered |
| `biomes.gd` (top-level) | 0 | ❌ Dead | Should be removed |

### Progression Scripts
| File | Lines | Status | Blockers |
|---|---|---|---|
| `progression/PlayerProgress.gd` | ~80 | 🟡 Partial | Overlaps with ProgressionManager |
| `progression/BiomeManager.gd` | ~50 | 🟡 Partial | Overlaps with ProgressionManager |
| `progression/UpgradeManager.gd` | ~40 | 🔴 Stub | No save support, no effect data |
| `progression/BaitManager.gd` | ~13 | 🔴 Stub | No save support, no integration |
| `progression/ProgressionManager.gd` | ~100 | 🟡 Partial | Wrong biome names, overlaps with all above |

### Boss Scripts
| File | Lines | Status | Critical Issues |
|---|---|---|---|
| `bosses/Boss.gd` | ~192 | ✅ Done | ~~Stun blocks damage~~ fixed; ~~double start_phase(1)~~ removed from base |
| `bosses/BossBattleManager.gd` | ~186 | ✅ Done | boss_scene == arena_scene issue |
| `combat/CombatFish.gd` | ~340 | ✅ Done | `_do_summon()` stub; no arena bounds |
| `TheGreatFisherduck.gd` | ~219 | 🟡 Partial | All attacks fire at once (needs timer system) |
| `DonCatfishoni.gd` | ~231 | � Mostly Done | ~~Undefined variable crash~~; ~~indentation error~~; ~~preload~~; ~~duplicate method~~ — all fixed |
| `CaptainPinchbeard.gd` | ~166 | � Mostly Done | ~~Shadowed vars~~; ~~re-declared signals~~ — fixed |
| `FinDiesel.gd` | ~196 | � Mostly Done | ~~Invalid list comprehension~~; ~~duplicate method~~; ~~shadowed var~~; ~~preload~~ — all fixed |
| `Guppazuma.gd` | ~251 | 🟢 Mostly Done | ~~Undeclared signals~~; ~~missing method~~ — all fixed |
| `CroakKing.gd` | ~168 | � Mostly Done | ~~.emit() on bool~~; ~~method/signal clash~~; ~~undeclared signals~~ — all fixed |
| `AbominableSnowbass.gd` | ~177 | � Mostly Done | ~~Undeclared signals~~; ~~await nonexistent signal~~ — fixed |
| `FrostbiteMaestro.gd` | ~222 | � Mostly Done | ~~Possible infinite recursion~~; ~~shadowed var~~; ~~indentation~~ — fixed |
| `MagmaChef.gd` | ~75 | 🔴 Stub | Every method is `pass` |
| `PranksterPoppo.gd` | ~117 | � Mostly Done | No attack dispatch; ~~preload with dynamic string~~; ~~shadowed var~~ — fixed |
| DonCatfishoni minions (2) | ~18 ea | 🔴 Stub | Missing Minion.gd base class |
| DonCatfishoni events (3) | ~11 ea | 🔴 Stub | Signals only, no logic |
| DonCatfishoni hazards (4) | ~10 ea | 🔴 Stub | Signals only, no logic |
| CroakKing hazards (4) | ~15 ea | 🔴 Stub | All `pass` |
| CroakKing minions (7) | ~15 ea | 🔴 Stub | All `pass` |
| CroakKingCeremony.gd | ~46 | 🟡 Partial | Undeclared signals; never properly invoked |

### Overworld Scripts
| File | Lines | Status | Blockers |
|---|---|---|---|
| `OverworldManager.gd` | ~60 | � Mostly Done | Stub navigation; ~~bad autoload check~~ fixed |
| `FishingSpot.gd` | ~5 | 🔴 Stub | Never connected, no habitat data |
| `OverworldScreen.gd` | ~50 | 🟡 Partial | Undefined input actions, hardcoded positions |
| `BossGateGuard.gd` | ~45 | 🟡 Partial | Assumes nonexistent Player methods |
| `ObliqueCamera2D.gd` | ~30 | 🔴 Broken | Deprecated properties, inverted zoom |

### UI Scripts
| File | Lines | Status | Blockers |
|---|---|---|---|
| `MainMenu.gd` | ~40 | 🟢 Mostly Done | Fragile SaveManager coupling |
| `PauseMenu.gd` | ~35 | � Mostly Done | ~~Bad autoload check~~ fixed; no Resume button |
| `SettingsMenuV2.gd` | ~80 | � Mostly Done | ~~Bad autoload check~~ fixed; accessibility stubs, hardcoded bus indices |
| `InventoryMenu.gd` | ~120 | 🔴 Broken | Godot 3 drag-and-drop API, empty item_data |
| `QuestLogMenu.gd` | ~35 | ✅ Done | ~~Data contract mismatch~~ — uses Quest objects, shows progress strings |
| `ShopMenu.gd` | ~80 | 🔴 Broken | Drag-and-drop API, no buy/sell logic |
| `TributeMenu.gd` | ~40 | 🔴 Broken | Missing class_name on TributeSlot |
| `TributeSlot.gd` | ~50 | 🔴 Broken | Full Godot 3 API, fish name check excludes most fish |
| `SaveNotification.gd` | ~25 | 🟢 Mostly Done | Tween conflict on rapid calls |
| `OpeningCutscene.gd` | ~15 | 🔴 Stub | No content, stuck after timer |
| `InventoryUI.gd` | ~25 | ❌ Dead | Superseded by InventoryMenu |
| `SettingsMenu.gd` | ~20 | ❌ Dead | Superseded by SettingsMenuV2 |

---

*End of Issues Document*
