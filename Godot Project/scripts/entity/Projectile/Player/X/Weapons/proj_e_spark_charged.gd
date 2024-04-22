extends Node

onready var wall = preload("res://nodes/entity/Projectile/Player/X/Weapons/proj_X_e_spark_charged.tscn")

func _ready():
	for n in [-1, 1]:
		var proj = wall.instance()
		proj.global_position = Global.Player.global_position
		proj.BulletDire = n
		get_parent().add_child(proj)
	queue_free()
