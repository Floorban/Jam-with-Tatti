class_name ActionButtonContainer
extends Node3D

func _ready() -> void:
	for child in get_children():
		if child is ElavatorButton:
			child.button_type = child.ButtonType.ACTION_BUTTON
		else:
			push_error("Invalid child in ", name, ",: ", child.name, "!")
