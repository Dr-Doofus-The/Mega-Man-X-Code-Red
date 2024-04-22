extends "res://scripts/entity/ProjectileBase.gd"

onready var trail = preload("res://nodes/particles/projectiles/player/X/par_x_buster_4_trail.tscn")

onready var y_position = position.y

var move = false


var direction = int(rand_range(-1,1))


func _ready():
	sprite.frame = 0
	sprite.playing = true
	var _con = connect("projectile_exiting",self,"_on_damage_dealt")

func _physics_process(delta):
	if move:
		projectile_speed = 9
		
		
		
	
		
		position.y = (sin(Global.time* 20) * 16) + y_position

			
		if Engine.get_physics_frames() % 2 == 0:
			spawn_particle()

func spawn_particle():
	var par = trail.instance()
	par.global_position = Vector2(global_position)
	par.flip_h = true if BulletDire < 0 else false
	par.x_movement = 2.6* BulletDire
	par.y_movement = -(sin(Global.time* 20) * 0.5)
	Global.ViewPort.add_child(par)

func _on_damage_dealt():
	Sound.play_sound(Sound.SND_PRJ_ENERGY_EXP,2,1.01)
	var damage_thing = hitbox.new()
	damage_thing.temporary = true
	damage_thing.size = Vector2(26,26)
	damage_thing.time = 0.2
	damage_thing.set_collision_layer_bit(0,false)
	damage_thing.set_collision_layer_bit(4,true)
	damage_thing.set_collision_mask_bit(2,true)
	damage_thing.set_collision_mask_bit(0,false)
	damage_thing.damage = 3
	damage_thing.global_position = global_position

	var spr = AnimatedSprite.new()
	spr.z_index = 2
	spr.frames = sprite.frames
	spr.flip_h = true if randi()%2 == 0 else false
	spr.flip_v = true if randi()%2 == 0 else false
	
	Global.ViewPort.get_child(0).add_child(damage_thing)
	damage_thing.add_child(spr)
	spr.play("explosion")
	spr.frame = 0


func _on_AnimatedSprite_animation_finished():
	move = true


func _on_Timer_timeout():
	spawn_particle()
