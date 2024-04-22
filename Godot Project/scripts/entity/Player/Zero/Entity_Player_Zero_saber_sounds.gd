extends AudioStreamPlayer

onready var SWING =  preload("res://sound_assests/player/Zero/snd_player_zero_saber_swing.wav")

func play_sound(sound, pitch):
	if stream != sound:
		stream = sound
	if pitch_scale != pitch:
		pitch_scale = pitch
	play(0)
