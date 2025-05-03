class_name KeyTutorial
extends NullTutorial

var _key_picked_up = false
var _key_used = false
var _key_tut_done = 0

const KEY_TUTS : Dictionary[String, T.tut.ApplyTutorialAction_1_tutorialAction] = {
	"pickup_key_tut_done" : T.tut.ApplyTutorialAction_1_tutorialAction.pickUpKeyAction,
	"open_door_tut_done" : T.tut.ApplyTutorialAction_1_tutorialAction.openDoorAction }

func _init(
		server : LibMozokServer,
		worldName : StringName,
		player : Player
		) -> void:
	super(server, worldName, player)
	player.connect("key_used", _on_key_used)
	player.connect("keys_changed", _on_keys_changed)

func _apply_key_tut(tut_action : T.tut.ApplyTutorialAction_1_tutorialAction):
	_apply_tut_action(tut_action)
	_key_tut_done += 1
	if _key_tut_done == KEY_TUTS.size():
		T.tut.FinishTutorial_2(0, _server,
				T.tut.FinishTutorial_2_1_tutorial.keyTutorial,
				T.tut.FinishTutorial_2_2_action1.pickUpKeyAction,
				T.tut.FinishTutorial_2_3_action2.openDoorAction)

func _on_keys_changed(keys : Array):
	if keys.size() > 0:
		if _key_picked_up == false:
			_key_picked_up = true
			_apply_key_tut(
					T.tut.ApplyTutorialAction_1_tutorialAction.pickUpKeyAction)

func _on_key_used(_type):
	if _key_used == false:
		_key_used = true
		_apply_key_tut(
				T.tut.ApplyTutorialAction_1_tutorialAction.openDoorAction)
