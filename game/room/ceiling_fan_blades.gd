extends MeshInstance3D

@export_range(0, 20, 0.5) var rotation_speed: float = 1

func _process(delta: float) -> void:
	rotation.y += rotation_speed * delta
