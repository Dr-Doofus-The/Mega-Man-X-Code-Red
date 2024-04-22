extends KinematicBody2D

enum item_type {
	EXTRA_LIFE,
	HEALTH_RESTORE,
	WEAPON_RESTORE,
	HEART_TANK,
	SUB_TANK,
	DNA
}

onready var itemsprite = $AnimatedSprite
onready var coll_shape = $CollisionShape2D
onready var item_jingle = preload("res://sound_assests/ui/notif/notif_heart_sub_tank.wav")

export (int) var ItemID
export (int) var ItemID2

export (int) var ItemValue : int = 0

export(item_type) var Item_Type = item_type.HEALTH_RESTORE

export(int, "Small", "Big") var Item_size = 0

var velocity:Vector2 = Vector2.ZERO

var isgrounded = false
var magnetizing = false
var magnetize_speed = 30.0

var dna_timer : Timer

func _ready():
	set_physics_process(false)
	match Item_Type:
		item_type.HEART_TANK:
			if GameProgress.heart_tank_array.has(ItemID) == true:
				queue_free()
		item_type.DNA:
			ItemValue = ItemID
			$Sprite.frame = ItemValue
			var timer = Timer.new()
			timer.autostart = true
			add_child(timer)
			timer.connect("timeout",self,"switch_dna_id")
	

func _physics_process(delta):
	
	if not magnetizing:
		if not is_on_floor():
			velocity.y += Global.Gravity * delta
		else:
			velocity.y = 0
		
		if is_on_floor() and isgrounded == false:
			isgrounded = true
			$AnimatedSprite.playing = true
			
			
		if is_on_floor():
			velocity.x = 0
	else:
		magnetize_speed += delta * 1100
		velocity = global_position.direction_to(Global.Player.global_position).normalized() * magnetize_speed
	
	
	velocity = move_and_slide(velocity,Vector2.UP)

	

	if Item_Type == item_type.SUB_TANK:
		if Engine.get_physics_frames() % 3 == 0:
			
			itemsprite.modulate = Color(1,1,1) if itemsprite.modulate == Color(1,1,1) else Color(1,1,1)
	#global_position = global_position.round()

func magnetize():
	if ![item_type.HEART_TANK,item_type.SUB_TANK].has(Item_Type):
		velocity = Vector2.ZERO
		magnetizing = true
		set_collision_mask_bit(0,false)
	
func _on_Hitbox_body_entered(body):
	if body == Global.Player:
		match Item_Type:
			item_type.HEALTH_RESTORE:
				if body.hp < body.hp_max:
					body.hp += ItemValue
					EventBus.emit_signal("PlayerHealthUpdated",true)
				elif body.hp == body.hp_max:
					
					#CHECKS IF THERE IS EVEN ANY SUBTANKS TO WORK WITH
					if not GameProgress.Subtank_container.empty():
						
						var index = 0
						while index < GameProgress.Subtank_container.size():
							if not GameProgress.Subtank_container[index]["juice"] == GameProgress.Subtank_container[index]["juice_limit"]:
								fill_subtank(index)
								break
							index += 1
						
						#Checks if the first subtank is full
						#if GameProgress.Subtank_container[0]["juice"] == GameProgress.Subtank_container[0]["juice_limit"]:
							#Check if there is another subtank
						#	if GameProgress.Subtank_container.size() > 1 and GameProgress.Subtank_container[1]["juice"] != GameProgress.Subtank_container[1]["juice_limit"]:
						#		fill_subtank(1)
						#	else:
						#		pass
						#fill_subtank(0)
			
			item_type.WEAPON_RESTORE:
				match Global.Player.character_name:
					0:
						#Check What Weapon to Refill
						var wp_index = Global.Player.WeaponManager.current_weapon_index
						
						var loop_count = 0

						if GameProgress.Boss_Defeated_Array.has(true):
							while Global.Player.WeaponManager.weapons[wp_index] != null and Global.Player.WeaponManager.weapons[wp_index].ammo == Global.Player.WeaponManager.weapons[wp_index].Ammo_capacity || Global.Player.WeaponManager.weapons[wp_index] == null:

								
								if wp_index == 8:
									wp_index = 0
									
								else:
									wp_index += 1
								
								if loop_count >= 9:
									break
								else:
									loop_count += 1
							
						#Refill
						if Global.Player.WeaponManager.weapons[wp_index] != null:
							if Global.Player.WeaponManager.weapons[wp_index].ammo < Global.Player.WeaponManager.weapons[wp_index].Ammo_capacity:
								Global.Player.WeaponManager.weapons[wp_index].ammo += (ceil(Global.Player.WeaponManager.weapons[wp_index].Ammo_capacity/float(ItemValue)))
						EventBus.emit_signal("UpdateWeaponInfo")
						#Break loop if all weapons are full or you have no weapons
					
					1:

						#Refill
						Global.Player.WeaponManager.meter += 70/float(ItemValue)
						EventBus.emit_signal("UpdateWeaponInfo")
						#Break loop if all weapons are full or you have no weapons
					
			item_type.HEART_TANK:
				GameProgress.heart_tank_array.append(ItemID)
				heart_tank_animation()
				
			item_type.SUB_TANK:
				GameProgress.add_subtank()
				Global.Current_Hud.box_notify("SUBTANK ACQUIRED", "SUBTANK DESCRIPTION")
				visible = false
				var sound = SFX.new()
				sound.stream = item_jingle
				Global.ViewPort.add_child(sound)
				get_tree().paused = true
				Global.canPause = false
				yield(get_tree().create_timer(1),"timeout")
				get_tree().paused = false
				Global.canPause = true
		
			item_type.DNA:
				if Global.Player.character_name == 2:
					Global.Player.WeaponManager.set_copy_boost(ItemValue)
		
		if not Item_Type == item_type.HEART_TANK:
			queue_free()

func fill_subtank(id):
	match Item_size:
		0:
			GameProgress.Subtank_container[id]["juice"] += 1
			Sound.play_sound(Sound.SND_NOTIF_01,0,1.2)
		1:
			GameProgress.Subtank_container[id]["juice"] += 2
			Sound.play_sound(Sound.SND_NOTIF_01,0,1.2)
	if GameProgress.Subtank_container[id]["juice"] > GameProgress.Subtank_container[id]["juice_limit"]:
		GameProgress.Subtank_container[id]["juice"] = GameProgress.Subtank_container[id]["juice_limit"]

func heart_tank_animation():
	pause_mode = Node.PAUSE_MODE_PROCESS
	get_tree().paused = true
	visible = false
	Global.canPause = false
	Global.Current_Hud.box_notify("HEART TANK ACQUIRED", "MAXIMUM HEALTH INCREASED")
	Sound.SND_NOTIF_ITEM.play()
	yield(get_tree().create_timer(1),"timeout")
	var hp_count = 2
	Sound.SND_UI_UPDATE_HEALTH.play()
	while hp_count > 0:
		
		for n in Global.Character_Slots:
			n.hp_max += 1
			n.hp += 1
		EventBus.emit_signal("UpdateHealthBar")
		EventBus.emit_signal("PlayerHealthUpdated",false)
		
		hp_count -= 1
		yield(get_tree().create_timer(.04),"timeout")
	Sound.SND_UI_UPDATE_HEALTH.stop()
	Global.Player._update_max_health()
	get_tree().paused = false
	Global.canPause = true
	queue_free()
	
func _on_VisibilityNotifier2D_screen_exited():
	itemsprite.visible = false


func _on_VisibilityNotifier2D_screen_entered():
	itemsprite.visible = true
	set_physics_process(true)

func switch_dna_id():
	if ItemValue == ItemID:
		ItemValue = ItemID2
	else:
		ItemValue  = ItemID
	$Sprite.frame = ItemValue
	
