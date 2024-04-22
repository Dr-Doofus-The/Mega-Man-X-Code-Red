extends KinematicBody2D



onready var og_pos = position
var velocity = Vector2(0,rand_range(-1,1))
var sinking = false
var x_offset = 0.5

export (int) var sinking_speed = 50

export (int) var sinking_pos


func _physics_process(delta):
	
	var dir = og_pos - position if sinking == false else Vector2(global_position.x,sinking_pos) - position
	
	if sinking:
		dir = dir.normalized() * 0.12
		velocity = velocity.clamped(1.0)	
	else:
		dir = dir.normalized() * 0.03
		velocity = velocity.clamped(0.8)
	velocity += dir * (delta * 60)
	
	var distance_value = clamp(0.65 - (global_position.distance_to(Vector2(global_position.x,sinking_pos)) * 0.015),0,1)
	get_material().set_shader_param("color_palette_modifier",distance_value)
	position.y += velocity.y


	if $RayCast2D.is_colliding():
		sinking = true
		if Engine.get_physics_frames()% 2 == 0:
			x_offset *= -1
	else:
		sinking = false
