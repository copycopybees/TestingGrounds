extends Control

@export var tu_label_path : NodePath
@onready var tu_label = get_node(tu_label_path)
@export var enu_label_path : NodePath
@onready var enu_label = get_node(enu_label_path)
@export var unit_name_label_path : NodePath
@onready var unit_name_label = get_node(unit_name_label_path)
@export var movement_unit_container_path : NodePath
@onready var movement_unit_container = get_node(movement_unit_container_path)

func _on_unit_transmitted(unit: Unit) -> void:
	movement_unit_container.show()
	unit_name_label.text = unit.unit_name
	tu_label.text = str(unit.tu)
	enu_label.text = str(unit.enu)

func _ready():
	get_tree().root.connect('size_changed', _on_screen_resized)

func _on_screen_resized():
	var screen_size = get_tree().root.get_visible_rect().size
	if screen_size.x/screen_size.y > 4.0/3.0:
		position.x = (screen_size.x - size.x)/2
	else:
		position.y = (screen_size.y - size.y)
