extends Control
var wp_manager = [] #0 = X | 1 = Zero | 2 = Axl
var player

func _ready():
	wp_manager.resize(2)
	var _con = EventBus.connect("PlayerInitialized",self,"initialized")

func initialized():
	yield(get_tree(),"physics_frame")
	for n in Global.Character_Slots:
		match n.character_name:
			0:
				wp_manager[0] = n.WeaponManager
			1:
				wp_manager[1] = n.WeaponManager

	reset()
	var _con = EventBus.connect("UpdateWeaponInfo",self,"update_weapon_icon")
	var _con2 = EventBus.connect("PlayerHealthUpdated",self,"update_life")
	var _con3 = EventBus.connect("UpdateHealthBar",self,"update_bar_size")
	
	update_weapon_icon()
	update_life(false)
	update_bar_size()

func reset():
	
	if EventBus.is_connected("UpdateWeaponInfo",self,"update_weapon_icon"):
		EventBus.disconnect("UpdateWeaponInfo",self,"update_weapon_icon")
		EventBus.disconnect("PlayerHealthUpdated",self,"update_life")
		EventBus.disconnect("UpdateHealthBar",self,"update_bar_size")


func update_weapon_icon():
	match Global.Player.character_name:
		0:
#			if wp_manager and wp_manager.current_weapon_index != 0:
#				$Icon.frame = 4
#				$Icon/Weapon_icon.visible = true
#				$Icon/Weapon_icon.frame = clamp(wp_manager.weapons[wp_manager.current_weapon_index].Weapon_Icon_Frame - 1,0,7)
#			else:
			$Icon.frame = 0
			$Icon/Weapon_icon.visible = false
#				
			$Health_Bar_Frame/Weapon_Bar_Progress.get_material().set_shader_param("first_color", wp_manager[0].weapons[wp_manager[0].current_weapon_index].Weapon_Color - Color(0.4,0.4,0.4))
			$Health_Bar_Frame/Weapon_Bar_Progress.get_material().set_shader_param("second_color", wp_manager[0].weapons[wp_manager[0].current_weapon_index].Weapon_Color)
			update_weapon_bar()
			ammo_counter_update()
			$Icon/Character_Specific_Colors.modulate = Color("51cdeb")
	
		1:
			$Icon.frame = 1
			$Icon/Character_Specific_Colors/Label.text = str(Global.lives)
			$Icon/Character_Specific_Colors.modulate = Color("ff6a6a")
			update_weapon_bar()
	

func ammo_counter_update():
	match Global.Player.character_name:
#		"X":
#			if wp_manager.current_weapon_index != 0:
#				if wp_manager.show_charge_ammo and wp_manager.current_weapon_index != 0:
#					$Icon/Character_Specific_Colors/Label.text = str(floor((wp_manager.weapons[wp_manager.current_weapon_index].ammo)/(wp_manager.weapons[wp_manager.current_weapon_index].charged_shot_cost)))
#				else:
#					$Icon/Character_Specific_Colors/Label.text = str(wp_manager.weapons[wp_manager.current_weapon_index].ammo)
#			else:
#				$Icon/Character_Specific_Colors/Label.text = str(Global.lives)
		1:
			$Icon/Character_Specific_Colors/Label.text = str(Global.lives)
func update_weapon_bar():
	match Global.Player.character_name:
		0:
			$Health_Bar_Frame/Weapon_Bar_Progress.max_value = wp_manager[0].weapons[wp_manager[0].current_weapon_index].Ammo_capacity
			$Health_Bar_Frame/Weapon_Bar_Progress.value = wp_manager[0].weapons[wp_manager[0].current_weapon_index].ammo
		1:
			$Health_Bar_Frame/Weapon_Bar_Progress.max_value = wp_manager[1].max_meter
			$Health_Bar_Frame/Weapon_Bar_Progress.value = wp_manager[1].meter

			set_bar_color(1)

func set_bar_color(chara : int):
	match chara:
		1:
			var meter = wp_manager[1].meter
			
			if meter == 100:
				
				$Health_Bar_Frame/Weapon_Bar_Progress.get_material().set_shader_param("first_color", Color("#dbc804") / 2)
				$Health_Bar_Frame/Weapon_Bar_Progress.get_material().set_shader_param("second_color", Color("#dbc804"))
				return
			if meter >= 75 and meter < 99:
				
				$Health_Bar_Frame/Weapon_Bar_Progress.get_material().set_shader_param("first_color", Color("#b012b4") / 2)
				$Health_Bar_Frame/Weapon_Bar_Progress.get_material().set_shader_param("second_color", Color("#b012b4"))
				return
				
			if meter >= 50 and meter < 75:
				
				$Health_Bar_Frame/Weapon_Bar_Progress.get_material().set_shader_param("first_color", Color("#b41212") / 2)
				$Health_Bar_Frame/Weapon_Bar_Progress.get_material().set_shader_param("second_color", Color("#b41212"))
				return
				
			if meter >= 25 and meter < 50:
				
				$Health_Bar_Frame/Weapon_Bar_Progress.get_material().set_shader_param("first_color", Color("#12b414") / 2)
				$Health_Bar_Frame/Weapon_Bar_Progress.get_material().set_shader_param("second_color", Color("#12b414"))
				return
				
			if meter >= 0 and meter < 25:
				
				$Health_Bar_Frame/Weapon_Bar_Progress.get_material().set_shader_param("first_color", Color("#1243b4") / 2)
				$Health_Bar_Frame/Weapon_Bar_Progress.get_material().set_shader_param("second_color", Color("#1243b4"))
				return

func update_life(slow : bool):
	var inactive_player : player_character
	
	if Global.Character_Slots[1]:
		inactive_player = Global.Character_Slots[abs(Global.get_active_player() - 1)]
	
	$Health_Bar_Frame/Health_Bar_Progress.max_value = Global.Player.hp_max
	$Health_Bar_Frame/Health_Bar_Progress_red.max_value = Global.Player.hp_max
	if inactive_player:
		$Inactive_Bar/Health_Bar_Inactive_Player/Health_Bar_Progress.max_value = inactive_player.hp_max
	
	if slow:
		Sound.SND_UI_UPDATE_HEALTH.play()
		while $Health_Bar_Frame/Health_Bar_Progress.value != Global.Player.hp:
			$Health_Bar_Frame/Health_Bar_Progress.value += 0.5
			$Timer.start(0.03) ; yield($Timer,"timeout")
		Sound.SND_UI_UPDATE_HEALTH.stop()
	
	$Health_Bar_Frame/Health_Bar_Progress.value = Global.Player.hp
	if inactive_player:
		$Inactive_Bar/Health_Bar_Inactive_Player/Health_Bar_Progress.value = inactive_player.hp
	
	if $Health_Bar_Frame/Health_Bar_Progress_red.value < Global.Player.hp:
		$Health_Bar_Frame/Health_Bar_Progress_red.value = Global.Player.hp
	else:
		$Red_start_timer.start()
	
func update_bar_size():

	$Health_Bar_Frame.rect_size.x = Global.Player.hp_max * 3 + 4
	$Health_Bar_Frame/Health_Bar_Progress.rect_size.x = Global.Player.hp_max * 3
	$Health_Bar_Frame/Health_Bar_Progress_red.rect_size.x = Global.Player.hp_max * 3
	
	$Inactive_Bar/Health_Bar_Inactive_Player.rect_size.x = (Global.Player.hp_max * 3) + 11
	$Inactive_Bar/Health_Bar_Inactive_Player/Health_Bar_Progress.rect_size.x = (Global.Player.hp_max * 3) + 3
	
	$Health_Bar_Frame/Weapon_Bar_Progress.rect_size.x = Global.Player.hp_max * 3 - 16


func _on_Red_start_timer_timeout():
	while $Health_Bar_Frame/Health_Bar_Progress_red.value > Global.Player.hp:
		
		$Health_Bar_Frame/Health_Bar_Progress_red.value -= 0.5
		$red_decrement_timer.start(); yield($red_decrement_timer,"timeout")
