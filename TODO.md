# AnUntitledFeesh - Development Checklist

## General TODOs
- [ ] Implement save/load system for player progress
- [ ] Polish and connect all shop UI and inventory interactions
- [ ] Implement all TODOs and placeholder comments in scripts (search for TODO)
- [ ] UI for fishing, inventory, tension meter, etc.
- [ ] Audio/visual feedback and polish
- [ ] General polish, bugfixes, and balancing
- [ ] Add sound effects for fishing, reeling, catching, and special events
- [ ] Add visual effects for bites, tension, and rare events
- [ ] Add and polish all sound effects and music cues
- [ ] Add feedback for rare/fun catches and boss moments
- [ ] Implement quest save/load and quest UI
- [ ] Add upgrade purchasing UI and effects
- [ ] Implement all upgrade effects in gameplay
- [ ] Achievements and unlockables
- [ ] Online leaderboards
- [ ] Photo mode
- [ ] Character customization
- [ ] Dynamic music
- [ ] Seasonal events
- [ ] Foraging for bait
- [ ] NPCs and side quests
- [ ] Weather effects
- [ ] Day/night cycle
- [ ] Environmental hazards
- [ ] Boat fishing
- [ ] Special fish with unique acquisition
- [ ] Fish encyclopedia

## Fishing System TODOs
- [x] Player movement and fishing state logic
- [x] Bobber phase and reaction window
- [x] Reeling minigame framework
- [x] Fish data structure and per-biome fish lists
- [x] Connect fish fight patterns to tension meter
- [x] Inventory system for caught fish
- [x] Store and display caught fish
- [x] Track fish by biome and rarity
- [x] Unlock new areas after boss battles <!-- Progression and area unlocks scaffolded -->
- [x] Integrate biome selection and fish selection logic
- [x] Map fish fight patterns to reeling minigame behavior
- [x] Implement bait selection and its effect on fish bites
- [x] Area progression logic (unlock new biomes) <!-- ProgressionManager, BiomeManager, and unlock logic scaffolded -->
- [x] Fishing gear upgrades <!-- UpgradeManager scaffolded -->
- [ ] Add unique events (e.g., Angry Hermit Crab Shell)
- [ ] Complete all fishing UI (bobber, tension meter, reeling minigame, etc.)
- [ ] Add sound and visual feedback for fishing actions (bites, reeling, catching, failing)
- [ ] Implement unique fish abilities and special events
- [ ] Add and polish player animations (movement, fishing, reeling, etc.)

## Boss Battles TODOs
- [x] Boss fish battle system  <!-- Modular boss system, base class, manager, and arenas scaffolded -->
- [x] Design boss fish for each biome <!-- 10 unique bosses designed and scaffolded -->
- [x] Use caught fish in boss battles <!-- Boss system supports using caught fish -->
- [x] Unique boss mechanics per area <!-- Boss scripts scaffolded for unique logic -->
- [x] Implement minion summoning and behavior for bosses that use minions
- [x] Implement all boss attack logic and unique mechanics
- [x] Complete all phase transitions and special phase logic for each boss
- [x] Connect boss signals to arena/environment (e.g., breaking ice, hazards, minion spawns)
- [ ] Build and polish all boss arenas (add obstacles, visuals, interactive elements)
- [ ] Implement all boss attack logic and unique mechanics (see boss scripts for stubs)
- [ ] Add defeat/victory animations and transitions for each boss
- [ ] Connect boss signals to arena/environment (e.g., breaking ice, hazards, minion spawns)
- [ ] Implement minion summoning and behavior for bosses that use minions
- [ ] Complete all phase transitions and special phase logic for each boss
- [ ] Implement and polish the “Spotlight Showdown” for Abominable Snowbass
- [ ] Add visual effects for boss attacks, arena hazards, and special events
- [ ] Playtest and balance all boss fights

### Don Catfishoni Boss Implementation
- [x] Minion summoning and behavior (Brass Knuckle & Tommy Gun minions scaffolded)
- [x] Boss attack logic and unique mechanics (attacks, telegraphing, unique events scaffolded)
- [x] Phase transitions and escalation logic
- [x] Boss signals to arena/environment (hazards, lockdowns, etc.)
- [x] Banter/personality system
- [ ] Build and polish arena (obstacles, visuals, interactive elements)
- [ ] Add defeat/victory animations and transitions
- [ ] Implement/polish hazard and event visuals (contraband crates, fireworks, floods, lockdowns, etc.)
- [ ] Wire up UI/UX for unique mechanics (Negotiation Interrupts, Mobster Deal Roulette, etc.)
- [ ] Add sound and visual effects for attacks, minions, and arena events
- [ ] Playtest and balance fight for pacing, difficulty, and humor

### Abominable Snowbass Boss Implementation
- [ ] Minion summoning and behavior
- [x] Boss attack logic and unique mechanics
- [x] Phase transitions and escalation logic
- [x] Boss signals to arena/environment (hazards, events, etc.)
- [x] Banter/personality system
- [ ] Build and polish arena (obstacles, visuals, interactive elements)
- [ ] Add defeat/victory animations and transitions
- [ ] Implement/polish hazard and event visuals (ice, snow, etc.)
- [ ] Wire up UI/UX for unique mechanics (Spotlight Showdown, etc.)
- [ ] Add sound and visual effects for attacks, minions, and arena events
- [ ] Playtest and balance fight for pacing, difficulty, and humor

### Captain Pinchbeard Boss Implementation
- [ ] Minion summoning and behavior
- [x] Boss attack logic and unique mechanics
- [x] Phase transitions and escalation logic
- [x] Boss signals to arena/environment (hazards, events, etc.)
- [x] Banter/personality system
- [ ] Build and polish arena (obstacles, visuals, interactive elements)
- [ ] Add defeat/victory animations and transitions
- [ ] Implement/polish hazard and event visuals (traps, water, etc.)
- [ ] Wire up UI/UX for unique mechanics
- [ ] Add sound and visual effects for attacks, minions, and arena events
- [ ] Playtest and balance fight for pacing, difficulty, and humor

### Croak King Boss Implementation
- [x] Minion summoning and behavior
- [x] Boss attack logic and unique mechanics
- [x] Phase transitions and escalation logic
- [x] Boss signals to arena/environment (hazards, events, etc.)
- [x] Banter/personality system
- [ ] Build and polish arena (obstacles, visuals, interactive elements)
- [ ] Add defeat/victory animations and transitions
- [ ] Implement/polish hazard and event visuals (lilypads, mud, etc.)
- [ ] Wire up UI/UX for unique mechanics
- [ ] Add sound and visual effects for attacks, minions, and arena events
- [ ] Playtest and balance fight for pacing, difficulty, and humor

### Fin Diesel Boss Implementation
- [ ] Minion summoning and behavior
- [x] Boss attack logic and unique mechanics
- [x] Phase transitions and escalation logic
- [x] Boss signals to arena/environment (hazards, events, etc.)
- [x] Banter/personality system
- [ ] Build and polish arena (obstacles, visuals, interactive elements)
- [ ] Add defeat/victory animations and transitions
- [ ] Implement/polish hazard and event visuals (debris, oil, etc.)
- [ ] Wire up UI/UX for unique mechanics
- [ ] Add sound and visual effects for attacks, minions, and arena events
- [ ] Playtest and balance fight for pacing, difficulty, and humor

### Frostbite Maestro Boss Implementation
- [ ] Minion summoning and behavior
- [x] Boss attack logic and unique mechanics
- [x] Phase transitions and escalation logic
- [x] Boss signals to arena/environment (hazards, events, etc.)
- [x] Banter/personality system
- [ ] Build and polish arena (obstacles, visuals, interactive elements)
- [ ] Add defeat/victory animations and transitions
- [ ] Implement/polish hazard and event visuals (ice, music, etc.)
- [ ] Wire up UI/UX for unique mechanics
- [ ] Add sound and visual effects for attacks, minions, and arena events
- [ ] Playtest and balance fight for pacing, difficulty, and humor

### Guppazuma Boss Implementation
- [ ] Minion summoning and behavior
- [x] Boss attack logic and unique mechanics
- [x] Phase transitions and escalation logic
- [x] Boss signals to arena/environment (hazards, events, etc.)
- [x] Banter/personality system
- [ ] Build and polish arena (obstacles, visuals, interactive elements)
- [ ] Add defeat/victory animations and transitions
- [ ] Implement/polish hazard and event visuals (temple, traps, etc.)
- [ ] Wire up UI/UX for unique mechanics
- [ ] Add sound and visual effects for attacks, minions, and arena events
- [ ] Playtest and balance fight for pacing, difficulty, and humor

### Magma Chef Boss Implementation
- [ ] Minion summoning and behavior
- [x] Boss attack logic and unique mechanics
- [x] Phase transitions and escalation logic
- [x] Boss signals to arena/environment (hazards, events, etc.)
- [x] Banter/personality system
- [ ] Build and polish arena (obstacles, visuals, interactive elements)
- [ ] Add defeat/victory animations and transitions
- [ ] Implement/polish hazard and event visuals (lava, kitchen, etc.)
- [ ] Wire up UI/UX for unique mechanics
- [ ] Add sound and visual effects for attacks, minions, and arena events
- [ ] Playtest and balance fight for pacing, difficulty, and humor

### Prankster Poppo Boss Implementation
- [ ] Minion summoning and behavior
- [x] Boss attack logic and unique mechanics
- [x] Phase transitions and escalation logic
- [x] Boss signals to arena/environment (hazards, events, etc.)
- [x] Banter/personality system
- [ ] Build and polish arena (obstacles, visuals, interactive elements)
- [ ] Add defeat/victory animations and transitions
- [ ] Implement/polish hazard and event visuals (pranks, props, etc.)
- [ ] Wire up UI/UX for unique mechanics
- [ ] Add sound and visual effects for attacks, minions, and arena events
- [ ] Playtest and balance fight for pacing, difficulty, and humor

### The Great Fisherduck Boss Implementation
- [ ] Minion summoning and behavior
- [x] Boss attack logic and unique mechanics
- [x] Phase transitions and escalation logic
- [x] Boss signals to arena/environment (hazards, events, etc.)
- [x] Banter/personality system
- [ ] Build and polish arena (obstacles, visuals, interactive elements)
- [ ] Add defeat/victory animations and transitions
- [ ] Implement/polish hazard and event visuals (waterfowl, feathers, etc.)
- [ ] Wire up UI/UX for unique mechanics
- [ ] Add sound and visual effects for attacks, minions, and arena events
- [ ] Playtest and balance fight for pacing, difficulty, and humor

# TODO List

- [ ] Playtest all boss fights
  - Playtest each boss fight (Croak King, Don Catfishoni, The Great Fisherduck, Magma Chef, Fin Diesel, Captain Pinchbeard, Guppazuma, Frostbite Maestro, Abominable Snowbass, Prankster Poppo) for bugs, balance, and polish.
- [ ] Polish boss visuals and VFX
  - Add or refine visual effects, attack telegraphs, and boss animations for maximum clarity and spectacle.
- [ ] Polish boss audio and music cues
  - Ensure all bosses have unique, well-timed audio cues, taunts, and music transitions.
- [ ] Review and update boss design notes
  - Double-check that all design notes match the final implementation and update any discrepancies.
- [ ] Implement final boss unlock/sequence
  - Add logic for unlocking the final boss and triggering the endgame sequence after all others are defeated.
