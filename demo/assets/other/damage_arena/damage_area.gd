extends Area2D
## Damages the player if they are inside the damage area during the damage stage.


func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		body.take_hit(global_position, 1.0, 32.0, true, true)
