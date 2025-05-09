extends Map
## Forest location

# WARNING: Work In Progress !


func _on_dwelling_place_entrance_map_change_requested(
		_next_map: String, _spawn_point: String) -> void:
	M.game.MoveTo(0, _quest_server,
			M.game.MoveTo_1_player.player_,
			M.game.MoveTo_2_from.forest_,
			M.game.MoveTo_3_to.dwelling_place_)
