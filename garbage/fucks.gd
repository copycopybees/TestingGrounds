extends MultiMeshInstance3D

var t := 0.0
var n := 200
var s := 5.0

func _ready() -> void:
	multimesh.visible_instance_count = n
	
func _process(delta: float) -> void:
	t += delta * s
	for i in n:
		var a : float = (i - floor(t * s)) * PI * (3 - sqrt(5.0))
		var r := (i + fmod(t, 1.0)) * 0.1
		var xform : Transform3D = Transform3D()
		xform.origin = Vector3(r * cos(a), 0.0			, r * sin(a))
		multimesh.set_instance_transform(i, xform)
