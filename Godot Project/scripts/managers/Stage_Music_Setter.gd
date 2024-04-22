extends Node

export (String) var stage_music_path
export (float) var volume

func _ready():
	if stage_music_path:
		MusicPlayer.set_stage_music(stage_music_path, volume)
		MusicPlayer.start_music(false)
