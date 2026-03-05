# Codebase Analysis: What Needs to Be Rewritten

## Critical Issues - Must Fix

### 1. **Godot Version Compatibility Issues** (CRITICAL)

The codebase has a **mix of Godot 3 and Godot 4 syntax**, which will cause errors:

#### Godot 3 Syntax Found (needs updating to Godot 4):
- `export (PackedScene) var bullet_scene` → Should be `@export var bullet_scene: PackedScene`
- `.instance()` → Should be `.instantiate()`
- `connect("signal", self, "method")` → Should be `connect("signal", Callable(self, "method"))` or `.signal.connect(method)`
- `FileAccess.open()` is actually Godot 4 syntax, so that's correct

#### Files with Godot 3 syntax:
- `/scripts/bosses/Boss.gd` - `export` keyword
- `/scripts/bosses/TheGreatFisherduck/TheGreatFisherduck.gd` - `.instance()` calls
- `/scripts/bosses/Guppazuma/Guppazuma.gd` - `.instance()` calls  
- `/scripts/bosses/CroakKing/CroakKing.gd` - `.instance()` calls
- `/scripts/bosses/BossBattleManager.gd` - `.instance()` and old connect syntax
- `/scripts/DayNightWeatherManager.gd` - Old connect syntax
- `/scripts/Shop.gd` - Old connect syntax
- All boss scripts using preload + instance pattern

**Recommendation**: Decide on Godot 3 or 4, then update ALL syntax consistently.

---

## High Priority - Should Rewrite

### 2. **Fish Data System** (HIGH PRIORITY)

**File**: `/scripts/data/fish_data.gd`

**Issue**: Empty placeholder with just a comment `# ...existing code...`

```gdscript
const FISH_LIST = [
# ...existing code...
]
```

**Needs**: Complete fish database with all properties:
- Name, rarity, biome, habitat
- Bite timing, fight patterns
- Preferred baits
- Stats for boss fights

**Recommendation**: Create comprehensive fish data structure for all biomes.

---

### 3. **Boss Battle Manager** (HIGH PRIORITY)

**File**: `/scripts/bosses/BossBattleManager.gd`

**Issues**:
- Uses old Godot 3 syntax (`.instance()`, old `connect()`)
- Hard-coded boss paths may not exist
- No error handling for missing scenes
- Boss data references script paths, not scene paths

**Needs Rewrite**:
```gdscript
# Current (Godot 3):
boss_instance = boss_scene.instance()
boss_instance.connect("defeated", self, "_on_boss_defeated")

# Should be (Godot 4):
boss_instance = boss_scene.instantiate()
boss_instance.defeated.connect(_on_boss_defeated)
```

---

### 4. **Quest System Reconstruction** (HIGH PRIORITY)

**Files**: 
- `/scripts/QuestManager.gd`
- `/scripts/Quest.gd`

**Issues**:
- Quest save/load has TODOs for quest recreation
- No quest factory pattern
- Each quest needs unique ID for serialization
- Quest progress not tracked per-quest

**Current TODO**:
```gdscript
func from_dict(data: Dictionary):
    if "active_quests" in data:
        for quest_id in data["active_quests"]:
            # TODO: Implement quest recreation based on quest_id
            pass
```

**Needs**: Quest factory system to recreate quests from IDs.

---

## Medium Priority - Needs Implementation

### 5. **Inventory Drag-and-Drop** (MEDIUM)

**File**: `/scenes/ui/inventory/InventoryMenu.gd`

**Issue**: Placeholder TODOs for drag-and-drop
```gdscript
# TODO: Optionally, connect drag-and-drop handlers to each slot if needed
# TODO: Set icon texture, tooltip, signals
```

**Status**: Basic structure exists, needs full implementation.

---

### 6. **Settings System** (MEDIUM)

**File**: `/scenes/ui/SettingsMenuV2.gd`

**Issues**: Multiple TODOs for settings application:
```gdscript
# TODO: Actually show/hide subtitles in cutscenes/dialogue
# TODO: Apply text speed to dialogue/cutscene text
# TODO: Apply colorblind mode to game visuals
# TODO: Switch game language (requires translation support)
```

**Status**: UI exists, actual effects not implemented.

---

### 7. **Day/Night and Weather Systems** (MEDIUM)

**Files**:
- `/scripts/DayNightSystem.gd`
- `/scripts/WeatherSystem.gd`
- `/scripts/DayNightWeatherManager.gd`

**Issues**:
- Multiple TODOs for integration
- Old Godot 3 connect syntax
- No visual/audio hookups
- Timer-based but no actual effects

**TODOs**:
```gdscript
# TODO: Connect to a timer or game loop to call advance_time()
# TODO: Trigger lighting/music/UI changes for new phase
# TODO: Integrate with lighting, music, and gameplay
# TODO: Integrate with weather visuals, audio, and gameplay
```

**Recommendation**: Complete the integration or mark as "future feature".

---

## Low Priority - Refinement Needed

### 8. **Player Fishing Logic** (LOW)

**File**: `/scripts/Player.gd`

**Issues**:
- Debug comments left in code
- Some placeholder UI/animation TODOs
- Works functionally but needs polish

**Comments to address**:
```gdscript
# Bobber UI/Animation & Debug Fish Name:
# - For debugging: print or display the selected fish's name on screen
```

---

### 9. **Boss Scripts Polish** (LOW)

**Files**: All boss scripts in `/scripts/bosses/`

**Issues**:
- Inconsistent between bosses
- Some have minions/hazards, others are placeholders
- All use old Godot 3 syntax
- No banter integration yet (though banter text exists in docs)

**Status**: Framework exists, needs consistency and polish.

---

### 10. **UI Integration** (LOW)

**Files**:
- `/scenes/ui/MainMenu.gd`
- `/scenes/ui/OpeningCutscene.gd`
- `/scenes/overworld/OverworldScreen.gd`
- `/scenes/overworld/BossGateGuard.gd`

**Issues**: Placeholder TODOs for transitions:
```gdscript
# TODO: Replace with transition to overworld or last saved scene
# TODO: Transition to boss screen/cutscene
# TODO: Replace with actual dialogue UI
```

**Status**: Basic structure exists, needs scene wiring.

---

## Architectural Issues

### 11. **Mixed Godot Versions**

**Critical**: The codebase cannot run as-is because it mixes Godot 3 and 4 syntax.

**Files affected**: ~30+ script files

**Decision needed**: 
- Choose Godot 3 → Update all Godot 4 syntax (SaveManager, etc.)
- Choose Godot 4 → Update all Godot 3 syntax (Boss scripts, connect calls, etc.)

---

### 12. **Scene File References**

**Issue**: Many scripts reference `.tscn` files that may not exist or be configured:
- Arena scenes for each boss
- Minion scenes
- Hazard scenes
- Projectile scenes
- UI scenes

**Recommendation**: Audit which scenes exist vs. which are referenced.

---

### 13. **Missing Asset Dependencies**

Scripts reference visual/audio assets that don't exist:
- Sprite sheets for fish, bosses, players
- Sound effects
- Music tracks
- Particle effects
- Animation data

**Status**: Expected (noted in original analysis), but scripts should handle missing assets gracefully.

---

## Files That Need Complete Rewrite

### **High Priority Rewrites**:

1. **`/scripts/bosses/BossBattleManager.gd`** - Fix Godot version, error handling
2. **`/scripts/data/fish_data.gd`** - Add actual fish data
3. **`/scripts/QuestManager.gd`** - Implement quest factory/recreation
4. **`/scripts/bosses/Boss.gd`** - Update to correct Godot version
5. **All boss scripts** - Consistent Godot version syntax

### **Medium Priority Rewrites**:

6. **`/scripts/DayNightWeatherManager.gd`** - Fix connect syntax, complete integration
7. **`/scenes/ui/inventory/InventoryMenu.gd`** - Implement drag-and-drop fully
8. **`/scenes/ui/SettingsMenuV2.gd`** - Implement actual setting effects

### **Low Priority Rewrites**:

9. **UI transition scripts** - Wire up scene transitions
10. **Player.gd fishing sections** - Polish and remove debug code

---

## Files That Are Good (No Rewrite Needed)

✅ **SaveManager.gd** - Recently written, complete, Godot 4 syntax
✅ **Equipment.gd** - Complete with serialization
✅ **Inventory.gd** - Functional and complete
✅ **PlayerProgress.gd** - Complete with serialization
✅ **ProgressionManager.gd** - Complete logic
✅ **BiomeManager.gd** - Simple and complete
✅ **Fish.gd** - Good Resource structure
✅ **Quest.gd** - Good Resource structure (just needs factory)

---

## Immediate Action Plan

### Step 1: **Choose Godot Version** ⚠️
Decide: Godot 3 or Godot 4?

### Step 2: **Convert Syntax** (if Godot 4)
- [ ] Update all `export` → `@export`
- [ ] Update all `.instance()` → `.instantiate()`
- [ ] Update all old `connect()` syntax
- [ ] Test compilation

### Step 3: **Fill Critical Gaps**
- [ ] Write fish_data.gd with actual fish
- [ ] Implement quest factory pattern
- [ ] Fix BossBattleManager

### Step 4: **Test Core Systems**
- [ ] Test save/load
- [ ] Test fishing mechanics
- [ ] Test one boss battle

### Step 5: **Polish and Integration**
- [ ] Complete settings application
- [ ] Wire up UI transitions
- [ ] Implement day/night if needed

---

## Summary

**Must Rewrite**: 5 files (Godot version issues, empty data)
**Should Rewrite**: 8 files (incomplete features, TODOs)
**Can Keep**: 10+ files (SaveManager, Inventory, Equipment, etc.)

**Biggest Issue**: Mixed Godot 3/4 syntax - needs immediate decision and fix.

**Second Issue**: Empty/placeholder fish data - game can't function without it.

**Third Issue**: Quest save/load incomplete - needs factory pattern.

Everything else is refinement and polish.
