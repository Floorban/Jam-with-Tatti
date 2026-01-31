class_name ElavatorButton extends StaticBody3D

@onready var outline: MeshInstance3D = %Outline

func _ready() -> void:
	unfocus_button()

func focus_button() -> void:
	outline.visible = true

func unfocus_button() -> void:
	outline.visible = false

func on_pressed() -> void:
	print("pp")
