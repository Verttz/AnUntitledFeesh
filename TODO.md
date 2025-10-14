# AnUntitledFeesh - Development Checklist

## General TODOs
- [ ] Implement save/load system for player progress
- [ ] Polish and connect all shop UI and inventory interactions
- [ ] Implement all TODOs and placeholder comments in scripts (search for TODO)

## Core Features
- [x] Integrate biome selection and fish selection logic
- [x] Map fish fight patterns to reeling minigame behavior
- [x] Implement bait selection and its effect on fish bites
- [x] Inventory system for caught fish
- [x] Boss fish battle system  <!-- Modular boss system, base class, manager, and arenas scaffolded -->
- [x] Area progression logic (unlock new biomes) <!-- ProgressionManager, BiomeManager, and unlock logic scaffolded -->
- [ ] Build and polish all boss arenas (add obstacles, visuals, interactive elements)
- [ ] Implement all boss attack logic and unique mechanics
- [ ] Add defeat/victory animations and transitions for each boss
- [ ] Connect boss signals to arena/environment (e.g., breaking ice, hazards, minion spawns)
- [ ] Implement minion summoning and behavior for bosses that use minions
- [ ] Complete all phase transitions and special phase logic for each boss
- [ ] Implement and polish the “Spotlight Showdown” for Abominable Snowbass
- [ ] UI for fishing, inventory, tension meter, etc.
- [ ] Audio/visual feedback and polish
- [ ] General polish, bugfixes, and balancing

## Fishing System
- [x] Player movement and fishing state logic
- [x] Bobber phase and reaction window
- [x] Reeling minigame framework
- [x] Fish data structure and per-biome fish lists
- [x] Connect fish fight patterns to tension meter
- [ ] Add unique events (e.g., Angry Hermit Crab Shell)
- [ ] Complete all fishing UI (bobber, tension meter, reeling minigame, etc.)
- [ ] Add sound and visual feedback for fishing actions (bites, reeling, catching, failing)
- [ ] Implement unique fish abilities and special events
- [ ] Add and polish player animations (movement, fishing, reeling, etc.)

## Inventory & Progression
- [x] Store and display caught fish
- [x] Track fish by biome and rarity
- [x] Unlock new areas after boss battles <!-- Progression and area unlocks scaffolded -->
- [ ] Implement quest save/load and quest UI
- [ ] Add upgrade purchasing UI and effects
- [ ] Implement all upgrade effects in gameplay

## Boss Battles
- [x] Design boss fish for each biome <!-- 10 unique bosses designed and scaffolded -->
- [x] Use caught fish in boss battles <!-- Boss system supports using caught fish -->
- [x] Unique boss mechanics per area <!-- Boss scripts scaffolded for unique logic -->
- [ ] Implement all boss attack logic and unique mechanics (see boss scripts for stubs)
- [ ] Add defeat/victory animations and transitions for each boss
- [ ] Connect boss signals to arena/environment (e.g., breaking ice, hazards, minion spawns)
- [ ] Implement minion summoning and behavior for bosses that use minions
- [ ] Complete all phase transitions and special phase logic for each boss
- [ ] Implement and polish the “Spotlight Showdown” for Abominable Snowbass

## UI/UX
- [ ] Fishing UI (bobber, tension meter, prompts)
- [ ] Inventory UI
- [ ] Area/biome selection UI
- [ ] Feedback for rare/fun catches
- [ ] Polish and connect all shop UI and inventory interactions
- [ ] Implement quest save/load and quest UI

## Audio/Visuals
- [ ] Add sound effects for fishing, reeling, catching, and special events
- [ ] Add visual effects for bites, tension, and rare events
- [ ] Add and polish all sound effects and music cues
- [ ] Add visual effects for boss attacks, arena hazards, and special events
- [ ] Add feedback for rare/fun catches and boss moments

## Wishlist/Extras
- [ ] Unique fish abilities
- [ ] Day/night cycle
- [x] Fishing gear upgrades <!-- UpgradeManager scaffolded -->
- [ ] Environmental hazards
- [ ] NPCs and side quests
- [ ] Boat fishing
- [ ] Special fish with unique acquisition
- [ ] Character customization
- [ ] Weather effects
- [ ] Foraging for bait
- [ ] Achievements and unlockables
- [ ] Online leaderboards
- [ ] Photo mode
- [ ] Underwater exploration
- [ ] Seasonal events
- [ ] Crafting system
- [ ] Rival fishermen
- [ ] Fish encyclopedia
- [ ] Dynamic music
- [ ] Secret fishing spots
