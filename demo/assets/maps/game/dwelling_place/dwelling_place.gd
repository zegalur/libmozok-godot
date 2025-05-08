extends Map
## The player's home and the starting location of the game.

const HEART_CAVE_PASSWORD = ["RRR", "YYY", "BBB"]
const CHICKEN_COLORS = "YRBYRBYRB"

@onready var _chickens = %Chickens.get_children()
@onready var _chicken_color_points : Array[TextureRect] = [
	%C1, %C2, %C3, %C4, %C5, %C6, %C7, %C8, %C9]
	
@onready var _chicken_qobjs : Array[int] = [
	M.game.DP_DriveInto_1_chicken.dp_chicken_1_,
	M.game.DP_DriveInto_1_chicken.dp_chicken_2_,
	M.game.DP_DriveInto_1_chicken.dp_chicken_3_,
	M.game.DP_DriveInto_1_chicken.dp_chicken_4_,
	M.game.DP_DriveInto_1_chicken.dp_chicken_5_,
	M.game.DP_DriveInto_1_chicken.dp_chicken_6_,
	M.game.DP_DriveInto_1_chicken.dp_chicken_7_,
	M.game.DP_DriveInto_1_chicken.dp_chicken_8_,
	M.game.DP_DriveInto_1_chicken.dp_chicken_9_,
]
@onready var _narea_qobjs : Array[int] = [
	M.game.DP_DriveInto_2_area.dp_num_area_1_,
	M.game.DP_DriveInto_2_area.dp_num_area_2_,
	M.game.DP_DriveInto_2_area.dp_num_area_3_,
]

var _numbers_state : Array[String] = ["", "", ""]
var _abc_state : String = ""

# ----------------------------------- State ---------------------------------- #

const STATE_PRE = "dwelling_place/"
var talked_to_the_guard : bool
var heart_cave_sign_read : bool
var heart_cave_opened : bool
var secret_cave_opened : bool

func save_state(state : GameState):
	state.write(STATE_PRE + "talked_to_the_guard", talked_to_the_guard)
	state.write(STATE_PRE + "heart_cave_sign_read", heart_cave_sign_read)
	state.write(STATE_PRE + "heart_cave_opened", heart_cave_opened)
	state.write(STATE_PRE + "secret_cave_opened", secret_cave_opened)

func load_state(state : GameState):
	talked_to_the_guard = state.read(STATE_PRE + "talked_to_the_guard", false)
	heart_cave_sign_read = state.read(STATE_PRE + "heart_cave_sign_read", false)
	heart_cave_opened = state.read(STATE_PRE + "heart_cave_opened", false)
	secret_cave_opened = state.read(STATE_PRE + "secret_cave_opened", false)
	if heart_cave_opened:
		_remove_cave_rock(%HeartTrialCaveRock)
	if secret_cave_opened:
		_remove_cave_rock(%SecretCaveRock)
	M.game.DP_ResetChickenPinball(0, _quest_server)

# ----------------------------------- Main ----------------------------------- #

func _physics_process(delta: float) -> void:
	_chicken_pinball(delta)


# ------------------------------ Chicken Pinball ----------------------------- #

func _chicken_pinball(_delta: float) -> void:
	# Count the chickens inside the 1,2,3 areas.
	var rects : Dictionary[Control, int] = {
		%ChickenArea_1 : 0, 
		%ChickenArea_2_1 : 1, 
		%ChickenArea_2_2 : 1,
		%ChickenArea_3 : 2
		}
	var tabs : Array[HBoxContainer] = [
		%CurrentColors_1,
		%CurrentColors_2,
		%CurrentColors_3,
		]
	var cur_state_123 : Array[String] = ["", "", ""]
	for i in _chickens.size():
		var chicken = _chickens[i] as CharacterBody2D
		if is_instance_valid(chicken) == false:
			continue
		var hidden = true
		for rect in rects.keys():
			if rect.get_global_rect().has_point(chicken.global_position):
				cur_state_123[rects[rect]] += CHICKEN_COLORS[i]
				hidden = false
				if _chicken_color_points[i].get_parent() != tabs[rects[rect]]:
					_chicken_color_points[i].reparent(tabs[rects[rect]])
					var other = [0,1,2]
					other.erase(rects[rect])
					M.game.DP_DriveInto(0, _quest_server, 
							_chicken_qobjs[i], 
							_narea_qobjs[rects[rect]],
							_narea_qobjs[other[0]],
							_narea_qobjs[other[1]])
				break
		if hidden:
			if _chicken_color_points[i].get_parent() != %HiddenColors:
				_chicken_color_points[i].reparent(%HiddenColors)
				M.game.DP_DriveOut(0, _quest_server,
						_chicken_qobjs[i], 
						_narea_qobjs[0], 
						_narea_qobjs[1], 
						_narea_qobjs[2])
	
	# New 123-state?
	if cur_state_123 != _numbers_state:
		_numbers_state = cur_state_123
		if HEART_CAVE_PASSWORD == _numbers_state:
			if heart_cave_opened == false:
				heart_cave_opened = true
				_remove_cave_rock(%HeartTrialCaveRock)
				M.game.DP_OpenHeartTrialCave_GLOBAL(0, _quest_server)


func _remove_cave_rock(node : Node2D) -> void:
	var dust = node.get_child(0) as GPUParticles2D
	var body = node.get_child(1) as StaticBody2D
	var sprite = node.get_child(2) as Sprite2D
	dust.emitting = true
	await get_tree().create_timer(1.0).timeout
	body.queue_free()
	sprite.queue_free()

# ----------------------------------- Other ---------------------------------- #

func _on_guard_intro_activated() -> void:
	if talked_to_the_guard:
		return
	talked_to_the_guard = true
	M.game.TalkTo(0, _quest_server, 
			M.game.TalkTo_1_place.dwelling_place_,
			M.game.TalkTo_2_player.player_,
			M.game.TalkTo_3_npc.guard_philip_)
	M.game.GetFactFrom(0, _quest_server,
			M.game.GetFactFrom_1_place.dwelling_place_,
			M.game.GetFactFrom_2_player.player_,
			M.game.GetFactFrom_3_npc.guard_philip_,
			M.game.GetFactFrom_4_fact.king_is_waiting_)


func _on_forest_entry_map_change_requested(
		_next_map: String, _spawn_point: String) -> void:
	# TODO: change to forest
	M.game.MoveTo(0, _quest_server, 
			M.game.MoveTo_1_player.player_, 
			M.game.MoveTo_2_from.dwelling_place_,
			M.game.MoveTo_3_to.forest_)


func _on_trial_entrance_map_change_requested(
		_next_map: String, _spawn_point: String) -> void:
	M.game.MoveTo(0, _quest_server, 
			M.game.MoveTo_1_player.player_, 
			M.game.MoveTo_2_from.dwelling_place_,
			M.game.MoveTo_3_to.dwelling_place_heart_trial_)


func _on_big_heart_picked_up() -> void:
	# Take the dwelling place heart.
	M.game.TakeBigHeart(0, _quest_server, 
			M.game.TakeBigHeart_1_player.player_,
			M.game.TakeBigHeart_2_big_heart.big_heart_dwelling_place_,
			M.game.TakeBigHeart_3_location.dwelling_place_heart_island_
			)


func _on_trial_entrance_2_map_change_requested(
		_next_map: String, _spawn_point: String) -> void:
	M.game.MoveTo(0, _quest_server, 
			M.game.MoveTo_1_player.player_, 
			M.game.MoveTo_2_from.dwelling_place_heart_island_,
			M.game.MoveTo_3_to.dwelling_place_heart_trial_)


func _on_chicken_portal_teleported(spawn_point: String) -> void:
	teleport_to(spawn_point)


func _on_heart_cave_password_signpost_activated() -> void:
	if heart_cave_sign_read:
		return
	heart_cave_sign_read = true
	M.game.Inform(0, _quest_server,
			M.game.Inform_1_who.player_,
			M.game.Inform_2_what.dp_heart_trial_cave_blocked_)
