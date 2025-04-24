## Tutorial demo level.

class_name TutorialMap
extends Map

# The name of the tutorial quest world.
const W_TUT = "tut"

# Controls Tutorial
var _controls_tut_done = 0
const CONTROL_TUTS = {
	"movement_tut_done" : "movementAction",
	"attack_tut_done" : "attackAction",
	"hide_tut_done" : "hideAction" }

# Fighting Tutorial
var _fighting_tut_done = 0
const PLAYER_FIGHTING_TUTS = {
	"block_tut_done" : "blockAttackAction",
	"take_hit_tut_done" : "takeHitAction",
	"take_heart_tut_done" : "takeHeartAction",
	"die_tut_done" : "dieAction" }
const ENEMY_FIGHTING_TUTS = {
	"killed" : "killEnemyAction" }
var _is_enemy_killed_tut_done = false

# Key Tutorial
var _key_tut_done = 0
const KEY_TUTS = {
	"pickup_key_tut_done" : "pickUpKeyAction",
	"open_door_tut_done" : "openDoorAction" }

# Puzzle Tutorial
@onready var _block_01 = $"Env/Puzzle Island/PuzzleTutBlocks/PuzzleTutBlock01"
@onready var _block_02 = $"Env/Puzzle Island/PuzzleTutBlocks/PuzzleTutBlock02"
@onready var _block_03 = $"Env/Puzzle Island/PuzzleTutBlocks/PuzzleTutBlock03"
@onready var _block_04 = $"Env/Puzzle Island/PuzzleTutBlocks/PuzzleTutBlock04"
@onready var _block_05 = $"Env/Puzzle Island/PuzzleTutBlocks/PuzzleTutBlock05"
@onready var _puzzle_rect : Rect2 = $"Env/Puzzle Island/PuzzleArea".get_global_rect()
var _is_player_in_puzzle_area = false
var _player_cell_col : int = 3
var _player_cell_row : int = 3
const _AREA_SIZE = 4.0 # 4x4 cells
@onready var _blocks = [_block_01, _block_02, _block_03, _block_04, _block_05]
var _block_cells : Array = []

# Portal Tutorial
@onready var _portal = $"Env/Puzzle Island/PortalArea"

func set_player(player : Player):
	super(player)
	
	# Controls tutorial
	for signal_name in CONTROL_TUTS.keys():
		player.connect(signal_name, 
				_apply_controls_tut.bind(CONTROL_TUTS[signal_name]))
	
	# Fighting tutorial
	var fighting_tut_enemy = $"Env/Flying Island/Objects/FightingTutEnemy"
	fighting_tut_enemy.connect(
			ENEMY_FIGHTING_TUTS.keys().front(), 
			_apply_fighting_tut.bind(ENEMY_FIGHTING_TUTS.values().front()))
	for signal_name in PLAYER_FIGHTING_TUTS.keys():
		player.connect(signal_name, 
				_apply_fighting_tut.bind(PLAYER_FIGHTING_TUTS[signal_name]))
	
	# Key tutorial
	for signal_name in KEY_TUTS.keys():
		player.connect(signal_name,
				_apply_key_tut.bind(KEY_TUTS[signal_name]))
	
	# Puzzle tutorial
	player.connect("use_action", _on_use_action)
	for block in _blocks:
		_block_cells.push_back(_get_cell(block.global_position))
	player.connect("take_big_heart_tut_done", _on_big_heart_tut_done)


func set_server(server : LibMozokServer):
	super(server)
	_quest_server.connect("new_quest_status", _on_new_quest_status)
	_quest_server.connect("new_sub_quest", _on_new_subquest)


func _process(_delta):
	_update_puzzle_tutorial()


func _update_puzzle_tutorial():
	if _puzzle_rect.has_point(_player_node.global_position):
		_is_player_in_puzzle_area = true
		var new_cell = _get_cell(_player_node.global_position)
		var nr = new_cell.x
		var nc = new_cell.y
		var pc = _player_cell_col
		var pr = _player_cell_row
		var get_cell = func (row, col): return "pt_cell_" + str(row) + str(col)
		if nc < pc:
			_player_cell_col = nc
			_quest_server.pushAction(W_TUT, "PTut_MoveLeft", 
					[get_cell.call(pr, pc), get_cell.call(pr, nc)], 0)
		elif nc > pc:
			_player_cell_col = nc
			_quest_server.pushAction(W_TUT, "PTut_MoveRight",
					[get_cell.call(pr, pc), get_cell.call(pr, nc)], 0)
		elif nr > pr:
			_player_cell_row = nr
			_quest_server.pushAction(W_TUT, "PTut_MoveDown",
					[get_cell.call(pr, pc), get_cell.call(nr, pc)], 0)
		elif nr < pr:
			_player_cell_row = nr
			_quest_server.pushAction(W_TUT, "PTut_MoveUp",
					[get_cell.call(pr, pc), get_cell.call(nr, pc)], 0)
	else:
		_is_player_in_puzzle_area = false


func _apply_tut_action(tut_action_obj : String):
	_quest_server.pushAction(W_TUT, "ApplyTutorialAction", [tut_action_obj], 0)


func _apply_controls_tut(tut_action_obj : String):
	_apply_tut_action(tut_action_obj)
	_controls_tut_done += 1
	if _controls_tut_done == CONTROL_TUTS.size():
		var args = ["controlsTutorial"]
		args.append_array(CONTROL_TUTS.values())
		_quest_server.pushAction(W_TUT, "FinishTutorial_" + str(_controls_tut_done), args, 0)
		$"Env/Initial Island/ControlsTutDoor".open()


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
		_quest_server.pushAction(W_TUT, "FinishTutorial_" + str(_fighting_tut_done), args, 0)
		$"Env/Flying Island/TileLayer/FightingTutDoor".open()


func _apply_key_tut(tut_action_obj : String):
	_apply_tut_action(tut_action_obj)
	_key_tut_done += 1
	if _key_tut_done == KEY_TUTS.size():
		var args = ["keyTutorial"]
		args.append_array(KEY_TUTS.values())
		_quest_server.pushAction(W_TUT, "FinishTutorial_" + str(_key_tut_done), args, 0)


## Called when player's `use` action was activated.
func _on_use_action():
	_puzzle_tutorial_react_to_use_action()


func _puzzle_tutorial_react_to_use_action():
	if _puzzle_rect.has_point(_player_node.global_position):
		var p = Vector2i(_player_cell_row, _player_cell_col)
		var b = Vector2i(_player_cell_row, _player_cell_col)
		var f = Vector2i(_player_cell_row, _player_cell_col)
		var move_vec = Vector2(0, 0)
		var action_name = ""
		const CELL_SIZE = 64.0
		var player_dir = _player_node.get_player_direction()
		if player_dir == "up":
			f.x -= 2
			b.x -= 1
			move_vec.y -= CELL_SIZE
			action_name = "PTut_PushUp"
		elif player_dir == "down":
			f.x += 2
			b.x += 1
			move_vec.y += CELL_SIZE
			action_name = "PTut_PushDown"
		elif player_dir == "left":
			f.y -= 2
			b.y -= 1
			move_vec.x -= CELL_SIZE
			action_name = "PTut_PushLeft"
		elif player_dir == "right":
			f.y += 2
			b.y += 1
			move_vec.x += CELL_SIZE
			action_name = "PTut_PushRight"
		if (f.x >= _AREA_SIZE) or (f.x < 0) or (f.y >= _AREA_SIZE) or (f.y < 0):
			# Can't move the block outside the arena.
			return
		var block_indx = -1
		for i in _blocks.size():
			if f == _block_cells[i]:
				# Can't move the block because there are no free cells.
				return
			if b == _block_cells[i]:
				block_indx = i
				break
		if block_indx != -1:
			_blocks[block_indx].translate(move_vec)
			_block_cells[block_indx] = f
			var get_cell = func (row, col): return "pt_cell_" + str(row) + str(col)
			_quest_server.pushAction(W_TUT, action_name,
					[ get_cell.call(p.x, p.y), 
					get_cell.call(b.x, b.y), 
					get_cell.call(f.x, f.y) ], 0)


## (row, column)
func _get_cell(global_pos : Vector2) -> Vector2i:
	var loc_pos = global_pos - _puzzle_rect.position
	var nc = floor(loc_pos.x / (_puzzle_rect.size.x / _AREA_SIZE))
	var nr = floor(loc_pos.y / (_puzzle_rect.size.y / _AREA_SIZE))
	return Vector2i(nr, nc)


## Finish the puzzle tutorial.
func _on_big_heart_tut_done():
	_quest_server.pushAction(W_TUT, "PTut_Finish", 
			["pt_cell_00", "puzzleTutorial", "puzzleTutorial_GetHeart"], 0)


## React to new quest status event.
func _on_new_quest_status(_worldName, questName : String, status : int):
	if questName == "PuzzleTutorial_GetHeart":
		if status == LibMozokServer.QUEST_STATUS_UNREACHABLE:
			# Unreachable goals are skipped automatically. However, in this 
			# case, the puzzle quest was split into smaller subquest, and the 
			# associated goal is manually canceled here because we want the 
			# failed quest to appear in the quest book. Normally, you should not 
			# do it this way. Instead, create one quest with multiple goals. 
			# This method is used here for illustrative purposes only.
			_quest_server.pushAction(W_TUT, "PTut_Cancel", 
					["pt_cell_00", "puzzleTutorial", "puzzleTutorial_GetHeart"], 0)


## React to new subquest event.
func _on_new_subquest(
		_worldName : String, 
		questName : String, 
		_parentQuestName : String,
		_goal : int ):
	if(questName == "PortalTutorial"):
		_portal.show()


func _on_portal_area_2d_body_entered(body: Node2D) -> void:
	if _portal.visible:
		if body is Player:
			_quest_server.pushAction(W_TUT, "MoveToPortal", 
					["pt_cell_33", "portalTutorial"], 0)
