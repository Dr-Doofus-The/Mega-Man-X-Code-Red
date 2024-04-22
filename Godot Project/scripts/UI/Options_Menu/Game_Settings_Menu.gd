extends "res://scripts/UI/Menu_Base.gd"

onready var scroll_container = $Menu/ScrollContainer
onready var command_dash_option = $Menu/ScrollContainer/VBoxContainer/Command_dash
onready var auto_charge_option = $Menu/ScrollContainer/VBoxContainer/Auto_charge
onready var rapid_fire = $Menu/ScrollContainer/VBoxContainer/Rapid_fire

var anim_player

func _ready():
	anim_player = get_parent().get_parent().get_node("AnimationPlayer")
	
	define_option(command_dash_option, "Command Dash")
	define_option(auto_charge_option, "Auto Charge")
	define_option(rapid_fire, "Rapid Fire")

	update_option()
	
	anim_player.play("Transition_out")
	yield(anim_player, "animation_finished")
	command_dash_option.grab_focus()
	


	for buttons in $Menu/ScrollContainer/VBoxContainer.get_children():

		buttons.connect("focus_entered",self,"_on_focus_changed")

func update_option():
	
#COMMAND DASH SETTING	
	match Settings.command_dash:
		true:
			command_dash_option.get_node("Option_Answear").text = "ON"
		false:
			command_dash_option.get_node("Option_Answear").text = "OFF"

#AUTO-CHARGE
	match Settings.auto_charge:
		true:
			auto_charge_option.get_node("Option_Answear").text = "ON"
		false:
			auto_charge_option.get_node("Option_Answear").text = "OFF"

#AUTO-CHARGE
	match Settings.rapid_fire:
		true:
			rapid_fire.get_node("Option_Answear").text = "ON"
		false:
			rapid_fire.get_node("Option_Answear").text = "OFF"
						

func _input(event):


	match get_focus_owner():
#Command_Dash
		command_dash_option:
			if event.is_action_pressed("ui_right") || event.is_action_pressed("ui_left"):
				match Settings.command_dash:
					true:
						Settings.command_dash = false
					false:
						Settings.command_dash = true
				update_option()

#Auto_Charge
		auto_charge_option:
			if event.is_action_pressed("ui_right") || event.is_action_pressed("ui_left"):
				match Settings.auto_charge:
					true:
						Settings.auto_charge = false
					false:
						Settings.auto_charge = true		
					
				update_option()
#Rapid fire
		rapid_fire:
			if event.is_action_pressed("ui_right") || event.is_action_pressed("ui_left"):
				match Settings.rapid_fire:
					true:
						Settings.rapid_fire = false
					false:
						Settings.rapid_fire = true		
					
				update_option()

func _on_focus_changed():
	Global.SoundBank.SND_UI_SELECTION.play()

func define_option(node, name):
	node.get_node("Option_Name").text = name
	

func _on_Back_Button_pressed():
	Settings.save_settings()
	anim_player.play("Transition_in")
	yield(anim_player, "animation_finished")
	emit_signal("menu_closed")
	queue_free()
