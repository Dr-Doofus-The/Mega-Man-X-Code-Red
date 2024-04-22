extends TextureButton

signal exit_focus(node)

var id = 0 setget set_id, get_id
var desc : String

func _ready():
	_on_ui_pause_weapon_select_focus_exited()

func get_id():
	return id

func set_id(value):
	id = value
	update_values()
	
func update_values():

	if Global.Player:
		
		if id > 0:
			if GameProgress.Boss_Defeated_Array[id-1] == false:
				focus_mode = Control.FOCUS_NONE
				modulate.a = 0
				return
			else:
				focus_mode = Control.FOCUS_ALL
				modulate.a = 1
		
		var id_offset
		
		match Global.Player.character_name:
			0:
				
				id_offset = 0
				if id == 9:
					focus_mode =Control.FOCUS_ALL
					modulate.a = 1
			1:
				id_offset = 14
				
				if id == 9:
					focus_mode =Control.FOCUS_NONE
					modulate.a = 0
			2:
				id_offset = 23
				
				if id == 9:
					focus_mode =Control.FOCUS_NONE
					modulate.a = 0
		$weapon_icon.frame_coords.y = Global.Player.character_name
		$Label.text = JsonData.weapon_data_list[id + id_offset]["weaponname"]
		desc = JsonData.weapon_data_list[id + id_offset]["weapondesc"]



func _on_ui_pause_weapon_select_focus_entered():
	$Label.add_color_override("font_color",Color("ffffff"))
	var tw = create_tween()
	tw.tween_property($Label,"rect_position:x",43.0,0.05)
	emit_signal("exit_focus",self)


func _on_ui_pause_weapon_select_focus_exited():
	$Label.add_color_override("font_color",Color("e9a662"))
	var tw = create_tween()
	tw.tween_property($Label,"rect_position:x",40.0,0.05)


func _on_ui_pause_weapon_select_button_down():
	Sound.play_sound(Sound.SND_UI_SELECTION_CONFIRM,0,1)
	if id < 9:
		match Global.Player.character_name:
			0:
				Global.Player.WeaponManager.current_weapon_index = id
				Global.Player.WeaponManager.switch_weapons()
