extends Node2D

onready var torpedo = preload("res://nodes/entity/Projectile/Player/X/Weapons/proj_homing_torpedo.tscn")

var BulletDire = 1

func _ready():
	for n in [Vector2(0.2,0.4),Vector2(0.6,0.2),Vector2(0.5,0),Vector2(0.2,-0.4),Vector2(0.6,-0.2)]:
		var proj = torpedo.instance()
		proj.global_position = global_position
		proj.start_speed = 200
		proj.charged = true
		proj.BulletDire = BulletDire
		proj.velocity = Vector2(n.x * BulletDire, n.y)
		get_parent().add_child(proj)
	queue_free()
