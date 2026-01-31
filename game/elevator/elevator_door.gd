class_name ElevatorDoor extends CharacterBody3D

@onready var mesh_root: Node3D = $MeshRoot
@onready var collision: CollisionShape3D = $Collision
@onready var door_ray_cast: RayCast3D = $DoorRayCast

@export var open_scale_x := 0.05
@export var closed_scale_x := 1.0
@export var move_duration := 1.5

var door_tween: Tween
var is_open := false
var _box_shape: BoxShape3D
var _closed_size_x: float
var _closed_pos_x: float

func _ready() -> void:
	_box_shape = collision.shape as BoxShape3D
	_closed_size_x = _box_shape.size.x
	_closed_pos_x = collision.position.x
	open()

func _process(_delta: float) -> void:
	if door_ray_cast.is_colliding():
		open()

func open() -> void:
	if is_open:
		return

	is_open = true
	door_move_door_tween(open_scale_x)

func close() -> void:
	if not is_open or door_ray_cast.is_colliding():
		return

	is_open = false
	door_move_door_tween(closed_scale_x)

func door_move_door_tween(target_ratio: float) -> void:
	if door_tween and door_tween.is_running():
		door_tween.kill()

	door_tween = create_tween()
	door_tween.set_trans(door_tween.TRANS_SINE)
	door_tween.set_ease(door_tween.EASE_IN_OUT)

	door_tween.parallel().tween_property(
		mesh_root,
		"scale:x",
		target_ratio,
		move_duration
	)

	var target_size_x := _closed_size_x * target_ratio
	var target_pos_x := _closed_pos_x - (_closed_size_x - target_size_x) * 0.5

	# Tween BoxShape size
	door_tween.parallel().tween_property(
		_box_shape,
		"size:x",
		target_size_x,
		move_duration
	)

	# Tween CollisionShape position
	door_tween.parallel().tween_property(
		collision,
		"position:x",
		target_pos_x,
		move_duration
	)
