class_name TutorialMap
extends Map
## Tutorial demo level.

# The name of the tutorial quest world.
const W_TUT = "tut"

# Tutorials
var _controls_tutorial : ControlsTutorial
var _fighting_tutorial : FightingTutorial
var _key_tutorial : KeyTutorial
var _puzzle_tutorial : PuzzleTutorial

# Portal Tutorial
@onready var _portal = $"Env/Puzzle Island/PortalArea"


func setup(
		server : LibMozokServer, 
		player : Player,
		spawn_point : String,
		state : GameState
		) -> void:
	super(server, player, spawn_point, state)
	
	_quest_server.connect("new_sub_quest", _on_new_subquest)
	
	# Controls tutorial
	var controls_tut_door = $"Env/Initial Island/ControlsTutDoor"
	_controls_tutorial = ControlsTutorial.new(server, W_TUT, player)
	_controls_tutorial.connect("done", controls_tut_door.open)
	
	# Fighting tutorial
	var fighting_tut_enemy = $"Env/Flying Island/Objects/FightingTutEnemy"
	var fighting_tut_door = $"Env/Flying Island/TileLayer/FightingTutDoor"
	_fighting_tutorial = FightingTutorial.new(server, W_TUT, player, fighting_tut_enemy)
	_fighting_tutorial.connect("done", fighting_tut_door.open)
	
	# Key Tutorial
	_key_tutorial = KeyTutorial.new(server, W_TUT, player)
	
	# Puzzle tutorial
	_puzzle_tutorial = PuzzleTutorial.new(server, W_TUT, player, self)
	
	# Teleport tutorial
	player.connect("teleport", _on_teleport)


func _process(_delta):
	_controls_tutorial.process_tutorial(_delta)
	_puzzle_tutorial.process_tutorial(_delta)


## React to new subquest event.
func _on_new_subquest(
		_worldName : String, 
		questName : String, 
		_parentQuestName : String,
		_goal : int ):
	if(questName == "PortalTutorial"):
		_portal.show()


func _on_teleport(_teleport_name: String) -> void:
	_portal.hide()
	T.tut.MoveToPortal(0, _quest_server, 
			T.tut.MoveToPortal_1_entrance_cell.pt_cell_33,
			T.tut.MoveToPortal_2_tutorial.portalTutorial)
