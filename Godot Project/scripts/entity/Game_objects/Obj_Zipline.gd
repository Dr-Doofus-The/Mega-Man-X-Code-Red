extends Node2D

onready var follower = $Path2D/PathFollow2D

export (int, "Vertical", "Horizontal") var zipline_direction
export (bool) var movable = true

var offset_y = 30

func _process(delta):
	if Global.Player:
		$Sprite.global_position = (Global.Player.global_position - (Vector2(0,offset_y)))


func _physics_process(delta):
	
	if is_player_grabbing():

		$Sprite.visible = true
		$Sprite.flip_h = true if Global.Player.PlayerDirection > 0 else false
		Global.Player.global_position = follower.global_position + Vector2 (0,offset_y)
		if movable and $Pause_timer.time_left == 0 and !(Global.Player.character_name == 2 and Global.Player.IsShooting):
			var multiplier = 4 if Input.is_action_pressed("dash") else 2
			if multiplier > 2 and (Global.Player.dir != 0 || Global.Player.dirY != 0):
				if not Global.Player.IsDashJumping:
					Global.Player.SND_PLAYER_DASH.play()
				Global.Player.IsDashJumping = true
			else:
				Global.Player.IsDashJumping = false
			match zipline_direction:
				0:
					
					
					follower.offset -= (Global.Player.dirY * multiplier) * (delta * 60)
					
				1:
					
					follower.offset -= (Global.Player.dir * multiplier) * (delta * 60)
	else:
		$Sprite.visible = false
		


func update_follower():
	follower.offset = $Path2D.curve.get_closest_offset($Path2D.to_local(Global.Player.global_position - Vector2(0,11)))

	$Pause_timer.start()
	follower.unit_offset = clamp(follower.unit_offset,0,1)
	
	Global.Player.global_position = follower.global_position + Vector2 (0,32)
func is_player_grabbing() -> bool:
	if !Global.Player : return false
	return true if Global.Player.current_state == Global.Player.state.ZIPLINE and Global.Player.current_zipline == self else false
