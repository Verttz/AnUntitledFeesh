extends Resource
class_name Catch3CarpQuest

# Sample quest: Catch 3 Carp

@export var id: String = "catch_3_carp"
@export var title: String = "Carp Collector"
@export var description: String = "Catch 3 Carp and show your fishing prowess."
@export var requirements: Array = [
    {"type": "catch", "item": "Carp", "amount": 3}
]
@export var rewards: Array = [
    {"type": "gold", "amount": 50}
]
@export var is_completed: bool = false
@export var is_active: bool = false
