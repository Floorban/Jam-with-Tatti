class_name FloorButtonContainer
extends Node3D


func _ready() -> void:
	for child in get_children():
		if child is ElavatorButton:
			child.button_type = child.ButtonType.FLOOR_BUTTON
			child.set_floor(child.get_index())
