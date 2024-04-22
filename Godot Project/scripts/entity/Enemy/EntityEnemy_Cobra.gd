extends "res://scripts/entity/Enemy/EntityEnemy.gd"



func _ready():
	pass

func _physics_process(delta):
	
	if is_on_floor():
		velocity.x = enemy_direction * (delta * 5600)
		if is_on_wall():
			enemy_direction *= -1
			position.x += enemy_direction * 2
			
	else:
		velocity.x = 0
