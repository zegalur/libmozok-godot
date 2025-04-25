## The entry point of the game.

extends Node2D

@onready var _quest_server : LibMozokServer = get_node("LibMozokServer")
@onready var _map : Map = get_node("Map").get_child(0)
@onready var _gui : GameGUI = get_node("GameGui")
@onready var _player : Player = get_node("Player")

## Initialize the quest server, game map, and quest world.
func _ready():
	# Set player camera offset.
	_player.set_camera_offset(Vector2(150.0, 0.0)) # 150, 50
	
	# Setup the map.
	_map.setup(_quest_server, _player)
	
	# Load the main QSF.
	var main_qsf = FileAccess.open(
			"res://assets/quests/main.qsf.txt", FileAccess.READ)
	_quest_server.loadQuestScriptFile(
			"res://assets/quests/", "main.qsf.txt", 
			main_qsf.get_as_text(true), true)
	
	# Start the worker thread.
	_quest_server.startWorkerThread()
	
	check_server_status()


## Process the in-game and quest related messages.
func _process(_delta):
	if Input.is_key_pressed(KEY_ESCAPE):
		get_tree().quit()
	
	# Process all quest server messages.
	while _quest_server.processNextMessage():
		pass
	check_server_status()
	
	# Update GUI position
	var gui_glob_pos = _player.get_screen_center_position() - _gui.size * 0.5
	# Round to integers to remove the "jiggling"
	gui_glob_pos.x = floor(gui_glob_pos.x)
	gui_glob_pos.y = floor(gui_glob_pos.y)
	_gui.position = gui_glob_pos


func check_server_status():
	if _quest_server.getServerStatus() != OK:
		printerr("Oops! Error had been occured:")
		printerr(_quest_server.getServerStatusDescription())
		get_tree().quit()


## Called when quest action error occurs.
func _on_lib_mozok_server_action_error(
		_worldName, _actionName, _actionArguments, errorResult, _actionError):
	printerr("Oops! Action error! " + errorResult)
