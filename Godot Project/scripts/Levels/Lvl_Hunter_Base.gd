extends level

var ele_tw : SceneTreeTween

func _unhandled_input(event):
	
	if $Elevators/Tile/Area2D.get_overlapping_bodies().size() > 0 and event.is_action_pressed("down") and $Elevators.position.y < 40:
		elevator_move()
		
	if $Elevators/Tile/Area2D.get_overlapping_bodies().size() > 0 and event.is_action_pressed("up") and $Elevators.position.y > 400:
		elevator_move()

func elevator_move():
	var ele_tw = create_tween()
	ele_tw.set_process_mode(Tween.TWEEN_PROCESS_PHYSICS)
	ele_tw.set_trans(Tween.TRANS_SINE)
	ele_tw.set_ease(Tween.EASE_IN_OUT)
	ele_tw.set_pause_mode(SceneTreeTween.TWEEN_PAUSE_STOP)
	
	if $Elevators.position.y < 40:
		ele_tw.tween_property($Elevators,"position:y",448.0,2.2)
	else:
		ele_tw.tween_property($Elevators,"position:y",0.0,2.2)
	Global.Player.HasControl = false
	Global.Player.current_state = player_character.state.IDLE
	Global.Player.dir = 0
	

	

	if $Elevators.position.y > 400:
		Global.GameCamera.Offset_Vec.y = -63
		
	else:
		var tw = create_tween()
		Global.GameCamera.Offset_Vec.y = -64.0
		tw.tween_property(Global.GameCamera,"Offset_Vec:y",-41.0,0.6)
	
	if Global.Player.global_position.x < 0:
		$CameraBounds/elevator_corridor_left._update_camera_limits(false)
	else:
		$CameraBounds/elevator_corridor_right._update_camera_limits(false)
		
	yield(ele_tw,"finished")
	Global.Player.HasControl = true
	Global.GameCamera.Offset_Vec.y = 0
	if $Elevators.position.y > 400:
		$CameraBounds/bottom_corridor._update_camera_limits(false)
