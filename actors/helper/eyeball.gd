extends Sprite2D

@export var socket: Node2D
@export var stiffness: float = 400.0
@export var damping: float = 4.0
@export var max_offset: float = 3.5
@export var jitter: float = 750.0
@export var jitter_interval: float = 0.5
@export var gravity: float = 100.0

var eye_velocity: Vector2 = Vector2.ZERO  # renamed from "velocity"
var jitter_direction: Vector2 = Vector2.ZERO
var jitter_timer: float = 0.0

func _ready() -> void:
	top_level = true
	if socket:
		global_position = socket.global_position

func _physics_process(delta: float) -> void:
	if socket == null:
		return
	jitter_timer -= delta	
	if jitter_timer <= 0.0:
		jitter_direction = Vector2(randf_range(-1.0,1.0), randf_range(-1.0,1.0)).normalized()
		jitter_timer = jitter_interval
		
	var target_pos = socket.global_position
	var displacement = global_position - target_pos

	var spring_force = -displacement * stiffness
	var damping_force = -eye_velocity * damping
	var jitter_force = jitter_direction * jitter
	var gravity_force = Vector2(0, gravity)

	var acceleration = spring_force + damping_force + jitter_force + gravity_force
	eye_velocity += acceleration * delta
	global_position += eye_velocity * delta

	var offset = global_position - target_pos
	if offset.length() > max_offset:
		global_position = target_pos + offset.normalized() * max_offset
		eye_velocity = eye_velocity.bounce(offset.normalized()) * 0.8
		
