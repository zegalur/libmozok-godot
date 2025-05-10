class_name DialogueNode
extends Node
## Simplest node-based dialogue system.
##
## There are three types of `DialogueNode`s:
## - "TEXT": Describes some text shown in the text portion of the dialogue window.
##           Or the next portion of the text, when it is a child of another TEXT node.
## - "REPLY": Replies must be children of TEXT nodes; they will appear in the reply
##            portion of the dialogue window.
## - "LINK": A reference to another node (WARNING: under construction).
##
## When multiple nodes are available for selection, the first node that 
## satisfies all conditions will be selected.
##
## Typical dialogue:
##   - Text (conditional)
##   + Text 1
##     + Answer 1
##       - Reaction 1 (when there are no children, the dialogue will end)
##     - Answer 2 (when there are no children, the dialogue will end)

## Emitted when this node is activated during the dialogue.
signal activated()

## - "TEXT": Describes some text shown in the text portion of the dialogue window.
##           Or the next portion of the text, when it is a child of another TEXT node.
## - "REPLY": Replies must be children of TEXT nodes; they will appear in the reply
##            portion of the dialogue window.
## - "LINK": A reference to another node (WARNING: under construction).
@export_enum("TEXT", "REPLY", "LINK") var type = "TEXT"

@export_multiline var text : String

## If non-empty, node is selected only when condition is set `true` in the state.
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
