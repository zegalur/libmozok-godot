class_name FightingTutorial
extends NullTutorial

var _block_tut_done = false
var _block_count = 0
var _die_tut_done = false
var _take_heart_tut_done = false
var _take_hit_tut_done = false
var _fighting_tut_done = 0
const PLAYER_FIGHTING_TUTS = {
	"block_tut_done" : "blockAttackAction",
	"take_hit_tut_done" : "takeHitAction",
	"take_heart_tut_done" : "takeHeartAction",
	"die_tut_done" : "dieAction" }
const ENEMY_FIGHTING_TUTS = {
	"killed" : "killEnemyAction" }
var _is_enemy_killed_tut_done = false

func _init(
		server : LibMozokServer,
		worldName : StringName,
		player : Player, 
		fighting_tut_enemy : Enemy
		) -> void:
	super(server, worldName, player)
	_server = server
	_world = worldName
	player.connect("hit_taken", _on_hit_taken)
	player.connect("hit_blocked", _on_hit_blocked)
	player.connect("hearts_added", _on_hearts_added)
	player.connect("dead", _on_dead)
	fighting_tut_enemy.connect(
			ENEMY_FIGHTING_TUTS.keys().front(), 
			_apply_fighting_tut.bind(ENEMY_FIGHTING_TUTS.values().front()))

func  _on_dead():
	if _die_tut_done == false:
		_die_tut_done = true
		_apply_fighting_tut("dieAction")

func _on_hearts_added(_count : int):
	if _take_heart_tut_done == false:
		_take_heart_tut_done = true
		_apply_fighting_tut("takeHeartAction")

func _on_hit_taken(_from : Vector2, _damage : float):
	if _take_hit_tut_done == false:
		_take_hit_tut_done = true
		_apply_fighting_tut(PLAYER_FIGHTING_TUTS["take_hit_tut_done"])

func _on_hit_blocked(_from : Vector2):
	_block_count += 1
	if _block_tut_done == false and _block_count >= 3:
		_block_tut_done = true
		_apply_fighting_tut(PLAYER_FIGHTING_TUTS["block_tut_done"])

func _apply_fighting_tut(tut_action_obj : String):
	if tut_action_obj == ENEMY_FIGHTING_TUTS.values().front():
		if _is_enemy_killed_tut_done:
			return
		_is_enemy_killed_tut_done = true
	_fighting_tut_done += 1
	_apply_tut_action(tut_action_obj)
	if _fighting_tut_done == ENEMY_FIGHTING_TUTS.size() + PLAYER_FIGHTING_TUTS.size():
		var args = ["fightingTutorial"]
		args.append_array(PLAYER_FIGHTING_TUTS.values())
		args.append_array(ENEMY_FIGHTING_TUTS.values())
		_server.pushAction(_world, "FinishTutorial_" + str(_fighting_tut_done), args, 0)
		emit_signal("done")
