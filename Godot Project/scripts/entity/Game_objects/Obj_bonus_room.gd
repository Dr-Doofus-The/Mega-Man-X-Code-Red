extends ReferenceRect



export (int, "Reach the end") var challenge_type
export var timer : int

onready var spawn_point = $Spawn_Point
onready var camera_bounds = $Camera_Bounds

var active = false


func _ready():
	camera_bounds.global_position = Vector2.ZERO
	$Camera_Bounds/ReferenceRect.rect_size = rect_size
	$Camera_Bounds/ReferenceRect.rect_global_position = rect_global_position

func _physics_process(delta):
	if Global.stage_timer == 0 and active:
		active = false
		fail_bonus()

func start_bonus():
	Global.Player.animplayer.play("Teleport_In")
	Sound.SND_PL_TELEPORT_IN.play()
	yield(Global.Player.animplayer,"animation_finished")
	yield(get_tree(),"physics_frame")
	yield(get_tree(),"physics_frame")
	Global.Player.HasControl = false
	Global.Player.dir = 0
	Global.Player.current_state = player_character.state.IDLE
	Global.stage_timer = timer
	
	Global.Current_Hud.show_timer()
	match challenge_type:
		0:
			Global.Current_Hud.box_notify("reach the end")
	
	
	yield(get_tree().create_timer(0.2),"timeout")
	MusicPlayer.fade_music(true,0.05)
	MusicPlayer.change_music("res://sound_assests/music/misc/bonus_room.ogg")
	MusicPlayer.start_music(true)
	yield(Global.Current_Hud,"flash_done")
	
	Global.Player.HasControl = true
	Global.Player.current_state = player_character.state.IDLE
	Global.stage_timer_enabled = true

func fail_bonus(_a = null):
	Global.Current_Hud.blink_element(Global.Current_Hud.timer_text,11,4)
	Global.stage_timer_enabled = false
	Global.Player.HasControl = false
	Global.Player.dir = 0
	Global.Player.current_state = player_character.state.ANIMATION
	get_tree().paused = true
	MusicPlayer.change_music("res://sound_assests/music/misc/bonus_room_fail.ogg")
	MusicPlayer.start_music(true)
	yield(get_tree().create_timer(3.0),"timeout")
	return_to_bonus_platform(false)

func win_bonus():
	Global.Current_Hud.blink_element(Global.Current_Hud.timer_text,11,4)
	Global.stage_timer_enabled = false
	Global.Player.HasControl = false
	Global.Player.dir = 0
	MusicPlayer.change_music("res://sound_assests/music/Jingle/stage_clear_x.ogg")
	MusicPlayer.start_music(true)


	yield(get_tree().create_timer(3.25),"timeout")


	Global.Player.current_state = player_character.state.ANIMATION

	Global.Player.ent_sprite.play("Victory")
	yield(Global.Player.ent_sprite,"animation_finished")
	yield(get_tree().create_timer(0.5),"timeout")
	Global.Player.animplayer.play("Teleport_Out")
	Sound.SND_PL_TELEPORT_OUT.play()
	yield(Global.Player.animplayer,"animation_finished")
	return_to_bonus_platform(true)
	
func return_to_bonus_platform(deactivate : bool):
	active = false
	Global.teleport_player(Global.bonus_platform.global_position,Global.bonus_platform.cam_bounds)
	yield(Transition.get_node("AnimationPlayer"),"animation_finished")
	get_tree().paused = false
	Global.Current_Hud.timer_text.visible = false
	if deactivate:
		Global.bonus_platform.deactive_platform()
	else:
		Global.bonus_platform.get_node("Timer").start()
		Global.bonus_platform = null
	Sound.SND_PL_TELEPORT_IN.play()
	MusicPlayer.back_to_stage_music()
	MusicPlayer.start_music(true)
	MusicPlayer.fade_music(true,0.4)
	
	Global.Player.animplayer.play("Teleport_In")
	yield(Global.Player.animplayer,"animation_finished")
	Global.Player.HasControl = true
	Global.Player.current_state = player_character.state.IDLE
