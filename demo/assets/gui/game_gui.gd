## In-game GUI.

class_name GameGUI
extends Control

# Hearts
@onready var _hearts_box: Container = get_node("Hearts")
@onready var _heart_red: TextureRect = get_node("Hearts/Red")
@onready var _heart_gray: TextureRect = get_node("Hearts/Gray")
@onready var _heart_half: TextureRect = get_node("Hearts/Half")

# Quests
@onready var _quest_panel = preload("res://assets/gui/quest_panel.tscn")
@onready var _open_quests: VBoxContainer = %OpenQuests
@onready var _done_quests: VBoxContainer = %DoneQuests
@onready var _failed_quests: VBoxContainer = %FailedQuests
var _quests : Dictionary # Quest Name -> Quest Panel

# Keys
@onready var _keys_box = get_node("Keys")
@onready var _dungeon_key_icon = get_node("Keys/DungeonKeyIcon")


func _ready():
	custom_minimum_size = get_viewport_rect().size
	for heart_node in _hearts_box.get_children():
		_hearts_box.remove_child(heart_node)
	for key_icon in _keys_box.get_children():
		_keys_box.remove_child(key_icon)


func _process(_delta):
	pass


func update_hearts(hearts : int, max_hearts : int):
	# Remove previous hearts.
	var prev_hearts = _hearts_box.get_children()
	for heart_node in prev_hearts:
		_hearts_box.remove_child(heart_node)
		heart_node.queue_free()
	
	# Count how many of each type we need.
	var red_count = ceil(hearts)
	var half_count = 0
	if hearts - red_count > 0.0:
		if hearts - red_count > 0.5:
			red_count += 1
		elif hearts - red_count > 0.0:
			half_count += 1
	var gray_count = max(0, max_hearts - red_count - half_count)
	
	for i in red_count:
		_hearts_box.add_child(_heart_red.duplicate())
	for i in half_count:
		_hearts_box.add_child(_heart_half.duplicate())
	for i in gray_count:
		_hearts_box.add_child(_heart_gray.duplicate())


func update_keys(keys : Array):
	# Remove previous keys.
	var prev_keys = _keys_box.get_children()
	for key_node in prev_keys:
		_keys_box.remove_child(key_node)
		key_node.queue_free()
	
	for i in keys.size():
		_keys_box.add_child(_dungeon_key_icon.duplicate())


func new_main_quest(_worldName : String, questName : String):
	_new_quest(questName)


func new_sub_quest(
		_worldName : String, 
		questName : String, 
		_parentQuestName : String,
		_goal : int ):
	_new_quest(questName)


func _new_quest(questName : String):
	var panel = _quest_panel.instantiate() as QuestPanel
	panel.set_quest_name(questName)
	_quests[questName] = panel
	_open_quests.add_child(panel)
	_open_quests.move_child(panel, 0)


func _on_new_quest_state(_worldName, questName):
	(_quests[questName] as QuestPanel).on_new_quest_state()


func new_quest_plan(
		_worldName : String, 
		questName : String, 
		actionList : PackedStringArray, 
		actionArgsList : Array):
	(_quests[questName] as QuestPanel).set_quest_plan(
			actionList, actionArgsList)


func _on_new_quest_status(_worldName, questName, questStatus):
	(_quests[questName] as QuestPanel).set_quest_status(questStatus)
	if questStatus == LibMozokServer.QUEST_STATUS_DONE:
		_open_quests.remove_child(_quests[questName])
		_done_quests.add_child(_quests[questName])
	if questStatus == LibMozokServer.QUEST_STATUS_UNREACHABLE:
		_open_quests.remove_child(_quests[questName])
		_failed_quests.add_child(_quests[questName])

