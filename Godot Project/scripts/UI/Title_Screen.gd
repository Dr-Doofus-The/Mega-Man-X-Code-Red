extends Node2D

onready var test_level = "res://nodes/Levels/Lvl_Wind_Crowrang.tscn"

onready var characters = [
	"X", "Blade Armor X","Glide Armor X","Ultimate Armor X", "Zero", "Black Zero", "Axl"
]

onready var selected_characters = [0,4] setget _set_selected_characters, get_selected_characters

var menu_state = 0

var pathToGo = null

var canClick : bool = true

onready var level_list = [
	{"Name": "Hunter Base", "Path" : "res://nodes/Levels/Lvl_Hunter_Base.tscn"},
	#{"Name": "Test Level", "Path" : "res://TestLevel.tscn"},
	{"Name": "Test Level_2", "Path" : "res://nodes/Levels/Lvl_Test_2.tscn"},
	{"Name": "Test Level", "Path" : "res://nodes/Levels/lvl_test_3.tscn"},
	{"Name": "Slash Beast Boss", "Path" : "res://nodes/Levels/lvl_boss_test.tscn"},
	{"Name": "Flame mammoth", "Path" : "res://nodes/Levels/Flame_mammoth.tscn"},
	{"Name": "Flame Hyenard", "Path" : "res://nodes/Levels/Lvl_Flame_Hyenard.tscn"},
	#{"Name": "Magma Dragoon", "Path" : "res://nodes/Levels/MagmaDragoon_Stage.tscn"},
	{"Name": "Wind Crowrang", "Path" : "res://nodes/Levels/Lvl_Wind_Crowrang.tscn"}

]

func _ready():
	for n in level_list:
		var button = $TextureButton.duplicate()
		
		$VBoxContainer.add_child(button)
		button.visible = true
		button.get_node("Label").text = n["Name"]
		button.connect("focus_entered",self,"selection_changed")
	for a in $VBoxContainer2.get_children():
		a.connect("focus_entered",self,"selection_changed")
	_set_selected_characters([0,4])

func _unhandled_input(event):

	if event.is_action_pressed("ui_pause") and canClick:
		match menu_state:
			0:
				$AudioStreamPlayer.play()
				canClick = false
				$Yield_Timer.start(0.33);yield($Yield_Timer,"timeout")
				canClick = true
				
				$VBoxContainer.visible = true
				$VBoxContainer.get_child(0).grab_focus()
				$Label.visible = false
				menu_state = 1
				$UiArrowPlaceHolder.visible = true
				$UiArrowPlaceHolder.global_position.y = $VBoxContainer.get_focus_owner().rect_global_position.y


			1:
				var num = $VBoxContainer.get_focus_owner().get_index()
				$VBoxContainer.get_focus_owner().release_focus()
				Sound.SND_UI_SELECTION_CONFIRM.play()
				canClick = false
				$Yield_Timer.start(0.33);yield($Yield_Timer,"timeout")
				canClick = true
				pathToGo = level_list[num]["Path"]
				menu_state = 2
				$VBoxContainer.visible = false
				$VBoxContainer2.visible = true
				
				
				$VBoxContainer2.get_child(0).grab_focus()
				$UiArrowPlaceHolder.global_position.y = $VBoxContainer2.get_focus_owner().rect_global_position.y

				
			2:
				Sound.SND_UI_SELECTION_CONFIRM.play()
				canClick = false
				$Yield_Timer.start(0.33);yield($Yield_Timer,"timeout")
				for n in 2:
					match selected_characters[n]:
						0,1,2,3:
							Global.Characters_To_Spawn[n] = 0
							GameProgress.Head_Part = selected_characters[n]
							GameProgress.Arm_Part = selected_characters[n]
							GameProgress.Body_Part = selected_characters[n]
							GameProgress.Leg_Part = selected_characters[n]
						4,5:
							Global.Characters_To_Spawn[n] = 1
							GameProgress.current_zero_armor = selected_characters[n] - 4
						6:
							Global.Characters_To_Spawn[n] = 2
				Global.ViewPort.change_scene(pathToGo)
				
	if (event.is_action_pressed("left") or event.is_action_pressed("right")) and menu_state == 2:
		var dir = -1 if event.is_action_pressed("left") else 1
		
		var idx = $VBoxContainer2.get_focus_owner().get_index()
		Sound.play_sound(Sound.SND_UI_SELECTION,-3,1)
		match idx:
			0:
				_set_selected_characters([(selected_characters[0] + characters.size() + dir) % characters.size(),selected_characters[1]])
			1:
				_set_selected_characters([selected_characters[0],(selected_characters[1] + characters.size() + dir) % characters.size()])

func selection_changed():
	if menu_state > 0:
		Sound.play_sound(Sound.SND_UI_SELECTION,-3,1)
	$UiArrowPlaceHolder.global_position.y = $VBoxContainer.get_focus_owner().rect_global_position.y

func _set_selected_characters(value : Array) -> void:
	selected_characters = value
	$VBoxContainer2/TextureButton/Label.text = "Character 1: " + characters[selected_characters[0]]
	$VBoxContainer2/TextureButton2/Label.text = "Character 2: " + characters[selected_characters[1]]

func get_selected_characters() -> Array:
	return selected_characters
