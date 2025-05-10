class_name GameState
extends RefCounted
## Contains all (non-quest) information needed to save/load the game state.

const SERVER_LOAD_ACTIONS_KEY = "server_load_actions"
const LOAD_ACTION_NAME = "Load"

var _state : Dictionary


## Fully resets the game state.
func reset() -> void:
	_state = {}


## Writes or overwrites a value in the state by key.
func write(key : String, value : Variant) -> void:
	_state[key] = value


## Reads the value, or returns the default value if the key is absent.
func read(key : String, default : Variant) -> Variant:
	if _state.has(key):
		return _state[key]
	return default


## Saves the current state into a file.
## Returns `true` when saving was successful.
func save_to(file_name : String, server : LibMozokServer) -> bool:
	var state_copy = _state.duplicate(true)
	
	# Save LibMozok state.
	var server_save_data : Dictionary[String, String] = {}
	for worldName in server.getWorlds():
		server_save_data[worldName] = server.generateSaveFile(worldName)
		if server_save_data[worldName].begins_with("error:"):
			printerr("Can't generate save file for `" + worldName + "` quest world.")
			printerr("Error message:")
			printerr(server_save_data[worldName])
			return false
	state_copy[SERVER_LOAD_ACTIONS_KEY] = server_save_data
	
	# Write as JSON.
	var file = FileAccess.open(file_name, FileAccess.WRITE)
	if file == null:
		printerr("Can't open file `" + file_name + "` to save the game.")
		return false
	var json_str = JSON.stringify(state_copy)
	if file.store_line(json_str) == false:
		printerr("Can't write into `" + file_name + "`.")
		file.close()
		return false
	file.close()
	
	return true


## Loads the current state from the file.
## `server` can be set to `null`.
func load_from(file_name : String, server : LibMozokServer) -> bool:
	# Read the file.
	var file = FileAccess.open(file_name, FileAccess.READ)
	if file == null:
		printerr("Can't open file `" + file_name + "` to load the game.")
		return false
	var state_json = file.get_as_text()
	file.close()
	
	# Parse JSON content.
	var new_state = JSON.parse_string(state_json)
	if new_state == null:
		printerr("Can't parse the save file `" + file_name + "` JSON.")
		printerr("JSON:\n" + state_json)
		return false
	
	_state = new_state
	
	# Load quest server state.
	if server != null:
		var server_load_actions = _state[
				SERVER_LOAD_ACTIONS_KEY] as Dictionary[String, String]
		for worldName in server_load_actions.keys():
			server.addProject(
					worldName, 
					worldName + "(load)", 
					server_load_actions[worldName])
			server.pushAction(worldName, LOAD_ACTION_NAME, [], 0)
	
	return true
