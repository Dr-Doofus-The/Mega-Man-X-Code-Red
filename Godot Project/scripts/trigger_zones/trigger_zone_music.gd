extends Area2D

export (int, "Set Music", "Set Stage Music") var mode
export (String) var music
export (int) var volume

func _on_Area2D_body_entered(body):
	if body == Global.Player:
		if MusicPlayer.audio_player.stream.resource_path != music:
			match mode:
				0:
					MusicPlayer.change_music(music)
				1:
					MusicPlayer.set_stage_music(music, volume)
					MusicPlayer.start_music(true)
