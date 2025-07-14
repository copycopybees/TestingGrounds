extends Camera3D
const RAY_LENGTH = 1000.0
signal selector_ray_casted(mousepos : Vector3)
signal highlight_ray_casted(mousepos : Vector3)
signal cell_selected(cell: Vector3i)
var mousepos : Vector3
var bounds_position : Vector3
var bounds_end : Vector3
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	var space_state = get_world_3d().direct_space_state
	var view_mousepos = get_viewport().get_mouse_position()
	var origin = project_ray_origin(view_mousepos)
	var end = origin + project_ray_normal(view_mousepos) * RAY_LENGTH
	var query = PhysicsRayQueryParameters3D.create(origin, end, 0b0010, [self])
	query.collide_with_areas = true
	var intersect = space_state.intersect_ray(query)
	if intersect.has('position'):
		if intersect.position.y < 0:
			intersect.position.y = 0
		mousepos = 1.5 * floor(intersect.position.clamp(bounds_position, bounds_end + Vector3(0, 0, 1.5)) / 1.5)
		highlight_ray_casted.emit(mousepos)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("select_tile"):
		selector_ray_casted.emit(mousepos)
		var selected_cell = Vector3i(mousepos/1.5)
		cell_selected.emit(selected_cell)
		


func _on_battlescape_terrain_bounds(battlescape_bounds: Rect2) -> void:
	bounds_position = Vector3(battlescape_bounds.position.x, 0, battlescape_bounds.position.y)
	bounds_end = Vector3(battlescape_bounds.end.x, 0, battlescape_bounds.end.y)
