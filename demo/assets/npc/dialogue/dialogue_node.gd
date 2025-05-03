## Simplest node-based dialogue system.

class_name DialogueNode
extends Node

signal activated()

@export_enum("TEXT", "REPLY", "LINK") var type = "TEXT"
@export_multiline var text : String

## If non-empty, node is relevant only when condition is `true` in the state.
@export var condition : String = ""
@export var invert_condition : bool = false

func activate() -> void:
	emit_signal("activated")

func check_conditions(state : GameState) -> bool:
	if condition.length() == 0:
		return true
	var cond_def_value = true if invert_condition else false
	return state.read(condition, cond_def_value) != cond_def_value

func is_text() -> bool:
	return type == "TEXT"

func is_reply() -> bool:
	return type == "REPLY"

func find_next_text_dnode(state : GameState) -> DialogueNode:
	for n in get_children():
		if n is DialogueNode:
			if not n.check_conditions(state):
				continue
			if n.is_text():
				return n
	return null
