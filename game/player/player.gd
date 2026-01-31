class_name Player extends CharacterBody3D

@onready var head: Node3D = %Head
@onready var interaction_controller: InteractionController = %InteractionController
@onready var camera_controller: CameraController = $Head/CameraController

@export_category("Movement")
@export var walking_speed: float = 2.0
@export var sprinting_speed: float = 3.0
var can_move := true
var current_speed: float
var max_speed: float
var acceleration := 3.0
var hold_back_speed := 0.0
var moving: bool = false
var input_dir: Vector2 = Vector2.ZERO
var direction: Vector3 = Vector3.ZERO
var lerp_speed: float = 4.0

func set_player_input(stop: bool) -> void:
	can_move = !stop
	interaction_controller.can_interact = !stop
	camera_controller.can_control = !stop

func get_movement_dir() -> Vector3:
	input_dir = Input.get_vector("left", "right", "forward", "backward")
	return (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()

func _physics_process(delta: float) -> void:
	update_player_horizontal(delta)

func update_player_horizontal(delta: float) -> void:
	max_speed = walking_speed + hold_back_speed
	direction = lerp(direction, get_movement_dir(), delta * 10.0)
	if direction.length() > 0.01:
		# Accelerate towards max speed
		current_speed = move_toward(current_speed, max_speed, acceleration * delta)
	else:
		current_speed = move_toward(current_speed, 0, current_speed)
	
	velocity.x = direction.x * current_speed
	velocity.z = direction.z * current_speed * 0.8
	move_and_slide()
