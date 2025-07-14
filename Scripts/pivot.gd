extends Node3D


var prev_mouse_position : Vector2
var bounds_position : Vector3
var bounds_end : Vector3

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	_move_camera(delta)


func _move_camera(delta: float):
	var move:=Vector3()
	
	if Input.is_action_just_pressed("rotate_camera_l"):
		rotation_degrees.y -= 90
		if rotation_degrees.y <= -90:
			rotation_degrees.y = 270

	if Input.is_action_just_pressed("rotate_camera_r"):
		rotation_degrees.y += 90
		if rotation_degrees.y >= 360:
			rotation_degrees.y = 0

	if Input.is_action_pressed("move_camera_u"):
		if rotation_degrees.y == 0:
			move.x += 1
			move.z -= 1
		if rotation_degrees.y == 90:
			move.x -= 1
			move.z -= 1		
		if rotation_degrees.y == 180:
			move.x -= 1
			move.z += 1
		if rotation_degrees.y == 270:
			move.x += 1
			move.z += 1


	if Input.is_action_pressed("move_camera_d"):
		if rotation_degrees.y == 0:
			move.x -= 1
			move.z += 1
		if rotation_degrees.y == 90:
			move.x += 1
			move.z += 1		
		if rotation_degrees.y == 180:
			move.x += 1
			move.z -= 1
		if rotation_degrees.y == 270:
			move.x -= 1
			move.z -= 1


	if Input.is_action_pressed("move_camera_l"):
		if rotation_degrees.y == 0:
			move.x -= 0.5
			move.z -= 0.5
		if rotation_degrees.y == 90:
			move.x -= 0.5
			move.z += 0.5		
		if rotation_degrees.y == 180:
			move.x += 0.5
			move.z += 0.5
		if rotation_degrees.y == 270:
			move.x += 0.5
			move.z -= 0.5


	if Input.is_action_pressed("move_camera_r"):
		if rotation_degrees.y == 0:
			move.x += 0.5
			move.z += 0.5
		if rotation_degrees.y == 90:
			move.x += 0.5
			move.z -= 0.5		
		if rotation_degrees.y == 180:
			move.x -= 0.5
			move.z -= 0.5
		if rotation_degrees.y == 270:
			move.x -= 0.5
			move.z += 0.5

	position += move * delta * 20

	if Input.is_action_just_pressed("zoom_in"):
		if $Camera.size != 5:
			$Camera.size -= 1


	if Input.is_action_just_pressed("zoom_out"):
		if $Camera.size != 40:
			$Camera.size += 1
	
	var mouse_position := get_viewport().get_mouse_position()
	if Input.is_action_just_pressed("drag_camera"):
		prev_mouse_position = mouse_position
	if Input.is_action_pressed("drag_camera"):
		var mouse_delta := prev_mouse_position - mouse_position
		var screen_size := get_viewport().get_visible_rect().size
		mouse_delta.x /= screen_size.x
		mouse_delta.y /= screen_size.y
		mouse_delta = mouse_delta.rotated(PI*0.25) # Isometric adjustment
		prev_mouse_position = mouse_position
	
		position += Vector3(mouse_delta.x, 0.0, mouse_delta.y) * $Camera.size
	position = position.clamp(bounds_position - Vector3(3,0,3), bounds_end + Vector3(3,0,3))


func _on_battlescape_terrain_bounds(battlescape_bounds: Rect2) -> void:
	bounds_position = Vector3(battlescape_bounds.position.x, 0, battlescape_bounds.position.y)
	bounds_end = Vector3(battlescape_bounds.end.x, 0, battlescape_bounds.end.y)
