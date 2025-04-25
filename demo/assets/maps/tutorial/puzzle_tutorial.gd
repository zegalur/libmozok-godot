class_name PuzzleTutorial
extends NullTutorial

# Puzzle Tutorial
var _is_player_in_puzzle_area = false
var _player_cell_col : int = 3
var _player_cell_row : int = 3
const _AREA_SIZE = 4.0 # 4x4 cells
var _blocks : Array[StaticBody2D]
var _block_cells : Array = []
var _puzzle_rect : Rect2

func _init(
		server : LibMozokServer,
		worldName : StringName,
		player : Player,
		tutMap : Map
		) -> void:
	super(server, worldName, player)
	
	server.connect("new_quest_status", _on_new_quest_status)
	
	const path = "Env/Puzzle Island/PuzzleTutBlocks/"
	var _block_01 = tutMap.get_node(path + "PuzzleTutBlock01") as StaticBody2D
	var _block_02 = tutMap.get_node(path + "PuzzleTutBlock02") as StaticBody2D
	var _block_03 = tutMap.get_node(path + "PuzzleTutBlock03") as StaticBody2D
	var _block_04 = tutMap.get_node(path + "PuzzleTutBlock04") as StaticBody2D
	var _block_05 = tutMap.get_node(path + "PuzzleTutBlock05") as StaticBody2D
	_blocks = [_block_01, _block_02, _block_03, _block_04, _block_05]
	_puzzle_rect = tutMap.get_node("Env/Puzzle Island/PuzzleArea").get_global_rect()
	
	player.connect("use_action", _on_use_action)
	for block in _blocks:
		_block_cells.push_back(_get_cell(block.global_position))
	player.connect("big_heart_taken", _on_big_heart_tut_done)


func process_tutorial(_delta):
	if _puzzle_rect.has_point(_player.global_position):
		_is_player_in_puzzle_area = true
		var new_cell = _get_cell(_player.global_position)
		var nr = new_cell.x
		var nc = new_cell.y
		var pc = _player_cell_col
		var pr = _player_cell_row
		var get_cell = func (row, col): return "pt_cell_" + str(row) + str(col)
		if nc < pc:
			_player_cell_col = nc
			_server.pushAction(_world, "PTut_MoveLeft", 
					[get_cell.call(pr, pc), get_cell.call(pr, nc)], 0)
		elif nc > pc:
			_player_cell_col = nc
			_server.pushAction(_world, "PTut_MoveRight",
					[get_cell.call(pr, pc), get_cell.call(pr, nc)], 0)
		elif nr > pr:
			_player_cell_row = nr
			_server.pushAction(_world, "PTut_MoveDown",
					[get_cell.call(pr, pc), get_cell.call(nr, pc)], 0)
		elif nr < pr:
			_player_cell_row = nr
			_server.pushAction(_world, "PTut_MoveUp",
					[get_cell.call(pr, pc), get_cell.call(nr, pc)], 0)
	else:
		_is_player_in_puzzle_area = false


## Called when player's `use` action was activated.
func _on_use_action():
	_puzzle_tutorial_react_to_use_action()


func _puzzle_tutorial_react_to_use_action():
	if _puzzle_rect.has_point(_player.global_position):
		var p = Vector2i(_player_cell_row, _player_cell_col)
		var b = Vector2i(_player_cell_row, _player_cell_col)
		var f = Vector2i(_player_cell_row, _player_cell_col)
		var move_vec = Vector2(0, 0)
		var action_name = ""
		const CELL_SIZE = 64.0
		var player_dir = _player.get_player_direction()
		if player_dir == Player.PlayerDir.UP:
			f.x -= 2
			b.x -= 1
			move_vec.y -= CELL_SIZE
			action_name = "PTut_PushUp"
		elif player_dir == Player.PlayerDir.DOWN:
			f.x += 2
			b.x += 1
			move_vec.y += CELL_SIZE
			action_name = "PTut_PushDown"
		elif player_dir == Player.PlayerDir.LEFT:
			f.y -= 2
			b.y -= 1
			move_vec.x -= CELL_SIZE
			action_name = "PTut_PushLeft"
		elif player_dir == Player.PlayerDir.RIGHT:
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
			_server.pushAction(_world, action_name,
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
	_server.pushAction(_world, "PTut_Finish", 
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
			_server.pushAction(_world, "PTut_Cancel", 
					["pt_cell_00", "puzzleTutorial", "puzzleTutorial_GetHeart"], 0)
