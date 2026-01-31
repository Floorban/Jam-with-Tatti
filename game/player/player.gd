extends CharacterBody3D

@export_category("Camera Settings")
@onready var head: Node3D = %Head
@onready var player_camera: Camera3D = %PlayerCamera
var base_head_y : float
var base_fov: float = 90.0
@export var normal_sensitivity: float = 0.2
var current_sensitivity: float = normal_sensitivity
var sensitivity_restore_speed: float = 4.0
var sensitivity_fading_in: bool = false
var mouse_input: Vector2
@export_group("Camera Shake")
var decay: = 0.8
@export var max_offset: = Vector3(0.5, 0.5, 0.5)
var max_rotation: = Vector3(1.0, 1.0, 1.0) # degrees
var trauma: = 0.0
var trauma_power: = 2
var cam_original_position: Vector3
var cam_original_rotation: Vector3

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

func _ready() -> void:
	cam_original_position = player_camera.position
	cam_original_rotation = player_camera.rotation_degrees
	base_head_y = head.position.y

func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("esc"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED else Input.MOUSE_MODE_CAPTURED

	if event is InputEventMouseMotion:
		if current_sensitivity > 0.01: # and not interaction_controller.is_cam_locked()
			mouse_input = event.relative
			rotate_y(deg_to_rad(-mouse_input.x * current_sensitivity))
			head.rotate_x(deg_to_rad(-mouse_input.y * current_sensitivity))
			head.rotation.x = clamp(head.rotation.x, deg_to_rad(-85), deg_to_rad(85))

func get_movement_dir() -> Vector3:
	input_dir = Input.get_vector("left", "right", "forward", "backward")
	return (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()

func _process(delta: float) -> void:
	max_speed = walking_speed + hold_back_speed

func _physics_process(delta: float) -> void:
	update_player_horizontal(delta)

func update_player_horizontal(delta: float) -> void:
	direction = lerp(direction, get_movement_dir(), delta * 10.0)
	if direction.length() > 0.01:
		# Accelerate towards max speed
		current_speed = move_toward(current_speed, max_speed, acceleration * delta)
	else:
		current_speed = move_toward(current_speed, 0, current_speed)
	
	velocity.x = direction.x * current_speed
	velocity.z = direction.z * current_speed * 0.8
	move_and_slide()

func update_player_camera_movement(delta: float) -> void:
	head.position.y = lerp(head.position.y, base_head_y, delta*lerp_speed)
	player_camera.fov = lerp(player_camera.fov, base_fov, delta*lerp_speed)
