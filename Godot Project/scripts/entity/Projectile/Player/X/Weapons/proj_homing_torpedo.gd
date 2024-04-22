extends "res://scripts/entity/ProjectileBase.gd"

onready var smoke_fx = preload("res://nodes/particles/other/Par_smoke_puff_small.tscn")
onready var explosion_fx = preload("res://nodes/particles/other/Par_Explosion_Standard.tscn")
onready var bubble_fx = preload("res://nodes/particles/water/par_water_bubble.tscn")

onready var current_target = null
onready var thrust_sound = $AudioStreamPlayer
var charged = false
onready var velocity : Vector2
onready var accel : Vector2 = Vector2.ZERO
var start_speed = 80
var can_track = false
var has_tracked = false

var steering = false


func _ready():
	var _con = $Hitbox.connect("damage_dealt",self,"explode")
	if not charged:
		velocity = Vector2.RIGHT if BulletDire > 0 else Vector2.LEFT
		thrust_sound.volume_db = -3
		sprite.animation = "default"
		sprite.offset.x = -7
	else:
		thrust_sound.volume_db = -14
		sprite.animation = "Up"
		sprite.offset.x = 0
	rotation = velocity.angle()
	velocity = velocity * start_speed

	
	$AnimatedSprite/AnimatedSprite.visible = false
func _physics_process(delta):

	if current_target and can_track || charged and can_track and not has_tracked:
		accel += seek()
	
	else:
		accel = velocity * 5

	if steering:
		projectile_speed = lerp(projectile_speed, 100, 0.1)
	else:
		projectile_speed = lerp(projectile_speed, 450, 0.2)

	velocity += accel * delta
	velocity = velocity.clamped(projectile_speed)
	

	rotation = velocity.angle()
	position += velocity * delta
	
	sprite.rotation_degrees = (self.rotation_degrees * -1) + stepify(rotation_degrees, 18)

	if can_track and Engine.get_physics_frames() % 3 == 0:

		if get_overlapping_bodies().size() > 0 and get_overlapping_bodies()[0].is_in_group("Water"):
			call_deferred("spawn_bubble")
			$AnimatedSprite/AnimatedSprite.visible = false
		else:
			call_deferred("spawn_smoke")
			$AnimatedSprite/AnimatedSprite.visible = true

	if rotation_degrees >= 90 or rotation_degrees <= -90:
		sprite.flip_v = true
	else:
		sprite.flip_v = false
		



func _on_Enemy_Detector_body_entered(body):
	if current_target == null:
		current_target = body


func _on_Enemy_Detector_body_exited(body):
	if current_target == body:
		current_target = null
		steering = false
		

func seek():
	var steer = Vector2.ZERO
	var desired = Vector2.ZERO
	
	
	
	if current_target:
		desired = (current_target.global_position - global_position).normalized() * projectile_speed
		has_tracked = true
	else:
		desired = (Vector2(global_position.x + (BulletDire * 10), global_position.y) - global_position).normalized() * projectile_speed

	
	
	steer = (desired - velocity).normalized() * 250
	
	if current_target:
		if abs(desired.angle() - velocity.angle()) > 1:
			steering = true
		else:
			steering = false
	
	return steer
	
	
func explode(_1,_2,_3):
	var fx = explosion_fx.instance()
	fx.global_position = global_position
	Global.ViewPort.get_child(0).add_child(fx)
	Sound.play_standard_explosion_sound()


func _on_Timer_timeout():
	can_track = true
	$AnimatedSprite/AnimatedSprite.visible = true
	$AudioStreamPlayer.play()



func spawn_smoke():

	var fx = smoke_fx.instance()
	fx.global_position = $AnimatedSprite/Smoke_fx_spawn_point.global_position
	if randi() % 2 == 0:
		fx.flip_h = true
	Global.ViewPort.get_child(0).add_child(fx)		
		
func spawn_bubble():
	var fx = bubble_fx.instance()
	fx.global_position = $AnimatedSprite/Smoke_fx_spawn_point.global_position
	fx.life_time = 0.4
	if randi() % 2 == 0:
		fx.flip_h = true

	Global.ViewPort.get_child(0).add_child(fx)
