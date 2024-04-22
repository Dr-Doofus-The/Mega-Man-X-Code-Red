extends Node

var stage_music
var volume = 0
onready var music_tweem = $Tween
onready var audio_player = $AudioStreamPlayer



func set_stage_music(audiopath : String, vol : float):
	$AudioStreamPlayer.stream = load(audiopath)
	stage_music = $AudioStreamPlayer.stream
	$AudioStreamPlayer.volume_db = vol
	volume = vol
	fade_music(true, 0.01)

func start_music(instant : bool):

	if instant:
		$AudioStreamPlayer.play()
		audio_player.volume_db = volume
	else:
		
		$AudioStreamPlayer.stop()
		yield(get_tree().create_timer(1),"timeout")
		audio_player.volume_db = volume
		$AudioStreamPlayer.play()

func change_music(audiopath : String):
	$AudioStreamPlayer.stop()
	$AudioStreamPlayer.stream = load(audiopath)


func back_to_stage_music():
	$AudioStreamPlayer.stop()
	$AudioStreamPlayer.stream = stage_music



func stop_music():
	$AudioStreamPlayer.stop()

func fade_music(fade_in : bool, duration : float) -> void:
	

	if fade_in == true:
		$Tween.interpolate_property($AudioStreamPlayer, "volume_db", -20, volume, duration)
	else:
		$Tween.interpolate_property($AudioStreamPlayer, "volume_db", volume, -20 ,duration)
	$Tween.start()
	yield($Tween,"tween_completed")
	if fade_in:
		$AudioStreamPlayer.volume_db = volume
	else:
		$AudioStreamPlayer.volume_db = -80

