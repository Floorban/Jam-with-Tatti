extends MeshInstance3D

@export_range(0, 20, 0.5) var rotation_speed: float = 1

@onready var ceiling_fan_base: Node3D = $ceiling_fan_base
@onready var ceiling_fan_blades: Node3D = $ceiling_fan_blades



func _process(delta: float) -> void:
	ceiling_fan_blades.rotation.y += rotation_speed * delta
