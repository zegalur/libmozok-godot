## Hearts restore the player's health points.

class_name HeartItem
extends PickUpItem

@onready var _hidden = false

## Pick up the heart and restore the player's health point.
func pick_up(player : Player):
	if _hidden:
		return
	if player.is_max_hearts():
		return
	player.add_heart(1.0)
	queue_free()
	_hidden = true
