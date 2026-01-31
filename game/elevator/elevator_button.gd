class_name ElevatorButton 
extends StaticBody3D

@onready var outline: MeshInstance3D = %Outline
@onready var button_action_label: Label3D = %ButtonActionLabel

var button_type: ButtonType
enum ButtonType {
	FLOOR_BUTTON,
	ACTION_BUTTON,
}

var floor: int

signal floor_button_pressed(elevator_button: ElevatorButton, floor: int)
signal action_button_pressed(elevator_button: ElevatorButton)


func _ready() -> void:
	unfocus_button()



func set_floor(new_floor: int) -> void:
	if button_type != ButtonType.FLOOR_BUTTON:
		push_error("Trying to set floor on invalid button type: ", get_button_type_as_string())
		return
	
	floor = new_floor
	button_action_label.text = str(floor)



func set_button_type(new_button_type: ButtonType) -> void:
	button_type = new_button_type



func get_button_type_as_string() -> String:
	return ButtonType.keys()[button_type]



func focus_button() -> void:
	outline.visible = true

func unfocus_button() -> void:
	outline.visible = false

func on_pressed() -> void:
	if button_type == ButtonType.FLOOR_BUTTON:
		floor_button_pressed.emit(self, floor)
	
	elif button_type == ButtonType.ACTION_BUTTON:
		action_button_pressed.emit(self)
