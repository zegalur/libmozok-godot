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
	_map.set_player(_player)
	_map.set_server(_quest_server)
	
	# Create a quest world with the map name.
	_quest_server.createWorld(_map.name)
	
	# Add map quest projects to the quest server.
	for proj_file in _map.quest_file_paths:
		var map_project_file = FileAccess.open(proj_file, FileAccess.READ)
		var project_str = map_project_file.get_as_text()
		_quest_server.addProject(_map.name, proj_file.get_file(), project_str)
	
	# Push init actions.
	for init_action in _map.init_actions:
		_quest_server.pushAction(_map.name, init_action, [])
	
	# Start the worker thread.
	_quest_server.startWorkerThread()
	
	# Check the server status.
	if _quest_server.getServerStatus() != OK:
		printerr("Oops! Error had been occured during the server initialization:")
		printerr(_quest_server.getServerStatusDescription())
		get_tree().quit()


## Process the in-game and quest related messages.
func _process(_delta):
	if Input.is_key_pressed(KEY_ESCAPE):
		get_tree().quit()
	
	# Process all quest server messages.
	while _quest_server.processNextMessage():
		pass
	
	# Update GUI position
	var gui_glob_pos = _player.get_screen_center_position() - _gui.size * 0.5
	# Round to integers to remove the "jiggling"
	gui_glob_pos.x = floor(gui_glob_pos.x)
	gui_glob_pos.y = floor(gui_glob_pos.y)
	_gui.position = gui_glob_pos


## Called when quest action error occurs.
func _on_lib_mozok_server_action_error(
		_worldName, _actionName, _actionArguments, errorResult):
	printerr("Oops! Action error! " + errorResult)
