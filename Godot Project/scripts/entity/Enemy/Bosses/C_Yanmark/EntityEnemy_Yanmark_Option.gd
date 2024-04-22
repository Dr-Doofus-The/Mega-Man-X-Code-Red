extends "res://scripts/entity/Enemy/EntityEnemy.gd"

onready var movetween = $Tween
onready var shield_location = global_position
onready var center_location = get_parent().global_position

onready var projectile = preload("res://nodes/entity/Projectile/Bosses/Yanmark/Yanmark_bullet.tscn")

func _ready():
	movetween.interpolate_property(self, "global_position", center_location, shield_location, 0.5, Tween.TRANS_SINE, Tween.EASE_OUT)
	movetween.start()
	get_parent().get_parent().visible = true


func _process(_delta):
	ent_sprite.rotation_degrees = get_parent().get_parent().rotation_degrees * -1
func _on_Timer_timeout():
	var y_shot = projectile.instance()
	
	y_shot.position = global_position
	y_shot.rotation = (Global.Player.global_position - global_position).angle()
	Global.ViewPort.add_child(y_shot)
