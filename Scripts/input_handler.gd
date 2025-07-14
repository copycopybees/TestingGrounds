extends Control
signal rotate_camera_l
signal rotate_camera_r
signal move_camera_u
signal move_camera_d
signal move_camera_l
signal move_camera_r
signal zoom_in
signal zoom_out
signal tile_selected

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("rotate_camera_l"):
		emit_signal("rotate_camera_l")
	if Input.is_action_just_pressed("rotate_camera_r"):
		emit_signal("rotate_camera_r")
	if Input.is_action_pressed("move_camera_u"):
		emit_signal("move_camera_u")
	if Input.is_action_pressed("move_camera_d"):
		emit_signal("move_camera_d")
	if Input.is_action_pressed("move_camera_r"):
		emit_signal("move_camera_r")
	if Input.is_action_pressed("move_camera_l"):
		emit_signal("move_camera_l")
	if Input.is_action_just_released("zoom_in"):
		emit_signal("zoom_in")
	if Input.is_action_just_released("zoom_out"):
		emit_signal("zoom_out")
	if Input.is_action_just_pressed("select_tile"):
		emit_signal("tile_selected")
