extends Map
## The player's home and the starting location of the game.


# ----------------------------------- State ---------------------------------- #

const STATE_PRE = "dwelling_place/"
var talked_to_the_guard : bool

func save_state(state : GameState):
	state.write(STATE_PRE + "talked_to_the_guard", talked_to_the_guard)

func load_state(state : GameState):
	talked_to_the_guard = state.read(STATE_PRE + "talked_to_the_guard", false)


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
