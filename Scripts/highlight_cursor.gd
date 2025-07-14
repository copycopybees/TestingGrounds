extends Node3D


func _on_camera_highlight_ray_casted(mousecell: Vector3) -> void:
	position = mousecell  + Vector3(0.75, 0, 0.75)
