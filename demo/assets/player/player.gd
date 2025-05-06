class_name Player
extends CharacterBody2D
## Playable character.

signal dead()
signal hearts_changed(hearts : int, max_hearts : int)
signal keys_changed(keys : Array)
signal key_used(keyType : Key.KeyType)
signal use_action()
signal hit_taken(from : Vector2, damage : float)
signal hit_blocked(from : Vector2)
signal hearts_added(count : int)
signal big_heart_taken()
signal teleport(teleport_name : String)
signal dialogue_started(npc : NPC, dnode : DialogueNode)
signal save_game(save_point : SavePoint)

@onready var animated_sprite: AnimatedSprite2D = get_node("AnimatedSprite2D")
@onready var _camera = $Camera2D as Camera2D

const KEY_PRE = "player/"

## Player's normal walking/running speed (in pixels per second).
const RUN_SPEED = 220.0

## Player's speed while hiding behind the shield (in pixels per second).
const HIDE_SPEED = 110.0


## Player's animated sprite normal animation speed.
const ANIM_SPEED = 1.5

## Player's animated sprite speed while hiding behind the shield.
const HIDE_ANIM_SPEED = 1.0

## Movement with velocity less than this value are considered non-moving.
const VELOCITY_EPS = 0.01


# Controls the push from the enemy kick.
var _kick_force_vec = Vector2.ZERO
const KICK_FORCE = 300.0
const FORCE_DUR = 0.3

# Controls the health points.
const INITIAL_HEARTS = 3.0
var _hearts : float
var _max_hearts : float

# Controls the player's death and respawn.
var _dead_timer = 0.0
const RESPAWN_TIME = 3.0

# Controls teleportation animation.
var _teleport_timer = 0.0
var TELEPORT_TIME = 1.5
var _teleport_name : String

## Damage State - the player is invincible while damaged.
enum DamageState {
	NORMAL, ## Not damaged.
	DAMAGED, ## Temporarily invincible after taking damage.
}
var _damage_state = DamageState.NORMAL
var _damage_state_timer = 0.0
const DAMAGED_DURATION = 1.0


# General State
enum PlayerState {
	WAIT,
	WALK,
	HIDE,
	ATTACK,
	DEAD,
	TELEPORT,
	BUSY, # talking, shopping, etc.
}

# Player can't use surrounding objects in these states.
const INACTIVE_STATES = [PlayerState.BUSY, PlayerState.DEAD]

enum PlayerDir {
	LEFT,
	RIGHT,
	UP,
	DOWN
}
var _game_state : GameState
var _state = PlayerState.WAIT
var _last_direction : PlayerDir = PlayerDir.DOWN
var _last_move_vec : Vector2 = Vector2.ZERO
var _respawn_point : Vector2
var _keys = []


# Use area logic
var _usable_bodies : Array[Node2D]
var _usable_body_indx : int = 0


func _ready():
	_respawn_point = global_position


func save_state(state : GameState) -> void:
	state.write(KEY_PRE + "_hearts", _hearts)
	state.write(KEY_PRE + "_max_hearts", _max_hearts)
	_game_state = state


func load_state(state : GameState) -> void:
	_game_state = state
	_hearts = state.read(KEY_PRE + "_hearts", INITIAL_HEARTS)
	_max_hearts = state.read(KEY_PRE + "_max_hearts", INITIAL_HEARTS)
	_update_hearts()


## Converts a unit Vector2 to direction strings "up", left", "right" and "down".
func _to_dir(dir : Vector2) -> PlayerDir:
	dir *= -10.0
	const EPS = 0.01
	if dir.x >= EPS and abs(dir.x) + EPS > abs(dir.y):
		return PlayerDir.LEFT
	if dir.x <= -EPS and abs(dir.x) + EPS > abs(dir.y):
		return PlayerDir.RIGHT
	if dir.y >= EPS and abs(dir.y) > abs(dir.x):
		return PlayerDir.UP
	return PlayerDir.DOWN


func _dir_to_str(dir : PlayerDir) -> String:
	if dir == PlayerDir.UP:
		return "up"
	elif dir == PlayerDir.DOWN:
		return "down"
	elif dir == PlayerDir.LEFT:
		return "left"
	elif dir == PlayerDir.RIGHT:
		return "right"
	return "unknown"


## Take a hit from the given point and with the given damage.
## If `square` - uses the manhattan distance.
func take_hit(
		from : Vector2, 
		damage : float, 
		impact_radius : float = 27.0, 
		square : bool = false,
		ignore_shield : bool = false
		):
	if _damage_state == DamageState.DAMAGED:
		return # player is invincible in the damaged state
	var l = (global_position - from).length()
	if square:
		var m = (global_position - from).abs()
		l = max(m.x, m.y)
	if l > impact_radius:
		return # miss
	_kick_force_vec = (global_position - from).normalized()
	
	if not ignore_shield:
		if _state == PlayerState.HIDE:
			if _to_dir(-_kick_force_vec) == _last_direction:
				emit_signal("hit_blocked", from)
				return
	
	_damage_state_timer = 0.0
	_damage_state = DamageState.DAMAGED
	_hearts = max(0.0, _hearts - damage)
	emit_signal("hit_taken", from, damage)
	
	# pick up hearts from the nearby area
	for area in $PickUpArea.get_overlapping_areas():
		var node = area.get_parent()
		if node is PickUpItem:
			node.pick_up(self)
	
	_update_hearts()
	
	if _hearts == 0.0:
		_dead()


## Returns `true` if player is dead. 
## Returns false` if player is alive. 
func is_dead() -> bool:
	return _state == PlayerState.DEAD


## Adds health points.
func add_heart(count : float):
	var _was = _hearts
	_hearts = min(_max_hearts, _hearts + count)
	_update_hearts()
	emit_signal("hearts_added", _hearts - _was)


## Add new heart cell.
func add_heart_cell():
	_max_hearts += 1
	_hearts = _max_hearts
	_update_hearts()
	emit_signal("big_heart_taken")


## Returns `true` if health points are at maximum.
func is_max_hearts() -> bool:
	return _hearts == _max_hearts


## Adds a key to the inventory.
func add_key(key_type : Key.KeyType):
	_keys.push_back(key_type)
	emit_signal("keys_changed", _keys)


func get_screen_center_position() -> Vector2:
	return $Camera2D.get_screen_center_position()


func get_player_direction() -> PlayerDir:
	return _last_direction


func get_player_state() -> PlayerState:
	return _state


func set_camera_offset(offset : Vector2):
	$Camera2D.offset = offset


func set_respawn_point(global_pos : Vector2):
	_respawn_point = global_pos


func is_player_waiting() -> bool:
	return animated_sprite.is_playing() == false


func set_camera_limits(
		limit = Rect2(-10000000,-10000000,20000000,20000000)
		) -> void:
	_camera.limit_left = limit.position.x - _camera.offset.x
	_camera.limit_top = limit.position.y - _camera.offset.y
	_camera.limit_right = limit.end.x + _camera.offset.x
	_camera.limit_bottom = limit.end.y - _camera.offset.y
	_camera.drag_horizontal_offset = 0
	_camera.drag_vertical_offset = 0


## Returns the time needed to play the teleportation animation (in seconds).
func start_teleporting(teleport_name : String, spawn_point : String) -> float:
	_teleport_name = teleport_name
	_teleport_timer = 0.0
	_state = PlayerState.TELEPORT
	animated_sprite.play("rotating")
	return TELEPORT_TIME


func start_dialogue(npc : NPC, dnode : DialogueNode) -> void:
	if _state in [PlayerState.DEAD, PlayerState.TELEPORT, PlayerState.BUSY]:
		return
	_state = PlayerState.BUSY
	emit_signal("dialogue_started", npc, dnode)


func end_dialogue() -> void:
	_state = PlayerState.WAIT
	Input.action_release("menu_select")
	Input.action_release("use")


func _process(_delta: float) -> void:
	if _usable_bodies.size() == 0:
		%UsableObjCursor.hide()
	else:
		%UsableObjCursor.show()
		var uobj = _usable_bodies[_usable_body_indx]
		var cursor_pos_obj = uobj.find_child("CursorPos", false) as Node2D
		if cursor_pos_obj:
			uobj = cursor_pos_obj
		%UsableObjCursor.global_position = uobj.global_position


func _input(event: InputEvent) -> void:
	if event.is_action("select_next"):
		if _usable_bodies.size() > 0:
			_usable_body_indx = (_usable_body_indx + 1) % _usable_bodies.size()


func _physics_process(delta):
	const EPS = 0.001
	var direction_X = Input.get_axis("move_left", "move_right")
	var direction_Y = Input.get_axis("move_up", "move_down")
	var d = Vector2(direction_X, direction_Y)
	var dir = d.normalized() if d.length() > EPS else Vector2.ZERO
	_last_move_vec = dir
	
	_process_actions(delta)
	
	var l = _kick_force_vec.length()
	if l > EPS:
		_kick_force_vec -= _kick_force_vec.normalized() * min(1, delta / FORCE_DUR)
	else:
		_kick_force_vec = Vector2.ZERO
	
	var speed = 0.0
	if _state == PlayerState.HIDE:
		speed = HIDE_SPEED
	elif  _state == PlayerState.WALK:
		speed = RUN_SPEED
	var move_vec = dir * speed
	
	if _state in [PlayerState.WALK, PlayerState.ATTACK]:
		if dir.length() > VELOCITY_EPS:
			_last_direction = _to_dir(dir)
	
	velocity = move_vec + _kick_force_vec * KICK_FORCE
	move_and_slide()


func _process_actions(delta):
	const EPS = 0.001
	
	if _damage_state == DamageState.NORMAL:
		animated_sprite.modulate = Color.WHITE
	elif _damage_state == DamageState.DAMAGED:
		_damage_state_timer += delta
		animated_sprite.modulate = Color(1.0, 1.0, 1.0, 
				0.5 * abs(cos(_damage_state_timer/DAMAGED_DURATION * 15.0)))
		if _damage_state_timer >= DAMAGED_DURATION:
			_damage_state = DamageState.NORMAL
	
	if _state in [PlayerState.WAIT, PlayerState.WALK, PlayerState.HIDE]:
		if Input.is_action_pressed("hide"):
			_state = PlayerState.HIDE
		elif _last_move_vec.length() > EPS:
			_state = PlayerState.WALK
		else:
			_state = PlayerState.WAIT
	
	animated_sprite.scale.x = 1.0
	
	var dir_str = _dir_to_str(_last_direction)
	var walk_anim = "run-" + dir_str
	var hide_anim = "hide-" + dir_str
	var attack_anim = "attack-" + dir_str
	
	# Move the attack area.
	if _last_direction == PlayerDir.LEFT:
		$AttackAreaTr.position = Vector2(-13, -18)
		$AttackAreaTr.rotation_degrees = 179.0
		$UseArea.rotation_degrees = 90.0
	if _last_direction == PlayerDir.RIGHT:
		$AttackAreaTr.position = Vector2(17, -15)
		$AttackAreaTr.rotation_degrees = 0.0
		$UseArea.rotation_degrees = -90.0
	if _last_direction == PlayerDir.DOWN:
		$AttackAreaTr.position = Vector2(-5, -8)
		$AttackAreaTr.rotation_degrees = 83.1
		$UseArea.rotation_degrees = 0.0
	if _last_direction == PlayerDir.UP:
		$AttackAreaTr.position = Vector2(6, -42)
		$AttackAreaTr.rotation_degrees = -94.9
		$UseArea.rotation_degrees = 180.0
	
	if _state in [PlayerState.WALK, PlayerState.WAIT]:
		animated_sprite.speed_scale = ANIM_SPEED
		animated_sprite.play(walk_anim)
		if _last_move_vec.length() < VELOCITY_EPS:
			animated_sprite.pause()
			animated_sprite.frame = 0
		elif animated_sprite.is_playing() == false:
			animated_sprite.play()
		
		if Input.is_action_pressed("attack"):
			#Input.action_release("attack")
			_state = PlayerState.ATTACK
			animated_sprite.play(attack_anim)
			for obj in $AttackAreaTr/AttackArea.get_overlapping_areas():
				var node = obj.get_parent()
				if node is Enemy:
					node.take_hit(global_position, 1.0)
				elif obj is PickUpItem:
					obj.pick_up(self)
		elif Input.is_action_pressed("use"):
			Input.action_release("use")
			_on_use()
	
	elif _state == PlayerState.HIDE:
		if _last_direction == PlayerDir.LEFT:
			animated_sprite.scale.x = -1.0
		animated_sprite.speed_scale = HIDE_ANIM_SPEED
		animated_sprite.play(hide_anim)
		if _last_move_vec.length() < VELOCITY_EPS:
			animated_sprite.pause()
			animated_sprite.frame = 0
		elif animated_sprite.is_playing() == false:
			animated_sprite.play()
	
	elif _state == PlayerState.ATTACK:
		if animated_sprite.is_playing() == false:
			_state = PlayerState.WALK
	
	elif _state == PlayerState.DEAD:
		_dead_timer += delta
		if _dead_timer > RESPAWN_TIME:
			_respawn()
	
	elif _state == PlayerState.TELEPORT:
		_teleport_timer += delta
		if _teleport_timer > TELEPORT_TIME:
			_teleport_event()


func _update_hearts():
	emit_signal("hearts_changed", _hearts, _max_hearts)


func _dead():
	if _state == PlayerState.DEAD:
		return
	_state = PlayerState.DEAD
	_dead_timer = 0.0
	animated_sprite.play("dead")
	emit_signal("dead")


func _respawn():
	_state = PlayerState.WAIT
	global_position = _respawn_point
	_hearts = 2
	_update_hearts()
	_damage_state = DamageState.DAMAGED
	_damage_state_timer = 0.0


func _teleport_event():
	_state = PlayerState.WAIT
	emit_signal("teleport", _teleport_name)


func _on_pick_up_area_area_entered(area : Area2D):
	if area is PickUpItem:
		area.pick_up(self)


func _on_use():
	emit_signal("use_action")
	if _usable_bodies.size() > 0:
		var obj = _usable_bodies[_usable_body_indx]
		
		if obj is Door:
			var door = (obj as Door)
			if door.open_by_key && door.key_type in _keys:
				_keys.remove_at(_keys.find(door.key_type))
				door.open()
				emit_signal("key_used", door.key_type)
				emit_signal("keys_changed", _keys)
		
		elif obj is NPC:
			if _state not in INACTIVE_STATES:
				obj.talk(self, _game_state)
		
		elif obj is SavePoint:
			if _state not in INACTIVE_STATES:
				emit_signal("save_game", obj)
		
		elif obj.has_method("use"):
			obj.use()


func _on_use_area_body_entered(body: Node2D) -> void:
	_usable_bodies.push_back(body)


func _on_use_area_body_exited(body: Node2D) -> void:
	_usable_bodies.erase(body)
	_usable_body_indx = min(_usable_bodies.size(), _usable_body_indx)
