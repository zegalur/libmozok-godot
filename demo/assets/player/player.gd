## Playable character.

class_name Player
extends CharacterBody2D

signal dead()
signal hearts_changed(hearts : int, max_hearts : int)
signal keys_changed(keys : Array)
signal use_action()

@onready var animated_sprite: AnimatedSprite2D = get_node("AnimatedSprite2D")

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
var _hearts = 3.0
var _max_hearts = 3.0

# Controls the player's death and respawn.
var _dead_timer = 0.0
const RESPAWN_TIME = 3.0

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
	WALK,
	HIDE,
	ATTACK,
	DEAD,
}
var _state = PlayerState.WALK
var _last_direction : String = "down"
var _last_move_vec : Vector2 = Vector2.ZERO
var _respawn_point : Vector2
var _keys = []


func _ready():
	_update_hearts()
	_respawn_point = global_position


## Converts a unit Vector2 to direction strings "up", left", "right" and "down".
func _to_dir_str(dir : Vector2):
	dir *= -10.0
	const EPS = 0.01
	if dir.x >= EPS and abs(dir.x) + EPS > abs(dir.y):
		return "left"
	if dir.x <= -EPS and abs(dir.x) + EPS > abs(dir.y):
		return "right"
	if dir.y >= EPS and abs(dir.y) > abs(dir.x):
		return "up"
	return "down"


## Take a hit from the given point and with the given damage.
func take_hit(from : Vector2, damage : float):
	if _damage_state == DamageState.DAMAGED:
		return # player is invincible in the damaged state
	if (global_position - from).length() > 27.0:
		return # miss
	_kick_force_vec = (global_position - from).normalized()
	
	if _state == PlayerState.HIDE:
		if _to_dir_str(-_kick_force_vec) == _last_direction:
			_block_count += 1
			if _block_tut_done == false and _block_count >= 3:
				_block_tut_done = true
				emit_signal("block_tut_done")
			return
	
	_damage_state_timer = 0.0
	_damage_state = DamageState.DAMAGED
	_hearts = max(0.0, _hearts - damage)
	
	# pick up hearts from the nearby area
	for area in $PickUpArea.get_overlapping_areas():
		var node = area.get_parent()
		if node is PickUpItem:
			node.pick_up(self)
	
	_update_hearts()
	
	if _hearts == 0.0:
		_dead()
	
	if _take_hit_tut_done == false:
		_take_hit_tut_done = true
		emit_signal("take_hit_tut_done")


## Returns `true` if player is dead. 
## Returns false` if player is alive. 
func is_dead() -> bool:
	return _state == PlayerState.DEAD


## Adds health points.
func add_heart(count : float):
	_hearts = min(_max_hearts, _hearts + count)
	_update_hearts()
	if _take_heart_tut_done == false:
		_take_heart_tut_done = true
		emit_signal("take_heart_tut_done")

## Add new heart cell.
func add_heart_cell():
	_max_hearts += 1
	_hearts = _max_hearts
	_update_hearts()
	if _take_big_heart_tut_done == false:
		_take_big_heart_tut_done = true
		emit_signal("take_big_heart_tut_done")

## Returns `true` if health points are at maximum.
func is_max_hearts() -> bool:
	return _hearts == _max_hearts


## Adds a key to the inventory.
func add_key(key_type : Key.KeyType):
	_keys.push_back(key_type)
	emit_signal("keys_changed", _keys)
	if _pickup_key_tut_done == false:
		_pickup_key_tut_done = true
		emit_signal("pickup_key_tut_done")


func get_screen_center_position() -> Vector2:
	return $Camera2D.get_screen_center_position()


func get_player_direction() -> String:
	return _last_direction


func set_camera_offset(offset : Vector2):
	$Camera2D.offset = offset


func set_respawn_point(global_pos : Vector2):
	_respawn_point = global_pos


func _physics_process(delta):
	_process_actions(delta)
	
	var l = _kick_force_vec.length()
	if l > 0.001:
		_kick_force_vec -= _kick_force_vec.normalized() * min(1, delta / FORCE_DUR)
	else:
		_kick_force_vec = Vector2.ZERO
	
	var direction_X = Input.get_axis("move_left", "move_right")
	var direction_Y = Input.get_axis("move_up", "move_down")
	var dir = Vector2(direction_X, direction_Y).normalized()
	
	var speed = 0.0
	if _state == PlayerState.HIDE:
		speed = HIDE_SPEED
	elif  _state == PlayerState.WALK:
		speed = RUN_SPEED
	var move_vec = dir * speed
	
	_last_move_vec = dir
	if _state in [PlayerState.WALK, PlayerState.ATTACK]:
		if dir.length() > VELOCITY_EPS:
			_last_direction = _to_dir_str(dir)
	
	velocity = move_vec + _kick_force_vec * KICK_FORCE
	move_and_slide()


func _process_actions(delta):
	if _damage_state == DamageState.NORMAL:
		animated_sprite.modulate = Color.WHITE
	elif _damage_state == DamageState.DAMAGED:
		_damage_state_timer += delta
		animated_sprite.modulate = Color(1.0, 1.0, 1.0, 
				0.5 * abs(cos(_damage_state_timer/DAMAGED_DURATION * 15.0)))
		if _damage_state_timer >= DAMAGED_DURATION:
			_damage_state = DamageState.NORMAL
	
	if _state in [PlayerState.WALK, PlayerState.HIDE]: 
		if Input.is_action_pressed("hide"):
			_state = PlayerState.HIDE
		else:
			_state = PlayerState.WALK
	
	animated_sprite.scale.x = 1.0
	
	var walk_anim = "run-" + _last_direction
	var hide_anim = "hide-" + _last_direction
	var attack_anim = "attack-" + _last_direction
	
	# Move the attack area.
	if _last_direction == "left":
		$AttackAreaTr.position = Vector2(-13, -18)
		$AttackAreaTr.rotation_degrees = 179.0
		$UseArea.rotation_degrees = 90.0
	if _last_direction == "right":
		$AttackAreaTr.position = Vector2(17, -15)
		$AttackAreaTr.rotation_degrees = 0.0
		$UseArea.rotation_degrees = -90.0
	if _last_direction == "down":
		$AttackAreaTr.position = Vector2(-5, -8)
		$AttackAreaTr.rotation_degrees = 83.1
		$UseArea.rotation_degrees = 0.0
	if _last_direction == "up":
		$AttackAreaTr.position = Vector2(6, -42)
		$AttackAreaTr.rotation_degrees = -94.9
		$UseArea.rotation_degrees = 180.0
	
	_tutorials(delta)
	
	if _state == PlayerState.WALK:
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
		if _last_direction == "left":
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


func _update_hearts():
	emit_signal("hearts_changed", _hearts, _max_hearts)


func _dead():
	if _state == PlayerState.DEAD:
		return
	if _die_tut_done == false:
		_die_tut_done = true
		emit_signal("die_tut_done")
	_state = PlayerState.DEAD
	_dead_timer = 0.0
	animated_sprite.play("dead")
	emit_signal("dead")


func _respawn():
	_state = PlayerState.WALK
	global_position = _respawn_point
	_hearts = 2
	_update_hearts()
	_damage_state = DamageState.DAMAGED
	_damage_state_timer = 0.0


func _on_pick_up_area_area_entered(area : Area2D):
	if area is PickUpItem:
		area.pick_up(self)


func _on_use():
	emit_signal("use_action")
	for obj in $UseArea.get_overlapping_bodies():
		if obj is Door:
			var door = (obj as Door)
			if door.open_by_key && door.key_type in _keys:
				_keys.remove_at(_keys.find(door.key_type))
				door.open()
				emit_signal("keys_changed", _keys)
				if _open_door_tut_done == false:
					_open_door_tut_done = true
					emit_signal("open_door_tut_done")
				break


# Controls tutorial.
class ControlTut:
	var _timers = {"up" : 0.0, "down" : 0.0, "left" : 0.0, "right" : 0.0}
	var _done = false
	var _state : PlayerState
	var _amount : float
	var _signal : StringName
	var _player : Player
	
	func _init(
			player : Player, 
			state : PlayerState, 
			amount : float, 
			signal_name : String):
		_player = player
		_state = state
		_amount = amount
		_signal = signal_name
	
	func process(state : PlayerState, delta : float, last_dir : String):
		if _done == true:
			return
		if _state != state:
			return
		_timers[last_dir] += delta
		_done = true
		for timer in _timers.values():
			if timer < _amount:
				_done = false
		if _done == true:
			_player.emit_signal(_signal)

signal movement_tut_done()
signal attack_tut_done()
signal hide_tut_done()

@onready var _control_tutorials = [
	ControlTut.new(self, PlayerState.WALK, 0.1, "movement_tut_done"),
	ControlTut.new(self, PlayerState.ATTACK, 0.1, "attack_tut_done"),
	ControlTut.new(self, PlayerState.HIDE, 0.1, "hide_tut_done")]

func _tutorials(delta : float):
	# Movement Tutorials.
	if animated_sprite.is_playing() == true:
		for tut : ControlTut in _control_tutorials:
			tut.process(_state, delta, _last_direction)


# Fighting tutorial.
var _block_tut_done = false
var _block_count = 0
var _die_tut_done = false
var _take_heart_tut_done = false
var _take_hit_tut_done = false
signal block_tut_done()
signal die_tut_done()
signal take_heart_tut_done()
signal take_hit_tut_done()

# Key tutorial
var _pickup_key_tut_done = false
var _open_door_tut_done = false
signal pickup_key_tut_done()
signal open_door_tut_done()

# Puzzle tutorial
var _take_big_heart_tut_done = false
signal take_big_heart_tut_done()
