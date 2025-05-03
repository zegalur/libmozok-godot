# Auxilary class for the controls tutorial.
class_name ControlTut
extends NullTutorial

var _timers = {
	Player.PlayerDir.UP : 0.0, 
	Player.PlayerDir.DOWN : 0.0, 
	Player.PlayerDir.LEFT : 0.0, 
	Player.PlayerDir.RIGHT : 0.0}

var _done = false
var _state : Player.PlayerState
var _amount : float
var action = T.tut.ApplyTutorialAction_1_tutorialAction.movementAction

func _init(
		server : LibMozokServer,
		world_name : StringName,
		player : Player, 
		state : Player.PlayerState, 
		amount : float, 
		tut_action : T.tut.ApplyTutorialAction_1_tutorialAction
		):
	super(server, world_name, player)
	_server = server
	_player = player
	_state = state
	_amount = amount
	_world = world_name
	action = tut_action

# Returns `true` only once, when tutorial is done.
func process_tutorial(delta : float) -> bool:
	if _done == true:
		return false
	if _state != _player.get_player_state():
		return false
	_timers[_player.get_player_direction()] += delta
	_done = true
	for timer in _timers.values():
		if timer < _amount:
			_done = false
	if _done == true:
		# Apply the corresponding action.
		T.tut.ApplyTutorialAction(0, _server, action)
		return true
	return false
