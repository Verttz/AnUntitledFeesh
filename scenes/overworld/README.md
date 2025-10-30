# Overworld Framework

- `OverworldManager.gd` manages screen transitions and fade effects.
- `OverworldScreen.tscn` is the base scene for each area/screen.
- `ObliqueCamera2D.tscn` is a camera that follows the player, allows zoom, and uses an oblique angle.
- `FadeLayer.tscn` is a black overlay for fade transitions.

To add a new screen, duplicate `OverworldScreen.tscn` and customize its contents.
Connect each screen's exits to call `on_player_reach_edge(direction)`.
