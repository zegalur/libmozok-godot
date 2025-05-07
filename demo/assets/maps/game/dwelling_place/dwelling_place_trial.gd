extends Map
## Heart trial under the dwelling place area.

# Puzzle Area
@onready var _puzzle_portals = $Puzzle/Portals
@onready var _puzzle_portal = $Puzzle/PuzzlePortalArea
var _last_pcell : Vector2i # (x, y)
var _cells = {}
var _portals = []

# Fight Arena
@onready var _damage_area = preload("res://assets/other/damage_arena/damage_area.tscn")
var _last_fcell : Vector2i # (x, y)
var _fcell_timer : float


func _ready() -> void:
	super()
	_puzzle_portal.hide()
	%FightDoorIn.open()
	#
	_cells[Vector2i(0, 0)] = M.game.DP_ResetPuzzle_1_c00.dp_cell_00_
	_cells[Vector2i(1, 0)] = M.game.DP_ResetPuzzle_2_c01.dp_cell_01_
	_cells[Vector2i(2, 0)] = M.game.DP_ResetPuzzle_3_c02.dp_cell_02_
	_cells[Vector2i(3, 0)] = M.game.DP_ResetPuzzle_4_c03.dp_cell_03_
	_cells[Vector2i(4, 0)] = M.game.DP_ResetPuzzle_5_c04.dp_cell_04_
	#
	_cells[Vector2i(0, 1)] = M.game.DP_ResetPuzzle_6_c10.dp_cell_10_
	_cells[Vector2i(1, 1)] = M.game.DP_ResetPuzzle_7_c11.dp_cell_11_
	_cells[Vector2i(2, 1)] = M.game.DP_ResetPuzzle_8_c12.dp_cell_12_
	_cells[Vector2i(3, 1)] = M.game.DP_ResetPuzzle_9_c13.dp_cell_13_
	_cells[Vector2i(4, 1)] = M.game.DP_ResetPuzzle_10_c14.dp_cell_14_
	#
	_cells[Vector2i(0, 2)] = M.game.DP_ResetPuzzle_11_c20.dp_cell_20_
	_cells[Vector2i(1, 2)] = M.game.DP_ResetPuzzle_12_c21.dp_cell_21_
	_cells[Vector2i(2, 2)] = M.game.DP_ResetPuzzle_13_c22.dp_cell_22_
	_cells[Vector2i(3, 2)] = M.game.DP_ResetPuzzle_14_c23.dp_cell_23_
	_cells[Vector2i(4, 2)] = M.game.DP_ResetPuzzle_15_c24.dp_cell_24_
	#
	_cells[Vector2i(0, 3)] = M.game.DP_ResetPuzzle_16_c30.dp_cell_30_
	_cells[Vector2i(1, 3)] = M.game.DP_ResetPuzzle_17_c31.dp_cell_31_
	_cells[Vector2i(2, 3)] = M.game.DP_ResetPuzzle_18_c32.dp_cell_32_
	_cells[Vector2i(3, 3)] = M.game.DP_ResetPuzzle_19_c33.dp_cell_33_
	_cells[Vector2i(4, 3)] = M.game.DP_ResetPuzzle_20_c34.dp_cell_34_


func setup(
		server : LibMozokServer, 
		player : Player, 
		spawn_point : String,
		state : GameState
		) -> void:
	super(server, player, spawn_point, state)
	player.connect("dead", _on_dead)

# ----------------------------------- State ---------------------------------- #

const PRE = "dwelling_place/"
var _puzzle_trial_done : bool
var _fighting_trial_done : bool

func save_state(state: GameState) -> void:
	state.write(PRE + "_puzzle_trial_done", _puzzle_trial_done)
	state.write(PRE + "_fighting_trial_done", _fighting_trial_done)


func load_state(state: GameState) -> void:
	_puzzle_trial_done = state.read(PRE + "_puzzle_trial_done", false)
	_fighting_trial_done = state.read(PRE + "_fighting_trial_done", false)
	
	if _puzzle_trial_done:
		%Puzzle_Door.open()
	if _fighting_trial_done:
		%FightDoorIn.open()
		%FightDoorOut.open()
		for enemy in %ArenaEnemies.get_children():
			enemy.queue_free()


# ----------------------------------- Other ---------------------------------- #

func _physics_process(delta: float) -> void:
	_process_puzzle_trial()
	_process_fighting_trial(delta)


func _process_puzzle_trial() -> void:
	if _puzzle_trial_done:
		return
	if _player_node.is_dead():
		return
	
	var puzzle_rect = %Puzzle_Area.get_global_rect() as Rect2
	if puzzle_rect.has_point(_player_node.global_position) == false:
		return
	
	var rel_pos = _player_node.position - puzzle_rect.position
	var cell_pos = Vector2i((rel_pos / 64.0).floor())
	
	# Player enters the puzzle area for the first time?
	if _puzzle_portals.get_child_count() == 0:
		_start_puzzle_trial()
		_last_pcell = cell_pos
		return
	
	# New portal cell?
	if cell_pos != _last_pcell and cell_pos.x % 2 == 0 and cell_pos.y % 2 == 0:
		var portal = _puzzle_portal.duplicate() as Area2D
		_puzzle_portals.add_child(portal)
		portal.position = puzzle_rect.position + Vector2(_last_pcell * 64) + Vector2(32, 32)
		portal.show()
		_portals.push_back(_last_pcell)
		
		var p : Vector2i = _last_pcell / 2
		var c : Vector2i = cell_pos / 2
		
		# Push quest action.
		if c.x < p.x:
			M.game.DP_MoveLeft(0, _quest_server, _cells[p], _cells[c])
		elif c.x > p.x:
			M.game.DP_MoveRight(0, _quest_server, _cells[p], _cells[c])
		elif c.y < p.y:
			M.game.DP_MoveUp(0, _quest_server, _cells[p], _cells[c])
		elif c.y > p.y:
			M.game.DP_MoveDown(0, _quest_server, _cells[p], _cells[c])
		
		# Done?
		if _portals.size() >= 19 and c == Vector2i(2,0):
			_end_puzzle_trial()
			return
		
		_last_pcell = cell_pos


func _start_puzzle_trial() -> void:
	_portals.clear()
	var portal = _puzzle_portal.duplicate() as Area2D
	portal.position = %Puzzle_Entrance.position
	_puzzle_portals.add_child(portal)
	portal.show()


func _end_puzzle_trial() -> void:
	if _puzzle_trial_done:
		return
	_puzzle_trial_done = true
	%Puzzle_Door.open()
	for portal in _puzzle_portals.get_children():
		portal.queue_free()
	M.game.DP_FinishPuzzle(0, _quest_server,
		M.game.DP_FinishPuzzle_1_puzzle.dp_trial_puzzle_,
		M.game.DP_FinishPuzzle_2_fighting.dp_trial_fighting_,
		M.game.DP_FinishPuzzle_3_c00.dp_cell_00_,
		M.game.DP_FinishPuzzle_4_c01.dp_cell_01_,
		M.game.DP_FinishPuzzle_5_c02_exit.dp_cell_02_,
		M.game.DP_FinishPuzzle_6_c03.dp_cell_03_,
		M.game.DP_FinishPuzzle_7_c04.dp_cell_04_,
			M.game.DP_FinishPuzzle_8_c10.dp_cell_10_,
			M.game.DP_FinishPuzzle_9_c11.dp_cell_11_,
			M.game.DP_FinishPuzzle_10_c12.dp_cell_12_,
			M.game.DP_FinishPuzzle_11_c13.dp_cell_13_,
			M.game.DP_FinishPuzzle_12_c14.dp_cell_14_,
		M.game.DP_FinishPuzzle_13_c20.dp_cell_20_,
		M.game.DP_FinishPuzzle_14_c21.dp_cell_21_,
		M.game.DP_FinishPuzzle_15_c22.dp_cell_22_,
		M.game.DP_FinishPuzzle_16_c23.dp_cell_23_,
		M.game.DP_FinishPuzzle_17_c24.dp_cell_24_,
			M.game.DP_FinishPuzzle_18_c30.dp_cell_30_,
			M.game.DP_FinishPuzzle_19_c31.dp_cell_31_,
			M.game.DP_FinishPuzzle_20_c32.dp_cell_32_,
			M.game.DP_FinishPuzzle_21_c33.dp_cell_33_,
			M.game.DP_FinishPuzzle_22_c34.dp_cell_34_)


func _process_fighting_trial(delta : float) -> void:
	if _fighting_trial_done:
		return
	if _player_node.is_dead():
		return
	
	var arena_rect = %FightingArenaRect.get_global_rect() as Rect2
	if arena_rect.has_point(_player_node.global_position) == false:
		_fcell_timer = 0.0
		return
	
	_fcell_timer += delta
	
	%FightDoorIn.close()
	
	var rel_pos = _player_node.position - arena_rect.position
	var cell_pos = Vector2i((rel_pos / 64.0).floor())
	
	# New cell position (or timer event)?
	if cell_pos != _last_fcell or _fcell_timer > 3.0:
		_fcell_timer = 0.0
		var damage_zone = _damage_area.instantiate() as Node2D
		damage_zone.position = Vector2(cell_pos * 64) + Vector2(32,32)
		%DamageAreas.add_child(damage_zone)
		_last_fcell = cell_pos
	
	# Check if all the enemies are dead.
	for enemy in %ArenaEnemies.get_children():
		if enemy is Enemy:
			if enemy.is_dead() == false:
				return
	_end_fighting_trial()


func _end_fighting_trial() -> void:
	if _fighting_trial_done:
		return
	_fighting_trial_done = true
	%FightDoorIn.open()
	%FightDoorOut.open()
	for enemy in %ArenaEnemies.get_children():
		enemy.queue_free()
	M.game.DP_FinishFightingTrial(0, _quest_server,
			M.game.DP_FinishFightingTrial_1_player.player_,
			M.game.DP_FinishFightingTrial_2_trials.dwelling_place_heart_trial_,
			M.game.DP_FinishFightingTrial_3_cur.dp_trial_fighting_,
			M.game.DP_FinishFightingTrial_4_next.dp_trials_done_)
	# Finish the heart trial.
	M.game.DP_FinishTrial(0, _quest_server,
			M.game.DP_FinishTrial_1_player.player_,
			M.game.DP_FinishTrial_2_trials.dwelling_place_heart_trial_,
			M.game.DP_FinishTrial_3_island.dwelling_place_heart_island_,
			M.game.DP_FinishTrial_4_done.dp_trials_done_)


func _on_trial_entrance_1_map_change_requested(
		_next_map: String, _spawn_point: String) -> void:
	M.game.MoveTo(0, _quest_server, 
			M.game.MoveTo_1_player.player_, 
			M.game.MoveTo_2_from.dwelling_place_heart_trial_,
			M.game.MoveTo_3_to.dwelling_place_)


func _on_puzzle_portal_area_teleported(spawn_point: String) -> void:
	teleport_to(spawn_point)
	for portal in _puzzle_portals.get_children():
		portal.queue_free()


func _on_puzzle_portal_area_start_teleporting(_spawn_point: String) -> void:
	_reset_puzzle()


func _on_dead() -> void:
	for portal in _puzzle_portals.get_children():
		portal.queue_free()
	_reset_puzzle()
	_reset_fighting_arena()


func _reset_puzzle() -> void:
	if _puzzle_trial_done:
		return
	M.game.DP_ResetPuzzle(0, _quest_server,
		M.game.DP_ResetPuzzle_1_c00.dp_cell_00_,
		M.game.DP_ResetPuzzle_2_c01.dp_cell_01_,
		M.game.DP_ResetPuzzle_3_c02.dp_cell_02_,
		M.game.DP_ResetPuzzle_4_c03.dp_cell_03_,
		M.game.DP_ResetPuzzle_5_c04.dp_cell_04_,
			M.game.DP_ResetPuzzle_6_c10.dp_cell_10_,
			M.game.DP_ResetPuzzle_7_c11.dp_cell_11_,
			M.game.DP_ResetPuzzle_8_c12.dp_cell_12_,
			M.game.DP_ResetPuzzle_9_c13.dp_cell_13_,
			M.game.DP_ResetPuzzle_10_c14.dp_cell_14_,
		M.game.DP_ResetPuzzle_11_c20.dp_cell_20_,
		M.game.DP_ResetPuzzle_12_c21.dp_cell_21_,
		M.game.DP_ResetPuzzle_13_c22.dp_cell_22_,
		M.game.DP_ResetPuzzle_14_c23.dp_cell_23_,
		M.game.DP_ResetPuzzle_15_c24.dp_cell_24_,
			M.game.DP_ResetPuzzle_16_c30.dp_cell_30_,
			M.game.DP_ResetPuzzle_17_c31.dp_cell_31_,
			M.game.DP_ResetPuzzle_18_c32.dp_cell_32_,
			M.game.DP_ResetPuzzle_19_c33.dp_cell_33_,
			M.game.DP_ResetPuzzle_20_c34.dp_cell_34_)


func _reset_fighting_arena():
	%FightDoorIn.open()
	for enemy in %ArenaEnemies.get_children():
		if enemy is Enemy:
			enemy.reset()


func _on_trial_entrance_2_map_change_requested(
		_next_map: String, _spawn_point: String) -> void:
	M.game.MoveTo(0, _quest_server, 
			M.game.MoveTo_1_player.player_, 
			M.game.MoveTo_2_from.dwelling_place_heart_trial_,
			M.game.MoveTo_3_to.dwelling_place_heart_island_)
