extends KinematicBody2D

onready var time_offset = rand_range(-10.0, 10.0)

onready var Pos_Vec = position
onready var Float_Vec = Vector2.ZERO

onready var Knockback_Vec = Vector2.ZERO
onready var Knockback_Desired_Vec = Vector2.ZERO


func _physics_process(delta):

	
	Float_Vec.y = sin((Global.time + time_offset) * 7)*2
	
	Float_Vec.x = cos((Global.time + time_offset) * 5)*1.5
	
	Knockback_Vec += Knockback_Desired_Vec 
	
	if Knockback_Vec.y > 0:
		Knockback_Desired_Vec.y -= delta * Knockback_Vec.y
	elif Knockback_Vec.y < 0:
		Knockback_Desired_Vec.y += delta * 4
		
	Knockback_Desired_Vec = Knockback_Desired_Vec.move_toward(Vector2.ZERO,delta*1.2)
	#Knockback_Vec.y = clamp(Knockback_Vec.y, -1.3, 1.3)
	
	
	position = Pos_Vec + (Knockback_Vec + Float_Vec)
	


func _on_Area2D_body_entered(body):
	Knockback_Desired_Vec.y = body.global_position.direction_to(global_position).y * 1.2

