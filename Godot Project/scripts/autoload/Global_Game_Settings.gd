extends Node

# warning-ignore:unused_signal
signal Settings_changed()
signal key_changed()

const save_path = "res://settings.ini"
var config = ConfigFile.new()




#Gameplay
onready var command_dash = true
onready var maverick_intros = true
onready var ready_prompt = true


#DEBUG
onready var skip_ready = false


onready var options : Dictionary = {
	"video": {
		"Window_Size" : 2,
		"Fullscreen" : false,
		"V-sync" : true,
		"Screenshake" : true,
		"Filter" : false,
		"Border" : false
	},
	"audio": {
		"master" : 7,
		"sound_effect" : 7,
		"music" : 7,
		"voice" : 7,
		"footstep_sounds" : true
	},
	"input": {
		"command_dash" : false,
		"auto_charge" : false,
		"hover_mode" : false
	}
}


onready var input_map_keyboard := {
	"up" : KEY_W,
	"right" : KEY_D,
	"left" : KEY_A,
	"down" : KEY_S,
	"jump" : KEY_SPACE,
	"fire" : KEY_K,
	"special_weapon" : KEY_J,
	"dash" : KEY_L,
	"prev_weapon" : KEY_Q,
	"next_weapon" : KEY_E,
	"giga_attack" : KEY_I,
	"switch_player" : KEY_U,
	"subtank" : KEY_SHIFT
}

onready var input_map_controller := {
	"up" : JOY_BUTTON_12,
	"right" : JOY_BUTTON_15,
	"left" : JOY_BUTTON_14,
	"down" : JOY_BUTTON_13,
	"jump" : JOY_BUTTON_0,
	"fire" : JOY_BUTTON_2,
	"special_weapon" : JOY_BUTTON_6,
	"dash" : JOY_BUTTON_1,
	"prev_weapon" : JOY_BUTTON_4,
	"next_weapon" : JOY_BUTTON_5,
	"giga_attack" : JOY_BUTTON_7,
	"switch_player" : JOY_BUTTON_3,
	"subtank" : JOY_BUTTON_10
}

func _ready():

	#save_settings()
	load_settings()
	apply_video_settings()
	apply_audio_settings()
	yield(get_tree(),"physics_frame")
	EventBus.emit_signal("SettingsChanged")
	apply_key_input_map()
	apply_joy_input_map()

func apply_video_settings():
	var new_res = Vector2(320,240) * int(options["video"]["Window_Size"] + 1)
	OS.set_window_size(new_res)
	OS.window_position = OS.get_screen_size()/2 - new_res/2
	OS.window_fullscreen = options["video"]["Fullscreen"]
	OS.vsync_enabled = options["video"]["V-sync"]
	EventBus.emit_signal("SettingsChanged")
	#get_tree().get_root().emit_signal("size_changed")

func apply_audio_settings():

	var sfxbus = AudioServer.get_bus_index("SFX")
	if options["audio"]["sound_effect"] == 0:
		AudioServer.set_bus_mute(sfxbus,true)
	else:
		AudioServer.set_bus_mute(sfxbus,false)
		AudioServer.set_bus_volume_db(0,(options["audio"]["sound_effect"] * 2) - 18)
	
	var music = AudioServer.get_bus_index("Music")
	if options["audio"]["music"] == 0:
		AudioServer.set_bus_mute(music,true)
	else:
		AudioServer.set_bus_mute(music,false)
		AudioServer.set_bus_volume_db(music,(options["audio"]["music"] * 2) - 16)

	var voice = AudioServer.get_bus_index("Voices")
	if options["audio"]["voice"] == 0:
		AudioServer.set_bus_mute(voice,true)
	else:
		AudioServer.set_bus_mute(voice,false)
		AudioServer.set_bus_volume_db(voice,(options["audio"]["voice"] * 2) - 13)
		
	var masterbus = AudioServer.get_bus_index("Master")
	if options["audio"]["master"] == 0:
		AudioServer.set_bus_mute(masterbus,true)
	else:
		AudioServer.set_bus_mute(masterbus,false)
		AudioServer.set_bus_volume_db(masterbus,(options["audio"]["master"] * 2) - 20)


func apply_key_input_map():
	for n in input_map_keyboard:
		replace_input_action_key(n, OS.get_scancode_string(input_map_keyboard[n]))

func apply_joy_input_map():
	for n in input_map_controller:
		replace_input_action_button(n, input_map_controller[n])


func reset_key_input_map():
	input_map_keyboard = {
	"up" : KEY_W,
	"right" : KEY_D,
	"left" : KEY_A,
	"down" : KEY_S,
	"jump" : KEY_SPACE,
	"fire" : KEY_K,
	"special_weapon" : KEY_J,
	"dash" : KEY_L,
	"prev_weapon" : KEY_Q,
	"next_weapon" : KEY_E,
	"giga_attack" : KEY_I,
	"switch_player" : KEY_U,
	"subtank" : KEY_SHIFT
	}
	
	apply_key_input_map()
	emit_signal("key_changed")
	
func reset_button_input_map():
	input_map_controller = {
	"up" : JOY_BUTTON_12,
	"right" : JOY_BUTTON_15,
	"left" : JOY_BUTTON_14,
	"down" : JOY_BUTTON_13,
	"jump" : JOY_BUTTON_0,
	"fire" : JOY_BUTTON_2,
	"special_weapon" : JOY_BUTTON_6,
	"dash" : JOY_BUTTON_1,
	"prev_weapon" : JOY_BUTTON_4,
	"next_weapon" : JOY_BUTTON_5,
	"giga_attack" : JOY_BUTTON_7,
	"switch_player" : JOY_BUTTON_3,
	"subtank" : JOY_BUTTON_10
	}
	
	apply_joy_input_map()
	emit_signal("key_changed")

func replace_input_action_key(action_name, key : String, swap : bool = true):
	
	
	var clashing_action = ""
	var clashing_event
	if swap:
		for action in InputMap.get_actions():
			for event in InputMap.get_action_list(action):
				if event is InputEventKey and OS.get_scancode_string(event.scancode) == key and !action.begins_with("ui_"):
					clashing_action = action
					clashing_event = event
	
	for event in InputMap.get_action_list(action_name):
		if event is InputEventKey:
			if clashing_action:
				InputMap.action_erase_event(clashing_action, clashing_event)
				InputMap.action_add_event(clashing_action, event)
				input_map_keyboard[clashing_action] = event.scancode
	
			InputMap.action_erase_event(action_name,event)
		
	var new_event : InputEventKey = InputEventKey.new()
	new_event.scancode = OS.find_scancode_from_string(key)
	InputMap.action_add_event(action_name, new_event)

	input_map_keyboard[action_name] = new_event.scancode
	emit_signal("key_changed")

func replace_input_action_button(action_name, key : int, swap : bool = true):
	
	
	var clashing_action = ""
	var clashing_event
	if swap:
		for action in InputMap.get_actions():
			for event in InputMap.get_action_list(action):
				if event is InputEventJoypadButton and event.button_index == key and !action.begins_with("ui_"):
					clashing_action = action
					clashing_event = event
	
	for event in InputMap.get_action_list(action_name):
		if event is InputEventJoypadButton:
			if clashing_action:
				InputMap.action_erase_event(clashing_action, clashing_event)
				InputMap.action_add_event(clashing_action, event)
				input_map_controller[clashing_action] = event.button_index
	
			InputMap.action_erase_event(action_name,event)
		
	var new_event : InputEventJoypadButton = InputEventJoypadButton.new()
	new_event.button_index = key
	InputMap.action_add_event(action_name, new_event)

	input_map_controller[action_name] = new_event.button_index
	emit_signal("key_changed")


func _unhandled_input(event):

	if Input.is_key_pressed(KEY_ALT) and Input.is_key_pressed(KEY_ENTER):
		options["video"]["Fullscreen"] = !options["video"]["Fullscreen"]
		OS.window_fullscreen = !OS.window_fullscreen

func save_settings():
	for section in options.keys():
		for key in options[section]:
			config.set_value(section,key,options[section][key])
	config.save(save_path)

	
func load_settings():
	var error = config.load(save_path)
	if error != OK:
		return[]

	for section in options.keys():
		for key in options[section]:
			options[section][key] = config.get_value(section, key, null)
			set(key, options[section][key])

