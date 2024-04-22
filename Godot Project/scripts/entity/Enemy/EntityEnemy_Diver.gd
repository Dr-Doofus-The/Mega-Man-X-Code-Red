extends Enemy_Class


func _physics_process(_delta):
	position.x += enemy_direction * 3
