# Quest.gd
# Data structure for a single quest

extends Resource

class_name Quest

@export var id: String = ""
@export var title: String = ""
@export var description: String = ""
@export var requirements: Array = [] # e.g. [{"type": "catch", "item": "Carp", "amount": 3}]
@export var rewards: Array = [] # e.g. [{"type": "gold", "amount": 50}]
@export var is_completed: bool = false
@export var is_active: bool = false

func check_complete(player):
    # Check if all requirements are met
    for req in requirements:
        match req.type:
            "catch":
                if not player.backpack.has_item(req.item, req.amount):
                    return false
            "buy":
                # Could check purchase history or inventory
                pass
            "defeat":
                # Could check boss flags
                pass
    return true

func grant_rewards(player):
    for reward in rewards:
        match reward.type:
            "gold":
                player.add_gold(reward.amount)
            "item":
                player.backpack.add_item(reward.item, reward.amount)
            # Add more reward types as needed
    is_completed = true
    is_active = false
