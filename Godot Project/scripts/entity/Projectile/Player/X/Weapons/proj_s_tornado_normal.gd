extends "res://scripts/entity/ProjectileBase.gd"

onready var tor_sprite = preload("res://nodes/entity/Projectile/Player/X/Weapons/proj_X_s_tornado_sprite.tscn")

onready var impact_effect = preload("res://nodes/particles/projectiles/player/par_x_buster_1_impact.tscn")
onready var bubble_effect = preload("res://nodes/particles/water/par_water_bubble.tscn")

var tornado_spawn_count = 10
var build_up_offset = 2.8

func _ready():
	spawn_sprite()
	start_timer()
	$Hitbox/CollisionShape2D.shape.extents.x = 24
	$Hitbox.position.x = 0
	var _con = $Hitbox.connect("damage_dealt",self,"spawn_impact_fx")
	
	
func _physics_process(_delta):
	build_up_offset = clamp(build_up_offset,1,4)
	projectile_speed = 7/build_up_offset
	
	#if Engine.get_physics_frames()%3 == 0:
	#	spawn_bubble()

func spawn_sprite():
	var fx = tor_sprite.instance()
	fx.position.x = (abs(tornado_spawn_count - 10)*14) * -BulletDire
	fx.time_offset = abs(tornado_spawn_count - 10)
	if BulletDire < 0:
		fx.flip_h = true
	$Sprite_holder.add_child(fx)
	$Hitbox/CollisionShape2D.shape.extents.x += 6
	$Hitbox.position.x += 6 * -BulletDire
	tornado_spawn_count -= 1
	build_up_offset -= 0.22
	start_timer()

func spawn_bubble():

	
	for n in clamp($Sprite_holder.get_child_count(),0,6):
		var fx = bubble_effect.instance()
		var y_offset = rand_range(4,7) if Engine.get_physics_frames()%2 == 0 else rand_range(-4,-7)
		fx.global_position = Vector2(global_position.x + (((n * -BulletDire) * 15)), global_position.y + (y_offset* 5))
		fx.y_movement = -0
		fx.y_sine_movement = -y_offset
		fx.y_sine_time_multiplier = 24
		fx.life_time = 0.15
		Global.ViewPort.get_child(0).call_deferred("add_child",fx)

func spawn_impact_fx(_old_hp,_new_hp,target):
	var fx = impact_effect.instance()
	fx.global_position = Vector2(target.global_position.x + (global_position.x - target.global_position.x)/10, target.global_position.y + (global_position.y - target.global_position.y)/5 + rand_range(-1,1))
	Global.ViewPort.get_child(0).call_deferred("add_child",fx)

func start_timer():
	$Timer.start(0.04 * build_up_offset)

func _on_Timer_timeout():
	if tornado_spawn_count > 0:
		spawn_sprite()
	else:
		$Timer.stop()
