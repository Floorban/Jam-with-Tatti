class_name Building extends Node3D

@export var floor_height := 8.0

@export var move_speed := 2.0 # units per second
@export var floors: Array[Node3D]
var current_floor := 0

var tween: Tween

func move_to_floor(target_floor: int,  on_finished: Callable = Callable()) -> void:
	if target_floor < 0 or target_floor >= floors.size():
		push_error("Invalid floor index: ", target_floor)
		return

	if tween and tween.is_running():
		tween.kill()

	var target_floor_node := floors[target_floor]
	var target_y := global_position.y - target_floor_node.global_position.y
	var distance : float = abs(global_position.y - target_y)
	var duration : float = distance / move_speed

	tween = create_tween()
	tween.set_trans(Tween.TRANS_SINE)
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(self, "global_position:y", target_y, duration)

	current_floor = target_floor
	if on_finished.is_valid(): tween.tween_callback(on_finished)
