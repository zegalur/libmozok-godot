class_name MapChange
extends Area2D
## A map change area that emits `map_change_requested` when the player steps into it.

## Emitted when the player steps into a `MapChange` area.
signal map_change_requested(next_map : String, spawn_point : String)

## The path to the map `.tscn` file.
@export_file("*.tscn") var next_map_scene : String

## The name of the spawn point where the player will be spawned.
@export var spawn_point : String


func _on_body_entered(_body: Node2D) -> void:
	emit_signal("map_change_requested", next_map_scene, spawn_point)
