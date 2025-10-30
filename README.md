# AnUntitledFeesh
Creating a hybrid fishing game.

## Day/Night and Weather System Integration

The project includes a modular day/night and weather system:

- `DayNightSystem.gd`: Handles in-game time, day phases, and emits signals for transitions.
- `WeatherSystem.gd`: Handles random/scripted weather, emits signals for weather changes.
- `DayNightWeatherManager.gd`: Integrates both systems, advances time/weather, and connects signals for gameplay/UI hooks.

### Integration Details
- The manager is instantiated in `OverworldScreen.gd` and advances time/weather every second (10 in-game minutes).
- Signals are connected for phase changes, time advancement, and weather changes. These can be hooked to lighting, music, UI, and gameplay effects.
- All visual/audio/gameplay hooks are marked as TODOs for easy future implementation.
- To display time/weather in the UI, call `get_time_string()` and `get_weather()` on the manager instance.

See the scripts in `/scripts/` for detailed comments and pseudocode.
