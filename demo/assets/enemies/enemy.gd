## In-game enemy class.

class_name Enemy
extends CharacterBody2D

## Player's node.
@export var _player : Player


## Sets the player node.
func set_player(player : Player):
	_player = player


## Take a hit from the specified direction with the specified damage.
func take_hit(_from : Vector2, _damage : float):
	pass

