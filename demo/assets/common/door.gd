class_name Door
extends StaticBody2D
## Door that can be opened by a key.

## Is this door can be opened by a key.
@export var open_by_key = true

## The type of key needed to open this door.
@export var key_type : Key.KeyType = Key.KeyType.DUNGEON_KEY

## Animated sprite for the door.
@export var animated_sprite : AnimatedSprite2D

var _inititial_collision_layer : int
var _opened = false


func _ready():
	collision_layer = 1 + 64 # Map & UsableObj
	collision_mask = 0
	_inititial_collision_layer = collision_layer


## Opens the door.
func open():
	if _opened:
		return
	collision_layer = 0
	animated_sprite.play("open")
	_opened = true


## Closes the door.
func close():
	if not _opened:
		return
	collision_layer = _inititial_collision_layer
	animated_sprite.play("close")
	_opened = false
