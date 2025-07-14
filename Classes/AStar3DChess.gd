class_name AStar3DChess
extends AStar3D

func _compute_cost(u, v):
	var u_pos = get_point_position(u)
	var v_pos = get_point_position(v)
	var x_difference = abs(u_pos.x - v_pos.x)
	var z_difference = abs(u_pos.z - v_pos.z) 
	return abs(x_difference - z_difference) + min(x_difference,z_difference) * 1.5

func _estimate_cost(u, v):
	var u_pos = get_point_position(u)
	var v_pos = get_point_position(v)
	var x_difference = abs(u_pos.x - v_pos.x)
	var z_difference = abs(u_pos.z - v_pos.z)
	return abs(x_difference - z_difference) + min(x_difference,z_difference) * 1.5
