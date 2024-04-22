extends Control


func _ready():

	var index_pos = 0
	

	for n in GameProgress.Missing_Reploid_List["AirForce"]:
		
		
		if n != null:
			var data : Reploid_Data = n
			$TabContainer/Hostage_screen/Hostage_List_Column_1.text += str(data.reploid_name) + str("\n")
			
			
		index_pos += 1
	
	MusicPlayer.volume = 0
	MusicPlayer.change_music("res://sound_assests/music/menu/options.ogg")
	MusicPlayer.start_music(false)
	yield(get_tree().create_timer(0.5),"timeout")
	display_reploids()
	$TabContainer/Hostage_screen/Hostage_List_Column_1.visible = true


func display_reploids():
	
	$TabContainer/Hostage_screen/Hostage_List_Column_1.max_lines_visible += 1
	yield(get_tree().create_timer(0.25),"timeout")
	
	if $TabContainer/Hostage_screen/Hostage_List_Column_1.max_lines_visible < $TabContainer/Hostage_screen/Hostage_List_Column_1.get_line_count():
		display_reploids()
