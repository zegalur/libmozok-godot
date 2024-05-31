## Big heart increases the maximum health points.

class_name BigHeartItem
extends PickUpItem

@onready var _hidden = false

## Pick up the heart and restore the player's health point.
func pick_up(player : Player):
	if _hidden:
		return
	player.add_heart_cell()
	queue_free()
	_hidden = true
