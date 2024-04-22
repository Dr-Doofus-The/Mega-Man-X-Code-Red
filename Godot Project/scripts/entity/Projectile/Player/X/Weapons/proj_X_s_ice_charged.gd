extends KinematicBody2D

onready var BulletDire

onready var velocity = Vector2.ZERO

var mode = 0

var x_speed = 0

func _physics_process(delta):
	
	match mode:
		0:
			if is_on_floor():
				$KinematicBody2D/CollisionShape2D.set_deferred("disabled",false)
				mode = 1
		1:
			x_speed += delta
			position.x += x_speed
			velocity.x = 1


	if !$VisibilityNotifier2D.is_on_screen():
		queue_free()
	if is_on_floor():
		velocity.y = 0
	else:
		velocity.y += Global.Gravity * 66 *  delta
	if is_on_wall():
		queue_free()
	velocity = move_and_slide_with_snap(velocity,Vector2(0,15),Vector2.UP,true)



func _on_Area2D_body_entered(body):
	
	pass
#	if body != self and get_floor_angle(Vector2.UP) == 0:
#		queue_free()
