extends Node2D

export (Array) var spawner_array
var current_array_index = 0

func _ready():
	$Timer.paused = true

func spawn_thing():
	var obj = spawner_array[current_array_index].instance()
	if obj.get("respawnable"):
		obj.respawnable = false
	if obj.get("gravityenabled"):
		obj.gravityenabled = true
	add_child(obj)

func _on_VisibilityNotifier2D_screen_entered():
	$Timer.paused = false


func _on_VisibilityNotifier2D_screen_exited():
	$Timer.paused = true


func _on_Timer_timeout():
	spawn_thing()
	current_array_index = (current_array_index + 1) % spawner_array.size()
