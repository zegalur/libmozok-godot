extends Area2D
## Changes the map when player steps into.

## Emitted when the player steps into `MapChangeArea` and initiates a map change.
signal map_change_requested(next_map : String, spawn_point : String)

## The path to the map `.tscn` file.
@export_file("*.tscn") var next_map_scene : String

## The name of the spawn point where the player will be spawned.
@export var spawn_point : String = "Start"


func _on_body_entered(_body: Node2D) -> void:
	$MapChange.request_map_change(next_map_scene, spawn_point)


func _on_map_change_map_change_requested(
		next_map: String, spawn_point_name: String) -> void:
	emit_signal("map_change_requested", next_map, spawn_point_name)
