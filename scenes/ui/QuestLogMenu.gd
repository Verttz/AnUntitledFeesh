func show_quest_log():
    if quest_manager:
        visible = true
        _populate()
extends Control

# QuestLogMenu.gd: UI for displaying active and completed quests

@onready var active_list = $ActiveQuests
@onready var completed_list = $CompletedQuests
@onready var close_button = $CloseButton

var quest_manager = null

func open(manager):
    quest_manager = manager
    visible = true
    _populate()

func _ready():
    close_button.connect("pressed", self, "_on_close_pressed")
    visible = false

func _on_close_pressed():
    visible = false

func _populate():
    active_list.clear()
    completed_list.clear()
    if quest_manager:
        for quest in quest_manager.get_active_quests():
            active_list.add_item(quest.title + ": " + quest.description)
        for quest in quest_manager.get_completed_quests():
            completed_list.add_item(quest.title)
