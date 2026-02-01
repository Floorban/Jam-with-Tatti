class_name ElevatorController extends StaticBody3D

@export var building: Building

@export var door: ElevatorDoor
@onready var panel_button_open: ElevatorButton = %PanelButtonOpen
@onready var panel_button_close: ElevatorButton = %PanelButtonClose
@onready var panel_button_warning: ElevatorButton = %PanelButtonWarning
var floor_buttons: Array[ElevatorButton]

@export var close_wait_time := 6.0
@export var move_wait_time := 2.5
var target_floor: int
var current_floor: int
var pending_floors: Array[int] = []

var is_moving := false

func _ready() -> void:
	panel_button_open.action_button_pressed.connect(_on_open_button_pressed)
	panel_button_close.action_button_pressed.connect(_on_close_button_pressed)
	panel_button_warning.action_button_pressed.connect(_open_warning_button_pressed)
	for btn in get_tree().get_nodes_in_group("floor_button"):
		floor_buttons.append(btn)
		btn.floor_button_pressed.connect(_on_floor_button_pressed)

func _on_close_button_pressed(_close_button: ElevatorButton) -> void:
	if door.is_open:
		await get_tree().create_timer(0.5).timeout
		door.close()
		await get_tree().create_timer(move_wait_time).timeout
		_process_next_floor()

func _on_open_button_pressed(_open_button: ElevatorButton) -> void:
	door.open()
	_start_close_timer()

func _open_warning_button_pressed(_warning_button: ElevatorButton) -> void:
	pass

func _on_floor_button_pressed(_button: ElevatorButton, _floor: int) -> void:
	if _floor in pending_floors:
		return

	pending_floors.append(_floor)
	if not is_moving and not door.is_open:
		_process_next_floor()

func _process_next_floor() -> void:
	if is_moving:
		return
	if pending_floors.is_empty():
		return

	is_moving = true
	target_floor = pending_floors.pop_front()
	_start_move_timer()

func _start_close_timer() -> void:
	if is_moving:
		return
	var t = get_tree().create_timer(close_wait_time)
	await t.timeout
	door.close()
	await get_tree().create_timer(move_wait_time).timeout
	_process_next_floor()

func _start_move_timer() -> void:
	var t = get_tree().create_timer(move_wait_time)
	await t.timeout
	building.move_to_floor(target_floor, Callable(self, "_on_arrived_at_floor"))

func _on_arrived_at_floor() -> void:
	current_floor = target_floor
	for btn in floor_buttons:
		if btn.target_floor == current_floor:
			btn.set_button_on_arrival()
	is_moving = false
	print("arrive")
	door.open()
	_start_close_timer()









































































































































#const PANEL_PHYSICS_LAYER = 3
#
#@onready var interaction_component: InteractionComponent = $InteractionComponent
#@onready var elevator_camera: Camera3D = $ElevatorCamera
#
#var player: Player
#var controlling := false
#var camera_transitioning := false
#
#var hovring_button: ElevatorButton
#
#func _on_interact_elevator(interactor: Player) -> void:
	#if controlling:
		#return
	#player = interactor
	#set_elevator_control_state(true)
#
#func set_elevator_control_state(controlled) -> void:
	#camera_transitioning = true
	#controlling = controlled
	#if controlling: 
		#CameraTransition.transition_camera3D(player.camera_controller.player_camera, elevator_camera, 0.3, Callable(self, "set_player_input_state"))
	#else: 
		#CameraTransition.transition_camera3D(elevator_camera, player.camera_controller.player_camera, 0.15, Callable(self, "set_player_input_state"))
#
#func set_player_input_state() -> void:
	#if controlling: Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	#else: Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	#player.set_player_input(controlling)
	#camera_transitioning = false
#
#func _process(_delta: float) -> void:
	#if not controlling:
		#return
	#if not camera_transitioning and player.get_movement_dir() != Vector3.ZERO:
		#set_elevator_control_state(false)
	#if hovring_button and Input.is_action_just_pressed("primary"):
		#hovring_button.on_pressed()
#
#func _physics_process(_delta: float) -> void:
	#if not controlling:
		#return
	#var cam := get_viewport().get_camera_3d()
	#var mouse_pos := get_viewport().get_mouse_position()
	#var ray_start : Vector3 = cam.project_ray_origin(mouse_pos)
	#var dir : Vector3 = cam.project_ray_normal(mouse_pos)
	#
	#var space_state = get_world_3d().direct_space_state
	#var p := PhysicsRayQueryParameters3D.create(ray_start, ray_start + dir * 10)
	#p.collision_mask = 1 << PANEL_PHYSICS_LAYER - 1
	#var result := space_state.intersect_ray(p)
	#if result:
		#var btn : ElevatorButton = result.collider
		#if not btn:
			#return
		#if hovring_button and btn != hovring_button: 
			#hovring_button.unfocus_button()
		#hovring_button = btn
		#hovring_button.focus_button()
	#elif hovring_button: 
		#hovring_button.unfocus_button()
		#hovring_button = null
