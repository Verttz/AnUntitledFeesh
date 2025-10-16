extends Node

var banter_lines = [
	"You swimmin' in my territory, pal?",
	"Nobody outsmarts the Don!",
	"You call that dodging? My grandma swims faster!",
	"Boys, show 'em what we do to wiseguys!",
	"Hey! Watch the suit!"
]

func get_random_banter():
	return banter_lines[randi() % banter_lines.size()]

# Call this from the boss script to trigger banter during attacks, phase changes, or unique events.
