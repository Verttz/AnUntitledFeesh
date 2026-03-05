extends Control

# QuestLogMenu.gd: UI for displaying active and completed quests

@onready var active_list = $ActiveQuests
@onready var completed_list = $CompletedQuests
@onready var close_button = $CloseButton

var quest_manager = null

func open(manager = null):
    if manager:
        quest_manager = manager
    elif has_node("/root/QuestManager"):
        quest_manager = get_node("/root/QuestManager")
    visible = true
    _populate()

func _ready():
    close_button.pressed.connect(_on_close_pressed)
    visible = false

func _on_close_pressed():
    visible = false

func _populate():
    active_list.clear()
    completed_list.clear()
    if not quest_manager:
        return
    for quest in quest_manager.get_active_quests():
        var progress_str = ""
        if quest.requirements.size() > 0:
            progress_str = " [" + quest.get_progress_string(0) + "]"
        active_list.add_item(quest.title + ": " + quest.description + progress_str)
    for quest in quest_manager.get_completed_quests():
        active_list.add_item(quest.title + " (COMPLETE)")
