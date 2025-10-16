# QuestManager.gd
# Handles quest tracking, activation, and completion

extends Node

var quests = [] # Array of Quest resources
var active_quests = []
var completed_quests = []
var player = null

func _ready():
    # For demo: auto-load sample quest
    var Catch3CarpQuest = preload("res://scripts/quests/Catch3CarpQuest.gd").new()
    add_quest(Catch3CarpQuest)

func add_quest(quest: Quest):
    if not quests.has(quest):
        quests.append(quest)
        quest.is_active = true
        active_quests.append(quest)

func check_quests():
    for quest in active_quests:
        if quest.check_complete(player):
            quest.grant_rewards(player)
            completed_quests.append(quest)
    # Remove completed quests from active
    active_quests = [q for q in active_quests if not q.is_completed]

func set_player(p):
    player = p

func get_active_quests():
    return active_quests

func get_completed_quests():
    return completed_quests
