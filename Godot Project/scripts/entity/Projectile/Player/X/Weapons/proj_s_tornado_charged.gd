extends "res://scripts/entity/ProjectileBase.gd"

onready var tween = $Tween

func _ready():
	global_position.y = Global.GameCamera.get_camera_screen_center().y
	tween.interpolate_property($Hitbox/CollisionShape2D,"shape:extents:x", 100, 213, 0.8,Tween.TRANS_QUAD,Tween.EASE_OUT)
	tween.interpolate_property(sprite,"scale:x", 2.92,6.65,0.8,Tween.TRANS_QUAD,Tween.EASE_OUT)
	tween.start()
