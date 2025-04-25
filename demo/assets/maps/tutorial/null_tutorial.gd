# Base class for other tutorials.
class_name NullTutorial
extends RefCounted

signal done()

var _server : LibMozokServer
var _world : StringName
var _player : Player

func _init(
		server : LibMozokServer,
		worldName : StringName,
		player : Player
		) -> void :
	_server = server
	_world = worldName
	_player = player

func _apply_tut_action(tut_action_obj : String):
	_server.pushAction(_world, "ApplyTutorialAction", [tut_action_obj], 0)

func process_tutorial(_delta):
	pass
