extends "res://scripts/entity/Enemy/EntityEnemy.gd"


var isSwitchingDirections = false

const jump_height = 300

func _ready():
	
	if enemy_direction < 0:
		ent_sprite.play("crusin",false)
	else:
		ent_sprite.play("crusin",true)

func _physics_process(delta):

	if is_on_wall():
		switch_direction()



	if isSwitchingDirections == false:
		velocity.x = Movement_Speed * enemy_direction * (delta * 66)
	else:
		velocity.x = 0
		if is_on_floor():
			if enemy_direction > 0:
				ent_sprite.play("crusin",false)
			else:
				ent_sprite.play("crusin",true)
			enemy_direction = enemy_direction * -1
			isSwitchingDirections = false
			ent_sprite.playing = true
		else:
			velocity.y += Global.Gravity

	



func switch_direction():
	isSwitchingDirections = true
	velocity.y = -jump_height
	ent_sprite.playing = false


