extends "res://scripts/entity/ProjectileBase.gd"

onready var tween = $Tween
onready var velocity = Vector2.ZERO
onready var accel : Vector2 = Vector2.ZERO


var track_player = false
var up = false
var rot_value = 0
onready var particle_ghost = preload("res://nodes/particles/other/Par_Ghost_Type_2.tscn")

var item_follow

func _ready():
	

	
	if Input.is_action_pressed("up"):
		up = true
	
	velocity.x = projectile_speed * BulletDire
	tween.interpolate_property(self,"velocity:x",velocity.x, -7 * BulletDire ,0.5,Tween.TRANS_LINEAR,Tween.EASE_IN,0.15)
	tween.interpolate_property(self,"velocity:y",0,-6,0.25,Tween.TRANS_LINEAR,Tween.EASE_IN,0.15)
	tween.interpolate_property(self,"velocity:y",-6,1,0.3,Tween.TRANS_LINEAR,Tween.EASE_IN,0.4)
	tween.start()
	

func _physics_process(delta):
	
	if track_player:
		
		var desired = (Global.Player.global_position - global_position).normalized() * projectile_speed

		velocity.x = lerp(velocity.x,desired.x,clamp(Global.time, 0 ,0.3))
		velocity.y = lerp(velocity.y,desired.y,clamp(Global.time, 0 ,0.3))
	position += velocity * (delta * 60)
	
	if item_follow:
		item_follow.velocity = Vector2.ZERO
		item_follow.global_position = global_position
		item_follow.set_collision_mask_bit(0, false)
	
	rot_value += 22.5 * -BulletDire
	
	$AnimatedSprite.rotation_degrees = stepify(rot_value, 25)
	
	if Engine.get_physics_frames() % 4 == 0:
		
		spawn_ghost()
	

func spawn_ghost():
	var fx = particle_ghost.instance()
	fx.texture = $AnimatedSprite.frames.get_frame($AnimatedSprite.animation,$AnimatedSprite.frame)
	fx.scale = $AnimatedSprite.scale
	fx.global_position = global_position
	fx.self_modulate = Color(0.6,0.6,0.9)
	fx.rotation_degrees = $AnimatedSprite.rotation_degrees
	Global.ViewPort.get_child(0).add_child(fx)
	
func _on_Tween_tween_all_completed():
	track_player = true



func _on_Area2D_body_entered(body):
	if track_player and body == Global.Player:
		Global.Player.WeaponManager.weapons[4].ammo += 1
		EventBus.emit_signal("UpdateWeaponInfo")
		queue_free()

	if body.is_in_group("Item_Pickup") and item_follow == null:
		item_follow = body


func _on_Area2D_body_exited(body):
	if body == item_follow:
		
		item_follow = null


func _on_Area2D_tree_exiting():
	if item_follow:
		item_follow.set_collision_mask_bit(0, true)


func _on_Timer_timeout():
	$AudioStreamPlayer.play()
