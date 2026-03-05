# An Untitled Feesh — Game Design Document

*Generated from codebase analysis — March 2026*

---

## Table of Contents

1. [Game Overview](#1-game-overview)
2. [Story & Setting](#2-story--setting)
3. [Core Gameplay Loop](#3-core-gameplay-loop)
4. [Fishing System](#4-fishing-system)
5. [Combat System (Boss Fights)](#5-combat-system-boss-fights)
6. [Fish Database](#6-fish-database)
7. [Boss Roster](#7-boss-roster)
8. [Overworld & Biomes](#8-overworld--biomes)
9. [Progression & Economy](#9-progression--economy)
10. [Quest System](#10-quest-system)
11. [Inventory & Equipment](#11-inventory--equipment)
12. [UI Systems](#12-ui-systems)
13. [Save/Load System](#13-saveload-system)
14. [Day/Night & Weather](#14-daynight--weather)
15. [Audio & Visual Design](#15-audio--visual-design)

---

## 1. Game Overview

**Title:** An Untitled Feesh
**Engine:** Godot 4 (GDScript 2.0)
**Genre:** Fishing RPG / Twin-Stick Bullet Hell Boss Battler
**Perspective:** Top-down 2D

**Elevator Pitch:**
A lighthearted fishing adventure where the fish you catch become your fighters. Explore five biomes, master the fishing minigame, then sacrifice three fish at guardian gates to battle absurd bosses in twin-stick bullet hell arenas. Every fish has a unique weapon class and possible special ability. Win or lose, your tribute fish are consumed — making every catch and every sacrifice meaningful.

**Core Pillars:**
- Fish are the currency, the army, and the hook (literally)
- Every boss is beatable with the worst fish — skill beats stats
- Comedy and charm in every encounter
- Meaningful risk: all 3 tribute fish are lost regardless of outcome

---

## 2. Story & Setting

### Premise
A tourist arrives on an island having paid for "The Ultimate Fishing Adventure." Armed with a basic rod and tacklebox, they explore five biomes, catch fish, help locals, and discover that guardian gates require fish sacrifices to unlock boss arenas.

### Story Arc
1. Player arrives at the dock, receives basic gear
2. Locals offer quests for specific fish (teaches fishing mechanics)
3. Each biome has a guardian gate requiring 3 fish as tribute
4. Tribute fish come alive and fight for the player in bullet-hell boss arenas
5. After clearing all biomes, a reveal: bosses were mechanical puppets built by locals
6. The true nature of the sentient fish is left as a mystery (secret ending hooks)

### Key Characters
- **The Host** — Greets the player at each new area; dismisses mentions of boss fights
- **The Gate Guard** — Same character at every guardian gate across all biomes; guides the tribute ritual
- **Area Shopkeepers** — Unique NPC per biome (Bait Woman in Forest, Boat Captain in Ocean, Amazoness Fisher in Jungle, Mountain Climber in Frozen Mountain, Scientist in Lava)

---

## 3. Core Gameplay Loop

```
EXPLORE biome → FISH for catches → COMPLETE quests (optional) →
CHOOSE 3 tribute fish → BOSS FIGHT (twin-stick bullet hell) →
WIN: progress to next biome / LOSE: re-catch fish, try again
```

### Loop Detail
1. **Explore** — Move through the overworld, find fishing spots, talk to NPCs
2. **Fish** — Cast line at fishing spots; timing-based minigame determines catch
3. **Manage** — Equip gear, sell fish, complete quests, buy bait/upgrades
4. **Tribute** — At the guardian gate, select 3 fish from inventory; all 3 are consumed win or lose
5. **Fight** — Control one fish at a time in a twin-stick arena; swap on death
6. **Progress** — Defeating a boss unlocks the next biome

---

## 4. Fishing System

### State Machine
The fishing system (in `Player.gd`) uses a state machine:
```
IDLE → CASTING → WAITING → BITING → REELING → (catch or fail) → IDLE
```

### Casting
- Free-aim with mouse cursor; cast direction updates in real time
- Hold cast button to charge power; release sends the line
- Cast power determines distance (variable cast power implemented)

### Biting
- After the line lands, a randomized timer triggers a bite
- Fish selection is filtered by: biome, sub-biome/habitat, equipped bait
- Each fish has `bite_time_range` (e.g., 1.0–3.0s) and `reaction_window` (e.g., 0.7s)

### Reeling Minigame
- Tension meter with safe zone management
- Fish has a `fight_pattern` array of phases: `"calm"`, `"pull"`, `"dart"`
- Player must keep tension in the safe range while reeling
- Success = catch; failure = fish escapes

### Per-Fish Properties (from `fish_data.gd`)
| Property | Description |
|---|---|
| `bite_time_range` | Vector2 min/max seconds before fish bites |
| `reaction_window` | Seconds player has to react to the bite |
| `fight_pattern` | Array of phases during reeling minigame |
| `preferred_baits` | Array of bait names that attract this fish |
| `habitat` | Array of sub-biome locations (e.g., `["lake", "pond"]`) |

---

## 5. Combat System (Boss Fights)

### Overview
Boss fights are top-down twin-stick bullet hell encounters. The player controls one fish at a time from their 3-fish tribute. Fish have weapons, stats, and abilities.

### Controls
- **WASD** — Move fish
- **Mouse** — Aim weapon
- **Click** — Fire/swing weapon
- **Special key** — Activate special ability (if fish has one)

### Tribute Flow (in `BossBattleManager.gd`)
1. Player selects 3 fish from inventory at the guardian gate
2. Arena loads; player chooses starting fish
3. On fish death: dramatic pause → bullets clear → swap UI → new fish spawns
4. All 3 die = defeat (player expelled, all 3 fish lost)
5. Boss defeated = victory (surviving fish run off — still lost)
6. **All 3 tribute fish are consumed regardless of outcome**

### Stat Inflation
All fish stats are multiplied by 10 at combat load time for display/gameplay feel:
- HP, Attack, Defense × 10
- Speed stays raw (movement multiplier)

### Damage Formulas

**Player → Boss:**
```
damage_per_hit = fish_attack × weapon_modifier
```
No boss defense stat; boss HP is the balancing lever. Armored phases halve damage (broken by `armor_break` or completing a mechanic).

**Boss → Player:**
```
effective_damage = bullet_base_damage × (100 / (100 + fish_defense))
minimum damage = 1
```

### i-Frames
- 1.0 second of invulnerability after taking a hit
- Fish flashes during i-frames (0.1s toggle interval)

### Weapon Classes (11 total)
Every fish has one dedicated weapon mapped to a class. Melee classes have ~30-50% higher DPS than ranged to compensate for risk.

**Melee (5):**
| Class | Behavior | Range | Speed | Modifier |
|---|---|---|---|---|
| SLASH | Arc swing, 90° | 50px | 2.5/s | 1.0× |
| HEAVY_SLASH | Wide swing, 140° | 65px | 1.5/s | 1.5× |
| THRUST | Straight lunge | 80-100px | 2.0/s | 1.1× |
| SMASH | Overhead slam + AoE | 40px | 1.3/s | 1.5× |
| WHIP | Thin sweep, 30° | 90px | 2.0/s | 0.9× |

**Ranged (6):**
| Class | Behavior | Range | Speed | Modifier |
|---|---|---|---|---|
| SINGLE_SHOT | Charge and release | Full arena | 1.2/s | 1.8× |
| BOOMERANG | Thrown + return (2 hits) | 200px | 1.5/s | 0.6× ea |
| BLASTER | Standard projectile | Full arena | 2.5/s | 0.6× |
| BEAM | Continuous line (2s on/1s off) | Long | 8 tick/s | 0.25×/tick |
| RAPID_FIRE | Weak spray | Full arena | 9/s | 0.13× |
| LOBBED | Arced AoE explosion | Med-Long | 1.0/s | 1.3× |

**Class Distribution:** 71 melee (70%) / 31 ranged (30%). Ranged fish are prized finds.

### Melee HP Bonus
Melee weapon classes get +15% HP bonus at combat load time to compensate for point-blank dodging risk.

### Special Abilities

**Passive (proc on weapon hits):**
| Ability | Effect | Count |
|---|---|---|
| stun | 15% chance, 0.5s boss freeze, 5s internal cooldown | 13 |
| bleed | Stack DoT (atk×0.1/sec, 3s, max 3 stacks) | 6 |
| burn | Refreshing DoT (atk×0.15/sec, 4s) | 4 |
| poison | DoT + 15% boss slow (atk×0.1/sec, 5s) | 1 |
| pierce | Ignore boss armor phases | 3 |
| multi_shot | Every attack fires twice (2nd at 70% damage) | 10 |

**Active (press ability key, cooldown timer):**
| Ability | Effect | Cooldown | Count |
|---|---|---|---|
| berserk | +100% atk speed, +50% dmg, take 30% more | 20s | 3 |
| charge | Dash lunge, 3× attack, brief i-frames | 8s | 6 |
| reflect | Shield reflecting boss bullets as damage | 15s | 5 |
| heal | Restore 20% max HP | 25s | 6 |
| summon | Spawn ally fish (50% atk, 10s duration) | 30s | 2 |
| firestorm | Screen-wide AoE burst, 5× attack | 45s | 1 |
| dash | Invulnerable dash, 150px | 3s | 1 |
| armor_break | Next 3 hits deal 2× dmg, strips boss armor 5s | 18s | 3 |

### Boss Status Effects (in `Boss.gd`)
Bosses can receive: stun, bleed (stacking), burn (refreshing), poison (slow). These are applied by CombatFish passive abilities and processed via DoT ticking in `Boss._process()`.

### Boss Bullet Damage Tiers
| Bullet Type | Base Damage |
|---|---|
| Small bullet | 40–60 |
| Large bullet | 80–120 |
| Boss slam/charge | 150–250 |
| Stage hazard | 40–80 |
| Phase 2+ | All × 1.25–1.5 |

---

## 6. Fish Database

102 fish across 5 biomes stored in `scripts/data/fish_data.gd`. Each fish is a dictionary with:

| Field | Type | Description |
|---|---|---|
| `name` | String | Display name |
| `rarity` | int (0-4) | COMMON, UNCOMMON, RARE, LEGENDARY, MYTHIC |
| `biome` | String | Parent biome name |
| `habitat` | Array | Sub-biome locations |
| `hp` | int | Base HP (pre-inflation) |
| `attack` | int | Base attack |
| `defense` | int | Base defense |
| `speed` | int | Movement speed (not inflated) |
| `weapon` | String | Weapon name (maps to weapon class) |
| `special` | String | Ability name or `null` |
| `bite_time_range` | Vector2 | Fishing bite timing |
| `reaction_window` | float | Fishing reaction window |
| `fight_pattern` | Array | Reeling minigame phases |
| `preferred_baits` | Array | Baits that attract this fish |
| `rarity_multiplier` | float | Gold/reward payout modifier |

### Stat Ranges (post-inflation ×10)
| Rarity | HP | Attack | Defense | Speed |
|---|---|---|---|---|
| Common (0) | 240–360 | 50–80 | 10–20 | 4–8 |
| Uncommon (1) | 360–600 | 80–120 | 20–40 | 5–9 |
| Rare (2) | 650–900 | 120–200 | 30–60 | 6–9 |
| Legendary (3) | 1,000–1,500 | 180–280 | 60–100 | 2–11 |
| Mythic (4) | 2,000 | 350 | 150 | 3 |

### Per-Biome Fish Count
| Biome | Fish | Melee | Ranged |
|---|---|---|---|
| Forest | 26 | 19 | 7 |
| Ocean | 20 | 14 | 6 |
| Jungle | 19 | 13 | 6 |
| Frozen Mountain | 18 | 13 | 5 |
| Lava | 19 | 12 | 7 |

---

## 7. Boss Roster

10 bosses across 5 biomes (2 per biome: one standard, one challenge).

| # | Boss | Biome | HP | Role | Theme |
|---|---|---|---|---|---|
| 1 | TheGreatFisherduck | Forest | 20,000 | First boss, tutorial | Grumpy duck angler, fishing rod attacks |
| 2 | DonCatfishoni | Forest | 30,000 | Forest challenge | Mob-boss catfish, tommy gun bullets |
| 3 | CaptainPinchbeard | Ocean | 35,000 | Ocean standard | Pirate crab on a ferry, cannonball salvos |
| 4 | FinDiesel | Ocean | 45,000 | Ocean challenge | Shark bouncer, velvet ropes and bubblegum |
| 5 | Guppazuma | Jungle | 50,000 | Jungle standard | Aztec idol fish, audience favor system |
| 6 | CroakKing | Jungle | 60,000 | Jungle challenge | Frog king, minion conversion, throne mechanic |
| 7 | AbominableSnowbass | Frozen Mountain | 65,000 | FrozenMtn standard | Showboating celebrity, breakable ice |
| 8 | FrostbiteMaestro | Frozen Mountain | 75,000 | FrozenMtn challenge | Ice conductor, tempo-synced attacks |
| 9 | MagmaChef | Lava | 80,000 | Lava standard | Gordon Ramsay chef, lava kitchen |
| 10 | PranksterPoppo | Lava | 100,000 | Final boss | Jester, lava pool whack-a-mole, fake death |

### Fight Duration Targets
- Early boss (20k HP): 2–6 minutes depending on skill + fish quality
- Late boss (100k HP): 4–10 minutes
- Balance rule: every boss beatable with the worst fish (skill > stats)

---

## 8. Overworld & Biomes

### Biome Progression Order
```
Forest → Ocean → Jungle → Frozen Mountain → Lava → Fishing Sanctum (endgame)
```

### Biome Data (from `BiomeData` class in `scripts/data/biomes.gd`)
| Biome | Display Name | Sub-Biomes | Bosses | Sell Multiplier |
|---|---|---|---|---|
| Forest | Whispering Woods | lake, river, pond, swamp, waterfall | TheGreatFisherduck, DonCatfishoni | 1.0× |
| Ocean | Sapphire Seas | shore, reef, deep_sea, tide_pool, shipwreck | CaptainPinchbeard, FinDiesel | 1.2× |
| Jungle | Tangled Tropics | river, swamp, waterfall, lagoon, cenote | Guppazuma, CroakKing | 1.4× |
| FrozenMountain | Frostpeak Summit | glacier_lake, ice_cave, frozen_river, hot_spring, summit_pool | AbominableSnowbass, FrostbiteMaestro | 1.6× |
| Lava | Molten Depths | lava_flow, obsidian_pool, magma_cave, volcanic_spring, caldera | MagmaChef, PranksterPoppo | 1.8× |
| FishingSanctum | The Fishing Sanctum | sanctuary_pool | — | 2.0× |

### Overworld Structure
- Each biome is a series of `OverworldScreen` scenes with fade transitions
- Screens contain: Player spawn, fishing spots, NPCs, boss gate guard
- Navigation between screens via edge detection
- Autosave triggers on screen transitions

---

## 9. Progression & Economy

### Biome Unlocking
- Defeating a biome's standard boss unlocks the next biome
- Challenge bosses are optional (for completionists / better rewards)
- The Fishing Sanctum unlocks after all 5 biomes are cleared

### Currency
- Gold earned from: selling fish (price × biome sell multiplier × rarity), quest rewards, bounty completion
- Gold spent on: bait restocks, gear upgrades, cosmetic outfits

### Upgrades (from `UpgradeManager.gd`)
- Equipment upgrades: Rods (Rod1, Rod2), Boat, BaitBag
- Specific effects TBD per upgrade

### Bait System
- Each biome unlocks new bait types
- Fish have `preferred_baits` — using the right bait increases catch chances
- Bait is consumed on each cast

---

## 10. Quest System

### Quest Types

**NPC Quests:**
- Locals display exclamation marks when quests are available
- Typically request specific local fish (e.g., "Bring me 3 Carp")
- Rewards: modest gold, sometimes information or items
- All optional; can be abandoned anytime
- Turning in quest fish removes them from inventory

**Bounty Board Challenges:**
- Posted at each area's shop
- Focus on fishing challenges: size, weight, quantity, rarity targets
- Limited number per area, tied to rare/legendary fish count
- Rewards: more gold than NPC quests + hints about rare/legendary fish locations
- Completing bounties reveals increasingly valuable fishing intel

### Quest Data (from `Quest.gd`)
Quests support requirements:
- `catch_count` — catch X of a specific fish
- `total_weight` — catch fish totaling X weight
- `min_size` — catch a fish at least X size
- `rare_count` — catch X fish of a minimum rarity

### Quest Flow
1. Discover quest (NPC or bounty board)
2. Accept → appears in quest log
3. Progress updates on relevant fish catches
4. Turn in at source → rewards granted, fish consumed
5. No quests required for progression; only the boss gate matters

---

## 11. Inventory & Equipment

### Inventory Structure (from `Player.gd`)
- **Tacklebox** — Equipment storage (poles, lines, bobbers, sinkers, bait, clothes)
- **Backpack** — General item/fish storage with stackable and unique items

### Equipment Slots (from `Equipment.gd`)
| Slot | Purpose |
|---|---|
| pole | Fishing rod (affects cast distance, reeling) |
| line | Line strength (affects tension limits) |
| bobber | Bobber type (affects bite detection) |
| sink | Sinker (affects depth) |
| bait | Current bait (affects which fish bite) |
| clothes | Cosmetic outfit |

### Equipment Stats
Equipment modifies: `cast_distance_bonus`, `reel_speed_bonus`, `bite_chance_bonus`, `tension_safe_min/max`, `depth`.

---

## 12. UI Systems

### Implemented Menus
| Menu | Script | Status |
|---|---|---|
| Main Menu | `MainMenu.gd` | Functional (New Game, Continue, Settings, Quit) |
| Pause Menu | `PauseMenu.gd` | Functional (Save, Settings, Quit to Main) |
| Settings V2 | `SettingsMenuV2.gd` | Partially functional (volume, screen mode, resolution; accessibility stubs) |
| Inventory | `InventoryMenu.gd` | Framework only (3×3 grid + tabbed tacklebox) |
| Quest Log | `QuestLogMenu.gd` | Framework only (active/completed list display) |
| Shop | `ShopMenu.gd` | Framework only (buy/sell grid) |
| Tribute | `TributeMenu.gd` | Framework only (3-slot fish selection for boss gates) |
| Save Notification | `SaveNotification.gd` | Functional (fade-in/out "Game Saved" label) |
| Opening Cutscene | `OpeningCutscene.gd` | Placeholder (2.5s timer, no content) |

### Missing UI
- Boss battle HUD (fish HP bar, boss HP bar, special cooldown indicator)
- Fishing HUD (cast power meter, tension meter, bite indicator)
- Minimap / area map
- Dialogue system (currently just `print()` calls)
- Fish-swap selection UI during boss fights
- "Fin-ish Him" finishing move text (design doc specifies Phoenix Wright "Objection" style animation)

---

## 13. Save/Load System

### Architecture (from `SaveManager.gd`)
- Singleton pattern (intended as autoload)
- Saves to `user://savegame.dat` using Godot's `store_var`/`get_var`
- Data structure: `{ "player": {...}, "world": {...}, "quests": {...}, "progress": {...} }`

### What Gets Saved
- Player: position, gold, inventory (tacklebox + backpack), equipment
- Quests: active quest states, completed quest IDs
- Progression: current biome, unlocked bait, upgrades, fish collection log

### Auto-save Triggers
- On overworld screen transitions
- Manual save via pause menu (exploration mode only)

---

## 14. Day/Night & Weather

### Day/Night Cycle (from `DayNightSystem.gd`)
- Tracks in-game hour, minute, day
- Phases: `"dawn"`, `"day"`, `"dusk"`, `"night"`
- Signals emitted on phase change and time tick
- Time advanced via configurable timer (default: every 2 seconds game = 15 minutes in-game)

### Weather System (from `WeatherSystem.gd`)
- States: `"clear"`, `"rain"`, `"fog"`, `"storm"`
- Random transitions with configurable duration
- Signals emitted on weather change
- Intended to affect fish bite rates and available catches (not yet implemented)

### Coordinator (from `DayNightWeatherManager.gd`)
- Instantiates and ticks both systems via a shared Timer
- Added as child of OverworldScreen

---

## 15. Audio & Visual Design

### Audio (from design docs + settings)
- 3 audio buses planned: Master, Music, SFX
- Per-bus volume control and mute in SettingsMenuV2
- No audio assets or implementation yet

### Visual
- Top-down 2D perspective
- Oblique camera with zoom in/out
- Fade transitions between overworld screens
- Fish flash effect during i-frames in combat
- Boss telegraph system for attack previews

### Planned Polish
- Bobber animations and splash effects
- Weather visual effects (rain, fog, storm)
- Boss phase-change visual effects
- "Fin-ish Him" finishing move animation (Phoenix Wright style)
- Character customization via purchasable outfits

---

*End of Design Document*
