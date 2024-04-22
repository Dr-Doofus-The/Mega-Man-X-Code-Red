extends "res://scripts/entity/EntityBase.gd"

onready var impact_fx = preload("res://nodes/particles/projectiles/player/X/par_rolling_shield_wall_impact.tscn")

var BulletDire = 1

onready var speed = 300

func _ready():
	ent_sprite.animation = "start"
	ent_sprite.frame = 0

func _physics_process(delta):
	
	if is_on_wall():
		BulletDire = BulletDire * -1
		$AudioStreamPlayer.play()
		spawn_impact_fx()
		
	ent_sprite.flip_h = true if BulletDire < 0 else false
	
	
	
	velocity.x = speed * BulletDire * (delta * 60)
	move()


func _on_Hitbox_damage_dealt(_old_hp, new_hp, _target):
	if new_hp > 0:
		queue_free()


func _on_VisibilityNotifier2D_screen_exited():
	queue_free()


func _on_Sprite_animation_finished():
	if ent_sprite.animation == "start":
		ent_sprite.play("default")

func spawn_impact_fx():
	var fx = impact_fx.instance()
	fx.global_position = Vector2(global_position.x + (-BulletDire * 20),global_position.y)
	if BulletDire < 0:
		fx.flip_h = true
	Global.ViewPort.get_child(0).add_child(fx)
