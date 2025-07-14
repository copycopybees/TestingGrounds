extends Node3D

# Orientation Code:
# 0: 0 degrees
# 22: 90 degrees
# 10: 180 degrees
# 16: 270 degrees

signal terrain_bounds(bounds : Rect2)

var mapgrid_floor: AStar3DChess
var rng = RandomNumberGenerator.new()

var man_prefab := preload("res://Scenes/Prefabs/man.tscn")
var mci_prefab := preload("res://Scenes/Prefabs/movement_cost_indicator.tscn")
var player_units := preload("res://Data/Player/player_squad.json").data
var enemy_units := preload("res://Data/Faction Prefabs/test_faction_squad.json").data


var units : Array[Unit] = []
var selected_unit_index := -1
var unit_selected := false
var unit_to_move : Unit
var unit_path : PackedVector3Array
var travel_timer = 0.0
var path_index = 0
var last_clicked_cell := Vector3i(1000,0,1000)
var move_unit := false
var movement_cancelled := false
var present_teams : Array
var current_team : int

const TRAVEL_TIME = 0.6
enum WALL_TYPES {PLUS, WALL, CORNER, T, HALFWALL}
enum WALL_EXTENDS {NONE, UP, RIGHT, DOWN=4, LEFT=8, ALL=15}
enum DIRECTIONS {NW, N, NE, W, E, SW, S, SE}

@onready var terrain_cells = $TerrainMap.get_used_cells()

@onready var wall_map = $WallMap

@onready var path_multimesh = $PathArrow.multimesh

@onready var select_floor = $Pivot/SelectFloor

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_generate_navgrid()
	_initialise_units()
	var bounds : Rect2
	for i in terrain_cells.size():
		if terrain_cells[i].x < bounds.position.x:
			bounds.position.x = terrain_cells[i].x * 1.5
		elif terrain_cells[i].x > bounds.end.x:
			bounds.end.x = (terrain_cells[i].x + 1) * 1.5
		if terrain_cells[i].z < bounds.position.y:
			bounds.position.y = terrain_cells[i].z * 1.5
		elif terrain_cells[i].z > bounds.end.y:
			bounds.end.y = (terrain_cells[i].z + 1) * 1.5
	terrain_bounds.emit(bounds)
	_gather_present_teams()
	for unit in units:
		print(unit.unit_team)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if current_team == 0:
		_move_unit(delta)

func _generate_navgrid():
	mapgrid_floor = AStar3DChess.new()
	for i in terrain_cells.size():
		mapgrid_floor.add_point(i, terrain_cells[i])
	for i in mapgrid_floor.get_point_ids():
		var pos = mapgrid_floor.get_point_position(i)
		var cells_to_check = [
			Vector3i(pos.x-1,0,pos.z-1),Vector3i(pos.x,0,pos.z-1),Vector3i(pos.x+1,0,pos.z-1),
			Vector3i(pos.x-1,0,pos.z),                           Vector3i(pos.x+1,0,pos.z),
			Vector3i(pos.x-1,0,pos.z+1),Vector3i(pos.x,0,pos.z+1),Vector3i(pos.x+1,0,pos.z+1)
		]
		for j in DIRECTIONS.size():
			var cell = cells_to_check[j]
			var cell_id = validate_cell(Vector3(cell))
			
			if cell_id != -1:
				if not check_if_connection_blocked(pos, j):
					mapgrid_floor.connect_points(i,cell_id)


func _on_cell_selected(cell: Vector3i) -> void:
	if move_unit:
		return
	unit_selected = false
	for i in units.size():
		var unit = units[i]
		if unit.position != cell:
			continue
		if unit.unit_team != unit.UNIT_TEAM.PLAYER:
			continue
		unit_selected = true
		if selected_unit_index >= 0:
			deselect_unit(selected_unit_index)
		select_unit(i)
		break
	if not unit_selected and selected_unit_index >= 0:
		_set_unit_destination(selected_unit_index, cell)
		last_clicked_cell = cell

func _initialise_units():
	var i = 0
	for unit in player_units.units:
		var man_node := man_prefab.instantiate()
		var man_unit := HumanUnit.new()
		var pos = terrain_cells[i]
		man_unit.position = pos
		man_node.transform.origin = pos * 1.5
		man_unit.graphics_node = man_node
		$UnitContainer.add_child(man_node)
		man_unit.unit_name = unit.unit_name
		man_unit.unit_team = man_unit.UNIT_TEAM.PLAYER
		i += 1
		units.append(man_unit)
	i = 1
	for unit in enemy_units.units:
		var man_node := man_prefab.instantiate()
		var man_unit := HumanUnit.new()
		var pos = terrain_cells[-i]
		man_unit.position = pos
		man_node.transform.origin = pos * 1.5
		man_unit.graphics_node = man_node
		$UnitContainer.add_child(man_node)
		man_unit.unit_name = unit.unit_name
		man_unit.unit_team = man_unit.UNIT_TEAM.ENEMY
		i += 1
		units.append(man_unit)

func validate_cell(cell : Vector3, unit_id : int = -1):
	var cell_id = mapgrid_floor.get_closest_point(cell)
	if (cell - mapgrid_floor.get_point_position(cell_id)).length() > 0.5:
		return - 1
	for i in units.size():
		var unit = units[i]
		if i != unit_id:
			if (Vector3(unit.position) - cell).length() < 0.5:
				return - 1
	return cell_id

func _set_unit_destination(unit_index : int, target : Vector3i):
	if target == last_clicked_cell:
		unit_to_move = units[unit_index]
		move_unit = true
	else:
		var start = validate_cell(units[unit_index].position, unit_index)
		var end = validate_cell(target)
		
		var path = mapgrid_floor.get_point_path(start,end)
		if path.size() >= 2:
			unit_to_move = units[unit_index]
			unit_path = path
			path_multimesh.visible_instance_count = 0
			for i in $MCIContainer.get_children().size():
				$MCIContainer.get_children()[i].queue_free()
			draw_path_graphics(path)


			

func _move_unit(delta):
	if move_unit:
		if unit_to_move.tu == 0 or unit_to_move.enu == 0:
			unit_to_move = null
			move_unit = false
			path_index = 0
			movement_cancelled = false
			unit_path = []
			path_multimesh.visible_instance_count = 0
			for i in $MCIContainer.get_children().size():
				$MCIContainer.get_children()[i].queue_free()
			last_clicked_cell = Vector3i(100,100,100)
			return
		var start = unit_path[path_index]
		var end = unit_path[path_index+1]
		travel_timer += delta
		if Input.is_action_just_pressed('cancel_movement'):
			movement_cancelled = true
			for unit in units:
				if Vector3(unit.position) != unit_path[path_index+1]:
					continue
				else:
					movement_cancelled = false
					break
		if travel_timer < TRAVEL_TIME:
			unit_to_move.graphics_node.transform.origin = lerp(start, end, travel_timer/TRAVEL_TIME) * 1.5
		else:
			unit_to_move.graphics_node.transform.origin = end * 1.5
			travel_timer = 0.0
			unit_to_move.position = end
			path_index += 1
			unit_to_move.tu -= 5
			unit_to_move.enu -= 2
			if path_index >= unit_path.size()-1 or movement_cancelled or unit_to_move.tu == 0 or unit_to_move.enu == 0:
				unit_to_move = null
				move_unit = false
				path_index = 0
				movement_cancelled = false
				unit_path = []
				path_multimesh.visible_instance_count = 0
				for i in $MCIContainer.get_children().size():
					$MCIContainer.get_children()[i].queue_free()
				last_clicked_cell = Vector3i(100,100,100)

func get_wall_extends(cell):
	var wall = wall_map.get_cell_item(cell)
	var wall_orientation = wall_map.get_cell_item_orientation(cell)
	match wall:
		WALL_TYPES.CORNER:
			match wall_orientation:
				0: return WALL_EXTENDS.RIGHT + WALL_EXTENDS.DOWN
				22: return WALL_EXTENDS.DOWN + WALL_EXTENDS.LEFT
				10: return WALL_EXTENDS.LEFT + WALL_EXTENDS.UP
				16: return WALL_EXTENDS.UP + WALL_EXTENDS.RIGHT
		WALL_TYPES.WALL:
			match wall_orientation:
				0, 10: return WALL_EXTENDS.LEFT + WALL_EXTENDS.RIGHT
				22, 16: return WALL_EXTENDS.UP + WALL_EXTENDS.DOWN
		WALL_TYPES.PLUS:
			return WALL_EXTENDS.ALL
		WALL_TYPES.HALFWALL:
			match wall_orientation:
				0: return WALL_EXTENDS.RIGHT
				22: return WALL_EXTENDS.DOWN
				10: return WALL_EXTENDS.LEFT
				16: return WALL_EXTENDS.UP
		WALL_TYPES.T:
			match wall_orientation:
				0: return WALL_EXTENDS.ALL - WALL_EXTENDS.UP
				22: return WALL_EXTENDS.ALL - WALL_EXTENDS.RIGHT
				10: return WALL_EXTENDS.ALL - WALL_EXTENDS.DOWN
				16: return WALL_EXTENDS.ALL - WALL_EXTENDS.LEFT
	return WALL_EXTENDS.NONE

func check_if_connection_blocked(cell:Vector3i, connection:int):
	var our_cell = get_wall_extends(cell)
	var right_cell = get_wall_extends(cell + Vector3i(1,0,0))
	var down_cell = get_wall_extends(cell + Vector3i(0,0,1))
	var down_right_cell = get_wall_extends(cell + Vector3i(1,0,1))
	match connection:
		DIRECTIONS.NE:
			return right_cell>0
		DIRECTIONS.NW:
			return our_cell>0
		DIRECTIONS.SE:
			return down_right_cell>0
		DIRECTIONS.SW:
			return down_cell>0
		DIRECTIONS.N:
			return our_cell & WALL_EXTENDS.RIGHT and right_cell & WALL_EXTENDS.LEFT
		DIRECTIONS.E:
			return right_cell & WALL_EXTENDS.DOWN and down_right_cell & WALL_EXTENDS.UP
		DIRECTIONS.S:
			return down_cell & WALL_EXTENDS.RIGHT and down_right_cell & WALL_EXTENDS.LEFT
		DIRECTIONS.W:
			return our_cell & WALL_EXTENDS.DOWN and down_cell & WALL_EXTENDS.UP
	return false

func deselect_unit(unit):
	units[unit].graphics_node.deselect()
	unit_to_move = null
	move_unit = false
	path_index = 0
	movement_cancelled = false
	unit_path = []
	path_multimesh.visible_instance_count = 0
	for i in $MCIContainer.get_children().size():
		$MCIContainer.get_children()[i].queue_free()
	last_clicked_cell = Vector3i(100,100,100)
	selected_unit_index = -1
	
func select_unit(unit):
	units[unit].graphics_node.select()
	selected_unit_index = unit

func draw_path_graphics(path : PackedVector3Array):
	path_multimesh.visible_instance_count = path.size()-1
	for i in min(path.size()-1, 100):
		var movement_cost_indicator = mci_prefab.instantiate()
		var arrow_color = Color(0,1,0)
		var cell_xform = Transform3D()
		var path_from2d = Vector2(path[i].x, path[i].z)
		var path_to2d = Vector2(path[i+1].x, path[i+1].z)
		cell_xform = cell_xform.rotated(Vector3(0,1,0), -path_from2d.angle_to_point(path_to2d))
		cell_xform.origin = (path[i] + path[i+1]) * 1.5 / 2 + Vector3(0.75, 0, 0.75)
		movement_cost_indicator.position = path[i+1] * 1.5 + Vector3(1, 0, 0.5)
		path_multimesh.set_instance_transform(i, cell_xform )
		
		var tu = unit_to_move.tu - 5 * (i+1)
		var enu = unit_to_move.enu - 2 * (i+1)
		movement_cost_indicator.text = "🕓" + str(tu) + "\n🗲" + str(enu)
		if tu < 0 or enu < 0:
			arrow_color -= Color(0,1,0)
			if tu < 0:
				arrow_color += Color(1,0,0)
			if enu < 0:
				arrow_color += Color(0,0,1)
		path_multimesh.set_instance_color(i, arrow_color)
		$MCIContainer.add_child(movement_cost_indicator)


func _on_end_turn() -> void:
	if not move_unit:
		for unit in units:
			if unit.unit_team == current_team:
				unit.tu = unit.max_tu
				unit.enu = unit.max_enu
		#var team_index = present_teams.bsearch(current_team)
		#if present_teams.get(team_index + 1):
			#current_team = present_teams[team_index + 1]
		#else:
			#current_team = present_teams[0]

func _gather_present_teams():
	for unit in units:
		var unit_team = unit.unit_team
		if not present_teams.has(unit_team):
			present_teams.append(unit_team)
