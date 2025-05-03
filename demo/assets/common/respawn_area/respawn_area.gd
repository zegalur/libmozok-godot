## Player's respawn area.
## The global position of the respawn area's origin sets the respawn point.

class_name RespawnArea
extends Area2D

func _on_player_body_entered(body):
	if body is Player == false:
		return
	(body as Player).set_respawn_point(global_position)
