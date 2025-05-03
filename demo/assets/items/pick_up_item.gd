## Items that can be be picked up.

class_name PickUpItem
extends Area2D

signal picked_up()

func _ready():
	collision_layer = 32 # PickUp Item
	collision_mask = 0

## Pick up function. Called when item is inside the pick up zone.
## Override this function to make a custom pickup function.
func pick_up(_player : Player):
	emit_signal("picked_up")

## Hides the item and disables the collission.
func hide_item():
	collision_layer = 0
	hide()
