extends Control

onready var characters = Global.Characters_To_Spawn
onready var lvl : level

var play_sound = false
var button_before_popup = null
var popup_id = 0

var temp_desc : String
var final_desc : String
var random_letters = ["1","A","U","7","Z","G","X"]


func _ready():
	visible = false
	lvl = Global.Level
	set_values()
	if Global.Character_Slots[0]:
		update_values()
	for n in $Tabs/Status/VBoxContainer.get_children():
		n.set_id(n.get_index())
		n.connect("exit_focus",self,"selection_changed")
	for n in $Tabs/Status/HBoxContainer.get_children():
		n.connect("button_down",self,"selection_confirm")
	for n in $Popup/HBoxContainer.get_children():
		n.connect("button_down",self,"selection_confirm")

func set_values():
	for n in $Tabs/Status/Character_Mugshots.get_children():
		var children = n.get_children()
		

		match characters[n.get_index()]:
			0:
				children[0].text = "X"
				children[1].frame_coords.y = 0

			1:
				children[0].text = "Zero"
				children[1].frame_coords.y = 1
				
				children[1].frame_coords.x = GameProgress.current_zero_armor

			2:
				children[0].text = "Axl"
				children[1].frame_coords.y = 2

func _input(event):
	if Global.canPause == true:
		if event.is_action_pressed("ui_pause"):
			pause_game()
			
		
		if visible:
			if event.is_action_pressed("next_weapon"):
				Sound.play_sound(Sound.SND_UI_TAB_SWITCH,-4,1)
				$Tabs.current_tab = get_next_tab().get_index()
				play_sound = false
				update_values()
				
				$AnimationPlayer.stop()
				$AnimationPlayer.play("Switch_Tab")
				set_description_text_to_0()
				reveal_description_text(0)
				get_tab_focus()
				play_sound = true
			if event.is_action_pressed("prev_weapon"):
				Sound.play_sound(Sound.SND_UI_TAB_SWITCH,-4,1)
				$Tabs.current_tab = get_prev_tab().get_index()
				play_sound = false
				update_values()
				$AnimationPlayer.stop()
				$AnimationPlayer.play("Switch_Tab")
				set_description_text_to_0()
				reveal_description_text(0)
				get_tab_focus()
				play_sound = true
			
func selection_confirm():
	Sound.play_sound(Sound.SND_UI_SELECTION_CONFIRM,0,1)

func selection_changed(node):
	if play_sound:
		Sound.play_sound(Sound.SND_UI_SELECTION,-3,1)
	set_description_text_to_0()
	final_desc = node.desc
	reveal_description_text(0)

func pause_game():
	Global.canPause = false
	if Global.isPaused:
		play_sound = false
		$AnimationPlayer.play("Close")
		AudioServer.get_bus_effect(3,0).volume_db = 0
		Sound.play_sound(Sound.SND_UI_CLOSE,0,1)
		Settings.save_settings()

	else:
		$Tabs.current_tab = 0
		$AnimationPlayer.play("Open")
		AudioServer.get_bus_effect(3,0).volume_db = -7
		update_values()
		Global.isPaused = true
		get_tree().paused = true
		#$Tabs/Status/description.visible_characters = 0
		for n in $Tabs/Status/VBoxContainer.get_children():
			n.update_values()

func update_values():
	$Tabs/Status/life_count.text = str(":") + str(Global.lives)
	
	$Tabs/Status/heart_tank_count.text = str(":") + str(GameProgress.heart_tank_array.size()) + "/8"

	var time = Global.level_stats["Timer"]
	var _text = ": %02d:%02d:%02d" % [fmod(time, 60*60) / 60, fmod(time,60), fmod(time,1) * 100]
	$Tabs/Status/timer.text = _text
	var reploid_value = 0
	if GameProgress.Missing_Reploid_List.has(lvl.level_name):
		for n in GameProgress.Missing_Reploid_List[lvl.level_name]:
			if n == true:
				reploid_value +=1
		$Tabs/Status/reploid_count.text = str(":") + str(reploid_value) + str("/16")
	
	else:
		$Tabs/Status/reploid_count.text = str(":-/-")

	#Tab Names
	$Right_Tab_Name.text = get_next_tab().name
	
	$Left_Tab_Name.text = get_prev_tab().name
	
	$Tab_Name.text = str("[ ") + $Tabs.get_child($Tabs.current_tab).name + " ]"
	
	#Tanks

	if GameProgress.Subtank_container.size() > 2:
		$Tabs/Status/Tank_Container/Sub_tank_Button3.modulate.a = 1
		$Tabs/Status/Tank_Container/Sub_tank_Button3.focus_mode = Control.FOCUS_ALL
		$Tabs/Status/Tank_Container/Sub_tank_Button3.update_values()
	else:
		$Tabs/Status/Tank_Container/Sub_tank_Button3.modulate.a = 0
		$Tabs/Status/Tank_Container/Sub_tank_Button3.focus_mode = Control.FOCUS_NONE
		
	if GameProgress.Subtank_container.size() > 1:
		$Tabs/Status/Tank_Container/Sub_tank_Button2.modulate.a = 1
		$Tabs/Status/Tank_Container/Sub_tank_Button2.focus_mode = Control.FOCUS_ALL
		$Tabs/Status/Tank_Container/Sub_tank_Button2.update_values()
	else:
		$Tabs/Status/Tank_Container/Sub_tank_Button2.modulate.a = 0
		$Tabs/Status/Tank_Container/Sub_tank_Button2.focus_mode = Control.FOCUS_NONE
		
	if GameProgress.Subtank_container.size() > 0:
		$Tabs/Status/Tank_Container/Sub_tank_Button.modulate.a = 1
		$Tabs/Status/Tank_Container/Sub_tank_Button.focus_mode = Control.FOCUS_ALL
		$Tabs/Status/Tank_Container/Sub_tank_Button.update_values()
	else:
		$Tabs/Status/Tank_Container/Sub_tank_Button. modulate.a = 0
		$Tabs/Status/Tank_Container/Sub_tank_Button.focus_mode = Control.FOCUS_NONE
		

	update_health()

func set_description_text_to_0():
	match $Tabs.current_tab:
		0:
			temp_desc = ""
			final_desc = ""
			$Tabs/Status/description.text = ""

func reveal_description_text(pos : int):
	
	match $Tabs.current_tab:
		0:
			
			$Tabs/Status/description.text = temp_desc
			
			if temp_desc.length() < final_desc.length() and Global.isPaused:
				yield(get_tree(),"physics_frame")
				
				temp_desc = final_desc.substr(0,pos + 1) + "Æ"
				reveal_description_text(pos + 1)
			else:
				$Tabs/Status/description.text = final_desc

func update_health():
	
	for n in $Tabs/Status/Character_Mugshots.get_children():
		var children = n.get_children()
		children[2].max_value = Global.Character_Slots[n.get_index()].hp_max
		children[2].value = Global.Character_Slots[n.get_index()].hp
		children[3].text = str(Global.Character_Slots[n.get_index()].hp) + "/" + str(Global.Character_Slots[n.get_index()].hp_max)

	#Tanks
	if GameProgress.Subtank_container.size() > 1:
		$Tabs/Status/Tank_Container/Sub_tank_Button2/TextureProgress.value = GameProgress.Subtank_container[1].juice
	if GameProgress.Subtank_container.size() > 0:
		$Tabs/Status/Tank_Container/Sub_tank_Button/TextureProgress.value = GameProgress.Subtank_container[0].juice

func _on_AnimationPlayer_animation_finished(anim_name):
	match anim_name:
		"Open":
			selection_changed($Tabs/Status/VBoxContainer/ui_pause_weapon_select)
			get_tab_focus()
			play_sound = true
			Global.canPause = true
		"Close":
			Global.isPaused = false
			get_tree().paused = false
			Global.canPause = true	
			
func get_tab_focus():
	match $Tabs.current_tab:
		0:
			$Tabs/Status/VBoxContainer/ui_pause_weapon_select.grab_focus()
		1:
			$Tabs/Options/Options_menu/HBoxContainer/Video.grab_focus()

func _on_subtank_button():
	var id = $Tabs/Status/Tank_Container.get_focus_owner()

	if GameProgress.Subtank_container[id.get_index()]["juice"] != 0 and Global.Player.hp != Global.Player.hp_max:
		get_tree().get_root().set_disable_input(true)
		GameProgress.drain_subtank(id.get_index())
		yield(GameProgress,"subtank_refil_done")
		get_tree().get_root().set_disable_input(false)


func get_next_tab() -> Tabs:
	var current_pos = $Tabs.current_tab
	
	if current_pos == $Tabs.get_child_count() - 1:
		current_pos = 0
	else:
		current_pos += 1
	
	return $Tabs.get_children()[current_pos]
	
func get_prev_tab() -> Tabs:
	var current_pos = $Tabs.current_tab
	
	
	
	if current_pos == 0:
		current_pos = $Tabs.get_child_count() -1
		
	else:
		current_pos -= 1
	
	return $Tabs.get_children()[current_pos]

func open_popup(id : int):
	Global.canPause = false
	play_sound = false
	button_before_popup = get_focus_owner()
	get_focus_owner().release_focus()
	popup_id = id
	$AnimationPlayer.play("Pop_up_Open")
	yield($AnimationPlayer,"animation_finished")
	$Popup/HBoxContainer/TextureButton2.grab_focus()
	play_sound = true
	#get_tree().get_root().set_disable_input(false)

func close_popup():
	play_sound = false
	get_focus_owner().release_focus()
	$AnimationPlayer.play("Pop_up_Close")
	yield($AnimationPlayer,"animation_finished")
	button_before_popup.grab_focus() 
	button_before_popup = null
	play_sound = true
	Global.canPause = true

func popup_accept():
	play_sound = false
	get_focus_owner().release_focus()
	match popup_id:
		0: #Restart Stage?
			Global.restart_level()
		1:
			Global.ViewPort.change_scene("res://nodes/UI/Title_Screen/Title_Screen.tscn")
