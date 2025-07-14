class_name Unit
extends Object

enum UNIT_TYPE {HUMAN}
enum UNIT_TEAM {PLAYER,ENEMY,ALLY}

var position : Vector3i
var graphics_node : Node3D
var unit_name : String
var tu : int
var max_tu : int
var enu : int
var max_enu : int
var unit_type : UNIT_TYPE
var unit_team : UNIT_TEAM
