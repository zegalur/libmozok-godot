## In-game map. Defines the place and the rules of the game.

class_name Map
extends Node2D

## Quest project files that need to be loaded.
@export var quest_file_paths : PackedStringArray

## Initialization functions for quests that need to be called.
@export var init_actions : PackedStringArray

var _player_node : Player
var _quest_server : LibMozokServer

func _ready():
	pass

func set_player(player : Player):
	_player_node = player
	var children = find_children("*", "Enemy")
	for node in children:
		var enemy = node as Enemy
		enemy.set_player(_player_node)

func set_server(server : LibMozokServer):
	_quest_server = server
