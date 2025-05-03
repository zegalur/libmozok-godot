extends Node2D

func _on_portal_area_2d_body_entered(body: Node2D) -> void:
	if not visible:
		return
	var player = body as Player
	player.start_teleporting(name)
