class_name MapChange
extends Node2D
## A map change node that can emit `map_change_requested` received by the map.

## Emitted when the player initiated a `MapChange`.
signal map_change_requested(next_map : String, spawn_point : String)


func request_map_change(next_map_scene : String, spawn_point : String):
	emit_signal("map_change_requested", next_map_scene, spawn_point)
