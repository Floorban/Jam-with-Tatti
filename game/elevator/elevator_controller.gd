class_name ElevatorController extends StaticBody3D

const PANEL_PHYSICS_LAYER = 3

@onready var interaction_component: InteractionComponent = $InteractionComponent
@onready var elevator_camera: Camera3D = $ElevatorCamera

var player: Player
var controlling := false
var camera_transitioning := false

func _ready() -> void:
	interaction_component.interact = Callable(self, "_on_interact_elevator")

func _on_interact_elevator(interactor: Player) -> void:
	if controlling:
		return
	player = interactor
	set_elevator_control_state(true)

func set_elevator_control_state(controlled) -> void:
	camera_transitioning = true
	controlling = controlled
	if controlling: 
		CameraTransition.transition_camera3D(player.camera_controller.player_camera, elevator_camera, 0.4, Callable(self, "set_player_input_state"))
	else: 
		CameraTransition.transition_camera3D(elevator_camera, player.camera_controller.player_camera, 0.2, Callable(self, "set_player_input_state"))

func set_player_input_state() -> void:
	player.set_player_input(controlling)
	camera_transitioning = false

func _process(delta: float) -> void:
	if not camera_transitioning and controlling and player.get_movement_dir() != Vector3.ZERO:
		set_elevator_control_state(false)

func _physics_process(_delta: float) -> void:
	if not controlling:
		return
	var cam := get_viewport().get_camera_3d()
	var mouse_pos := get_viewport().get_mouse_position()
	var ray_start : Vector3 = cam.project_ray_origin(mouse_pos)
	var dir : Vector3 = cam.project_ray_normal(mouse_pos)
	
	var space_state = get_world_3d().direct_space_state
	var p := PhysicsRayQueryParameters3D.create(ray_start, ray_start + dir * 10)
	p.collision_mask = 1 << PANEL_PHYSICS_LAYER - 1
	var result := space_state.intersect_ray(p)
	if result:
		var btn : ElavatorButton = result.collider
		if btn: btn.on_pressed()
		#var col : CollisionShape3D = collider.get_node_or_null("CollisionShape")
		#ghost_mesh.global_transform = col.global_transform
