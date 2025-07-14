class_name HumanUnit
extends Unit

func _init():
	unit_type = UNIT_TYPE.HUMAN
	max_tu = 50
	tu = 50
	max_enu = 30
	enu = 30


func go_prone():
	print('prone')
