extends Area2D
## Portals teleport the player to a different location within the map.

# WARNING: ... Under construction ...


signal start_teleporting(spawn_point : String)
signal teleported(spawn_point : String)


## The name of the spawn point where the player should be teleported.
## Spawn point must be at the same map.
@export var spawn_point : String


func _on_portal_area_2d_body_entered(body: Node2D) -> void:
	if not visible:
		return
	var player = body as Player
	var wait_time_sec = player.start_teleporting(name, spawn_point)
	emit_signal("start_teleporting", spawn_point)
	await get_tree().create_timer(wait_time_sec * 0.65).timeout
	emit_signal("teleported", spawn_point)
