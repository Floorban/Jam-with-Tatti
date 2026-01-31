class_name NPC
extends CharacterBody3D

@export var initial_state: State = State.IDLE

@export_category("Move Speed")
@export var move_speed: float = 3
@export var move_speed_lerp: float = 5

@export_category("Idle")
@export var min_idle_time: float = 1
@export var max_idle_time: float = 3
@export_category("Walk")
@export var min_walk_time: float = 3
@export var max_walk_time: float = 5
@export_category("Sit")
@export var min_sit_time: float = 1
@export var max_sit_time: float = 3

@export_category("Looking")
@export var look_speed: float = 3
@export var look_speed_lerp: float = 5


var animator: AnimationPlayer

@onready var state_timer: Timer = %StateTimer
@onready var head_look_at: LookAtModifier3D = %HeadLookAt

var current_state: State = 500
enum State {
	IDLE,
	WALK,
	SIT,
}

var move_dir: Vector3 = Vector3.ZERO
var chair: Chair
var player: Player

func _ready() -> void:
	for child in get_children():
		if child is AnimationPlayer:
			animator = child
	
	state_timer.timeout.connect(_on_state_timer_timeout)
	change_state(initial_state)



func _physics_process(delta: float) -> void:
	match current_state:
		State.IDLE:
			pass
		
		State.WALK:
			velocity = velocity.lerp(move_dir * move_speed, move_speed_lerp * delta)
			handle_looking(delta)
			velocity.y += get_gravity().y * delta
			
			for i in get_slide_collision_count():
				var collision = get_slide_collision(i)
				
				var collider = collision.get_collider()
				if collider is Chair:
					chair = collider
					change_state(State.SIT)
				
				var normal: Vector3 = collision.get_normal()
				if normal != Vector3.UP:
					move_dir = move_dir.bounce(-normal)
					move_dir.y = 0
					#move_dir.x += randf_range(-0.1, 0.1)
					#move_dir.z += randf_range(-0.1, 0.1)
			
		State.SIT:
			look_at(global_position - chair.global_transform.basis.z)
			global_position = global_position.move_toward(chair.sit_pos_marker.global_position, move_speed_lerp * delta)
			

	move_and_slide()



func change_state(new_state: State) -> void:
	if current_state == new_state:
		return
	
	match current_state:
		State.SIT:
			animator.play_backwards("sit")
			await animator.animation_finished
	
	
	current_state = new_state
	print("New state: ", State.keys()[current_state])
	
	match current_state:
		State.IDLE:
			animator.play("idle")
			velocity = Vector3.ZERO
			move_dir = Vector3.ZERO
			state_timer.wait_time = randf_range(min_idle_time, max_idle_time)
			state_timer.start()
		
		State.WALK:
			animator.play("walk")
			move_dir = get_random_dir()
			state_timer.wait_time = randf_range(min_walk_time, max_walk_time)
			state_timer.start()

		State.SIT:
			velocity = Vector3.ZERO
			animator.play("sit")
			state_timer.wait_time = randf_range(min_sit_time, max_sit_time)
			state_timer.start()



func _on_state_timer_timeout() -> void:
	match current_state:
		State.IDLE:
			change_state(State.WALK)
		State.WALK:
			change_state(State.IDLE)
		State.SIT:
			change_state(State.WALK)



func handle_looking(delta: float) -> void:
	var forward_dir: Vector3 = -global_transform.basis.z
	var look_dir: Vector3 = forward_dir.lerp(move_dir, look_speed_lerp * delta)
	var target_look_dir: Vector3 = Vector3(global_position.x + look_dir.x, global_position.y, global_position.z + look_dir.z)
	
	look_at(target_look_dir)


func get_random_dir() -> Vector3:
	return Vector3(randf_range(-1, 1), 0, randf_range(-1, 1))


func _on_player_area_body_entered(body: Node3D) -> void:
	if body is Player:
		player = body


func _on_player_area_body_exited(body: Node3D) -> void:
	if body is Player:
		player = null
