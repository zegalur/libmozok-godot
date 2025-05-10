extends CharacterBody2D
## A chicken that runs away from the player.

const WALK_SPEED = 36.0
const RUN_SPEED = 300.0
const WALK_COEF = 0.5
const RUN_COEF = 1.0
const VELOCITY_CHANGE_TIME = 0.50
const STOP_RUNNING_AT = 3.0

enum State {
	WALKING,
	RUNNING
}

@onready var _last_angle : float = randf_range(0.0, 2.0 * PI)

var _velocity_timer = VELOCITY_CHANGE_TIME
var _state = State.WALKING
var _player_node : Player
var _can_stop_running : bool


func _ready() -> void:
	%Sprite.frame = randi_range(0, 5)


func _physics_process(delta: float) -> void:
	if _state == State.RUNNING:
		%Dust.emitting = true
		if _can_stop_running:
			_velocity_timer += delta
		if _velocity_timer >= STOP_RUNNING_AT:
			_velocity_timer = VELOCITY_CHANGE_TIME
			_state = State.WALKING
		else:
			var vec = (global_position-_player_node.global_position).normalized()
			var coef = _velocity_timer / STOP_RUNNING_AT
			if coef > 0.5:
				%Dust.emitting = false
			velocity = vec * (RUN_SPEED * (1.0 - coef) + WALK_SPEED * coef)
			%Sprite.speed_scale = (RUN_COEF * (1.0 - coef) + WALK_COEF * coef)
	
	if _state == State.WALKING:
		%Dust.emitting = false
		_velocity_timer += delta
		if _velocity_timer >= VELOCITY_CHANGE_TIME:
			_velocity_timer = 0.0
			_last_angle += 0.35 * randf_range(-PI, PI)
			while _last_angle < 0.0:
				_last_angle += 2.0 * PI
			while _last_angle > 2.0 * PI:
				_last_angle -= 2.0 * PI
			var speed = WALK_SPEED
			velocity = speed * Vector2.from_angle(_last_angle)
			%Sprite.speed_scale = WALK_COEF
	
	%Sprite.scale.x = -1.0 if velocity.x < 0.0 else 1.0
	move_and_slide()


func _on_player_detection_body_entered(body: Node2D) -> void:
	if body is Player:
		_velocity_timer = 0.0
		_state = State.RUNNING
		_player_node = body
		_can_stop_running = false


func _on_player_detection_body_exited(body: Node2D) -> void:
	if body is Player:
		_can_stop_running = true
