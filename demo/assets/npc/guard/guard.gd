extends NPC
## Royal guard NPC.

@export var initial_anim = "wait-down"


func _ready() -> void:
	$Sprite.play(initial_anim)
