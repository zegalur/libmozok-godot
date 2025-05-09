## The entry point of the game.

extends Node2D

const MAIN_QSF = "main.qsf.txt"
const TUTORIAL_MAP = "res://assets/maps/tutorial/tutorial.tscn"
const TUTORIAL_WORK_DIR = "res://quests/tutorials/"
const GAME_FIRST_MAP = "res://assets/maps/game/dwelling_place/dwelling_place.tscn"
const GAME_WORK_DIR = "res://quests/game/"
const START_SPAWN = "Start"
const EMPTY_FILE_SLOT = "[ empty ]"

@onready var _state : GameState = GameState.new()
@onready var _quest_server : LibMozokServer = %LibMozokServer
@onready var _gui : GameGUI = %GameGui
@onready var _player : Player = %Player
@onready var _maps : Node2D = %Maps
@onready var _mmenu = %MainMenu

var _current_map : Map
var _current_map_file : String
var _current_spawn_point : String
var _load_wnd = true
var _save_file_list : Array[String] = []


## Initialize the quest server, game map, and quest world.
func _ready():
	# Temporarily remove some nodes from the secene.
	remove_child(_player)
	$GUI.remove_child(_gui)
	
	# Set player camera offset.
	_player.set_camera_offset(Vector2(150.0, 0.0)) # 150, 50


## Process the in-game and quest related messages.
func _process(_delta):
	if Input.is_key_pressed(KEY_ESCAPE):
		get_tree().quit()
	
	# Process all quest server messages.
	while _quest_server.processNextMessage():
		check_server_status()
	check_server_status()


func check_server_status():
	if _quest_server.getServerStatus() != OK:
		printerr("Oops! Error had been occured:")
		printerr(_quest_server.getServerStatusDescription())
		get_tree().quit()


## Called when quest action error occurs.
func _on_lib_mozok_server_action_error(
		_worldName : String, 
		_actionName : String, 
		_actionArguments : PackedStringArray, 
		errorResult : String, 
		_actionError : int, 
		_data : int):
	printerr("Oops! Action error!")
	printerr("\tAction: " + _actionName + str(_actionArguments))
	printerr("\tResult: " + errorResult)


func _on_main_menu_exit() -> void:
	get_tree().quit()
	_player.queue_free()
	_gui.queue_free()


func _hide_main_menu() -> void:
	# Remove main menu and add in-game GUI. 
	$GUI.remove_child(_mmenu)
	$GUI.add_child(_gui)


func _load_game_qsf(working_dir : String, apply_init : bool) -> void:
	var main_qsf = FileAccess.open(
			working_dir + "main.qsf", FileAccess.READ)
	_quest_server.loadQuestScriptFile(
			working_dir, "main.qsf", 
			main_qsf.get_as_text(true), 
			apply_init)
	check_server_status()


func _create_game(working_dir : String, first_map : String) -> void:
	_hide_main_menu()
	_state.reset()
	_load_game_qsf(working_dir, true)
	
	# Start the worker thread.
	_quest_server.startWorkerThread()
	check_server_status()
	
	_load_map(first_map, START_SPAWN)


func _on_main_menu_tutorial() -> void:
	_create_game(TUTORIAL_WORK_DIR, TUTORIAL_MAP)


func _on_main_menu_new_game() -> void:
	_create_game(GAME_WORK_DIR, GAME_FIRST_MAP)


func _load_map(map_scene_file : String, spawn_point : String) -> void:
	# Create and setup the map.
	var map_scene = load(map_scene_file) as PackedScene
	if is_instance_valid(map_scene) == false:
		printerr("Can't load `%s` map scene." % map_scene_file)
	var map = map_scene.instantiate() as Map
	_current_map = map
	_current_map_file = map_scene_file
	_current_spawn_point = spawn_point
	map.connect("map_change_requested", _on_map_change_requested)
	if is_instance_valid(map) == false:
		printerr("Can't instantiate `%s` scene as `Map`." % map_scene_file)
	_maps.add_child(_current_map)
	map.setup(_quest_server, _player, spawn_point, _state)
	get_tree().call_group("SaveLoad", "load_state", _state)
	_gui.show_map_name(map.map_name)


func _on_map_change_requested(next_map : String, spawn_point : String) -> void:
	call_deferred("_change_map", next_map, spawn_point)


func _change_map(next_map : String, spawn_point : String) -> void:
	get_tree().call_group("SaveLoad", "save_state", _state)
	
	_player.global_position = Vector2.INF
	await get_tree().physics_frame
	_player.get_parent().remove_child(_player)
	
	_maps.remove_child(_current_map)
	_current_map.queue_free()
	_current_map = null
	_current_map_file = ""
	_current_spawn_point = START_SPAWN
	
	_load_map(next_map, spawn_point)


# =============================== SAVE / LOAD ================================ #

const SAVE_FILE_COUNT = 9
const SAVE_LOAD_CANCEL_INDX = SAVE_FILE_COUNT

const META_PRE = "meta/"
const META_DATE_TIME = META_PRE + "date_time"
const META_CUR_MAP_FILE = META_PRE + "current_map_file"
const META_CUR_MAP_NAME = META_PRE + "current_map_name"
const META_SPAWN_POINT = META_PRE + "spawn_point"


func _on_save_game(save_point : SavePoint) -> void:
	_load_wnd = false
	_current_spawn_point = save_point.get_spawn_point()
	_show_save_load("Save Game")


func _on_main_menu_load_game() -> void:
	_load_wnd = true
	_show_save_load("Load Game")


func _get_save_file_name(indx : int) -> String:
	return "user://savegame_" + str(indx + 1) + ".save"


func _show_save_load(title : String) -> void:
	var file_list : Array[String] = []
	for i in SAVE_FILE_COUNT:
		if FileAccess.file_exists(_get_save_file_name(i)) == false:
			file_list.push_back(EMPTY_FILE_SLOT)
			continue
		else:
			# Read the meta information.
			var tmp_state = GameState.new()
			tmp_state.load_from(_get_save_file_name(i), null)
			var datetime = tmp_state.read(
					META_DATE_TIME, "Unknown") as String
			var map_name = tmp_state.read(
					META_CUR_MAP_NAME, "Unknown")
			file_list.push_back(datetime.replace("T"," ") + " - " + map_name)
	_save_file_list = file_list.duplicate(true)
	file_list.push_back("Cancel")
	if _load_wnd:
		%MainMenu.deactivate()
	%SaveLoadGame.activate(title, file_list)


func _on_save_load_game_option_selected(indx: int) -> void:
	if _load_wnd:
		if indx == SAVE_LOAD_CANCEL_INDX:
			%MainMenu.call_deferred("activate")
			return
		if _save_file_list[indx] == EMPTY_FILE_SLOT:
			_show_save_load("Load Game")
			return
		_load_game(indx)
	else:
		if indx == SAVE_LOAD_CANCEL_INDX:
			return
		_save_game(indx)


func _save_game(indx : int) -> void:
	# Save current meta information.
	_state.write(META_DATE_TIME, Time.get_datetime_string_from_system())
	_state.write(META_CUR_MAP_FILE, _current_map_file)
	_state.write(META_CUR_MAP_NAME, _current_map.map_name)
	_state.write(META_SPAWN_POINT, _current_spawn_point)
	
	# TODO: add server.flush() to LibMozokServer public interface.
	
	# Process all the messages from the message queue.
	while _quest_server.processNextMessage():
		check_server_status()
	# Wait for worker thread to stop.
	while _quest_server.stopWorkerThread() == false:
		pass
	# Process all the messages until message queue and action queue is fully empty.
	while _quest_server.processNextMessage():
		while _quest_server.processNextMessage():
			check_server_status()
		if _quest_server.startWorkerThread() != OK:
			printerr("Can't start worker therad to process the secondary actions.")
			get_tree().quit()
		while _quest_server.stopWorkerThread() == false:
			pass
	check_server_status()
	
	# Save game state.
	var save_file = _get_save_file_name(indx)
	get_tree().call_group("SaveLoad", "save_state", _state)
	if _state.save_to(save_file, _quest_server) == false:
		printerr("Can't save the game. See the prev. error messages.")
		get_tree().quit()
	
	if _quest_server.startWorkerThread() != OK:
		printerr("Can't restart worker therad after saving.")
		get_tree().quit()


func _load_game(indx : int) -> void:
	_hide_main_menu()
	_load_game_qsf(GAME_WORK_DIR, false)
	
	# Read the game state.
	var save_file = _get_save_file_name(indx)
	if _state.load_from(save_file, _quest_server) == false:
		printerr("Can't load the game. See the prev. error messages.")
		get_tree().quit()
	
	# Start the worker thread.
	_quest_server.startWorkerThread()
	check_server_status()
	
	# Load the map.
	var map_file = _state.read(META_CUR_MAP_FILE, "")
	var spawn_point = _state.read(META_SPAWN_POINT, "")
	_load_map(map_file, spawn_point)


func _on_lib_mozok_server_search_limit_reached(
		worldName: String, questName: String, searchLimitValue: int) -> void:
	printerr("Search limit reached: [%s] %s %s" % [
			worldName, questName, str(searchLimitValue)])


func _on_lib_mozok_server_space_limit_reached(
		worldName: String, questName: String, spaceLimitValue: int) -> void:
	printerr("Space limit reached: [%s] %s %s" % [
			worldName, questName, str(spaceLimitValue)])
