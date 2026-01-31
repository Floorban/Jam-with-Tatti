class_name InteractionComponent extends Node

@onready var player : Player = get_tree().get_first_node_in_group("player") as Player

@export var object_ref: Node3D
@export var nodes_to_affect: Array[Node]

var can_interact: bool = false
var is_interacting: bool = false

## Runs once, when the player FIRST clicks on an object to interact with
func preInteract(_hand: Marker3D, _target: Node = null) -> void:
	is_interacting = true
	print("aa")

## Run every frame while the player is interacting with this object
func interact() -> void:
	if not can_interact:
		return

## Runs once, when the player LAST interacts with an object
func postInteract() -> void:
	player.interaction_controller.current_object = null
	is_interacting = false
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

## Alternate interaction using secondary button
func auxInteract() -> void:
	if not can_interact:
		return

## when the controller detect the obj before interact
func interact_hint() -> void:
	can_interact = true

## when the controller leaves
func disable_interact_hint() -> void:
	can_interact = false

## Iterates over a list of nodes that can be interacted with and executes their respective logic
func notify_nodes(percentage: float, primary: bool = true) -> void:
	for node in nodes_to_affect:
		if node and node.has_method("execute"):
			node.call("execute", percentage, primary)
