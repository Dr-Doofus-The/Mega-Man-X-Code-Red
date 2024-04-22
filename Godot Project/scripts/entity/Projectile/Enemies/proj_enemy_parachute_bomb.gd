extends "res://scripts/entity/ProjectileBase.gd"



onready var falling = false

onready var start_postion = global_position

func _ready():

	sprite.rotation_degrees = 180
	
	var distance_multiplier = clamp(global_position.distance_to(Global.Player.global_position) / 130,2,10)
	
	var sprite_rotate_to = 0 if global_position.x > Global.Player.global_position.x else 360
	$Tween.interpolate_property(self,"global_position:x",start_postion.x,Global.Player.global_position.x,0.4 * distance_multiplier,Tween.TRANS_QUAD,Tween.EASE_OUT)
	$Tween.interpolate_property(self,"global_position:y",start_postion.y,start_postion.y - 80,0.2 * distance_multiplier,Tween.TRANS_CIRC,Tween.EASE_OUT)
	$Tween.interpolate_property(self,"global_position:y",start_postion.y - 80,start_postion.y - 30,0.25 * distance_multiplier,Tween.TRANS_SINE,Tween.EASE_IN,0.2 * distance_multiplier)
	$Tween.interpolate_property(sprite,"rotation_degrees",180,sprite_rotate_to,0.3 * distance_multiplier,Tween.TRANS_LINEAR,Tween.EASE_IN,0.03 * distance_multiplier)
	$Tween.start()

func _physics_process(delta):
	if falling:
		

		if get_overlapping_bodies().size() > 0:
			queue_free()
		position.y += 2 * (delta * 60)
		
	if sprite.animation == "open":
		var sin_multiplier = sin(Global.time * 4) * 1
		position.x += sin_multiplier
		

	
	
	
func _on_Tween_tween_all_completed():
	falling = true


func _on_Timer_timeout():

	sprite.play("open")


func _on_Area2D_tree_exiting():
	var fx = Assets.PAR_EXPLOSION_STANDARD.instance()
	fx.global_position = global_position
	Global.ViewPort.call_deferred("add_child",fx)
	Sound.play_standard_explosion_sound()
