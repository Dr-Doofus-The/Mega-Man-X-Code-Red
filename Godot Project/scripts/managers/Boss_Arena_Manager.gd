extends Area2D


export (int, "Boss", "Mini Boss") var boss_type
export (int, "Stage_Clear", "Open_Door") var after_death

export (int) var player_walk_to_point
export (int) var door_unlock_id : int
export var camera_postion : Vector2

onready var Cutscene_Camera = $Cutscene_Cam
var Boss

func _ready():
	Boss = $Boss_container.get_child(0)
	Boss.connect("tree_exited",self,"_on_boss_Death")



func _on_Boss_Arena_body_entered(body):
	if body == Global.Player and Boss != null:
		
		yield(Global.Player, "regained_controls")
		yield(get_tree().create_timer(1.0),"timeout")
		MusicPlayer.stop_music()
		Global.Player.walk_to_point(player_walk_to_point)
		Global.Player.HasControl = false

		Global.Player.dir = 0
	
		if boss_type == 0:
			
			Cutscene_Camera.global_position = Global.GameCamera.get_camera_screen_center()
			Cutscene_Camera.current = true
			Global.Player.walk_to_point(player_walk_to_point)
			var tw = create_tween()
			tw.set_ease(Tween.EASE_IN_OUT)
			tw.set_trans(Tween.TRANS_QUAD)
			tw.tween_property(Cutscene_Camera,"global_position",camera_postion,1.5)
			
			if Settings.skip_ready:
				yield(get_tree().create_timer(1.0),"timeout")
			else:
				Global.Current_Hud.warning_notify()
				yield(get_tree().create_timer(4.5),"timeout")
		Boss._enter()

func return_to_game_camera():
	var tw = create_tween()
	tw.set_ease(Tween.EASE_IN_OUT)
	tw.set_trans(Tween.TRANS_QUAD)
	tw.tween_property(Cutscene_Camera,"global_position",Global.GameCamera.get_camera_screen_center(),0.8)
	yield(tw,"finished")
	Global.GameCamera.current = true
	
func get_arena_edge(direction : int):
	match direction:
		0:
			return global_position.y - ($CollisionShape2D.shape.extents.y/2)
		1:
			return global_position.x + ($CollisionShape2D.shape.extents.x/2)
		2:
			return global_position.y + ($CollisionShape2D.shape.extents.y/2)
		3:
			return global_position.x - ($CollisionShape2D.shape.extents.x/2)

func _on_boss_Death():
	if is_inside_tree():
		match boss_type:
			0:
				MusicPlayer.change_music("res://sound_assests/music/Jingle/stage_clear_x.ogg")
				MusicPlayer.fade_music(true,0.05)
				MusicPlayer.start_music(true)
				yield(get_tree().create_timer(3.25),"timeout")
				Global.Player.current_state = Global.Player.state.ANIMATION	
				Global.Player.ent_sprite.animation = "Victory"
			1:
				MusicPlayer.back_to_stage_music()
				MusicPlayer.fade_music(true,1.5)
				MusicPlayer.start_music(true)
				match after_death:
					1:
						EventBus.emit_signal("UnlockDoor",door_unlock_id)
