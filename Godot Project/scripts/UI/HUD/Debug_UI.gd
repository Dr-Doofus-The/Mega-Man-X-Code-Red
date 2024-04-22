extends Control


func _process(_delta):
	if Global.Player:
		$text.set_bbcode("FPS:" + str(Engine.get_frames_per_second()) + "\nPOSITION: (" + str(int(Global.Player.global_position.x)) + "," + str(int(Global.Player.global_position.y)) + ")\nSTATE: " + str(Global.Player.state.keys()[Global.Player.current_state]) + "\nHEALTH: " + str(Global.Player.hp) + "/" + str(Global.Player.hp_max)+ "\nVELOCITY: (" + str(int(Global.Player.velocity.x)) + "," + str(int(Global.Player.velocity.y)) + ")"+ "\nIS ATTACKING: " + str(Global.Player.isAttacking))
	#pass
func _unhandled_key_input(event):

	if OS.is_debug_build():
	
		if Input.is_key_pressed(KEY_KP_0):
			
			Sound.play_sound(Sound.SND_UI_SELECTION_CONFIRM,1,1)
			if get_tree().paused:
				get_tree().paused = false
				Global.isPaused = false
				Global.canPause = true
			else:
			
				get_tree().paused = true
				Global.isPaused = true
				Global.canPause = false
				
		if Input.is_key_pressed(KEY_KP_1):
			if get_tree().paused:
				get_tree().paused = false
				Global.isPaused = false
				Global.canPause = true
				for _n in range(2):
					yield(get_tree(),"physics_frame")
				get_tree().paused = true
				Global.isPaused = true
				Global.canPause = false
			else:
			
				get_tree().paused = true
				Global.isPaused = true
				Global.canPause = false
		
		if Input.is_key_pressed(KEY_0):
			Global.Current_Hud.box_notify("Test")		
		if Input.is_key_pressed(KEY_1):
			Global.Current_Hud.box_notify("Test","Bottom Text")

