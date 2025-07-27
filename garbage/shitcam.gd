extends Camera3D

@export var move_speed := 5.0
@export var boost_speed := 20.0
@export var mouse_sensitivity := 0.002
@export var invert_y := false

var _rotation := Vector2.ZERO
var _boosting := false

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _input(event):
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		_rotation.x -= event.relative.y * mouse_sensitivity * (-1 if invert_y else 1)
		_rotation.y -= event.relative.x * mouse_sensitivity
		_rotation.x = clamp(_rotation.x, deg_to_rad(-89), deg_to_rad(89))
		rotation = Vector3(_rotation.x, _rotation.y, 0)

	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_ESCAPE:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func _process(delta):
	var dir := Vector3.ZERO

	# Movement
	if Input.is_action_pressed("move_camera_u"):
		dir -= transform.basis.z
	if Input.is_action_pressed("move_camera_d"):
		dir += transform.basis.z
	if Input.is_action_pressed("move_camera_l"):
		dir -= transform.basis.x
	if Input.is_action_pressed("move_camera_r"):
		dir += transform.basis.x
	if Input.is_action_pressed("space"):
		dir += transform.basis.y
	if Input.is_action_pressed("ctrl"):
		dir -= transform.basis.y

	dir = dir.normalized()

	# Boosting (Shift key)
	var speed = move_speed

	# Move the camera
	position += dir * speed * delta
