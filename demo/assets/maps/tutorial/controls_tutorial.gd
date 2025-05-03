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
		ControlTut.new(server, worldName, player, Player.PlayerState.WALK, 0.1, 
				T.tut.ApplyTutorialAction_1_tutorialAction.movementAction),
		ControlTut.new(server, worldName, player, Player.PlayerState.ATTACK, 0.1, 
				T.tut.ApplyTutorialAction_1_tutorialAction.attackAction),
		ControlTut.new(server, worldName, player, Player.PlayerState.HIDE, 0.1, 
				T.tut.ApplyTutorialAction_1_tutorialAction.hideAction)]


func process_tutorial(_delta):
	for tut in _control_tutorials:
		if tut.process_tutorial(_delta):
			_controls_tut_done += 1
	if _controls_tut_done == _control_tutorials.size():
		T.tut.FinishTutorial_3(0, _server,
			T.tut.FinishTutorial_3_1_tutorial.controlsTutorial,
			T.tut.FinishTutorial_3_2_action1.movementAction,
			T.tut.FinishTutorial_3_3_action2.attackAction,
			T.tut.FinishTutorial_3_4_action3.hideAction)
		_controls_tut_done = 0
		emit_signal("done")
