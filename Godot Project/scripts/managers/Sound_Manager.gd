extends Node

onready var SND_UI_SELECTION : AudioStreamPlayer = $snd_ui_selection_change
onready var SND_UI_SELECTION_CONFIRM : AudioStreamPlayer = $snd_ui_selection_confirm
onready var SND_UI_CLOSE : AudioStreamPlayer = $snd_ui_close
onready var SND_UI_TAB_SWITCH : AudioStreamPlayer = $snd_ui_tab_switch
onready var SND_UI_UPDATE_HEALTH : AudioStreamPlayer = $snd_ui_update_health
onready var SND_UI_TEXT : AudioStreamPlayer = $snd_ui_text
onready var SND_UI_LOCK_ON : AudioStreamPlayer = $snd_ui_lock_on
onready var SND_OBJ_EXPBOX_BEEP : AudioStreamPlayer = $snd_obj_ExpBox_beep
onready var SND_OBJ_BOX_FALL : AudioStreamPlayer = $snd_obj_Box_impact
onready var SND_OBJ_MACHINE_MOVE : AudioStreamPlayer = $snd_obj_machine_move
onready var SND_NOTIF_ITEM : AudioStreamPlayer = $snd_notif_item
onready var SND_NOTIF_01 : AudioStreamPlayer = $snd_notif_01
onready var SND_X_BUSTER_HIT : AudioStreamPlayer = $snd_prj_x_buster_hit
onready var SND_PRJ_NOVA_STRIKE : AudioStreamPlayer = $snd_prj_nova_strike
onready var SND_PRJ_ENERGY_EXP : AudioStreamPlayer = $snd_prj_energy_exp
onready var SND_PRJ_LAUNCH : AudioStreamPlayer = $snd_prj_launch
onready var SND_ATTA_SABER_SWING_1 : AudioStreamPlayer = $snd_atta_saber_swing_1
onready var SND_ATTA_SABER_SWING_2 : AudioStreamPlayer = $snd_atta_saber_swing_2
onready var SND_ATTA_SABER_SWING_3 : AudioStreamPlayer = $snd_atta_saber_swing_3
onready var SND_ATTA_SABER_HIT : AudioStreamPlayer = $snd_atta_saber_hit
onready var SND_HIT_SHIELD : AudioStreamPlayer = $snd_hit_shield
onready var SND_PRJ_X_BUSTER_FIRE : AudioStreamPlayer = $snd_prj_x_buster_fire
onready var SND_PRJ_X_BUSTER_1_FIRE : AudioStreamPlayer = $snd_prj_x_buster_1_fire
onready var SND_PRJ_X_BUSTER_2_FIRE : AudioStreamPlayer = $snd_prj_x_buster_2_fire
onready var SND_PL_X_CHARGE : AudioStreamPlayer = $snd_pl_x_charge
onready var SND_PL_ZERO_CHARGE : AudioStreamPlayer = $snd_pl_zero_charge
onready var SND_PL_FOOTSTEP : AudioStreamPlayer = $snd_pl_footstep
onready var SND_PL_TELEPORT_IN : AudioStreamPlayer = $snd_pl_teleport_in
onready var SND_PL_TELEPORT_OUT : AudioStreamPlayer = $snd_pl_teleport_out
onready var SND_PL_TELEPORT_LAND : AudioStreamPlayer = $snd_pl_teleport_land

#Voices
onready var X_VOICE := {
	"jump" : 
		[preload("res://sound_assests/player/X/Voice/X7/snd_player_x_voice_jump_01.wav"),preload("res://sound_assests/player/X/Voice/X7/snd_player_x_voice_jump_02.wav")],
	
	"damage" :
		[preload("res://sound_assests/player/X/Voice/X7/snd_player_x_voice_damage_01.wav"),preload("res://sound_assests/player/X/Voice/X7/snd_player_x_voice_damage_02.wav"),preload("res://sound_assests/player/X/Voice/X7/snd_player_x_voice_damage_03.wav")],
		
	"death":
		preload("res://sound_assests/player/X/Voice/X7/snd_player_x_voice_death.wav"),
		
	"low_health":
		preload("res://sound_assests/player/X/Voice/X7/snd_player_x_voice_low_health.wav"),
		
	"charge_shot":
		[preload("res://sound_assests/player/X/Voice/X7/snd_player_x_voice_charge_shot_01.wav"),preload("res://sound_assests/player/X/Voice/X7/snd_player_x_voice_charge_shot_02.wav")],

	"big_charge_shot":
		[preload("res://sound_assests/player/X/Voice/X7/snd_player_x_voice_charge_shot_big_01.wav"),preload("res://sound_assests/player/X/Voice/X7/snd_player_x_voice_charge_shot_big_02.wav")]
}

onready var Zero_Voice := {
	"jump" : 
		[preload("res://sound_assests/player/Zero/Voice/X7/snd_player_zero_jump.wav"),
		preload("res://sound_assests/player/Zero/Voice/X7/snd_player_zero_jump_2.wav")],
		
	"damage" :
		[preload("res://sound_assests/player/Zero/Voice/X7/snd_player_zero_damage_1.wav"),
		preload("res://sound_assests/player/Zero/Voice/X7/snd_player_zero_damage_2.wav")],
		
	"death":
		preload("res://sound_assests/player/Zero/Voice/X7/snd_player_zero_death.wav"),
		
	"low_health":
		preload("res://sound_assests/player/Zero/Voice/X7/snd_player_zero_low_health.wav"),
	
	"attack":
		[preload("res://sound_assests/player/Zero/Voice/X7/snd_player_zero_attack_1.wav"),
		preload("res://sound_assests/player/Zero/Voice/X7/snd_player_zero_attack_2.wav"),
		preload("res://sound_assests/player/Zero/Voice/X7/snd_player_zero_attack_3.wav"),
		preload("res://sound_assests/player/Zero/Voice/X7/snd_player_zero_attack_4.wav"),
		preload("res://sound_assests/player/Zero/Voice/X7/snd_player_zero_attack_5.wav"),
		preload("res://sound_assests/player/Zero/Voice/X7/snd_player_zero_attack_6.wav")
		]
}

onready var AXL_VOICE := {
	"jump" : 
		[preload("res://sound_assests/player/Axl/Voice/snd_player_axl_voice_jump_01.wav"),
		preload("res://sound_assests/player/Axl/Voice/snd_player_axl_voice_jump_02.wav"),
		preload("res://sound_assests/player/Axl/Voice/snd_player_axl_voice_jump_03.wav")],
		
	"damage" :
		[preload("res://sound_assests/player/Axl/Voice/snd_player_axl_voice_damage_01.wav"),
		preload("res://sound_assests/player/Axl/Voice/snd_player_axl_voice_damage_02.wav")],
		
	"death":
		preload("res://sound_assests/player/Axl/Voice/snd_player_axl_voice_death.wav"),

	"low_health":
		preload("res://sound_assests/player/Axl/Voice/snd_player_axl_voice_low_health.wav"),

	"attack":
		[preload("res://sound_assests/player/Axl/Voice/snd_player_axl_voice_attack_01.wav"),
		preload("res://sound_assests/player/Axl/Voice/snd_player_axl_voice_attack_02.wav")],

	"copy":
		[preload("res://sound_assests/player/Axl/Voice/snd_player_axl_voice_copy_01.wav"),
		preload("res://sound_assests/player/Axl/Voice/snd_player_axl_voice_copy_02.wav")]
}


func _ready():
	Global.SoundBank = self

func play_sound(sound : AudioStreamPlayer, volume : float, pitch : float):
	sound.volume_db = volume
	sound.pitch_scale = pitch
	sound.play()

func play_standard_explosion_sound():
	if randi() % 2 == 0:
		$snd_explosion_standard_01.pitch_scale = rand_range(0.75, 1.25)
		$snd_explosion_standard_01.play()
		
	else:
		$snd_explosion_standard_01.pitch_scale = rand_range(0.75, 1.25)
		$snd_explosion_standard_02.play()
func play_footstep():
	if Settings.options["audio"]["footstep_sounds"]:
		play_sound(SND_PL_FOOTSTEP,0,rand_range(0.95,1.05))
