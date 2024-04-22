extends "res://scripts/UI/Menu_Base.gd"

signal pause_menu_opened()

onready var Weapon_selection_column = $The_actual_Pause_Menu/Weapon_Selection_Container
onready var Options_menu = preload("res://nodes/UI/Options/Options_menu.tscn")
onready var anim_player = $AnimationPlayer



func _input(event):
	if Global.canPause and event.is_action_pressed("ui_pause") and Global.isPaused == false:
		emit_signal("pause_menu_opened")
		Global.emit_signal("Paused")
		GoTo_PauseMenu()
		
		

		
	if Global.canPause and event.is_action_pressed("ui_pause") and Global.isPaused and $The_actual_Pause_Menu.visible:
		BackTo_Game()

func GoTo_PauseMenu():
	get_tree().paused = true
	Global.canPause = false
	Global.isPaused = true
	anim_player.play("Enter_Menu")
	
func BackTo_Game():
	Global.canPause = false
	anim_player.play("Exit_Menu")


func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "Enter_Menu":
		Global.canPause = true
		
		#Comment: The menu will default to the X-Buster but when i have implemented special weapons, then it should default to X's currently active weapon
		$The_actual_Pause_Menu/Weapon_Selection_Container/UI_Pause_Weapon_Selection_X_buster.grab_focus()
	
	if anim_name == "Exit_Menu":
		get_tree().paused = false
		Global.emit_signal("Paused")
		Global.canPause = true
		Global.isPaused = false
	


func _on_Options_button_pressed():
	anim_player.play("Transition_in")
	yield(anim_player, "animation_finished")
	$The_actual_Pause_Menu.visible = false
	var menu = Options_menu.instance()
	add_child(menu)
	move_child(menu, 0)
	get_node("Options_menu").connect("menu_closed", self, "Close_Options_Menu")

func Close_Options_Menu():
	$The_actual_Pause_Menu.visible = true	
	anim_player.play("Transition_out")
	yield(anim_player, "animation_finished")
	$The_actual_Pause_Menu/Weapon_Selection_Container/UI_Pause_Weapon_Selection_X_buster.grab_focus()
