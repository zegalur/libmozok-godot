## Red skeletons are the simplest enemies in the game. 
## They are slow, attack only at close range, and lack any special abilities.

class_name RedSkeleton
extends Enemy

## Movement speed in pixels per second.
@export var movement_speed = 100.0

## The distance at which the enemy will activate.
@export var activation_distance = 300.0

## Damage from one kick.
@export var attack_damage = 1.0

## Enemy's health points.
@export var hearts = 3.0

## Set this property to `true` if you want this enemy to automatically respawn 
## after being defeated.
@export var respawn_on_dead = false

@onready var navigation_agent: NavigationAgent2D = get_node("NavigationAgent2D")
@onready var animated_sprite: AnimatedSprite2D = get_node("AnimatedSprite2D")

signal killed()


## All enemy states.
enum EnemyState {
	SLEEP, ## Sleeping, need to be activated.
	WAIT, ## Waiting for the next command.
	WALK_TO_PLAYER, ## Player is reachable, walking to player.
	ATTACK, ## Player is in range, attacking the player.
	DAMAGE, ## Damaged from the direct hit.
	WALK_BACK, ## Walking back to the starting point.
	DEAD, ## Enemy is dead.
	}

var _state = EnemyState.SLEEP ## Current state
var _initial_pos : Vector2 ## Initial position (global coordinates)
var _initial_collision_layer : int
var _initial_hearts : float

## Navigation times, used to track the time since the last navigation update.
var _nav_timer = 0.0 

## Intervals between navigation updates in the `_process` function.
const NAV_STEP = 1.0

# This parameter controls how the enemy is pushed by a direct hit.
var _kick_force_vec = Vector2.ZERO
const KICK_FORCE = 300.0
const FORCE_DUR = 0.3
var _kick_timer = 0.0

## How long the enemy is dead.
var _dead_timer = 0.0

## When to initiate the respawn.
const RESPAWN_TIME = 3.0


func _ready() -> void:
	navigation_agent.velocity_computed.connect(Callable(_on_velocity_computed))
	_initial_pos = global_position
	_initial_collision_layer = collision_layer
	_initial_hearts = hearts


## Check if the player is inside the activation zone.
## See the `activation_distance` parameter.
func _is_player_in_activation_radius():
	if _player.is_dead() == true:
		return false
	return (_player.global_position - global_position).length() <= activation_distance


## Sets the new navigation target.
func set_movement_target(movement_target: Vector2):
	navigation_agent.set_target_position(movement_target)


## Enemy takes a hit from the given direction and damage.
func take_hit(from : Vector2, damage : float):
	if _state in [EnemyState.DEAD]:
		return
	
	_kick_force_vec = (global_position - from).normalized()
	_kick_timer = 0.0
	
	if _state in [EnemyState.DAMAGE]:
		# skip damage
		return
	
	_state = EnemyState.DAMAGE
	animated_sprite.play("damage")
	_nav_timer = 0.0
	
	hearts = max(0, hearts - damage)
	if hearts <= 0.0:
		_dead()


func _physics_process(delta):
	if _state == EnemyState.DEAD:
		if respawn_on_dead == false:
			return
		_dead_timer += delta
		if _dead_timer > RESPAWN_TIME:
			_respawn()
	
	if _state == EnemyState.DAMAGE:
		if _kick_force_vec.length() > 0.001:
			_kick_force_vec -= _kick_force_vec.normalized() * min(1, delta / FORCE_DUR)
		else:
			_kick_force_vec = Vector2.ZERO
		
		velocity = _kick_force_vec * KICK_FORCE
		move_and_slide()
		return
	
	if navigation_agent.is_navigation_finished():
		return

	if _state not in [EnemyState.WALK_TO_PLAYER, EnemyState.WALK_BACK]:
		return

	var next_path_position: Vector2 = navigation_agent.get_next_path_position()
	var new_velocity: Vector2 = global_position.direction_to(next_path_position) * movement_speed
	if navigation_agent.avoidance_enabled:
		navigation_agent.set_velocity(new_velocity)
	else:
		_on_velocity_computed(new_velocity)


func _on_velocity_computed(safe_velocity: Vector2):
	velocity = safe_velocity
	move_and_slide()


func _process(delta):
	if _state == EnemyState.DEAD:
		return
	
	if _state not in [EnemyState.SLEEP, EnemyState.WALK_BACK, EnemyState.DEAD]:
		_nav_timer += delta
		if _nav_timer >= NAV_STEP:
			_nav_timer = 0.0
			set_movement_target(_player.global_position)
	
	if _state == EnemyState.SLEEP:
		if _is_player_in_activation_radius():
			_state = EnemyState.WAIT
			_nav_timer = NAV_STEP
	
	elif _state == EnemyState.DAMAGE:
		if animated_sprite.is_playing() == false:
			_state = EnemyState.WAIT
			animated_sprite.play("idle")
	
	elif _state == EnemyState.WAIT:
		if (navigation_agent.is_target_reachable() == false
				or _player.is_dead() == true):
			set_movement_target(_initial_pos)
			_state = EnemyState.WALK_BACK
			animated_sprite.play("run")
		else:
			animated_sprite.play("run")
			_nav_timer = 0.0
			_state = EnemyState.WALK_TO_PLAYER
			
	elif _state == EnemyState.WALK_TO_PLAYER:
		animated_sprite.scale.x = -1.0 if velocity.x > 0.0 else 1.0
		if navigation_agent.is_target_reached():
			_state = EnemyState.ATTACK
			animated_sprite.play("attack")
		elif navigation_agent.is_target_reachable() == false:
			_state = EnemyState.WAIT
			animated_sprite.play("idle")
	
	elif _state == EnemyState.WALK_BACK:
		animated_sprite.scale.x = -1.0 if velocity.x > 0.0 else 1.0
		if _is_player_in_activation_radius():
			_state = EnemyState.WAIT
		elif navigation_agent.is_target_reached():
			_state = EnemyState.SLEEP
			animated_sprite.play("idle")
	
	elif _state == EnemyState.ATTACK:
		if navigation_agent.is_target_reached() == false:
			_state = EnemyState.WAIT
			animated_sprite.play("idle")
		else:
			var dx = _player.global_position.x - global_position.x
			animated_sprite.scale.x = -1.0 if dx > 0.0 else 1.0
			_player.take_hit(global_position, attack_damage)


func _dead():
	_state = EnemyState.DEAD
	animated_sprite.play("death")
	collision_layer = 0
	_dead_timer = 0.0
	emit_signal("killed")


func _respawn():
	_state = EnemyState.WALK_BACK
	collision_layer = _initial_collision_layer
	hearts = _initial_hearts
