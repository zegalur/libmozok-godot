class_name SavePoint
extends StaticBody2D
## Save points are special usable objects that allow the player to save the game.

## Returns save point's spawn point name.
func get_spawn_point() -> String:
	return name + "/" + %SpawnPoint.name
