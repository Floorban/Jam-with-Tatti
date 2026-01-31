extends Node

var on_finished: Callable = Callable()

@onready var camera3D: Camera3D = $Camera3D
@onready var tween: Tween

var transition_time := 0.0
var transition_duration := 1.0

var from_camera: Camera3D
var to_camera: Camera3D
var transitioning: bool = false

func _ready() -> void:
	camera3D.current = false

func _process(delta: float) -> void:
	if transitioning:
		transition_time += delta
		var t : float = clamp(transition_time / transition_duration, 0.0, 1.0)
		t = ease(t, 0.5)  # Optional easing
		# Interpolate position and rotation
		var from_transform := from_camera.global_transform
		var to_transform := to_camera.global_transform
		var interpolated_origin := from_transform.origin.lerp(to_transform.origin, t)
		var interpolated_basis := from_transform.basis.slerp(to_transform.basis, t)
		camera3D.global_transform = Transform3D(interpolated_basis, interpolated_origin)
		# Interpolate FOV
		camera3D.fov = lerp(from_camera.fov, to_camera.fov, t)
		if t >= 1.0:
			# Transition complete
			transitioning = false
			camera3D.current = false
			to_camera.current = true
			if on_finished.is_valid():
				on_finished.call()
				on_finished = Callable()

func switch_camera(from, to) -> void:
	from.current = false
	to.current = true

func transition_camera3D(from: Camera3D, to: Camera3D, duration: float = 1.0, callback: Callable = Callable()) -> void:
	if transitioning:
		return

	# Store reference to both cameras
	from_camera = from
	to_camera = to
	transition_duration = duration
	transition_time = 0.0
	on_finished = callback

	# Initialize transition camera
	camera3D.fov = from.fov
	camera3D.cull_mask = from.cull_mask
	camera3D.global_transform = from.global_transform
	camera3D.current = true
	to.current = false
	from.current = false

	transitioning = true
