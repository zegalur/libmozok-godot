class_name NullTutorial
extends RefCounted
## Base class for other tutorials.

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


func _apply_tut_action(tut_action : T.tut.ApplyTutorialAction_1_tutorialAction):
	T.tut.ApplyTutorialAction(0, _server, tut_action)


func process_tutorial(_delta):
	pass
