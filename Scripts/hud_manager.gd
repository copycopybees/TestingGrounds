extends SubViewport

@export var tu_label_path : NodePath
@onready var tu_label = get_node(tu_label_path)
@export var enu_label_path : NodePath
@onready var enu_label = get_node(enu_label_path)
@export var unit_name_label_path : NodePath
@onready var unit_name_label = get_node(unit_name_label_path)

func _on_unit_transmitted(unit: Unit) -> void:
	$HBoxContainer.show()
	unit_name_label.text = unit.unit_name
	tu_label.text = str(unit.tu)
	enu_label.text = str(unit.enu)
