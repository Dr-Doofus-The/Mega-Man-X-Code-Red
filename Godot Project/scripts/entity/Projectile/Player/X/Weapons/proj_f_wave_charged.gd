extends "res://scripts/entity/ProjectileBase.gd"

onready var projectile_spawn = preload("res://nodes/entity/Projectile/Player/X/Weapons/proj_X_fire_wave_charged_particle.tscn")

onready var mode = 0
var offset = 22
var velocity = Vector2.ZERO

func _ready():
	$RayCast2D.position.x = offset * BulletDire

func _physics_process(delta):
	
	match mode:
		0:
			velocity.y += delta * 12
			velocity.x = BulletDire * projectile_speed * (delta*60)
			
			position += velocity

func _on_Area2D_body_entered(_body):
	if mode == 0:
		mode = 1
		call_deferred("spawn_pillar",true)
		$Hitbox.set_deferred("monitorable", false)
		visible = false
		$Timer.start()


func spawn_pillar(onself: bool):
	var space_state = get_world_2d().direct_space_state

	var result
	
	if onself:
		result = space_state.intersect_ray(Vector2(global_position.x,global_position.y - 15),Vector2(global_position.x,global_position.y + offset),[self],collision_mask)
	else:
		result = space_state.intersect_ray(Vector2(global_position.x + (BulletDire * offset),global_position.y - 15),Vector2(global_position.x + (BulletDire * offset),global_position.y + offset),[self],collision_mask)

	if result and not $RayCast2D.is_colliding():
		var pillar = projectile_spawn.instance()
		pillar.global_position = result.position
		get_parent().add_child(pillar)
		global_position = result.position
	else:
		queue_free()


func _on_Timer_timeout():
	spawn_pillar(false)
