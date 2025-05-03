extends Node2D
## Portals teleport the player to a different location within the map.

# WARNING: ... Under construction ...

func _on_portal_area_2d_body_entered(body: Node2D) -> void:
	if not visible:
		return
	var player = body as Player
	player.start_teleporting(name)
