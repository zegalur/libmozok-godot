class_name GameGUI
extends Control
## In-game GUI (quest panel, health, keys, dialogues etc).

signal dialogue_ended()

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

# Dialogue Box
@onready var _dialogue_box = %DialogueBox
@onready var _npc_portrait = %NPCPortrait
@onready var _npc_name = %NPCName
@onready var _dialogue_text = %DialogueText
@onready var _answers = %Answers as SelectOptionNode
@onready var _empty_portrait = _npc_portrait.texture
var _answer_nodes : Array[DialogueNode] = []
const END_DIALOGUE_ANSWER = "[end]"
const NEXT_ANSWER = "[next]"

# Other
@onready var _map_name = %MapNameLabel
@onready var _map_name_player = %MapNamePlayer
var _state : GameState


func _ready():
	custom_minimum_size = get_viewport_rect().size
	for heart_node in _hearts_box.get_children():
		_hearts_box.remove_child(heart_node)
	for key_icon in _keys_box.get_children():
		_keys_box.remove_child(key_icon)
	_dialogue_box.hide()
	_answers.active = false


func save_state(state : GameState) -> void:
	pass


func load_state(state : GameState) -> void:
	_state = state


func _process(_delta):
	pass


## Displays an animated map name at the top-center of the screen.
func show_map_name(map_name : String) -> void:
	_map_name.text = tr(map_name)
	_map_name_player.play("ShowMapName")


## Updates the hearts indicator at the top-left of the screen.
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


## Updates the keys icons at the top-left of the screen.
func update_keys(keys : Array):
	# Remove previous keys.
	var prev_keys = _keys_box.get_children()
	for key_node in prev_keys:
		_keys_box.remove_child(key_node)
		key_node.queue_free()
	
	for i in keys.size():
		_keys_box.add_child(_dungeon_key_icon.duplicate())


# ================================= QUESTS =================================== #

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


# ================================ DIALOGUE ================================== #

## Starts a new dialogue with the given NPC from the specified dialogue node.
func start_dialogue(npc : NPC, dnode : DialogueNode) -> void:
	_dialogue_box.show()
	_answers.active = true
	_npc_portrait.texture = npc.portrait if npc.portrait else _empty_portrait
	_npc_name.text = npc.npc_name + ":"
	_activate_dnode(dnode)


func _activate_dnode(dnode : DialogueNode) -> void:
	dnode.activate()
	_dialogue_text.text = dnode.text
	_answer_nodes = []
	var options : Array[String] = []
	for n in dnode.get_children():
		if n is DialogueNode:
			if not n.check_conditions(_state):
				continue
			if n.is_text():
				_answer_nodes = [n]
				options = [NEXT_ANSWER] as Array[String]
				break
			elif n.is_reply():
				_answer_nodes.push_back(n)
				options.push_back(n.text)
	if _answer_nodes.size() == 0:
		options = [END_DIALOGUE_ANSWER] as Array[String]
	_answers.options = options
	_answers.selected = 0


func _on_answers_option_selected(indx: int) -> void:
	if _answer_nodes.size() == 0:
		_end_dialogue()
	elif _answer_nodes[indx].is_text():
		_activate_dnode(_answer_nodes[indx])
	elif _answer_nodes[indx].is_reply():
		var next_dnode = _answer_nodes[indx].find_next_text_dnode(_state)
		if next_dnode == null:
			_end_dialogue()
		else:
			_activate_dnode(next_dnode)


func _end_dialogue() -> void:
	_dialogue_box.hide()
	_answers.active = false
	emit_signal("dialogue_ended")
