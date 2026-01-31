class_name InteractionController extends Node

@export var player: Player
@export var can_interact: bool = true: 
	set(value):
		can_interact = value
		if value: check_potential_interactables()
		else: _unfocus()
@onready var interaction_raycast: RayCast3D = %InteractionRay

var current_object: Object
var last_potential_object: Object
var interaction_component: InteractionComponent
var last_hover_component: InteractionComponent

var is_focused: bool = false
@onready var default_reticle: TextureRect = %ReticleDefault
@onready var highlight_reticle: TextureRect = %ReticleCanInteract

func _ready() -> void:
	ui_init()

func _process(_delta: float) -> void:
	if not can_interact: return
	# If on the previous frame, keep interacting with it
	if current_object and not interaction_component:
		stop_interactions()
	else:
		check_potential_interactables()

func stop_interactions() -> void:
	if current_object: # and not interaction_component is InteractionHolddable
		current_object = null
	_unfocus()

func check_potential_interactables() -> void:
	var potential_object: Object = interaction_raycast.get_collider()
	
	if (potential_object and potential_object is Node):
		var node: Node = potential_object
		interaction_component = null
		while node:
			interaction_component = node.get_node_or_null("InteractionComponent")
			if interaction_component:
				break
			node = node.get_parent()
		if interaction_component:
			last_potential_object = current_object
			# Disable hint for previous hover component if different
			if last_hover_component:
				if last_hover_component != interaction_component:
					last_hover_component.disable_interact_hint()
				else:
					last_hover_component.interact_hint()
			last_hover_component = interaction_component
			_focus()
			if Input.is_action_just_pressed("primary"):
				current_object = potential_object
				match interaction_component.interact_type:
					InteractionComponent.InteractionType.CLICK:
						interaction_component.interact.call(player)
		else: 
			stop_interactions()
	else:
		stop_interactions()

## Called when the player is looking at an interactable objects
func _focus() -> void:
	if is_focused:
		return
	is_focused = true
	default_reticle.visible = false
	highlight_reticle.visible = true
	if interaction_component: interaction_component.interact_hint()

## Called when the player is NOT looking at an interactable objects
func _unfocus() -> void:
	if not is_focused:
		return
	is_focused = false
	default_reticle.visible = true
	highlight_reticle.visible = false
	if interaction_component: interaction_component.disable_interact_hint()

func ui_init() -> void:
	var screen_size = get_viewport().get_visible_rect().size
	if default_reticle.texture: default_reticle.position = screen_size / 2 - default_reticle.texture.get_size() / 2
	highlight_reticle.position = screen_size / 2 - highlight_reticle.texture.get_size() / 2
	default_reticle.visible = false
	highlight_reticle.visible = false
