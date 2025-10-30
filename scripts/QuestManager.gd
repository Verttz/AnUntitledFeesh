
"""
QuestManager.gd
---------------
Handles quest tracking, activation, and completion for the player.
Manages lists of all quests, active quests, and completed quests. Provides methods to add quests, check for completion, and grant rewards.
"""

extends Node

# --- Quest State ---
var quests = [] # Array of all Quest resources
var active_quests = [] # Currently active quests
var completed_quests = [] # Completed quests
var player = null # Reference to player node

func _ready():
    """
    Initializes the quest manager. For demo, auto-loads a sample quest.
    """
    var Catch3CarpQuest = preload("res://scripts/quests/Catch3CarpQuest.gd").new()
    add_quest(Catch3CarpQuest)

func add_quest(quest: Quest):
    """
    Adds a quest to the quest list and activates it if not already present.
    """
    if not quests.has(quest):
        quests.append(quest)
        quest.is_active = true
        active_quests.append(quest)

func check_quests():
    """
    Checks all active quests for completion. Grants rewards and moves completed quests to completed_quests.
    """
    for quest in active_quests:
        if quest.check_complete(player):
            quest.grant_rewards(player)
            completed_quests.append(quest)
    # Remove completed quests from active
    active_quests = [q for q in active_quests if not q.is_completed]

func set_player(p):
    """
    Sets the player reference for quest progress and reward handling.
    """
    player = p

func get_active_quests():
    """
    Returns the list of currently active quests.
    """
    return active_quests

func get_completed_quests():
    """
    Returns the list of completed quests.
    """
    return completed_quests
