## In-game map. Defines the place and the rules of the game.

class_name Map
extends Node2D

signal map_change_requested(next_map : String, spawn_point, String)

var _player_node : Player
var _quest_server : LibMozokServer

# Sets where player node will be placed by the `setup()`.
@export var player_node_dest : NodePath

# If not empty, sets the `Control` node that will be used 
# to set up the camera limits.
@export var camera_limits : NodePath

# Map name (briefly displayed at the top of the screen)
@export var map_name : String

func _ready():
	var map_change_nodes = find_children("*", "MapChange")
	for node in map_change_nodes:
		if node is MapChange:
			node.connect("map_change_requested", _on_map_change_requested)

func setup(
		server : LibMozokServer, 
		player : Player, 
		spawn_point : String,
		_state : GameState
		) -> void:
	_quest_server = server
	_player_node = player
	
	# Put the player inside the player destination node.
	var player_dest_node = find_child(player_node_dest)
	if player_dest_node == null:
		printerr("Can't find player destination node `%s`" % player_node_dest)
	player_dest_node.add_child(player)
	
	var start_points : Array[Node] = [] 
	if spawn_point.contains("/"):
		var parent_name = spawn_point.substr(0, spawn_point.find("/"))
		var sp_name = spawn_point.substr(spawn_point.find("/") + 1)
		var parent_node = find_child(parent_name)
		if is_instance_valid(parent_node):
			start_points = parent_node.find_children(sp_name, "SpawnPoint")
	else:
		start_points = find_children(spawn_point, "SpawnPoint")
	if start_points.size() > 0:
		player.global_position = start_points[0].global_position
	else:
		printerr("Can't find spawn point `%s`" % spawn_point)
	
	# Setup the camera limits.
	if camera_limits.is_empty():
		player.set_camera_limits()
	else:
		var limits = find_child(camera_limits) as Control
		if limits == null:
			player.set_camera_limits()
		else:
			player.set_camera_limits(limits.get_global_rect())
	
	var children = find_children("*", "Enemy")
	for node in children:
		var enemy = node as Enemy
		enemy.set_player(_player_node)

func _on_map_change_requested(next_map : String, spawn_point : String):
	emit_signal("map_change_requested", next_map, spawn_point)
