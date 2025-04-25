class_name ControlsTutorial
extends NullTutorial

var _control_tutorials : Array[ControlTut]
var _controls_tut_done = 0

func _init(
		server : LibMozokServer,
		worldName : StringName,
		player : Player
		) -> void:
	super(server, worldName, player)
	
	_control_tutorials =  [
		ControlTut.new(server, worldName, player, Player.PlayerState.WALK, 0.1, "movementAction"),
		ControlTut.new(server, worldName, player, Player.PlayerState.ATTACK, 0.1, "attackAction"),
		ControlTut.new(server, worldName, player, Player.PlayerState.HIDE, 0.1, "hideAction")]

func process_tutorial(_delta):
	for tut in _control_tutorials:
		if tut.process_tutorial(_delta):
			_controls_tut_done += 1
	if _controls_tut_done == _control_tutorials.size():
		var args = ["controlsTutorial"]
		var tcount = str(_controls_tut_done)
		for tut in _control_tutorials:
			args.push_back(tut.action)
		_server.pushAction(_world, "FinishTutorial_" + tcount, args, 0)
		_controls_tut_done = 0
		emit_signal("done")
