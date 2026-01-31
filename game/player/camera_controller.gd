class_name CameraController extends Node3D

@export var player_controller: Player

@export_category("Camera Settings")
@onready var player_camera: Camera3D = %PlayerCamera
@export var normal_sensitivity: float = 0.01
@onready var current_sensitivity: float = normal_sensitivity
var sensitivity_restore_speed: float = 4.0
var sensitivity_fading_in: bool = false
var input_rotation: Vector3
var mouse_input: Vector2

@export_group("Camera Shake")
var decay: = 0.8
@export var max_offset: = Vector3(0.5, 0.5, 0.5)
var max_rotation: = Vector3(1.0, 1.0, 1.0) # degrees
var trauma: = 0.0
var trauma_power: = 2
var cam_original_position: Vector3
var cam_original_rotation: Vector3

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("esc"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED else Input.MOUSE_MODE_CAPTURED

	if event is InputEventMouseMotion:
		mouse_input.x += -event.screen_relative.x * current_sensitivity
		mouse_input.y += -event.screen_relative.y * current_sensitivity

func _process(_delta: float) -> void:
	input_rotation.x = clampf(input_rotation.x + mouse_input.y, deg_to_rad(-90), deg_to_rad(85))
	input_rotation.y += mouse_input.x
	
	player_controller.head.transform.basis = Basis.from_euler(Vector3(input_rotation.x, 0.0, 0.0))
	player_controller.global_transform.basis = Basis.from_euler(Vector3(0.0, input_rotation.y, 0.0))
	
	global_transform = player_controller.head.get_global_transform_interpolated()
	
	mouse_input = Vector2.ZERO
