class_name InteractionComponent extends Node

enum InteractionType {
	CLICK,   # press once
	HOLD,    # hold to interact
}

@onready var player : Player = get_tree().get_first_node_in_group("player") as Player

@export var interact_type : InteractionType = InteractionType.CLICK
var can_interact: bool = false
var is_interacting: bool = false
@export var interact_duration := 1.0

var interact: Callable = func(_interactor : Player):
	pass

var focus_hint: Callable = func():
	pass

var unfocus_hint: Callable = func():
	pass

### Runs once, when the player FIRST clicks on an object to interact with
#func preInteract(_hand: Marker3D, _target: Node = null) -> void:
	#is_interacting = true

### Run every frame while the player is interacting with this object
#func ongoingInteract() -> void:
	#if not can_interact:
		#return

### Runs once, when the player LAST interacts with an object
#func postInteract() -> void:
	#player.interaction_controller.current_object = null
	#is_interacting = false
	#Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

### Alternate interaction using secondary button
#func auxInteract() -> void:
	#if not can_interact:
		#return

## when the controller detect the obj before interact
func interact_hint() -> void:
	can_interact = true
	focus_hint.call()

## when the controller leaves
func disable_interact_hint() -> void:
	can_interact = false
	unfocus_hint.call()
