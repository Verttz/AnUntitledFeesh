# AnUntitledFeesh - Complete Game Design Reference

**Date:** November 27, 2025  
**Status:** Core systems defined, ready for implementation  
**Purpose:** Comprehensive game design document with all systems, mechanics, and implementation questions

---

## 📋 DOCUMENT STATUS

### ✅ FULLY DEFINED SYSTEMS (Implementation Ready)
- Story, narrative, and world structure
- Quest system (NPC quests and bounty boards)
- **Boss fight mechanics:** Sequential lives, unique patterns, 3-5min fights, HP enrages, phase banter
- **Fishing core mechanics:** Free aim, depth via sinker/lure, bait categories, 4 time periods
- **Time/Weather:** 24hr=17min, 4 periods, clear/rain/storm, 48hr forecast, sleep/wait available
- **Tutorial flow:** Brief intro (ticket→plane→land→start), discover gate, manual tribute selection
- **Upgrade system:** 3-tier structure, permanent purchases, biome progression
- **Currency:** "Fishbux" (easter egg), displayed as fish coin icon
- **Shop system:** Smart inventory (only missing tiers + valid bait), visual browse + desk list
- **Backtracking:** Full fast travel unlocked after reaching area 2
- **UI/UX:** Quest log + side tracker, Fish Finder identification, hotbar + time/weather display
- **Difficulty:** Choose at start, changeable anytime (not mid-fight)
- **Pacifist Mode:** Friendly boss opens gate peacefully
- **Accessibility:** ALL proposed options are must-haves, separate from difficulty

### 🔧 NEEDS IMPLEMENTATION DETAILS (Balance & Numbers)
- Upgrade stat values (cast distance, reel speed, tension duration)
- Economy pricing (fish sell prices, upgrade costs)
- Savage Mode specifics (HP multiplier, speed, patterns, rewards)
- HUD layout details (tension meter position, hotbar style)
- Area-specific mechanics per biome

### 🔮 DEFERRED FOR LATER
- Secret ending and lore system design
- Cosmetic system decision
- Audio/music direction (waiting for visual assets)

---

## 🎮 CORE SYSTEMS

---

## 1. ✅ UPGRADE SYSTEM

### Confirmed Design:
- **Types:** Rod, Reel, Line, Bait Bag, Tacklebox, Fish Bag
- **Effects:** 
  - Easier fishing (difficult fish become catchable)
  - Extended tension meter capacity
  - Increased carry capacity for bait, gear, and fish
  - More options for weights, floats, and bait types
- **Progression:** Linear core upgrades with horizontal options
- **Persistence:** Core upgrades carry across biomes, area-specific gear stays local
- **Purchase:** Permanent (no downgrading or swapping)
- **Balance:** Prices increase per biome, fish values scale to match (never feels like a struggle)

### 🔧 IMPLEMENTATION QUESTIONS:

**Q1: How many tiers per upgrade?**

**Option A: 3 Tiers (Recommended)**
- Tier 1: Forest Shop
- Tier 2: Ocean/Jungle Shops
- Tier 3: Mountain/Lava Shops
- *Clean progression, 1-2 major upgrades per shop*

**Option B: 5 Tiers**
- One tier per biome (Forest → Ocean → Jungle → Mountain → Lava)
- *More incremental, constant sense of progression*

**Option C: Variable Tiers**
- Different upgrades have different tier counts
- Example: Rod has 5 tiers, Bait Bag has 3
- *Flexible, matches gameplay needs*

**✅ DECISION: Option A - 3 Tiers**
- Tier 1: Forest Shop
- Tier 2: Ocean/Jungle Shops  
- Tier 3: Mountain/Lava Shops
- Different items have different upgrade levels per shop (new tacklebox, new rod, new reel, etc.)

---

**Q2: Specific stat values and effects?**

Proposed structure with placeholder numbers:

| Upgrade | Base (Start) | Tier 1 | Tier 2 | Tier 3 |
|---------|--------------|--------|--------|--------|
| **Rod** | 10m cast | 12m cast (+20%) | 14m cast (+40%) | 16m cast (+60%) |
| **Reel** | 1.0x speed | 1.15x speed | 1.30x speed | 1.50x speed |
| **Line** | 30kg max | 50kg max | 100kg max | 200kg max |
| **Tension Bar** | 5 seconds | 7 seconds (+2s) | 9 seconds (+4s) | 11 seconds (+6s) |
| **Bait Bag** | 10/type | 20/type | 50/type | 100/type |
| **Tacklebox** | 3 slots | 5 slots | 10 slots | 15 slots |
| **Fish Bag** | 5 fish | 10 fish | 20 fish | 30 fish |

**Horizontal Options** (one-time unlocks):
- **Weights:** Light (shallow), Medium (all-purpose), Heavy (deep)
- **Floats:** Fixed bobber, Slip bobber, Drift bobber
- **Special Tools:** Net, Fish Finder, Depth Gauge (what do these do?)

**Questions:**
- Do these numbers feel right for progression?
- Should "Tension Bar" be separate or built into Rod/Reel?
- What do the Special Tools actually do?
- Any missing upgrade categories?

---

**Q3: Placeholder pricing?**

Rough balance pass for testing:

### Forest (Early Game)
**Fish Sell Prices:**
- Common: $10-30
- Uncommon: $40-60
- Rare: $80-120

**Upgrade Costs:**
- Rod Tier 1: $200
- Reel Tier 1: $200
- Line Tier 1: $150
- Bait Bag Tier 1: $150
- Tacklebox Tier 1: $100
- Fish Bag Tier 1: $100

*~10-15 fish sales per upgrade*

### Ocean/Jungle (Mid Game)
**Fish Sell Prices:**
- Common: $50-80
- Uncommon: $100-150
- Rare: $200-300

**Upgrade Costs:**
- Rod Tier 2: $800
- Reel Tier 2: $800
- Line Tier 2: $600
- Bait Bag Tier 2: $500
- Tacklebox Tier 2: $400
- Fish Bag Tier 2: $400

*Still ~10-15 fish sales per upgrade*

### Mountain/Lava (Late Game)
**Fish Sell Prices:**
- Common: $150-200
- Uncommon: $300-400
- Rare: $500-800
- Legendary: $1000-1500

**Upgrade Costs:**
- Rod Tier 3: $2000
- Reel Tier 3: $2000
- Line Tier 3: $1500
- Bait Bag Tier 3: $1200
- Tacklebox Tier 3: $1000
- Fish Bag Tier 3: $1000

*Maintains ~10-15 fish ratio*

**Questions:**
- Does this pace feel right?
- Should grinding be faster/slower?
- Should there be bundle discounts?
- Are legendary fish valuable enough?

---

**Q4: Area-Specific Gear Details**

**Confirmed:**
- **Jungle:** Bow fishing equipment (alternative fishing method)

**Proposed for other biomes:**

**Ocean:**
- Boat rental/access fee?
- Boat upgrade tiers (rowboat → motorboat)?
- Diving gear (underwater fishing spots)?

**Mountain:**
- Ice auger (drill fishing holes)
- Warm clothing (fish during blizzards)?
- Ice spikes (prevents slipping)?

**Lava:**
- Heat-resistant boots (required near lava)?
- Cooling rods (special rod for lava fishing)?
- Lava net (catch fire-based fish)?

**Questions:**
- What mechanics for each biome's gear?
- One-time purchase or tiered upgrades?
- REQUIRED to fish in area or optional enhancements?
- How does Jungle bow fishing actually work (gameplay)?

---

## 2. ✅ BOSS FIGHT MECHANICS

### Confirmed Design:
- **Player Control:** You control the fish directly in top-down bullet-hell combat
- **Fish Stats Apply:** HP, attack, defense, speed from fish_data.gd affect combat
- **Special Abilities:** multi_shot, stun, charge, etc. are ONLY used in boss fights
- **Strategy:** Players choose 3 tribute fish based on playstyle (tank, DPS, balanced)
- **Two Game Phases:**
  1. Fishing (relaxing, adventure, catching fish)
  2. Boss Fights (intense bullet-hell combat)

### 🔧 IMPLEMENTATION QUESTIONS:

**Q1: Switching between tribute fish during battle?**

**Option A: Live switching**
- Press 1/2/3 to swap between your 3 tribute fish mid-battle
- Each fish has separate HP bar
- Switch when one fish is low HP
- *Pros: Strategic depth, all 3 fish matter*

**Option B: Pick one before battle**
- Choose 1 of your 3 tribute fish before battle starts
- Only that fish fights (other 2 are reserves)
- If you die, restart battle and can pick a different fish
- *Pros: Simpler, focused gameplay*

**Option C: Sequential lives**
- Fight with Fish #1 until it dies
- Then auto-switch to Fish #2
- Then Fish #3
- Lose all 3 = battle failed
- *Pros: Simple, clear failure condition*

**✅ DECISION: Option C - Sequential Lives**
- Fight with Fish #1 until it dies
- Auto-switch to Fish #2
- Then Fish #3
- Lose all 3 = battle failed, return to overworld

---

**Q2: How do fish stats translate to combat?**

Proposed formula:

| Fish Stat | Boss Fight Effect |
|-----------|-------------------|
| **HP** | Direct HP in battle (100 HP = 100 hit points) |
| **Speed** | Movement speed (slow fish = harder to dodge) |
| **Attack** | Damage per hit/projectile |
| **Defense** | Damage reduction (10 def = 10% less damage taken?) |

**Fish Weapons:**
- **bite:** Short-range melee attack
- **tail_slap:** Medium-range swipe
- **charge:** Dash attack
- **water_jet:** Ranged projectile
- **multi_shot:** Fires 3+ projectiles
- **stun:** Slows boss temporarily

**Questions:**
- Do these stat translations feel balanced?
- Should defense be flat reduction (10 def = -10 damage) or percentage (10 def = -10%)?
- How should weapon types affect boss fights (damage? range? cooldown?)?
- Should special abilities have cooldowns or limited uses?

---

**Q3: Boss attack patterns?**

You mentioned "bullet-hell" style combat. How complex?

**Difficulty Mode Patterns:**

**Pacifist Mode:**
- Boss gate opens automatically (no fight)
- OR extremely simple bullet-hell pattern (1-2 moves, very telegraphed)

**Normal Mode:**
- 3-5 attack patterns per boss
- Clear telegraphs (wind-up animations, visual warnings)
- Moderate bullet density
- Similar to Enter the Gungeon or Binding of Isaac

**Savage Mode:**
- 5-8 attack patterns per boss
- Complex patterns with mixed attacks
- Higher bullet density
- Faster attack speed
- Less telegraphing
- MMO raid-style difficulty

**✅ DECISIONS:**
- **Unique patterns per boss:** Each boss has own unique fight (some attacks may look similar)
- **Fight duration:** 3-5 minutes per boss *(needs balance testing)*
- **Phase transitions:** YES - Bosses enrage at HP % intervals (triggering new attacks)
- **Time limit:** NO - No enrage timer, only HP-based phases

---

**Q4: Boss banter during fights?**

StoryOutline.md mentions bosses have personalities and banter. How does this work?

**Option A: Pre-battle only**
- Banter happens before fight starts
- No dialogue during combat (too distracting)

**Option B: Phase transitions**
- Dialogue at specific HP thresholds (75%, 50%, 25%)
- Brief pause or slowdown during dialogue
- Adds personality without interrupting flow

**Option C: Constant chatter**
- Random voice lines during combat
- No pause, text box appears but combat continues
- Risk: Could distract from bullet-hell gameplay

**✅ DECISION: Option B - Phase Transitions + Audio Cues**
- Dialogue at HP thresholds (75%, 50%, 25%)
- Brief pause/slowdown during major dialogue
- Random audio lines during combat (can serve as attack warnings)

---

## 3. ✅ ECONOMY & CURRENCY

### Confirmed Design:
- **Currency:** Not yet named (see Q1 below)
- **Income:** Selling caught fish at shop
- **Spending:** Upgrades, bait, area-specific gear
- **Balance:** Fish values scale with biome to match upgrade costs
- **Shops:** Per-biome shops (1 shop per area with area-specific goods)
- **Feeling:** "Never feels like a true struggle" - steady income flow

### 🔧 IMPLEMENTATION QUESTIONS:

**Q1: Currency name?**

| Option | Flavor | Notes |
|--------|--------|-------|
| **Shells** | Thematic (ocean/fishing) | Classic, fits game tone |
| **Scales** | Thematic (fish-based) | Unique, fish-themed |
| **Fins** | Thematic (fish-based) | Short, punny potential |
| **Bucks** | Pun (fish + money) | Humorous, but may break immersion |
| **Coins** | Generic (fantasy RPG) | Safe, clear to players |
| **Credits** | Generic (sci-fi) | Doesn't fit fishing theme |

**✅ DECISION: "Fishbux"**
- **Display:** Coin icon with fish emblem (no text label)
- **In-game reference:** One hidden idle NPC dialogue mentions "Fishbux" (easter egg)
- **UI:** Just shows the coin icon + number (e.g., [🪙] 450)

---

**Q2: Fish sell price formula?**

Proposed pricing structure:

**Base Price by Rarity:**
- Common: $20 base
- Uncommon: $50 base
- Rare: $100 base
- Legendary: $300 base

**Biome Multiplier:**
- Forest: x1.0
- Ocean: x2.0
- Jungle: x2.5
- Mountain: x3.0
- Lava: x4.0

**Size/Weight Bonus:**
- Small fish: -20%
- Medium fish: +0%
- Large fish: +30%
- Trophy fish: +50%

**Example:**
- Common Forest Fish (medium): $20 x 1.0 = $20
- Rare Ocean Fish (large): $100 x 2.0 x 1.3 = $260
- Legendary Lava Fish (trophy): $300 x 4.0 x 1.5 = $1800

**Questions:**
- Does this formula feel fair?
- Should there be bonuses for pristine condition (caught perfectly)?
- Should quest fish sell for more/less than normal?
- Should there be "vendor trash" fish (always low value) vs "trophy fish" (always high)?

---

**Q3: Shop inventory per biome?**

What does each shop sell?

**Proposed Shop Contents:**

**Forest Shop:**
- Tier 1 upgrades (Rod, Reel, Line, Bait Bag, Tacklebox, Fish Bag)
- Basic bait (worms, crickets, minnows)
- Horizontal gear (Light Weight, Fixed Bobber)
- Fish Finder (special tool)

**Ocean Shop:**
- Tier 2 upgrades
- Ocean bait (squid, shrimp, crab)
- Horizontal gear (Medium Weight, Slip Bobber)
- Boat rental/access?

**Jungle Shop:**
- Tier 2 upgrades (if not bought in Ocean)
- Jungle bait (frogs, beetles, grubs)
- Bow fishing equipment
- Net (special tool)

**Mountain Shop:**
- Tier 3 upgrades
- Mountain bait (salmon eggs, powerbait)
- Ice auger + warm clothing
- Horizontal gear (Heavy Weight, Drift Bobber)

**Lava Shop:**
- Tier 3 upgrades (if not bought in Mountain)
- Lava bait (fire flies, magma worms)
- Heat-resistant gear
- Depth Gauge (special tool)

**✅ DECISIONS:**
- **Smart upgrade inventory:** Shops sell all tiers up to area limit, but only show items player hasn't bought yet
  - Example: If player has Tier 1 Rod, Ocean shop won't show Tier 1 Rod (only Tier 2)
  - If player skipped Tier 1 Bait Bag, Ocean shop shows both Tier 1 AND Tier 2 Bait Bag
- **Smart bait inventory:** Shops only sell bait that works for fish in that area
  - If no fish bite worms in Lava biome, Lava shop won't sell worms
  - Bait availability = automatic fish species guide

**🤔 STILL DECIDING:**
- Should there be shop-exclusive fish (only catchable with shop-specific bait)?

---

## 4. ✅ FISHING MECHANICS

### Confirmed Design:
- **Casting:** Free aim with mouse/controller, precision-based (not just distance)
- **Cast Power:** Charge meter determines cast strength
- **Bait System:** Bait type affects which fish spawn (different fish prefer different baits)
- **Time/Weather:** CORE MECHANICS - affect fish spawns and behavior
- **Tension Meter:** Scales based on biome difficulty AND fish rarity
- **Reaction Windows:** Bite timing and hook-setting are skill-based

### 🔧 IMPLEMENTATION QUESTIONS:

**Q1: Precision casting mechanics?**

"Precision-based, not just distance" - what does this mean?

**Option A: Target zones**
- Cast into specific circles/areas on water
- Different zones spawn different fish types
- Example: Deep water = big fish, shallows = small fish

**Option B: Depth control**
- Cast distance + depth slider
- Control how deep your bait sinks
- Different fish at different depths

**Option C: Lure presentation**
- Cast, then control lure movement (reel speed, jerks, pauses)
- Fish react to lure behavior
- More realistic fishing simulation

**Option D: All of the above**
- Cast to target zone (location matters)
- Set depth (how deep bait goes)
- Control presentation (how you reel)
- Most complex, most realistic

**✅ DECISION: Hybrid System (All mechanics)**
- **Free aim casting:** Cast anywhere in fishing zone (mouse/controller aim)
- **Depth control:** Sinker/lure type determines how deep bait goes
  - Light sinker = shallow water fishing
  - Heavy sinker = deep water fishing
- **Lure presentation:** Implied through reel speed and bait behavior
- **Location matters:** Different zones spawn different fish types 
---

**Q2: Time/Weather specifics?**

"Core mechanics" - how detailed?

**Time System:**

**Option A: Simple day/night**
- Day (6am-6pm): Diurnal fish spawn
- Night (6pm-6am): Nocturnal fish spawn
- Time passes automatically or player-controlled?

**Option B: Four time periods**
- Morning (6am-12pm): Morning fish
- Afternoon (12pm-6pm): Afternoon fish
- Evening (6pm-12am): Evening fish
- Night (12am-6am): Night fish
- More granular fish spawns

**Option C: Real-time clock**
- Actual hours and minutes
- Fish have specific spawn windows (Bass from 2pm-4pm)
- Very detailed, may be tedious

**Weather System:**

**Option A: Simple (3 types)**
- Clear: Normal spawns
- Rain: Water fish more active, bonus bite chance
- Storm: Rare fish appear, harder casting

**Option B: Detailed (6+ types)**
- Clear, Cloudy, Rain, Storm, Fog, Snow (Mountain), Heat (Lava)
- Each weather affects different fish types
- Some fish ONLY spawn in specific weather

**✅ DECISIONS:**

**Time System:**
- **Four periods:** Morning (6am-12pm), Afternoon (12pm-6pm), Evening (6pm-12am), Night (12am-6am)
- **Real-time progression:** 24 in-game hours = 17 real-life minutes
- **Time skip:** Sleep in bed or sit on bench to advance time

**Weather System:**
- **Base types:** Clear, Rain, Storm
- **Biome variants:** Snow (Mountain), Heat/Ash (Lava)
- **Weather forecast:** 48-hour prediction available (helps planning)
- **Generation:** Random/dynamic (not fixed schedule)

**Fish behavior changes with time AND weather**

---

**Q3: Tension meter scaling?**

"Scales based on biome difficulty AND fish rarity"

Proposed formula:

**Base Tension Duration:**
- Common fish: 5 seconds
- Uncommon fish: 4 seconds
- Rare fish: 3 seconds
- Legendary fish: 2 seconds

**Biome Modifier:**
- Forest: +0 seconds (base values)
- Ocean: -0.5 seconds
- Jungle: -0.5 seconds
- Mountain: -1 second
- Lava: -1 second

**Example:**
- Common Forest Fish: 5 seconds
- Common Lava Fish: 4 seconds
- Legendary Forest Fish: 2 seconds
- Legendary Lava Fish: 1 second

**With Upgrades:**
- Tension Bar Tier 1: +2 seconds to all fish
- Tension Bar Tier 2: +4 seconds to all fish
- Tension Bar Tier 3: +6 seconds to all fish

**Questions:**
- Do these numbers feel balanced?
- Should some fish have unique tension behavior (erratic, steady, pulsing)?
- Should upgrades add flat time or percentage time?

---

**Q4: Bait-specific fish spawns?**

"Bait type affects which fish spawn"

How strict is this system?

**Option A: Exclusive spawns**
- Each fish ONLY spawns with specific bait
- Must use correct bait or fish won't appear
- *Pros: Predictable, strategic*
- *Cons: May feel restrictive*

**Option B: Preferred bait**
- Each fish prefers certain bait (higher spawn chance)
- Can still catch fish with "wrong" bait (just rare)
- *Pros: Flexible, forgiving*
- *Cons: Less strategic pressure*

**Option C: Bait categories**
- Live bait (worms, crickets, minnows) → attracts X fish types
- Lures (spinners, jigs, flies) → attracts Y fish types
- Special bait (cheese, dough, scent) → attracts Z fish types
- *Pros: Simplifies system, clear categories*

**✅ DECISION: Option C - Bait Categories with Exceptions**

**Bait Categories:**
- **Live bait** (worms, crickets, minnows) → Attracts category X fish
- **Lures** (spinners, jigs, flies) → Attracts category Y fish  
- **Special bait** (cheese, dough, scent) → Attracts category Z fish

**Exceptions:**
- **Legendary fish:** May require specific unique bait
- **Easter egg fish:** May have special bait requirements
- Adds discovery element without overcomplicating standard fishing

---

## 5. ✅ PROGRESSION & PACING

### Confirmed Design:
- **Boss Defeats:** Unlock next biome
- **Quests:** Fully optional (not required for progression)
- **Tribute System:** Need 3 caught fish to fight boss
- **Player Agency:** Stay in biome as long as desired, move on when ready
- **No Time Pressure:** Exploration and fishing at own pace

### 🔧 IMPLEMENTATION QUESTIONS:

**Q1: Backtracking & fast travel?**

Can players return to earlier biomes?

**Option A: Full backtracking**
- Biome portals/gates stay open
- Fast travel from map or overworld
- Can return to earlier shops/quests anytime

**Option B: One-way progression**
- Once you beat a boss and move forward, can't go back
- Forces commitment, adds weight to decisions
- May frustrate completionists

**Option C: Unlock fast travel later**
- Early game: One-way progression
- Mid-game: Unlock fast travel item/mechanic
- Rewards progression, adds utility

**✅ DECISION: Option A - Full Backtracking with Progressive Unlock**
- **Upon reaching Area 2:** Fast travel system unlocks (tutorial shows how to return to Area 1)
- **After tutorial:** Can fast travel to any previously visited biome
- **Access method:** Map menu or portal/gate system in overworld
- **Purpose:** Return for quests, fish species, shop upgrades, bounty boards

---

**Q2: First-time biome exploration?**

What happens when entering a new biome?

**Option A: Tutorial NPC**
- Host or local NPC explains area mechanics
- Gives overview of area-specific fish/bait
- Optional tutorial quest

**Option B: Environmental storytelling**
- No explicit tutorial
- Players discover mechanics by exploration
- Signs, visual cues, ambient dialogue

**Option C: Progressive unlocks**
- Area starts partially locked
- Complete 1-2 quests to unlock full area
- Forces engagement with area mechanics

**Your preference?**

---

**Q3: Quest progression pace?**

Quests are optional, but how available are they?

**Option A: All quests available immediately**
- When entering a biome, all NPC quests and bounties appear
- Players choose which to do
- *Pros: Maximum freedom*

**Option B: Sequential unlocks**
- Complete Quest 1 → Quest 2 unlocks → Quest 3 unlocks
- Bounties always available (max 3)
- *Pros: Guided experience, prevents overwhelm*

**Option C: Time-gated**
- Quests unlock after fishing X fish or spending Y time
- Simulates NPCs "getting to know you"
- *Pros: Paces content, feels natural*

**Your preference?**

---

**Q4: Fishing X fish before boss?**

Should there be a minimum fish requirement before boss battle?

**Option A: Strict tribute only**
- Must catch exactly 3 fish (tribute)
- Can fight boss immediately
- *Pros: Fast pacing, respects player skill*

**Option B: Soft suggestion**
- Game suggests catching 10-15 fish before boss
- Not enforced, just UI hint
- *Pros: Guides new players, doesn't restrict veterans*

**Option C: Enforced minimum**
- Must catch 10 unique species before boss
- Encourages exploration of biome
- *Pros: Forces engagement, prevents rushing*

**Your preference?**

---

## 6. 🔧 AREA-SPECIFIC MECHANICS (Needs Brainstorming)

### Confirmed:
- **Jungle:** Bow fishing (alternative fishing method)

### Proposed Ideas for Other Biomes:

---

**FOREST (Starting Area):**

**Option A: River currents**
- Flowing river sections with current
- Must cast upstream or adjust for drift
- Fish move with current

**Option B: Lily pad platforms**
- Can stand on lily pads to reach new spots
- Some fish only accessible from lily pads
- Lily pads slowly sink (timed pressure)

**Option C: Shallow/deep zones**
- Wade into shallow water vs fish from shore
- Different fish in each zone
- Introduces water depth mechanics

**Your preference or other ideas?**

---

**OCEAN (Early-Mid Game):**

**Option A: Boat fishing**
- Rent/buy boat to access deep water
- Different fish spawn far from shore
- Boat upgrades (speed, stability)

**Option B: Tidal pools**
- Time-based tidal mechanics
- Low tide = accessible pools with rare fish
- High tide = different fishing spots
- Must time fishing to tides

**Option C: Underwater fishing**
- Dive with gear to spearfish
- Different mechanics from rod fishing
- Limited oxygen adds tension

**Your preference or other ideas?**

---

**MOUNTAIN (Late Game):**

**Option A: Ice fishing**
- Drill holes in frozen lakes with ice auger
- Fish spawn beneath ice at different depths
- Ice thickness varies (thin ice = danger?)

**Option B: Blizzard mechanics**
- Weather affects visibility and casting
- Some fish only spawn during blizzards
- Need warm clothing to fish safely

**Option C: Altitude zones**
- Low altitude (forest edge) vs high altitude (peak)
- Oxygen affects stamina/tension meter?
- Different fish at different elevations

**Your preference or other ideas?**

---

**LAVA (Endgame):**

**Option A: Heat zones**
- Must manage heat exposure
- Cooling gear required for extended fishing
- Some spots too hot without upgrades

**Option B: Geyser fishing**
- Geysers erupt periodically
- Fish spawn during/after eruptions
- Timing-based mechanic

**Option C: Lava hazards**
- Molten lava flows block fishing spots
- Must navigate around hazards
- Some fish only in dangerous spots

**Your preference or other ideas?**

---

**JUNGLE (Confirmed: Bow Fishing)**

**Additional questions about bow fishing:**
- How does bow fishing differ from rod fishing mechanically?
- Is it faster? More precise? Different fish types?
- Do you AIM and SHOOT fish directly (like spearfishing)?
- Or is it cast-based like rod fishing but with a bow?

**Your clarification?**

---

## 7. ✅ TUTORIAL & ONBOARDING

### Confirmed Design:
- **Intro:** Slideshow explaining premise (family fishing trip, something evil)
- **Start Location:** Dock with Host
- **First Quest:** Host teaches fishing with Trout catch goal
- **Failure Allowed:** Can fail first quest and retry
- **No On-Screen Prompts:** No "Press X to fish" tutorial overlays
- **Surprise Element:** Boss isn't revealed until first encounter (player surprised by evil)

### 🔧 IMPLEMENTATION QUESTIONS:

**Q1: Slideshow specifics?**

How long and detailed?

**Option A: Brief (5-10 slides)**
- Family fishing trip setup
- "Something feels wrong..."
- Wake up at dock
- *Pros: Quick, doesn't overstay welcome*

**Option B: Detailed (15-20 slides)**
- Character introductions (family members)
- Travel montage to fishing spot
- Gradual creepy buildup
- Fade to black, wake at dock
- *Pros: More story immersion*

**Option C: Animated cutscene**
- Fully animated 1-2 minute sequence
- Professional voiceover or text
- *Pros: Most impactful, but development intensive*

**✅ DECISION: Very Brief Intro (5-10 slides max)**
1. Buy ticket to "The Ultimate Fishing Adventure"
2. On plane (maybe 1-2 slides of travel)
3. Land at destination
4. Step out → Game start at dock

**No family members, no buildup, no creepy foreshadowing in intro**
- Mystery revealed through gameplay, not intro

---

**Q2: First fishing tutorial pacing?**

Host teaches fishing with Trout goal. How?

**Option A: Guided step-by-step**
- Host: "First, select your bait"
- Player selects bait
- Host: "Now, aim your cast..."
- Player casts
- Etc.

**Option B: Single instruction**
- Host: "Catch me a Trout to prove you know how to fish!"
- All mechanics available, player figures it out
- Host offers hints if player struggles (after 2-3 failed attempts)

**Option C: Show, don't tell**
- Host demonstrates fishing (AI catches a fish)
- Player mimics what they saw
- No explicit instructions

**Your preference?**

---

**Q3: First boss surprise encounter?**

"Boss isn't revealed until first encounter"

**Option A: Immediate after first quest**
- Catch Trout → Host congratulates → Sudden boss appearance
- No warning, pure shock
- *Pros: Maximum surprise*

**Option B: After small exploration**
- Catch Trout → Host says "explore the forest!"
- Player catches 5-10 fish
- THEN boss appears
- *Pros: Player has more fish tribute ready*

**Option C: Story hint before encounter**
- Catch Trout → Host mentions "strange sounds in the forest"
- Player explores, finds evidence of something wrong
- Boss encounter still surprising but slightly foreshadowed
- *Pros: Builds tension, less abrupt*

**✅ DECISION: Discovery Through Exploration**

**Flow:**
1. Player finishes first fishing tutorial (catches Trout for Host)
2. Player explores forest, fishing and discovering area
3. Player stumbles upon **Boss Gate**
4. Gate guard explains: "Bring 3 fish as tribute to challenge the guardian"
5. Guard adds: "The better the fish, the better the tribute" (hints at fish stats)
6. Player catches 3 fish, returns to gate
7. Guard escorts player to arena
8. Boss appears and demands to fight

**Surprise element:** Player doesn't know it's a bullet-hell combat game until this moment
---

**Q4: Post-tutorial guidance?**

After first boss defeat (or skip), how much guidance?

**Option A: Quest markers**
- NPC quests have markers on map
- Bounty boards highlighted
- Clear direction for players

**Option B: Minimal UI**
- NPCs say "I'm at the shop" but no markers
- Players explore to find content
- *Pros: Exploration-focused*

**Option C: Host compass**
- Host gives general directions ("Head northwest to Ocean")
- No precise markers, just cardinal directions
- *Pros: Balance between guidance and exploration*

**✅ DECISION: Quest Markers + Journal System**

**Quest Discovery:**
- NPCs with available quests have **exclamation points** over their heads
- Talk to NPC → Accept quest → Added to journal

**Quest Tracking:**
- Quests listed in journal (menu)
- Clear quest descriptions ("Catch 10 fish at Northern Lake")
- **No map markers** - Players read quest, understand location, explore to find it

**Map Unlocks:**
- As players explore, map reveals:
  - Fish species in area
  - Effective bait types
  - Fishing spot quality
- Quest descriptions are self-explanatory ("Northern Lake" is clear, no handholding needed)
---

## 8. ✅ BOSS FAILURE STATES

### Confirmed Design:
- **Failure = Kicked to Overworld:** Player returns to biome overworld (safe area)
- **Tribute Fish Lost:** The 3 fish used as tribute are gone (must catch new ones)
- **Save Before Fight:** Player can save before boss attempt (optional)
- **No Permadeath:** Player doesn't lose progression or upgrades
- **Retry:** Must catch 3 new fish and try again

### 🔧 IMPLEMENTATION QUESTIONS:

**Q1: Save point location?**

"Can save before fight"

**Option A: Auto-save before boss**
- Approaching boss gate triggers auto-save
- Player can load this save if they lose
- *Pros: Convenient, can't forget*

**Option B: Manual save point**
- Save statue/campfire near boss gate
- Player must manually interact to save
- *Pros: Player agency, can choose not to save*

**Option C: No special save**
- Normal save system applies (save anytime in overworld)
- Losing boss = lose tribute fish, must re-catch
- No special safety net
- *Pros: Simplest, most consequences*

**✅ DECISION: Option C - No Special Save System**
- Normal save system (save anytime in overworld)
- Losing boss fight = lose 3 tribute fish
- Penalty is minimal (just recatch fish)
- Player can save before boss if they want, but it's not necessary
- No auto-save prompt or save statue near gate

---

**Q2: Tribute fish selection before battle?**

When do players choose their 3 tribute fish?

**Option A: Automatic (last 3 caught)**
- Your 3 most recently caught fish auto-tribute
- No choice in selection
- *Pros: Simple, forces planning*
- *Cons: Less strategic*

**Option B: Manual selection at gate**
- Approach boss gate → UI shows all caught fish
- Player selects 3 fish to tribute
- Confirms selection before entering
- *Pros: Strategic, allows optimization*

**Option C: Tribute pool system**
- Designate up to 10 fish as "tribute pool"
- Boss uses 3 random fish from pool
- *Pros: Flexible, doesn't require exact selection*

**✅ DECISION: Option B - Manual Selection at Gate**
- Approach boss gate with guard
- UI opens showing all fish in player's inventory
- Player selects 3 fish to offer as tribute
- Confirmation prompt before entering arena
- Strategic choice: Pick based on HP, speed, attack, defense, special abilities
---

**Q3: Losing same fish twice?**

If player loses, catches same Trout again, and loses again?

**Option A: Infinite recatch**
- Fish respawn immediately after being lost
- Can catch same species repeatedly
- *Pros: Not punishing, accessible*

**Option B: Species cooldown**
- After losing tribute fish, that species has 5-10 minute cooldown
- Forces diversity in tribute choices
- *Pros: Encourages exploration*

**Option C: Unique fish instances**
- Each caught fish is unique (ID-based)
- Losing "Larry the Bass" means Larry is gone forever
- Can catch another Bass but it's different stats
- *Pros: High stakes, emotional attachment*
- *Cons: Complex, may frustrate players*

**✅ DECISION: Standard Fishing RNG (No Special Respawn)**

**System:**
- Losing boss fight = 3 tribute fish are gone
- Player returns to fishing to catch new fish
- **No guaranteed species:** Each cast = random fish from spawn pool (based on bait, location, time, weather)
- **Can recatch same species,** but RNG-based (might catch different fish first)
- **Exceptions:** Legendary fish and easter eggs may have specific spawn conditions

**Example:**
- Lost with Catfish, Bass, Rare Fish
- Can fish for them again, but might catch Trout, Carp, or Pike first
- Bait + location narrows the pool, but doesn't guarantee specific species
---

**Q4: Boss "learning" on retry?**

Should bosses change after failed attempts?

**Option A: Static patterns**
- Boss always has same attacks
- Purely player skill to improve
- *Pros: Fair, learnable*

**Option B: Dialogue changes**
- Boss mocks player for losing
- Patterns stay same but personality reacts
- *Pros: Adds flavor without changing difficulty*

**Option C: Adaptive difficulty**
- After 3+ failures, boss offers "easy mode" for that fight
- OR Host offers tips/hints
- *Pros: Accessibility without forced difficulty*

**✅ DECISION: Option B - Dialogue Changes (Compassionate Boss)**

**Static attack patterns** (fair, learnable)

**Dialogue progression after losses:**
- **1st loss:** Standard taunt ("Better luck next time, fisherman!")
- **2nd loss:** Slightly concerned ("Are you sure you're ready for this?")
- **3rd+ losses:** Boss gets genuinely worried and helpful:
  - "Hey, it's okay. You can just go. I just feel bad now."
  - "Look, stop throwing yourself under my foot. It's getting weird."
  - "Oh, no. I am going to punch this direction, sure hope this fisherman doesn't dodge because I will be so defenseless and helpless afterwards."

**Purpose:** Adds personality, humor, and subtle hints without changing difficulty

---

## 9. ✅ UI/UX

### Confirmed Design:
- **Hotbar:** Quick access to bait, gear, consumables
- **Time/Weather Display:** Always visible
- **Active Bait Indicator:** Shows currently equipped bait
- **Bounty Board:** Physical board in shop for quest turn-ins (not for acceptance)
- **No Tutorial Prompts:** No on-screen "Press X to Y" instructions

### 🔧 IMPLEMENTATION QUESTIONS:

**Q1: HUD layout?**

Where should UI elements be positioned?

**Proposed Layout:**

```
[Time: 2:35 PM] [Weather: Sunny]        [Active Bait: Worm]
[Tension Meter: ========------]

                   [GAME WORLD]

[Hotbar: [1] [2] [3] [4] [5]]
[Fish Bag: 7/10] [Currency: $450]
```

**Questions:**
- Should tension meter be center-screen or bottom?
- Should hotbar numbers (1-5) be visible or just icons?
- Should fish bag count be always visible or only when fishing?

---

**Q2: Quest tracking UI?**

How do players see active quests?

**Option A: Quest log (menu-based)**
- Press Tab/Menu to open quest log
- Shows all active quests with progress
- Not visible during gameplay

**Option B: Side tracker**
- Active quest shows on right side of screen
- "Catch 3 Carp (1/3)"
- Always visible, toggleable

**Option C: Minimal (no tracker)**
- NPCs tell you quest verbally
- No UI tracking, rely on memory
- Check with NPC for progress

**✅ DECISION: Hybrid Quest Log + Side Tracker**
- **Quest Log (Menu):** Press Tab/Menu to see all active quests with full descriptions and progress
- **Side Tracker:** Track 2-3 quests on right side of screen during gameplay
  - Shows quest name + progress ("Catch 3 Carp (1/3)")
  - Toggleable (can hide if distracting)
  - Player chooses which quests to track

---

**Q3: Fish identification?**

When catching a fish, how is it identified?

**Option A: Instant identification**
- Fish name appears immediately
- "You caught a Largemouth Bass!"
- *Pros: Clear, informative*

**Option B: First catch = discovery**
- First time catching a species: "???"
- Shows silhouette until examined
- After first catch, identified automatically
- *Pros: Collection mechanic, rewarding*

**Option C: Fish Finder required**
- Without Fish Finder: "You caught a fish!"
- With Fish Finder: "You caught a Largemouth Bass!"
- *Pros: Makes Fish Finder upgrade meaningful*

**✅ DECISION: Option C - Fish Finder Required**
- **Without Fish Finder:** "You caught a fish!" (no species name)
- **With Fish Finder:** "You caught a Largemouth Bass!" (full identification)
- **Fish Finder:** Very early upgrade (available in Forest shop)
- Makes the upgrade meaningful and rewarding
- Encourages players to buy Fish Finder early (which they will)

---

**Q4: Shop UI?**

How does shopping work?

**Option A: List-based**
- Traditional RPG shop menu
- List of items, prices, buy/sell buttons
- *Pros: Functional, clear*

**Option B: Visual shop**
- Items displayed on shelves/walls
- Click on items to examine and buy
- *Pros: Immersive, visually interesting*

**Option C: Hybrid**
- Visual shop for browsing
- Opens list menu when interacting with shelf
- *Pros: Best of both worlds*

**✅ DECISION: Hybrid Visual + List System**

**Browsing:**
- Items displayed on shelves, walls, racks (visual shop)
- Click/interact with items to examine and purchase
- Immersive, allows window shopping

**Shopkeeper Desk:**
- Talk to shopkeeper at desk
- Opens traditional list menu showing ALL shop inventory
- Prices, stats, buy/sell interface
- Faster for players who know what they want

**Best of both worlds:** Exploration for new players, efficiency for veterans

---

## 10. ✅ DIFFICULTY MODES & ACCESSIBILITY

### Confirmed Design:
- **Pacifist Mode:** Skip boss fights, gate opens automatically
- **Normal Mode:** Standard difficulty, fair challenge
- **Savage Mode:** MMO raid-style difficulty, complex patterns
- **Accessibility Priority:** "We're all about inclusivity. All accessibility options we CAN make, we will make."

### 🔧 IMPLEMENTATION QUESTIONS:

**Q1: Difficulty selection timing?**

When does player choose difficulty?

**Option A: At game start**
- Slideshow intro → Difficulty selection screen
- Can't change later
- *Pros: Sets expectations*

**Option B: Per-boss selection**
- Approaching each boss gate, choose difficulty
- Can mix (Normal for Boss 1, Savage for Boss 2)
- *Pros: Maximum flexibility*

**Option C: Anytime in settings**
- Change difficulty in pause menu anytime
- Even mid-boss-fight
- *Pros: Most accessible, no commitment*

**✅ DECISION: Select at Start, Change Anytime (Except Mid-Fight)**
- **At game start:** Choose Pacifist, Normal, or Savage
- **In settings menu:** Can change difficulty anytime (in overworld, in fishing areas)
- **Cannot change:** During active boss fight
- **Purpose:** Sets initial expectation but allows flexibility without mid-combat cheese
---

**Q2: Savage Mode specifics?**

"MMO raid-style" - how hard?

**Suggested Savage Changes:**
- Boss HP: +50-100%
- Attack patterns: 2x speed
- New attack combinations (mixing patterns)
- Less telegraphing (faster wind-ups)
- Environmental hazards (arena shrinks, lava rises)
- Enrage timers (fight must be won within 5 minutes or boss goes berserk)

**Questions:**
- Do these changes fit your vision?
- Should Savage Mode have better rewards (cosmetics? titles?)?
- Should there be achievements for Savage Mode clears?

---

**Q3: Accessibility options?**

What specific features?

**Proposed Options:**

**Visual:**
- Colorblind modes (deuteranopia, protanopia, tritanopia)
- High contrast mode
- Larger UI elements
- Screen reader support

**Audio:**
- Subtitles for all dialogue
- Visual indicators for sound cues (screen flash when fish bites)
- Separate volume controls (music, SFX, dialogue)

**Gameplay:**
- Slow-motion mode (0.75x, 0.5x speed)
- Extended reaction windows (longer bite times, wider tension meters)
- Auto-cast option (game aims for you)
- Boss pattern telegraphs (show safe zones during attacks)

**Input:**
- Remappable controls
- Gamepad support
- Mouse + keyboard support
- One-handed mode (all actions on one side of keyboard/controller)

**✅ DECISIONS:**

**ALL proposed accessibility options are MUST-HAVES:**
- Colorblind modes (deuteranopia, protanopia, tritanopia)
- High contrast mode
- Larger UI elements
- Screen reader support
- Subtitles for all dialogue
- Visual indicators for sound cues
- Separate volume controls
- Slow-motion mode (0.75x, 0.5x)
- Extended reaction windows
- Auto-cast option
- Boss pattern telegraphs (safe zone indicators)
- Remappable controls
- Gamepad + Mouse/Keyboard support
- One-handed mode

**Philosophy:** "Accessibility is most important. If someone only has one hand but wants to play Savage? Go nuts. Set accessibility options, then game on."

**Additional features to brainstorm:** (TBD)

---

**Q4: Pacifist Mode progression?**

If skipping bosses, how does story work?

**Option A: Same story, no combat**
- Boss appears, dialogue happens
- Player says "I don't want to fight"
- Boss respects decision, opens gate
- *Pros: Narrative intact, peaceful*

**Option B: Abbreviated story**
- Boss appears, gate opens automatically
- Skip dialogue, just move forward
- *Pros: Fast progression*

**Option C: Alternative challenge**
- Instead of combat, complete fishing challenge
- "Catch 10 fish in 5 minutes" or similar
- Gate opens if successful
- *Pros: Still has challenge, just not combat*

**✅ DECISION: Option A - Same Story, No Combat**

**Pacifist Mode Flow:**
1. Player brings 3 fish to boss gate (same as Normal/Savage)
2. Guard escorts player to arena
3. Boss appears, standard dialogue
4. Player (or boss) indicates no desire to fight
5. Boss responds peacefully: "Well, alright then. Go this direction to head to the next area."
6. Boss gives friendly wave, gate to next biome opens
7. **Full narrative intact, full personality shown, zero combat**

**Purpose:** Players who want fishing-only experience still get full story and character interactions
---

## 11. 🔮 DEFERRED: SECRET ENDING & LORE

### Current Status:
- **User Response:** "100% have to be revisited, I do not have any of these answers yet"
- **Design State:** Not defined, will return to later

### Placeholder Questions (For Future):
- What are the "secrets" players discover?
- How are clues delivered (environmental, NPC dialogue, hidden items)?
- What triggers the secret ending path?
- What is the true nature of the "evil presence"?
- Is there post-game content after secret ending?

**Action:** Mark as LOW PRIORITY, design after core systems are implemented.

---

## 12. 🔮 DEFERRED: COSMETICS

### Current Status:
- **User Response:** "still need to figure out if cosmetics are necessary"
- **Design State:** Undecided

### Considerations:
- Would cosmetics be player character customization or fish customization?
- Would they be earned (achievements) or purchased (currency)?
- Would they affect gameplay or purely visual?
- Are they worth development time vs other features?

**Action:** Mark as OPTIONAL, decide after core systems are complete.

---

## 13. 🔮 DEFERRED: AUDIO/MUSIC

### Current Status:
- **User Response:** Waiting for visual assets before creating music
- **Design State:** Not defined, audio direction deferred

### Placeholder Questions (For Future):
- Music style (orchestral, electronic, folk, ambient)?
- Boss battle music (one track or unique per boss)?
- Area themes (each biome has unique music)?
- Sound design priority (realistic fish sounds vs stylized)?

**Action:** Mark as LOW PRIORITY, design after visual direction is established.

---

## ✅ PRIORITY NEXT STEPS

---

## 🔧 REMAINING OPEN QUESTIONS (Need Your Input)

### UPGRADE SYSTEM:
**Q1: Do proposed stat effects feel balanced?**
- Rod: 10m → 12m → 14m → 16m cast distance (+20%/+40%/+60%)
- Reel: 1.0x → 1.15x → 1.30x → 1.50x speed
- Line: 30kg → 50kg → 100kg → 200kg max weight
- Tension Bar: 5s → 7s → 9s → 11s (+2s/+4s/+6s)
- Bait Bag: 10 → 20 → 50 → 100 per bait type
- Tacklebox: 3 → 5 → 10 → 15 equipment slots
- Fish Bag: 5 → 10 → 20 → 30 fish capacity

**Q2: Should "Tension Bar" be separate upgrade or built into Rod/Reel?**

**Q3: What do Special Tools actually do?**
- Net: ??? (faster landing? bonus catch chance?)
- Fish Finder: Identifies species (CONFIRMED)
- Depth Gauge: ??? (shows depth zones? fish depth hints?)

---

### ECONOMY:
**Q4: Are placeholder prices balanced?**

**Forest:**
- Fish sell: Common $10-30, Uncommon $40-60, Rare $80-120
- Upgrades: Rod $200, Reel $200, Line $150, Bait Bag $150, Tacklebox $100, Fish Bag $100
- *~10-15 fish sales per upgrade*

**Ocean/Jungle:**
- Fish sell: Common $50-80, Uncommon $100-150, Rare $200-300
- Upgrades: Rod $800, Reel $800, Line $600, Bait Bag $500, Tacklebox $400, Fish Bag $400

**Mountain/Lava:**
- Fish sell: Common $150-200, Uncommon $300-400, Rare $500-800, Legendary $1000-1500
- Upgrades: Rod $2000, Reel $2000, Line $1500, Bait Bag $1200, Tacklebox $1000, Fish Bag $1000

**Q5: Does the fish sell price formula work?**
- Base by rarity + Biome multiplier (Forest x1, Ocean x2, Jungle x2.5, Mountain x3, Lava x4)
- Size bonus (Small -20%, Medium +0%, Large +30%, Trophy +50%)

**Q6: Should there be shop-exclusive fish?**
- Fish only catchable with shop-specific bait?

---

### AREA-SPECIFIC MECHANICS:
**Q7: What unique mechanic for each biome?**

**Forest (Starting):**
- River currents? Lily pad platforms? Shallow/deep zones? Other?

**Ocean (Early-Mid):**
- Boat fishing (rent/upgrade boats)? Tidal pools (time-based)? Underwater spearfishing? Other?

**Jungle (Mid):**
- **CONFIRMED: Bow fishing** - How does it work mechanically?
  - Aim and shoot visible fish directly?
  - Cast-based like rod but with bow mechanics?
  - Faster/more precise than rod fishing?
  - Different fish types only catchable with bow?

**Mountain (Late):**
- Ice fishing (drill holes)? Blizzard mechanics? Altitude zones? Other?

**Lava (Endgame):**
- Heat zones (cooling gear)? Geyser fishing (timing)? Lava hazards? Other?

---

### PROGRESSION:
**Q8: First-time biome exploration?**
- Tutorial NPC explains area? Environmental storytelling only? Progressive unlocks?

**Q9: Quest availability pacing?**
- All quests available immediately? Sequential unlocks? Time-gated (catch X fish first)?

**Q10: Minimum fish before boss?**
- Tribute only (3 fish)? Soft suggestion (game hints 10-15 fish)? Enforced minimum?

---

### TUTORIAL:
**Q11: First fishing tutorial pacing?**
- Guided step-by-step (Host explains each mechanic)?
- Single instruction (\"Catch a Trout!\", player figures it out)?
- Show don't tell (Host demonstrates, player mimics)?

---

### BOSS FIGHTS:
**Q12: Savage Mode specifics?**
- Boss HP increase? (+50%? +100%?)
- Attack speed multiplier? (1.5x? 2x?)
- New attack combinations?
- Less telegraphing?
- Environmental hazards (shrinking arena, rising lava)?
- Should Savage have better rewards? (cosmetics, titles, achievements?)

---

### UI/UX:
**Q13: HUD layout details?**
- Should tension meter be center-screen or bottom?
- Should hotbar show numbers (1-5) or just icons?
- Should fish bag count be always visible or only when fishing?

---

### DEFERRED (Low Priority):
- Secret ending and lore system
- Cosmetic system decision
- Audio/music direction

---

## 📊 IMPLEMENTATION READINESS SUMMARY

### ✅ READY TO CODE (20+ Systems):
1. Sequential boss lives system
2. Boss phase transitions (HP-based enrages)
3. Boss compassionate dialogue (loss counter)
4. Fishbux currency (icon + easter egg reference)
5. Smart shop inventory (hide owned tiers, valid bait only)
6. Free aim casting system
7. Depth control via sinker/lure
8. 4-period time system (24hr = 17min)
9. Weather system (clear/rain/storm + biome variants)
10. 48-hour weather forecast
11. Sleep/wait time skip
12. Bait category system
13. Fast travel unlock (after area 2)
14. Brief tutorial intro (ticket→plane→land→start)
15. Boss gate discovery flow
16. Quest marker system (exclamation points)
17. Quest journal + side tracker (2-3 quests)
18. Fish Finder identification system
19. Hybrid shop UI (visual browse + desk list)
20. Difficulty selection (start + anytime change)
21. Pacifist peaceful progression
22. All accessibility features

### 🔧 NEEDS BALANCE PASS (Design Complete, Numbers TBD):
- Upgrade stat values
- Economy pricing
- Savage Mode multipliers
- Tension meter scaling
- Fish sell prices

### 🤔 NEEDS CREATIVE DECISIONS (5 Open Questions):
- Area-specific mechanics (5 biomes)
- Jungle bow fishing mechanics
- Special tool effects (Net, Depth Gauge)
- Tutorial pacing style
- Quest unlock pacing

---

## 🎯 RECOMMENDED NEXT STEPS

**Option 1: Finalize Area Mechanics (Most Creative)**
- Brainstorm unique mechanics for Forest, Ocean, Mountain, Lava
- Define Jungle bow fishing gameplay
- Will inform shop inventory and upgrade needs

**Option 2: Lock Down Economy (Most Systemic)**
- Test placeholder prices with gameplay flow
- Adjust fish values and upgrade costs
- Balance grinding pace
- Will inform upgrade progression feel

**Option 3: Prototype Core Systems (Most Practical)**
- Start coding the 20+ ready-to-implement systems
- Use placeholder values for prices/stats
- Test gameplay feel in practice
- Adjust numbers based on actual playtesting

**Which would you like to tackle first?**
