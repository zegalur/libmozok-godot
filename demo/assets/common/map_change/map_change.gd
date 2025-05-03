class_name MapChange
extends Area2D

signal map_change_requested(next_map : String, spawn_point : String)

@export_file("*.tscn") var next_map_scene : String
@export var spawn_point : String

func _on_body_entered(_body: Node2D) -> void:
	emit_signal("map_change_requested", next_map_scene, spawn_point)
