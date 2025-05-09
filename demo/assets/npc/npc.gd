class_name NPC
extends CharacterBody2D
## NPC (Non-Playable Character). Can be talked to.

@export var portrait : Texture2D
@export_multiline var npc_name : String = "[Unknown]"


func talk(player : Player, state : GameState):
	# Find and activate the first appropriate dialogue node.
	for n in get_children():
		if n is DialogueNode:
			if not n.is_text():
				continue
			if n.check_conditions(state):
				player.start_dialogue(self, n)
				break
