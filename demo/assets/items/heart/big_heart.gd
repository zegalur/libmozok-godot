class_name BigHeartItem
extends PickUpItem
## Big heart increases the maximum health points.

@onready var _picked_up = false
var key : String


func _ready() -> void:
	super()
	var parent = get_parent()
	while is_instance_valid(parent) and (parent is Map) == false:
		parent = parent.get_parent()
	if parent is Map:
		key = parent.map_name + "/" + name
	else:
		key = ""


func save_state(state : GameState) -> void:
	state.write(key, _picked_up)


func load_state(state : GameState) -> void:
	_picked_up = state.read(key, false)
	if _picked_up:
		hide_item()


## Pick up the heart and restore the player's health point.
func pick_up(player : Player):
	if _picked_up:
		return
	player.add_heart_cell()
	hide_item()
	_picked_up = true
	super(player)
