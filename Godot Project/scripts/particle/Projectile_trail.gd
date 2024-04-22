extends Particles2D

var follower

var timer_started = false


func _ready():
	$Timer.wait_time = lifetime * 2

func _process(_delta):
	if is_instance_valid(follower):
		position = follower.position
	else:
		emitting = false
		if timer_started == false:
			$Timer.start()
			timer_started = true



func _on_Timer_timeout():
	queue_free()
	
