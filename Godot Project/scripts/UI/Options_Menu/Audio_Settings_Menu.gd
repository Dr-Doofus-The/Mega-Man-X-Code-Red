extends "res://scripts/UI/Menu_Base.gd"

onready var master_option = $Menu/ScrollContainer/VBoxContainer/Master
onready var music_option = $Menu/ScrollContainer/VBoxContainer/Music_option
onready var sfx_option = $Menu/ScrollContainer/VBoxContainer/SFX
onready var x_voice_option = $Menu/ScrollContainer/VBoxContainer/X_voice_options
onready var charge_sfx_option = $Menu/ScrollContainer/VBoxContainer/Charge_sfx



onready var charge_sfx_array = ["ON", "FADE_OUT", "OFF"]

var anim_player

func _ready():
	define_option(master_option, "Master")
	
	define_option(sfx_option, "Sound effects")
	define_option(music_option, "Music")
	define_option(x_voice_option, "X voice style")
	define_option(charge_sfx_option, "Charge Sound Effect")

	master_option.get_node("TextureProgress").max_value = 0
	master_option.get_node("TextureProgress").step = 3
	master_option.get_node("TextureProgress").min_value = -30
	
	sfx_option.get_node("TextureProgress").max_value = 0
	sfx_option.get_node("TextureProgress").step = 3
	sfx_option.get_node("TextureProgress").min_value = -30



	update_option()
	
	anim_player = get_parent().get_parent().get_node("AnimationPlayer")
	anim_player.play("Transition_out")
	yield(anim_player, "animation_finished")	
	master_option.grab_focus()	

	for buttons in $Menu/ScrollContainer/VBoxContainer.get_children():

		buttons.connect("focus_entered",self,"_on_focus_changed")

func update_option():
	

	match Settings.X_voice_options:
		6:
			x_voice_option.get_node("Option_Answear").text = "MHX"
		5:
			x_voice_option.get_node("Option_Answear").text = "X8"
		4:
			x_voice_option.get_node("Option_Answear").text = "X7"
		3:
			x_voice_option.get_node("Option_Answear").text = "X6"
		2:
			x_voice_option.get_node("Option_Answear").text = "X5"
		1:
			x_voice_option.get_node("Option_Answear").text = "X4"
		0:
			x_voice_option.get_node("Option_Answear").text = "NONE"
			
	match Settings.charge_sfx:
		0:
			charge_sfx_option.get_node("Option_Answear").text = "OFF"
		1:
			charge_sfx_option.get_node("Option_Answear").text = "FADE_OUT"
		2:
			charge_sfx_option.get_node("Option_Answear").text = "ON"

	master_option.get_node("TextureProgress").value = AudioServer.get_bus_volume_db(0)
	sfx_option.get_node("TextureProgress").value = AudioServer.get_bus_volume_db(1)

func _input(event):

	match get_focus_owner():
		master_option:
			if event.is_action_pressed("ui_right"):
				if AudioServer.get_bus_volume_db(0) < -30:
					AudioServer.set_bus_volume_db(0, -27)
				elif AudioServer.get_bus_volume_db(0) < 0:
					AudioServer.set_bus_volume_db(0, AudioServer.get_bus_volume_db(0) + 3)
				Global.SoundBank.SND_UI_SELECTION.play()
			if event.is_action_pressed("ui_left"):
				if AudioServer.get_bus_volume_db(0) < -27:
					AudioServer.set_bus_volume_db(0, -800)
				elif AudioServer.get_bus_volume_db(0) > -30:
					AudioServer.set_bus_volume_db(0, AudioServer.get_bus_volume_db(0) - 3)
				Global.SoundBank.SND_UI_SELECTION.play()
			update_option()	

		sfx_option:
			if event.is_action_pressed("ui_right"):
				if AudioServer.get_bus_volume_db(1) < -30:
					AudioServer.set_bus_volume_db(1, -27)
				elif AudioServer.get_bus_volume_db(1) < 0:
					AudioServer.set_bus_volume_db(1, AudioServer.get_bus_volume_db(1) + 3)
				Global.SoundBank.SND_UI_SELECTION.play()
			if event.is_action_pressed("ui_left"):
				if AudioServer.get_bus_volume_db(1) < -27:
					AudioServer.set_bus_volume_db(1, -800)
				elif AudioServer.get_bus_volume_db(1) > -30:
					AudioServer.set_bus_volume_db(1, AudioServer.get_bus_volume_db(1) - 3)
				Global.SoundBank.SND_UI_SELECTION.play()								
			update_option()
	#X_voice_options
		x_voice_option:
			if event.is_action_pressed("ui_right"):
				if Settings.X_voice_options == 6:
					Settings.X_voice_options = 0
				else:
					Settings.X_voice_options +=1
				update_option()

			if event.is_action_pressed("ui_left"):
				if Settings.X_voice_options == 0:
					Settings.X_voice_options = 6
				else:
					Settings.X_voice_options -=1
				update_option()

		charge_sfx_option:
			if event.is_action_pressed("ui_right"):
				
				if Settings.charge_sfx == 2:
					Settings.charge_sfx = 0
				else:
					Settings.charge_sfx +=1
				update_option()
			if event.is_action_pressed("ui_left"):

				if Settings.charge_sfx == 0:
					Settings.charge_sfx = 2
				else:
					Settings.charge_sfx -=1
				update_option()



func define_option(node, name):
	node.get_node("Option_Name").text = name
	
func _on_focus_changed():
	Global.SoundBank.SND_UI_SELECTION.play()

func _on_Back_Button_pressed():
	Settings.save_settings()
	Settings.emit_signal("Settings_changed")	
	anim_player.play("Transition_in")
	yield(anim_player, "animation_finished")	
	emit_signal("menu_closed")
	queue_free()
