extends MeshInstance3D

const DENSITY := 64
const LENGTH := 128.0
const SUBDIVISIONS := 8

@export var material : ShaderMaterial

func _create_tristrip(unit_pos:Vector3, dir:float, dispersion:float, spread:float):
	var surface_array = []
	surface_array.resize(Mesh.ARRAY_MAX)
	var verts = PackedVector3Array()
	verts.resize((DENSITY+1)*4)
	var uvs = PackedVector2Array()
	uvs.resize((DENSITY+1)*4)
	#var normals = PackedVector3Array()
	#normals.resize((DENSITY+1)*4)
	var outer_radius = tan(spread) * LENGTH + dispersion
	for i in DENSITY+1:
		var start_vert = unit_pos + Vector3(0,sin(-TAU/DENSITY*i) * dispersion,cos(-TAU/DENSITY*i) * dispersion).rotated(Vector3.UP,dir)
		var end_vert = unit_pos + Vector3(LENGTH,sin(-TAU/DENSITY*i) * outer_radius,cos(-TAU/DENSITY*i) * outer_radius).rotated(Vector3.UP,dir)
		verts[i*2] = start_vert
		verts[i*2+1] = end_vert
		uvs[i*2] = Vector2(float(i)/DENSITY,0)
		uvs[i*2+1] = Vector2(float(i)/DENSITY,1)
	var j = DENSITY+1
	for i in DENSITY+1:
		var start_vert = unit_pos + Vector3(0,sin(-TAU/DENSITY*j) * dispersion,cos(-TAU/DENSITY*j) * dispersion).rotated(Vector3.UP,dir)
		var end_vert =  unit_pos + Vector3(LENGTH,sin(-TAU/DENSITY*j) * outer_radius,cos(-TAU/DENSITY*j) * outer_radius).rotated(Vector3.UP,dir)
		j -= 1
		verts[(DENSITY+1) * 2 + i*2] = start_vert
		verts[(DENSITY+1) * 2 + i*2+1] = end_vert
		uvs[(DENSITY+1) * 2 + i*2] = Vector2(1.0 - float(i)/DENSITY,0)
		uvs[(DENSITY+1) * 2 + i*2+1] = Vector2(1.0 - float(i)/DENSITY,1)
		#uvs[(DENSITY+1) * 2 + i*2] = Vector2(1.0,0)
		#uvs[(DENSITY+1) * 2 + i*2+1] = Vector2(1.0,1)
	surface_array[Mesh.ARRAY_VERTEX] = verts
	surface_array[Mesh.ARRAY_TEX_UV] = uvs
	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLE_STRIP, surface_array)
	mesh.surface_set_material(0, material)

func _create_tristrip_rings(unit_pos:Vector3, dir:float, dispersion:float, spread:float):
	for subdiv in SUBDIVISIONS:
		var surface_array = []
		surface_array.resize(Mesh.ARRAY_MAX)
		var verts = PackedVector3Array()
		verts.resize((DENSITY+1)*4)
		var uvs = PackedVector2Array()
		uvs.resize((DENSITY+1)*4)
		
		var inner_distance = LENGTH * subdiv / SUBDIVISIONS
		var outer_distance = LENGTH * (subdiv + 1.0) / SUBDIVISIONS
		var inner_radius = tan(spread) * inner_distance + dispersion
		var outer_radius = tan(spread) * outer_distance + dispersion
		
		for i in DENSITY+1:
			var start_vert = unit_pos + Vector3(inner_distance, sin(-TAU/DENSITY*i) * inner_radius, cos(-TAU/DENSITY*i) * inner_radius).rotated(Vector3.UP,dir)
			var end_vert = unit_pos + Vector3(outer_distance, sin(-TAU/DENSITY*i) * outer_radius, cos(-TAU/DENSITY*i) * outer_radius).rotated(Vector3.UP,dir)
			verts[i*2] = start_vert
			verts[i*2+1] = end_vert
			uvs[i*2] = Vector2(float(i)/DENSITY,0)
			uvs[i*2+1] = Vector2(float(i)/DENSITY,1)
		var j = DENSITY+1
		for i in DENSITY+1:
			var start_vert = unit_pos + Vector3(inner_distance, sin(-TAU/DENSITY*j) * inner_radius, cos(-TAU/DENSITY*j) * inner_radius).rotated(Vector3.UP,dir)
			var end_vert =  unit_pos + Vector3(outer_distance, sin(-TAU/DENSITY*j) * outer_radius,cos(-TAU/DENSITY*j) * outer_radius).rotated(Vector3.UP,dir)
			j -= 1
			verts[(DENSITY+1) * 2 + i*2] = start_vert
			verts[(DENSITY+1) * 2 + i*2+1] = end_vert
			uvs[(DENSITY+1) * 2 + i*2] = Vector2(1.0 - float(i)/DENSITY,0)
			uvs[(DENSITY+1) * 2 + i*2+1] = Vector2(1.0 - float(i)/DENSITY,1)
		surface_array[Mesh.ARRAY_VERTEX] = verts
		surface_array[Mesh.ARRAY_TEX_UV] = uvs
		mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLE_STRIP, surface_array)
		mesh.surface_set_material(subdiv, material)

func update_cone(unit_pos:Vector3, dir:float, dispersion:float, spread:float):
	clear_cone()
	#_create_tristrip(unit_pos, dir, dispersion, spread)
	_create_tristrip_rings(unit_pos, dir, dispersion, spread)
	#material.set_shader_parameter("angle", spread)

func clear_cone():
	mesh.clear_surfaces()
