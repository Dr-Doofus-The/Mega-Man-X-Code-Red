extends "res://scripts/entity/ProjectileBase.gd"

onready var linger = preload("res://nodes/entity/Projectile/Bosses/Hi_Max/Proj_Max_linger.tscn")
func _ready():
	spawn_thing()

func _on_Timer_timeout():
	spawn_thing()

func spawn_thing():
	var proj = linger.instance()
	proj.position = global_position
	Global.ViewPort.add_child(proj)
