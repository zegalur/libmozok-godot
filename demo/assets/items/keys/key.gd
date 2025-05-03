class_name Key
extends PickUpItem
## Keys are used to open closed doors.

## Key type.
enum KeyType {
	## Dungeon key - opens a normal dungeon door.
	DUNGEON_KEY,
	}
	
@export var key_type = KeyType.DUNGEON_KEY
@onready var _hidden = false


## Pick up the key and add it to the inventary.
func pick_up(player : Player):
	if _hidden:
		return
	player.add_key(key_type)
	queue_free()
	_hidden = true
