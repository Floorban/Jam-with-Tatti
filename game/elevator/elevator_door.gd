class_name ElevatorDoor extends CharacterBody3D

@onready var mesh_root: Node3D = $MeshRoot
@onready var collision: CollisionShape3D = $Collision
@onready var door_ray_cast: RayCast3D = $DoorRayCast

@export var open_scale_x := 0.05
@export var closed_scale_x := 1.0
@export var move_duration := 0.4

var is_open := false
var tween: Tween

func open() -> void:
	if is_open:
		return

	# Cancel open if something is blocking the door
	if door_ray_cast.is_colliding():
		close()
		return

	is_open = true
	door_move_tween(open_scale_x)

func close() -> void:
	if not is_open:
		return

	is_open = false
	door_move_tween(closed_scale_x)

func door_move_tween(target_x: float) -> void:
	if tween and tween.is_running():
		tween.kill()

	tween = create_tween()
	tween.set_trans(Tween.TRANS_SINE)
	tween.set_ease(Tween.EASE_IN_OUT)

	tween.tween_property(
		mesh_root,
		"scale:x",
		target_x,
		move_duration
	)

	tween.tween_property(
		collision,
		"scale:x",
		target_x,
		move_duration
	)
