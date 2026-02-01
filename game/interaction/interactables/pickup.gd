class_name Pickup extends CharacterBody3D

@onready var interaction_component: InteractionComponent = $InteractionComponent
@onready var outline: MeshInstance3D = %Outline

var original_parent: Node3D

func _ready() -> void:
	interaction_component.interact = Callable(self, "_on_pick_up")
	interaction_component.focus_hint = Callable(self, "focus_pickup")
	interaction_component.unfocus_hint = Callable(self, "unfocus_pickup")
	unfocus_pickup()
	original_parent = get_parent() as Node3D

func _on_pick_up(interactor: Player) -> void:
	
	if not interactor.can_pickup():
		return
	set_collision_layer_value(1, false)
	set_physics_process(false)
	set_process(false)
	call_deferred("_attach_pickup", interactor.hand, Vector3.ZERO)
	interactor.pickup(self)

func _attach_pickup(new_parent: Node3D, new_position: Vector3) -> void:
	reparent(new_parent)
	position = new_position
	rotation = Vector3.ZERO

func on_drop(drop_position: Vector3) -> void:
	set_collision_layer_value(1, true)
	set_physics_process(true)
	set_process(true)
	call_deferred("_attach_pickup", original_parent, drop_position)

func focus_pickup() -> void:
	outline.visible = true

func unfocus_pickup() -> void:
	outline.visible = false
