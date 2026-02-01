class_name Player extends CharacterBody3D

@onready var head: Node3D = %Head
@onready var hand: Marker3D = %Hand
@onready var ground_ray: RayCast3D = %GroundRay
@onready var interaction_controller: InteractionController = %InteractionController
@onready var camera_controller: CameraController = $Head/CameraController

@export_category("Movement")
@export var walking_speed: float = 2.0
@export var sprinting_speed: float = 3.0
@export var acceleration: float = 7
@export var deceleration: float = 10
var gravity: float = 5

var can_move: bool = true
var current_speed: float
var max_speed: float
var input_dir: Vector2 = Vector2.ZERO
var move_direction: Vector3 = Vector3.ZERO

var current_pickup: Pickup


func set_player_input(stop: bool) -> void:
	can_move = !stop
	interaction_controller.can_interact = !stop
	camera_controller.can_control = !stop


func get_movement_dir() -> Vector3:
	input_dir = Input.get_vector("left", "right", "forward", "backward")
	return (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()


func _physics_process(delta: float) -> void:
	handle_gravity(delta)
	update_player_movement(delta)
	if Input.is_action_just_pressed("primary"):
		drop()


func update_player_movement(delta: float) -> void:

	
	if not can_move:
		return
	
	if Input.is_action_pressed("sprint"):
		max_speed = sprinting_speed
	else:
		max_speed = walking_speed
	
	move_direction = get_movement_dir()
	
	if move_direction != Vector3.ZERO:
		current_speed = lerp(current_speed, max_speed, acceleration * delta)
	else:
		current_speed = lerp(current_speed, 0.0, deceleration * delta)
	
	velocity.x = move_direction.x * current_speed
	velocity.z = move_direction.z * current_speed

	
	move_and_slide()


func handle_gravity(delta: float) -> void:
	if not is_on_floor():
		velocity.y -= gravity * delta


func can_pickup() -> bool:
	return current_pickup == null


func pickup(new_pickup: Pickup) -> void:
	current_pickup = new_pickup
	interaction_controller.can_interact = false
	interaction_controller.interaction_raycast.enabled = false


func drop() -> void:
	if current_pickup == null:
		return
	
	var drop_position := _get_drop_position()
	current_pickup.on_drop(drop_position)
	current_pickup = null
	interaction_controller.can_interact = true
	interaction_controller.interaction_raycast.enabled = true


func _get_drop_position() -> Vector3:
	ground_ray.force_raycast_update()
	if ground_ray.is_colliding():
		var point : = ground_ray.get_collision_point()
		var normal := ground_ray.get_collision_normal()
		return point + normal * 0.05

	return global_position + -global_transform.basis.z * 0.5
