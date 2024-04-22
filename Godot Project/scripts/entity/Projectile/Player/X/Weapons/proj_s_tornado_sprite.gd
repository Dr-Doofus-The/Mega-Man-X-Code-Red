extends AnimatedSprite


func _physics_process(delta):
	Global.time += delta
	offset.y = sin(Global.time * 30) * 2.2
