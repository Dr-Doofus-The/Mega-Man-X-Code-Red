extends Viewport

func _ready():
	randomize()
	Global.ViewPort = self

func change_scene(scene : String):
	
	Global.Character_Slots = [null,null]
	
	var loader = ResourceLoader.load_interactive(scene)
	
	Transition.get_node("AnimationPlayer").play("Transition_in")
	MusicPlayer.fade_music(false, 0.7)
	yield(Transition.get_node("AnimationPlayer"),"animation_finished")
	while true:
		var err = loader.poll()
		if err == ERR_FILE_EOF:
			var new_scene = loader.get_resource()
			for n in get_children():
				n.queue_free()
			Global.set_values_to_null()
			call_deferred("add_child",new_scene.instance())
			get_tree().paused = false
			Transition.get_node("AnimationPlayer").play("Transition_out")
			Global.isPaused = false
			MusicPlayer.stop_music()
			break
