extends Area2D


func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		body.take_hit(global_position, 1.0, 32.0, true, true)
