class_name KeyTutorial
extends NullTutorial

var _key_picked_up = false
var _key_used = false
var _key_tut_done = 0
const KEY_TUTS = {
	"pickup_key_tut_done" : "pickUpKeyAction",
	"open_door_tut_done" : "openDoorAction" }

func _init(
		server : LibMozokServer,
		worldName : StringName,
		player : Player
		) -> void:
	super(server, worldName, player)
	player.connect("key_used", _on_key_used)
	player.connect("keys_changed", _on_keys_changed)

func _apply_key_tut(tut_action_obj : String):
	_apply_tut_action(tut_action_obj)
	_key_tut_done += 1
	if _key_tut_done == KEY_TUTS.size():
		var args = ["keyTutorial"]
		var scount = str(_key_tut_done)
		args.append_array(KEY_TUTS.values())
		_server.pushAction(_world, "FinishTutorial_" + scount, args, 0)

func _on_keys_changed(keys : Array):
	if keys.size() > 0:
		if _key_picked_up == false:
			_key_picked_up = true
			_apply_key_tut("pickUpKeyAction")

func _on_key_used(_type):
	if _key_used == false:
		_key_used = true
		_apply_key_tut("openDoorAction")
