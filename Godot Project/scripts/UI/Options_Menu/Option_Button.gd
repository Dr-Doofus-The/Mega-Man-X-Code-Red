extends "res://scripts/UI/Pause_Menu/UI_Pause_Menu_Buttonbasic.gd"

onready var name_text : String
onready var value_text : String


var option_type : int
var disabled
var slider
var reveal_tween : SceneTreeTween
var arrow_offset := [199,236]
var special_button


var remapper = false
var remapper_id = 0
var waiting_for_input = false
var wait_input_buffer = false
var input_mode

#onready var option_value


func _ready():

	input_mode = get_parent().get_parent().get_parent().name
	$Text_1.text = name_text.replace("_", " ")
	#$Text_2.text = value_text
	if !slider:
		$HSlider.queue_free()
	set_option_text()
	if special_button:
		$Arrows.modulate.a = 0
		$Text_2.visible = false
	match name_text:
		"hover_mode":
			arrow_offset = [187,248]
			
	if remapper:
		var _con = Settings.connect("key_changed",self,"set_option_text")

func _unhandled_input(event):

	
	var dir = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")

	
	if Global.isPaused:
		if get_parent().get_focus_owner() == self:
			if not (special_button or remapper):
				if dir != 0:
					if !slider:
						if dir == -1 :
							$Arrows/Left_Arrow.rect_position.x = arrow_offset[0] - 4
						else: 
							$Arrows/Right_Arrow.rect_position.x = arrow_offset[1] + 4
					
					var option_section
				
					match option_type:
						0:
							option_section = "video"
						1:
							option_section = "audio"
						2:
							option_section = "input"
						3:
							option_section = "debug"
					
					match typeof(Settings.options[option_section][name_text]):
						TYPE_BOOL:
							$Text_2.visible_characters = 12
							Settings.options[option_section][name_text] = !Settings.options[option_section][name_text]
						TYPE_INT:
							match name_text:
								"Window_Size":
									Settings.options["video"][name_text] = int(clamp(Settings.options["video"][name_text] + dir,0,3))
								"master":
									Settings.options["audio"][name_text] = int(clamp(Settings.options["audio"][name_text] + dir,0,10))
								"music":
									Settings.options["audio"][name_text] = int(clamp(Settings.options["audio"][name_text] + dir,0,10))
								"voice":
									Settings.options["audio"][name_text] = int(clamp(Settings.options["audio"][name_text] + dir,0,10))
								"sound_effect":
									Settings.options["audio"][name_text] = int(clamp(Settings.options["audio"][name_text] + dir,0,10))

					set_option_text()
					match option_type:
						0:
							Settings.apply_video_settings()
						1:
							Settings.apply_audio_settings()
				elif dir == 0:
					
					$Arrows/Right_Arrow.rect_position.x = arrow_offset[1]
					$Arrows/Left_Arrow.rect_position.x = arrow_offset[0]
		if remapper and waiting_for_input:

			if event.is_pressed() and !event.is_echo() and !wait_input_buffer:
				if input_mode == "Keyboard_map":
					if event is InputEventKey:
						Settings.replace_input_action_key(Settings.input_map_keyboard.keys()[remapper_id], OS.get_scancode_string(event.scancode))
						grab_focus()
						waiting_for_input = false
						Global.canPause = true
						selection_change()
						set_option_text()
				else:
					if event is InputEventJoypadButton:
						Settings.replace_input_action_button(Settings.input_map_keyboard.keys()[remapper_id],(event.button_index))
						grab_focus()
						waiting_for_input = false
						Global.canPause = true
						selection_change()
						set_option_text()
func set_option_text():

	if (!special_button):
		if remapper:
			
			$Arrows.visible = false
			
			if waiting_for_input:
				$Text_2.text = "....."
				$Text_2.visible_characters = -1
			else:
				if input_mode == "Keyboard_map":
					$Text_2.text = OS.get_scancode_string(Settings.input_map_keyboard.values()[remapper_id])
					$Text_2.visible_characters = -1
				else:
					$Text_2.text = str(Settings.input_map_controller.values()[remapper_id])
					$Text_2.visible_characters = -1
				
			return
		var option_section
		
		match option_type:
			0:
				option_section = "video"
			1:
				option_section = "audio"
			2:
				option_section = "input"
			3:
				option_section = "input"

		match typeof(Settings.options[option_section][name_text]):
			TYPE_BOOL:
				match name_text:
					"hover_mode":
						$Text_2.text = "HOLD" if Settings.options[option_section][name_text] else "TOGGLE"
						return
				
				$Text_2.text = "ON" if Settings.options[option_section][name_text] else "OFF"
			TYPE_INT:
				if slider:
					$HSlider.value = Settings.options[option_section][name_text]
					return
				
				match name_text:
					"Window_Size":
						$Text_2.text = str(Settings.options[option_section][name_text] + 1) + "X"


func selection_change():
	if focused:
		modulate = Color.white
		if !slider and !remapper:
			$Arrows.visible = true
	elif not waiting_for_input:
		modulate = Color("e9a662")
		$Arrows.visible = false

func _on_Option_Button_focus_entered():
	selection_change()

func _on_Option_Button_focus_exited():
	selection_change()


func reveal_text():
	if reveal_tween:
		reveal_tween.stop()
	$Text_1.visible_characters = 0
	$Text_2.visible_characters = 0
	if slider:
		$HSlider.visible = false
	reveal_tween = create_tween()
	reveal_tween.tween_property($Text_1,"visible_characters",$Text_1.text.length(),$Text_1.text.length()/20.0)
	if !slider:
		reveal_tween.parallel().tween_property($Text_2,"visible_characters",$Text_2.text.length(),$Text_2.text.length()/20.0)
		
	else:
		reveal_tween.parallel().tween_property($HSlider,"visible",true,0.2)
	
func _on_Option_Button_visibility_changed():
	if visible:
		reveal_text()


func _on_Option_Button_button_down():
	if special_button:
		match name_text:
			"Keyboard_Settings":
				get_parent().get_parent().get_parent().current_tab = 1
				get_parent().get_parent().get_parent().get_child(1).get_child(0).get_child(0).get_child(0).grab_focus()
			"Controller_Settings":
				get_parent().get_parent().get_parent().current_tab = 2
				get_parent().get_parent().get_parent().get_child(2).get_child(0).get_child(0).get_child(0).grab_focus()
			"exit":
				get_parent().get_parent().get_parent().get_parent().current_tab = 0
				get_parent().get_parent().get_parent().get_parent().get_child(0).get_child(0).get_child(0).grab_focus()
			"reset_to_default":
				if input_mode == "Keyboard_map":
					Settings.reset_key_input_map()
				else:
					Settings.reset_button_input_map()
		return
	if remapper:
		wait_input_buffer = true
		waiting_for_input = true
		release_focus()
		set_option_text()
		Global.canPause = false
		yield(get_tree(),"physics_frame")
		wait_input_buffer = false

