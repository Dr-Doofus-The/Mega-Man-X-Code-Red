extends Area2D

export var teleport_position : Vector2
export var cam_bounds : NodePath

func _ready():
	pass


func _on_Obj_teleport_area_body_entered(body):
	
	Global.teleport_player(teleport_position,get_node(cam_bounds))
