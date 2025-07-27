extends MeshInstance3D
const DENSITY := 8
const LENGTH := 200.0
@export var material : Material

func update_cone(unit_pos:Vector3,dir:float,dispersion:float,spread:float):
	clear_cone()
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
		var start_vert = Vector3(0,sin(-TAU/DENSITY*i) * dispersion,cos(-TAU/DENSITY*i) * dispersion).rotated(Vector3.UP,dir)
		var end_vert =  Vector3(LENGTH,sin(-TAU/DENSITY*i) * outer_radius,cos(-TAU/DENSITY*i) * outer_radius).rotated(Vector3.UP,dir)
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
	surface_array[Mesh.ARRAY_VERTEX] = verts
	surface_array[Mesh.ARRAY_TEX_UV] = uvs
	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLE_STRIP, surface_array)
	mesh.surface_set_material(0, material)

func clear_cone():
	mesh.clear_surfaces()
