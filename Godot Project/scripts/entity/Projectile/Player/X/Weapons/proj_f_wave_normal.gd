extends "res://scripts/entity/ProjectileBase.gd"

onready var smoke_fx = preload("res://nodes/particles/other/Par_smoke_puff_small.tscn")
onready var bubble_fx = preload("res://nodes/particles/water/par_water_bubble.tscn")

onready var y_movement = sin(float(Engine.get_frames_drawn()) / 8) * 1.5

func _ready():


		
	if randi() % 12 == 0:
		var fx = smoke_fx.instance()
		fx.x_movement = rand_range(1, 5) * BulletDire
		fx.y_movement = rand_range(-2,0)
		fx.global_position = global_position
		Global.ViewPort.add_child(fx)

func _physics_process(delta):
	sprite.offset.y += y_movement * (delta * 60)

func spawn_bubble():
	var fx = bubble_fx.instance()
	fx.x_movement = rand_range(2, 4) * BulletDire
	fx.y_movement = rand_range(-2,-1)
	fx.global_position = global_position
	fx.life_time = 0.5
	Global.ViewPort.get_child(0).call_deferred("add_child",fx)
func _on_Area2D_body_entered(body):
	if body.is_in_group("Water"):
		if randi() % 2 == 0:
			call_deferred("spawn_bubble")
		queue_free()
