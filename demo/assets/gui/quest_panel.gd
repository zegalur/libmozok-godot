## Quest panel from the in-game GUI.
## Shows quest title, description, current status and current quest plan.

class_name QuestPanel
extends PanelContainer

@onready var _title = $VBoxContainer/HBoxContainer/Title
@onready var _details = $VBoxContainer/Details
@onready var _description = $VBoxContainer/Details/HBoxContainer2/Description
@onready var _plan = $VBoxContainer/Details/PlanContainer/VBoxContainer/Plan
@onready var _plan_label = $VBoxContainer/Details/PlanLabel
@onready var _plan_container = $VBoxContainer/Details/PlanContainer

@onready var _open_icon = preload("res://assets/gui/imgs/quest-icon-open.png")
@onready var _done_icon = preload("res://assets/gui/imgs/quest-icon-done.png")
@onready var _failed_icon = preload("res://assets/gui/imgs/quest-icon-failed.png")
@onready var _unknown_icon = preload("res://assets/gui/imgs/quest-icon-unknown.png")
@onready var _quest_status_icon = $VBoxContainer/HBoxContainer/StatusIcon

var _quest_name : String
var _is_ready = false
var _quest_status : int
var _action_list : PackedStringArray
var _action_args : Array


func _ready():
	_is_ready = true
	_update_text()


func set_quest_name(quest_name : String):
	_quest_name = quest_name
	_update_text()
	$AnimationPlayer.stop()
	$AnimationPlayer.play("active")


func set_quest_plan(
		actionList : PackedStringArray, 
		actionArgsList : Array):
	_action_list = actionList
	_action_args = actionArgsList
	_plan.modulate.a = 1.0
	_update_text()
	$AnimationPlayer.stop()
	$AnimationPlayer.play("active")


func set_quest_status(new_status : int):
	_quest_status = new_status
	var hide_details_at = [
			LibMozokServer.QUEST_STATUS_DONE,
			LibMozokServer.QUEST_STATUS_UNREACHABLE
			]
	if _quest_status in hide_details_at:
		_details.visible = false
	_update_text()
	$AnimationPlayer.stop()
	$AnimationPlayer.play("active")


func on_new_quest_state():
	_plan.modulate.a = 0.85
	_quest_status_icon.texture = _unknown_icon
	$AnimationPlayer.stop()
	$AnimationPlayer.play("active")


## Updates the quest panel text, using Godot's built-in translation capabilities 
## to convert raw quest, object, and action names into narrated text.
func _update_text():
	if _is_ready == false:
		return
		
	var plan = ""
	for i in _action_list.size():
		plan += str(i + 1) + ". "
		var fmap = []
		for j in _action_args[i].size():
			fmap.push_back(tr("OBJ_" + _action_args[i][j]))
		plan += tr("ACTION_" + _action_list[i]).format(fmap)
		if i != _action_list.size() - 1:
			plan += "\n"
	
	var quest_icon = _open_icon
	if _quest_status == LibMozokServer.QUEST_STATUS_DONE:
		quest_icon = _done_icon
	if _quest_status == LibMozokServer.QUEST_STATUS_UNREACHABLE:
		quest_icon = _failed_icon
	_quest_status_icon.texture = quest_icon
	
	_title.text = tr("TITLE_" + _quest_name)
	_description.text = tr("DESC_" + _quest_name)
	_plan.text = plan
	
	if (_quest_status == LibMozokServer.QUEST_STATUS_DONE
			or _quest_status == LibMozokServer.QUEST_STATUS_UNREACHABLE):
		_plan_label.hide()
		_plan_container.hide()


func _on_toggle_details_pressed():
	_details.visible = not _details.visible
