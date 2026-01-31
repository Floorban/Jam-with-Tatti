class_name FloorButtonContainer
extends Node3D

func _ready() -> void:
	for child in get_children():
		if child is ElevatorButton:
			child.set_button_type(ElevatorButton.ButtonType.FLOOR_BUTTON)
			child.set_floor(child.get_index())
		else:
			push_error("Invalid child in ", name, ",: ", child.name, "!")
