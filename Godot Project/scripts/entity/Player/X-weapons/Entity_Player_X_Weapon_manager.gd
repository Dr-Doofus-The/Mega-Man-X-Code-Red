extends Node2D

signal weapon_changed(weapon_name)
signal special_weapon_fired()

signal fire_shot()
signal fire_chargeshot()

onready var projectile_spawn_point = $"../Projectile_Spawn/Projectile_Spawn_Point"

onready var muzzleflash = get_node("../Projectile_Spawn/Projectile_Spawn_Point/Muzzle")
onready var muzzleflash_back = get_node("../Projectile_Spawn/Projectile_Spawn_Point/Muzzle/Muzzle_Back")
onready var shot_anim_timer = $"%Shot_Anim_Timer"

onready var saber_hitbox = get_node("../Sprite/Saber_Container/Saber_hitbox")
onready var saber_hitbox_col = get_node("../Sprite/Saber_Container/Saber_hitbox/CollisionShape2D")



# WEAPONS
onready var shotgun_ice = preload("res://nodes/entity/Players/X/Weapons/X_Weapon_Shotgun_Ice.tscn")
onready var homing_torpedo = preload("res://nodes/entity/Players/X/Weapons/X_Weapon_Homing_Torpedo.tscn")
onready var chameleon_sting = preload("res://nodes/entity/Players/X/Weapons/X_Weapon_Chameleon_Sting.tscn")
onready var boomerang_cutter = preload("res://nodes/entity/Players/X/Weapons/X_Weapon_Boomerang_Cutter.tscn")
onready var fire_wave = preload("res://nodes/entity/Players/X/Weapons/X_Weapon_Fire_Wave.tscn")
onready var rolling_shield = preload("res://nodes/entity/Players/X/Weapons/X_Weapon_Rolling_Shield.tscn")

onready var charge_fx_lvl2 = get_node("../Sprite/Charge_fxs/Level_2_charge_fx")
onready var charge_fx_lvl3 = get_node("../Sprite/Charge_fxs/Level_3_charge_fx")


onready var current_weapons = $X_buster
onready var X_buster_projectile_spawner = $X_buster/Projectile_spawner

var weapons: Array = [null,null,null,null,null,null,null,null,null]
var current_weapon_index = 0

onready var Player = get_parent()

var is_charge_anim_playing

enum buster_shots {STANDARD, STANDARD_CHARGE_1,STANDARD_CHARGE_2,STANDARD_CHARGE_3}

var charge_timers : Array = [0,0] # INDEX 0 = BUSTER | INDEX 1 = SPECIAL WEAPON

var charge_threshold : Array = [0.5,1.7,3]

var charge_cooldown_time = 0
var shoot_anim_cooldown_time = 0.3


enum SaberAttacks{STANDARD_SLASH, AIR_SLASH, CHARGE_SLASH_BLADE, SPECIAL_WEAPON}

func _ready():
	var _con = Global.connect("PlayerSpawned", self,"start_weapon")
	
	weapons[0] = $X_buster
	spawn_special_weapons()
	
func _unhandled_input(event):
	

	
	if Player.HasControl and !get_tree().paused:
		#Switching Weapons:
		
		if GameProgress.Boss_Defeated_Array.has(true) and (event.is_action_pressed("next_weapon") || event.is_action_pressed("prev_weapon")):
			var weapon_switch_dir
			
			if event.is_action_pressed("next_weapon"):
				weapon_switch_dir = 1
			elif event.is_action_pressed("prev_weapon"):
				weapon_switch_dir = -1
			if weapon_switch_dir:
				
				current_weapon_index = (current_weapon_index + weapon_switch_dir) % 9
				if current_weapon_index < 0:
					current_weapon_index += 8
				while weapons[current_weapon_index] == null:
					current_weapon_index = (current_weapon_index + weapon_switch_dir) % 9
					if current_weapon_index < 0:
						current_weapon_index += 8
				switch_weapons()
		
		if event.is_action_pressed("fire") and can_shoot():
			if Settings.options["input"]["auto_charge"]:
				if charge_timers[0] < charge_threshold[0]:

					fire_shot(buster_shots.STANDARD)
			else:
				fire_shot(buster_shots.STANDARD)
		
		#CHARGE SHOT
		if event.is_action_released("fire") and can_shoot() and !Settings.options["input"]["auto_charge"] || event.is_action_pressed("fire") and can_shoot() and Settings.options["input"]["auto_charge"]:
			Player.flash_coordinate = Vector2.ZERO
			if charge_timers[0] >= charge_threshold[2] and GameProgress.Arm_Part != GameProgress.Armor.NONE:
				if GameProgress.Arm_Part == GameProgress.Armor.BLADE and Input.is_action_pressed("up"):
					do_saber_attack(SaberAttacks.CHARGE_SLASH_BLADE)
				else:
					fire_shot(buster_shots.STANDARD_CHARGE_3)
			elif charge_timers[0] >= charge_threshold[1]:
				fire_shot(buster_shots.STANDARD_CHARGE_2)
			elif charge_timers[0] >= charge_threshold[0]:
				fire_shot(buster_shots.STANDARD_CHARGE_1)
		
		#Special Weapon + Saber
		
		if event.is_action_pressed("special_weapon"):
			#fire_special_weapon(1)
			
			if current_weapon_index == 0:
			
				match Player.animplayer.current_animation:
					_:
						if Player.is_on_floor() and !Player.isAttacking:
							do_saber_attack(SaberAttacks.STANDARD_SLASH)
						elif !Player.is_on_floor()and !Player.isAttacking:
							do_saber_attack(SaberAttacks.AIR_SLASH)
			elif can_fire_special_weapon():
				
				if Input.is_action_pressed("up") and [5].has(current_weapon_index):
					do_saber_attack(SaberAttacks.SPECIAL_WEAPON)
				else:
					fire_special_weapon(1)
		
		#GIGA
		
		if event.is_action_pressed("giga_attack"):
			if GameProgress.Body_Part == GameProgress.Armor.ULTIMATE:
				do_nova_strike()
			
	if event.is_action_released("fire") and !Settings.options["input"]["auto_charge"]:
		Player.flash_coordinate = Vector2.ZERO
		Sound.SND_PL_X_CHARGE.stop()
	

func _physics_process(delta):
	if Global.Player == Player and !get_tree().paused:
		if Player.isAttacking and Player.saber_animator.is_playing():
			match Player.saber_animator.current_animation:
				"Saber_Air_Charge_Blade":
					Player.stop_movement()
					
			
			$"../Sprite/Saber_Container".visible = true
			$"../Sprite/Saber_Container".scale.x = Player.PlayerDirection
		else:
			saber_hitbox_col.set_deferred("disabled", true)
			$"../Sprite/Saber_Container".visible = false
			Player.saber_animator.stop()
		
		if Input.is_action_pressed("fire") || Settings.options["input"]["auto_charge"]:
			charge_timers[0] += delta
			
			if charge_timers[0] > charge_threshold[2] and GameProgress.Arm_Part != GameProgress.Armor.NONE:
				Player.flash_coordinate = Vector2(0.675,0.054)
			
			elif charge_timers[0] > charge_threshold[1]:
				charge_fx_lvl3.visible = true
				Player.flash_coordinate = Vector2(0.447,0.054)

		
			elif charge_timers[0] > charge_threshold[0]:
				charge_fx_lvl2.visible = true
				charge_fx_lvl2.playing = true
				Player.flash_coordinate = Vector2(0.338,0.054)
				if !Sound.SND_PL_X_CHARGE.playing:
					Sound.SND_PL_X_CHARGE.play()
		else:
			if charge_timers[0] > 0:
				charge_timers[0] = 0
				charge_fx_lvl3.visible = false
				
				charge_fx_lvl2.visible = false
				charge_fx_lvl2.playing = false
				charge_fx_lvl2.frame = 0
		
	
	#Flashing
	if Engine.get_physics_frames()%3 == 0 and !get_tree().paused:
		
		#DAMAGE FLASH
		if Player.i_frame_timer.time_left > 0:
			if Player.ent_sprite.material.get_shader_param("frame_coordinate") != Vector2(0.228,0.036):
				Player.switch_palette(Vector2(0.228,0.036))
			else:
					Player.return_to_standard_palette()
		
		#BASICALLY EVERYTHING ELSE
		if Player.flash_coordinate != Vector2.ZERO:
		
			if Player.charge_fxs_mat.get_shader_param("frame_coordinate") != Player.flash_coordinate:
				if !Player.i_frame_timer.time_left > 0:
					Player.switch_palette(Player.flash_coordinate)
				Player.charge_fxs_mat.set_shader_param("frame_coordinate",Player.flash_coordinate)

			else:
				if !Player.i_frame_timer.time_left > 0:
					if Player.flash_fire_timer.time_left > 0:
						Player.switch_palette(Player.current_color_palette_fire)
					else:
						Player.switch_palette(Player.current_color_palette)
				Player.charge_fxs_mat.set_shader_param("frame_coordinate", Player.WeaponManager.current_weapons.color_palette_coordinate)
				

		#else:
		#	Player.return_to_standard_palette()
			
	if Player.flash_coordinate == Vector2.ZERO and Player.i_frame_timer.time_left == 0:
		Player.return_to_standard_palette()
		
	if !shoot_anim_cooldown_time <= 0:
		shoot_anim_cooldown_time -= delta
	if !charge_cooldown_time <= 0:
		charge_cooldown_time -= delta

func fire_shot(lvl):
	var bullet : Projectile
	$"../Projectile_Spawn".scale.x = -1 if Player.PlayerDirection < 0 else 1
	muzzleflash.frame = 0
	Player.isAttacking = false
	match lvl:
		buster_shots.STANDARD:
			bullet = Assets.PROJ_X_BUSTER_1.instance()
			charge_cooldown_time = 0.06
			emit_signal("fire_shot")
			Sound.SND_PRJ_X_BUSTER_FIRE.play()
			Player.flash_fire_timer.start()
			muzzleflash.play("buster_1")
		buster_shots.STANDARD_CHARGE_1:
			bullet = Assets.PROJ_X_BUSTER_2.instance()
			emit_signal("fire_shot")
			charge_cooldown_time = 0.3
			Sound.SND_PRJ_X_BUSTER_1_FIRE.play()
			muzzleflash.play("buster_2")
		buster_shots.STANDARD_CHARGE_2:
			bullet = Assets.PROJ_X_BUSTER_3.instance()
			emit_signal("fire_chargeshot")
			charge_cooldown_time = 0.3
			Sound.SND_PRJ_X_BUSTER_2_FIRE.play()
			muzzleflash.play("buster_3")
			muzzleflash_back.play("buster_3")
			Player.play_voice("charge_shot")
			
		buster_shots.STANDARD_CHARGE_3:
			
			match GameProgress.Arm_Part:
				GameProgress.Armor.ULTIMATE:
					bullet = Assets.PROJ_X_BUSTER_ULTIMATE.instance()
					Sound.SND_PRJ_X_BUSTER_2_FIRE.play()
					
					
					
				GameProgress.Armor.GLIDE:
					bullet = Assets.PROJ_X_BUSTER_GLIDE.instance()
					Sound.SND_PRJ_X_BUSTER_2_FIRE.play()
					
					for n in [-0.2,-0.1,0.1,0.2]:
						var bul : Projectile = Assets.PROJ_X_BUSTER_2.instance()
						bul.global_position = projectile_spawn_point.global_position
						bul.rotation = n*5.0
						bul.BulletDire = Player.PlayerDirection
						bul.auto_rotate_sprite = false
						weapons[0].projectile_spawner.add_child(bul)
						
						var tw = bul.create_tween()
						tw.tween_property(bul,"rotation",0.0,0.5)
				_:
					bullet = Assets.PROJ_X_BUSTER_3.instance()
					Sound.SND_PRJ_X_BUSTER_2_FIRE.play()
			charge_cooldown_time = 0.3
			emit_signal("fire_chargeshot")
			Player.play_voice("big_charge_shot")
			
	if [Player.state.WALLSLIDING,Player.state.WALLCLING].has(Player.current_state):
		bullet.BulletDire = Player.PlayerDirection * -1
	else:
		bullet.BulletDire = Player.PlayerDirection

	bullet.global_position = projectile_spawn_point.global_position
	weapons[0].projectile_spawner.add_child(bullet)

	shot_anim_timer.start()
	Player.IsShooting = true
	charge_timers[0] = 0
	for n in $"../Sprite/Charge_fxs".get_children():
		n.visible = false
	Player.flash_coordinate = Vector2.ZERO
	Sound.SND_PL_X_CHARGE.stop()
	
	match lvl:
		buster_shots.STANDARD:
			match GameProgress.Arm_Part:

				_:
					charge_cooldown_time = 0.06

func fire_special_weapon(lvl):
	
		
		current_weapons.fire_shot(lvl)
		emit_signal("fire_shot")
		
		shot_anim_timer.start()
		Player.IsShooting = true
		EventBus.emit_signal("UpdateWeaponInfo")


func can_shoot() -> bool:
	return true if ![Player.state.GIGA].has(Player.current_state) and !Player.isAttacking and charge_cooldown_time <= 0 and weapons[0].projectile_spawner.get_child_count() < weapons[0].max_on_screen else false

func can_saber() -> bool:
	return true if ![Player.state.GIGA].has(Player.current_state) else false
	

func can_fire_weapon_charge():
	pass

func can_fire_special_weapon() -> bool:
	return true if (current_weapons.ammo - current_weapons.normal_shot_cost) >= 0 and current_weapons.projectile_spawner.get_child_count() < current_weapons.max_on_screen and charge_cooldown_time <= 0 and ![Player.state.GIGA].has(Player.current_state) and !Player.isAttacking else false

func can_special_weapon_saber() -> bool:
	return true if (current_weapons.ammo - current_weapons.saber_shot_cost) >= 0 and ![Player.state.GIGA].has(Player.current_state) and !Player.isAttacking and current_weapons.projectile_spawner.get_child_count() < current_weapons.max_on_screen else false

func do_saber_attack(attack):
	Player.isAttacking = true
	$"../Sprite/Saber_Container/Saber_Sprite".visible = true
	saber_hitbox_col.set_deferred("disabled", false)
	
	Player.saber_animator.playback_speed = 1 if GameProgress.Arm_Part != GameProgress.Armor.BLADE else 1.25
	saber_hitbox.linger_frames = 4 if Player.saber_animator.playback_speed == 1 else 3
	
	match attack:
		SaberAttacks.STANDARD_SLASH:
			Player.saber_animator.play("Saber_1")
			Player.current_state = Player.state.IDLE
			Player.dir = 0
			Player.x_velocity = 0
			Sound.play_sound(Sound.SND_ATTA_SABER_SWING_1,1,1)
		SaberAttacks.AIR_SLASH:
			Player.saber_animator.play("Saber_Air")
			Sound.play_sound(Sound.SND_ATTA_SABER_SWING_1,1,1)
		SaberAttacks.CHARGE_SLASH_BLADE:
			if Player.is_on_floor():
				Player.saber_animator.play("Saber_Charge_Blade")
				Player.current_state = Player.state.IDLE
				Player.dir = 0
				Player.x_velocity = 0
			else:
				Player.gravity_affected = false
				Player.saber_animator.play("Saber_Air_Charge_Blade")
			Sound.play_sound(Sound.SND_ATTA_SABER_SWING_1,1,1)
		SaberAttacks.SPECIAL_WEAPON:
			if Player.is_on_floor():
				Player.current_state = Player.state.IDLE
				Player.dir = 0
				Player.x_velocity = 0
				Player.saber_animator.play("Saber_Wind_Cutter")
			else: 
				Player.saber_animator.play("Saber_Air_Wind_Cutter")
			Sound.play_sound(Sound.SND_ATTA_SABER_SWING_1,1,1)

func perform_special_saber_action():

	match current_weapons.name:
		"Wind_Cutter":
			var proj : Projectile = Assets.PROJ_X_WIND_CUTTER_SABER.instance()
			proj.global_position = global_position + Vector2(Player.PlayerDirection * 32, 0)
			proj.BulletDire = Player.PlayerDirection
			current_weapons.projectile_spawner.add_child(proj)
		"Volt_Tornado":
			var proj : Projectile = Assets.PROJ_X_VOLT_TORNADO_SABER.instance()
			proj.global_position = global_position + Vector2(Player.PlayerDirection * 32, 0)
			proj.BulletDire = Player.PlayerDirection
			current_weapons.projectile_spawner.add_child(proj)

func do_nova_strike():

	var onwall = true if [Player.state.WALLCLING,Player.state.WALLSLIDING].has(Player.current_state) else false


	Player.do_giga_attack()
	
	if onwall:
		Player.dir = -0.8 * Player.PlayerDirection

	else:
		Player.dir = 0.8 * Player.PlayerDirection

	$"../Sounds/snd_player_jump".play()
	Player.velocity.y = -200
	Player.get_giga_attack().active = false
	Player.AirDashCount = 0
	var velo_tween = create_tween()
	
	velo_tween.tween_property(Player,"velocity:y",0.0,0.22)
	
	Player.ent_sprite.frame = 0
	Player.ent_sprite.play("Nova_Strike")
	Player.ent_sprite.frame = 0

func nova_strike():
	Sound.play_sound(Sound.SND_PRJ_NOVA_STRIKE,6,0.88)

	Player.turn_off_hurtbox(true)
	Player.ent_sprite.play("Nova_Strike_Loop")
	Player.get_giga_attack().active = true
	Player.velocity.y = 0
	Player.dir = 3.4 * Player.PlayerDirection
	var strike_hitbox = hitbox.new()
	strike_hitbox.temporary = true
	strike_hitbox.time = 0.5
	strike_hitbox.size = Vector2(48,30)
	strike_hitbox.damage = 99
	strike_hitbox.set_collision_layer_bit(4,true)
	strike_hitbox.set_collision_mask_bit(2,true)
	Player.add_child(strike_hitbox)
	var timer = Timer.new()
	Player.add_child(timer)
	timer.start((0.5));yield(timer,"timeout")
	timer.queue_free()
	if Player.ent_sprite.animation == "Nova_Strike_Loop":
		Player.end_giga()
		Player.IsDashJumping = true
		Player.x_momentum_velocity = 400 * Player.PlayerDirection
		Player.turn_off_hurtbox(false)


func spawn_special_weapons():
	var current_array_index = 0
	for n in GameProgress.Boss_Defeated_Array:

		if n:
			var weapon
			match current_array_index:
				0:
					weapon = shotgun_ice.instance()
				1:
					weapon = Assets.X_WEAP_WINDCUTTER.instance()
				2:
					weapon = rolling_shield.instance()
				3:
					weapon = Assets.X_WEAP_SPLASHLASER.instance()
				4:
					weapon = Assets.X_WEAP_VOLTTORNADO.instance()
				5:
					weapon = homing_torpedo.instance()
				6:
					weapon = Assets.X_WEAP_ARTILLERYMISSLE.instance()
				7:
					weapon = Assets.X_WEAP_SPREADBLAZER.instance()
			add_child(weapon)
			weapons[current_array_index + 1] = weapon
		current_array_index += 1
func start_weapon():
	current_weapon_index = 0
	switch_weapons()

func switch_weapons():
	current_weapons = weapons[current_weapon_index]
	emit_signal("weapon_changed",current_weapons.get_name())
	EventBus.emit_signal("UpdateWeaponInfo")
	Player.current_color_palette = Vector2(0.228,-0.001)
	yield(get_tree().create_timer(0.02),"timeout")
	Player.current_color_palette = current_weapons.color_palette_coordinate
	Player.current_color_palette_fire = current_weapons.fire_color_palette_coordinate
	Player.charge_fxs_mat.set_shader_param("frame_coordinate",current_weapons.color_palette_coordinate)


func is_weapon_projectile_alive():
	return true if current_weapons.projectile_spawner.get_child_count() > 0 else false

func refill_weapon(index, amount):
	weapons[index].ammo += amount


func _on_Sprite_frame_changed():
	match Player.ent_sprite.animation:
		"Nova_Strike":
			if Player.ent_sprite.frame == 5:
				nova_strike()

func _on_AnimationPlayer_animation_finished(anim_name):
	pass

func _on_Saber_AnimPlayer_animation_finished(anim_name):
	if Player.isAttacking:
		Player.isAttacking = false
		match anim_name:
			"Saber_Air_Charge_Blade":
				Player.gravity_affected = true


func _on_Saber_hitbox_damage_dealt(_old_hp, _new_hp, target):
	var par_location = saber_hitbox_col.global_position + ((target.global_position - saber_hitbox_col.global_position)/2)
	if !target.invulnerable:
		Sound.play_sound(Sound.SND_ATTA_SABER_HIT,-2,1)
		var par = Assets.PAR_SLASH_STANDARD.instance()
		
		var par_2 = Assets.PAR_SLASH_STANDARD_X6_EFFECT.instance()

		par.global_position = par_location
		Global.ViewPort.add_child(par)

		par_2.global_position = par_location
		par_2.rotation_degrees = (int(rand_range(0,2)) * 45) * Player.PlayerDirection
		par_2.modulate = Color("70b2f8fe")
		Global.ViewPort.add_child(par_2)
		
	else:
		var par = Assets.PAR_SHIELD_HIT.instance()
		par.global_position = par_location
		Global.ViewPort.add_child(par)

	
	if saber_hitbox.linger_frames > 0:
		Global._freeze_frame(0.04)

func _on_Shot_Anim_Timer_timeout():
	if Player.IsShooting:
		Player.IsShooting = false
