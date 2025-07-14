extends Node3D

@onready var mesh = $metarig/Skeleton3D/mesh
@export var outline_material : Material

func select():
	mesh.material_overlay = outline_material

func deselect():
	mesh.material_overlay = null
