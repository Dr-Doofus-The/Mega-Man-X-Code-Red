extends "res://scripts/entity/Enemy/EntityEnemy.gd"


func _physics_process(_delta):
	if not is_on_floor():
		velocity.x = 0
