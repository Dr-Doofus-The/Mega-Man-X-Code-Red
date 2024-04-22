extends "res://scripts/UI/Menu_Base.gd"
onready var opt_button = preload("res://nodes/UI/Options/Option_Button.tscn")

func _ready():
	for n in Settings.options["video"]:
		var button = opt_button.instance()
		button.name_text = n
		$TabContainer/video/HBoxContainer.add_child(button)
	for n in Settings.options["audio"]:
		
		var button = opt_button.instance()
		button.name_text = n
		button.option_type = 1
		if ["master","sound_effect","music","voice"].has(n):
			button.slider = true
		
		$TabContainer/audio/HBoxContainer.add_child(button)
	for n in ["Keyboard_Settings","Controller_Settings"]:
		var button = opt_button.instance()
		button.name_text = n
		button.special_button = true
		$TabContainer/input/TabContainer/Main/HBoxContainer.add_child(button)



	var index_keyboard = 0
	for n in Settings.input_map_keyboard:
		var button = opt_button.instance()
		button.name_text = n
		button.remapper = true
		button.remapper_id = index_keyboard
		index_keyboard += 1
		$TabContainer/input/TabContainer/Keyboard_map/ScrollContainer/HBoxContainer.add_child(button)
		
	var space_button = Button.new()
	space_button.modulate.a = 0
	space_button.focus_mode =Control.FOCUS_NONE
	space_button.rect_min_size.y = 14
	$TabContainer/input/TabContainer/Keyboard_map/ScrollContainer/HBoxContainer.add_child(space_button)
		
	for n in ["reset_to_default","exit"]:
		var button = opt_button.instance()
		button.name_text = n
		button.special_button = true
		$TabContainer/input/TabContainer/Keyboard_map/ScrollContainer/HBoxContainer.add_child(button)





	var index_controller = 0
	for n in Settings.input_map_controller:
		var button = opt_button.instance()
		button.name_text = n
		button.remapper = true
		button.remapper_id = index_controller
		index_controller += 1
		$TabContainer/input/TabContainer/Controller_map/ScrollContainer/HBoxContainer.add_child(button)
		
	var space_button1 = Button.new()
	space_button1.modulate.a = 0
	space_button1.focus_mode =Control.FOCUS_NONE
	space_button1.rect_min_size.y = 14
	$TabContainer/input/TabContainer/Controller_map/ScrollContainer/HBoxContainer.add_child(space_button1)
		
	for n in ["reset_to_default","exit"]:
		var button = opt_button.instance()
		button.name_text = n
		button.special_button = true
		$TabContainer/input/TabContainer/Controller_map/ScrollContainer/HBoxContainer.add_child(button)


















	for n in Settings.options["input"]:
		var button = opt_button.instance()
		button.option_type = 2
		button.name_text = n
		$TabContainer/input/TabContainer/Main/HBoxContainer.add_child(button)


	for button in $HBoxContainer.get_children():
		button.tab = true
		button.connect("button_down",self,"on_button_press")

func on_button_press():
	$TabContainer.current_tab = get_focus_owner().get_index()
	if $TabContainer.current_tab == 2:
		$TabContainer/input/TabContainer.current_tab = 0
