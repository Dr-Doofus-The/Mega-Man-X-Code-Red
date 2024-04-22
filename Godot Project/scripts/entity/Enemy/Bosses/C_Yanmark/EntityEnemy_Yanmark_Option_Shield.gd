extends Node2D

var start_rotation = false

func _ready():
	pass

func _process(_delta):
	if start_rotation:
		rotation_degrees += 1
	
	if $Yanmarks.get_child_count() == 0:
		queue_free()

func _on_Timer_timeout():
	start_rotation = true
