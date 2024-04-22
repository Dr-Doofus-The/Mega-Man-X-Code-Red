extends Node2D

enum attack_states {No_Attack, Saber_1, Saber_2, Saber_3, 
Air_slash, Up_slash, Dash_slash, Down_Thrust, Uppercut, 
Crouch_Slash, Aerial_Spin, Rolling_Slash,

Raijinshou, Hadengeki

}
var current_attack = attack_states.No_Attack


onready var Player = get_parent()
onready var saber_animator = $Saber_animator
onready var saber_sprite = $Saber_Content/AnimatedSprite
onready var saber_hitbox = $Saber_Content/Hitbox
onready var saber_hitbox_col = $Saber_Content/Hitbox/CollisionShape2D

onready var Can_Combo = true

#Z-Buster
var charge_timer : float = 0.0

var charge_threshold : Array = [0.7,3.0]

var charge_cooldown_time = 0
var shoot_anim_cooldown_time = 0.3

onready var meter = 0 setget set_meter, get_meter
onready var max_meter = 100

func _unhandled_input(event):

	
	if Player.HasControl:
#		if event.is_action_pressed("next_weapon") and can_fire_buster() and meter > 5:
#			fire_shot(0)
			#Sound.play_sound(Sound.SND_PL_ZERO_CHARGE,4,1)
		if event.is_action_released("fire") and can_fire_buster() and charge_timer > charge_threshold[0]:
			if charge_timer >= charge_threshold[1] and meter > 10:
				fire_shot(1)
			elif charge_timer > 0 and meter > 5:
				fire_shot(0)


func _physics_process(delta):

	if Global.Player == Player:
		if Input.is_action_pressed("fire") and meter > 10:
			charge_timer += delta
			if !Sound.SND_PL_ZERO_CHARGE.playing and charge_timer > charge_threshold[0]:
				Sound.play_sound(Sound.SND_PL_ZERO_CHARGE,2,1)
		else:


			charge_timer = 0
			Sound.SND_PL_ZERO_CHARGE.stop()
	
	if charge_timer > charge_threshold[1]:
		Player.charge_fxs.get_child(1).visible = true
	if charge_timer > charge_threshold[0]:
		Player.charge_fxs.get_child(0).visible = true
	else:
		Player.charge_fxs.get_child(1).visible = false
		Player.charge_fxs.get_child(0).visible = false
	

	if Input.is_action_just_pressed("fire"): 
		if Player.HasControl and Can_Combo:
			if not Player.is_on_floor():
				if Input.is_action_pressed("down"):
					_do_attack("Down_Thrust")
				elif Input.is_action_pressed("up") and current_attack != attack_states.Aerial_Spin:
					_do_attack("Aerial_Spin")
				else:
					if ![attack_states.Uppercut, attack_states.Air_slash].has(current_attack):
						_do_attack("Air_slash")
					
			else:
				if Input.is_action_pressed("up"):
					if Player.current_state == Player.state.DASHING and current_attack != attack_states.Dash_slash:
						_do_attack("Rolling_Slash")
					else:
						_do_attack("Uppercut")

				if Player.current_state == Player.state.CROUCHING || Player.current_state == Player.state.IDLE and Input.is_action_pressed("down"):
					_do_attack("Crouch_Slash")

			match current_attack:
				attack_states.No_Attack:
					if [Player.state.IDLE, Player.state.RUNNING, Player.state.RUN_IN, Player.state.DASHING, Player.state.DASH_SKID, Player.state.DASH_START].has(Player.current_state):

						if [Player.state.DASHING, Player.state.DASH_START].has(Player.current_state):
							_do_attack("Dash_slash")
						else:
							_do_attack("Saber_1")
				attack_states.Saber_1:
					_do_attack("Saber_2")
				attack_states.Saber_2:
					_do_attack("Saber_3")
				attack_states.Saber_3:
					_do_attack("Air_slash_land")
	
	if Input.is_action_just_pressed("special_weapon"):
		if Player.HasControl and Can_Combo:
			if Player.is_on_floor():
				if Input.is_action_pressed("ui_up") and GameProgress.Boss_Defeated_Array[4] == true:
					_do_attack("Raijinshou")
					return
				if GameProgress.Boss_Defeated_Array[3] == true:
					_do_attack("Hadengeki")
	if Player.isAttacking:
		
		
		$Saber_Content.scale.x = -1 if Player.PlayerDirection < 0 else 1
		
		match current_attack:
			attack_states.Rolling_Slash:
				Player.current_state = Player.state.DASHING
				if Player.dir != 0 and Player.dir < Player.PlayerDirection:
					Player.isAttacking = false
					Player.current_state = Player.state.RUNNING
			attack_states.Uppercut:
				if saber_animator.current_animation == "Uppercut_Loop":

					
					if Player.velocity.y > 0:
						Player.velocity.y *= 0.2
						Player.x_momentum_velocity *= 0.2
						saber_animator.play("Uppercut_End")
					if Player.velocity.y > -300:
						Can_Combo = true

			attack_states.Dash_slash:
				Player.current_state = Player.state.DASHING
			attack_states.Down_Thrust:

				if Player.is_on_floor():
					Player.AirDashCount = 1
					Player.x_velocity = 0
					Player.HasDoubleJumped = false
					
				elif Player.HasControl:
					Player.x_velocity = (Input.get_action_strength("right") - Input.get_action_strength("left")) * 80
				if saber_animator.current_animation == "Down_Thrust_Loop" and Player.is_on_floor():
					if Player.dirY > 0:
						Player.current_state = Player.state.CROUCHING
					else:
						Player.current_state = Player.state.IDLE
					$"../Sounds/snd_player_land".play()
					Player.isAttacking = true
					Player.ent_sprite.prev_state = Player.state.IDLE
					saber_animator.play("Down_Thrust_End")
			attack_states.Raijinshou:
				if Player.HasControl and saber_animator.current_animation != "Raijinshou":
					Player.x_velocity = (Input.get_action_strength("right") - Input.get_action_strength("left")) * 70
			attack_states.Aerial_Spin:
				
				
				
				if Player.is_on_floor() || Input.is_action_just_pressed("jump") and Player.AirDashCount > 0 and Player.HasControl:
					Player.isAttacking = false
			attack_states.Air_slash:
				if Player.is_on_floor() and saber_animator.current_animation == "Air_slash":
					var anim_pos = saber_animator.current_animation_position
					saber_animator.play("Air_slash_land")
					saber_animator.seek(anim_pos)
					Player.current_state = Player.state.IDLE
					Player.ent_sprite.prev_state = Player.state.IDLE
					Player.dir = 0
					Player.x_velocity = 0
					Player.isAttacking = true

	else:
		Player.canAttackMoveInAir = true
		Player.AttackSnap = true
		current_attack = attack_states.No_Attack
		saber_sprite.visible = false
		saber_hitbox.monitorable = false
		Player.AttackCancelable = true
		Can_Combo = true
		saber_animator.stop()
		saber_hitbox.linger_frames = 0
		saber_hitbox_col.set_deferred("disabled", true)
	

func _do_attack(attack):
	if Player.dir != 0:
		Player.PlayerDirection = Player.dir
	Player.isAttacking = true
	if saber_animator.has_animation(attack):
		saber_animator.stop(true)
		saber_animator.play(attack)
	current_attack = attack_states.get(attack)
	Player.AttackCancelable = false
	Can_Combo = false
	Player.CanVariableJumping = true
	Player.canAttackMoveInAir = true
	Player.AttackCrouch = true
	Player.AttackSnap = true
	saber_hitbox.combo_value = 0
	if Player.current_state == Player.state.AIRDASH:
		Player.current_state = Player.state.FALLING
	
	match attack:
		"Saber_1":
			Player.velocity.x = 0
			saber_hitbox.hitbox_name = "SABER_1"
			saber_hitbox.damage = 4
			saber_hitbox.linger_frames = 0
			saber_hitbox.combo_value = 1
			Player.stop_movement()
			Player.current_state = Player.state.IDLE
			Sound.play_sound(Sound.SND_ATTA_SABER_SWING_1,0,1)

			Player.play_voice("attack",2)
		"Saber_2":
			Player.velocity.x = 0
			saber_hitbox.hitbox_name = "SABER_2"
			saber_hitbox.damage = 6
			saber_hitbox.linger_frames = 0
			saber_hitbox.combo_value = 2
			Sound.play_sound(Sound.SND_ATTA_SABER_SWING_2,0,1)

			Player.play_voice("attack",3)
		"Saber_3":
			Player.AttackCrouch = false
			Player.velocity.x = 0
			saber_hitbox.hitbox_name = "SABER_3"
			saber_hitbox.damage = 4
			saber_hitbox.linger_frames = 3
			saber_hitbox.combo_value = 3
			Sound.play_sound(Sound.SND_ATTA_SABER_SWING_3,0,1)
			Player.play_voice("attack",5)
		"Air_slash":
			saber_hitbox.hitbox_name = "SABER_AIR"
			saber_hitbox.damage = 4
			saber_hitbox.linger_frames = 4
			Sound.play_sound(Sound.SND_ATTA_SABER_SWING_1,0,1)

			Player.play_voice("attack",5)
		"Dash_slash":

			saber_hitbox.hitbox_name = "SABER_3"
			saber_hitbox.damage = 5
			saber_hitbox.linger_frames = 4
			Sound.play_sound(Sound.SND_ATTA_SABER_SWING_1,0,1)

			
			Player.play_voice("attack",3)
			Player.current_state = Player.state.DASHING
		"Rolling_Slash":
			
			saber_hitbox.hitbox_name = "SABER_3"
			saber_hitbox.damage = 6
			Sound.play_sound(Sound.SND_ATTA_SABER_SWING_1,0,1)

			saber_hitbox.linger_frames = 4
			
			Player.play_voice("attack",5)
	

		"Crouch_Slash":
			Player.current_state = Player.state.CROUCHING
			Player.velocity.x = 0
			saber_hitbox.hitbox_name = "SABER_3"
			saber_hitbox.damage = 4
			saber_hitbox.linger_frames = 0
			Sound.play_sound(Sound.SND_ATTA_SABER_SWING_1,0,1)

			Player.play_voice("attack",2)

		"Uppercut":
			
			Player.canAttackMoveInAir = false
			Player.current_state = Player.state.IDLE
			Player.stop_movement()
			saber_hitbox.hitbox_name = "SABER_3"
			saber_hitbox.damage = 6
			saber_hitbox.linger_frames = 3
			saber_hitbox.combo_value = 5
			Sound.play_sound(Sound.SND_ATTA_SABER_SWING_1,0,1)

			Player.play_voice("attack",1)

		"Raijinshou":
			
			Player.canAttackMoveInAir = false
			Player.current_state = Player.state.IDLE
			Player.stop_movement()
			saber_hitbox.hitbox_name = "SABER_3"
			saber_hitbox.damage = 6
			saber_hitbox.linger_frames = 3
			saber_hitbox.combo_value = 5
			Sound.play_sound(Sound.SND_ATTA_SABER_SWING_1,0,1)
			
			Player.play_voice("attack",1)
		"Down_Thrust":
			Player.canAttackMoveInAir = false
			Player.AttackCrouch = false
			Player.CanVariableJumping = true
			Player.dir = 0
			Player.velocity.y = -250
			Player.x_momentum_velocity *= 0.2
			Player.AttackSnap = true
			var tw = create_tween()
			tw.tween_property(Player,"velocity:y",500.0,0.15)
			saber_hitbox.hitbox_name = "SABER_3"
			saber_hitbox.damage = 6
			saber_hitbox.linger_frames = 4
			saber_hitbox.combo_value = 6
			Sound.play_sound(Sound.SND_ATTA_SABER_SWING_1,0,1)
			Player.current_state = Player.state.FALLING
			
			Player.play_voice("attack",3)
		"Aerial_Spin":
			#Player.CanVariableJumping = false
			saber_hitbox.hitbox_name = "SABER_AIR"
			saber_hitbox.damage = 5
			saber_hitbox.linger_frames = 4
			saber_hitbox.combo_value = 5
			
			Player.play_voice("attack",3)
			Sound.play_sound(Sound.SND_ATTA_SABER_SWING_1,0,1)
			
		"Hadengeki":
			Player.AttackCrouch = false
			Player.AttackCancelable = false
			Player.velocity.x = 0
			saber_hitbox.hitbox_name = "SABER_3"
			saber_hitbox.damage = 4
			saber_hitbox.linger_frames = 3
			saber_hitbox.combo_value = 3
			Player.stop_movement()
			Player.current_state = Player.state.IDLE
			Sound.play_sound(Sound.SND_ATTA_SABER_SWING_3,0,1)
			
			Player.play_voice("attack",0)
			var proj : Projectile = Assets.PROJ_X_BUSTER_3.instance()
			proj.global_position = self.global_position + Vector2(12,0)
			proj.BulletDire = Player.PlayerDirection
			Global.ViewPort.add_child(proj)

func _can_cancel_attack():
	Player.AttackCancelable = true

func _can_combo():
	Can_Combo = true


func _on_Sprite_animation_finished():
	pass



func _on_Hitbox_damage_dealt(old_hp, new_hp, target):
	
	var par_location = saber_hitbox_col.global_position + ((target.global_position - saber_hitbox_col.global_position)/2)
	if !target.invulnerable:
		Sound.play_sound(Sound.SND_ATTA_SABER_HIT,-2,1)
		var par = Assets.PAR_SLASH_STANDARD.instance()
		
		var par_2 = Assets.PAR_SLASH_STANDARD_X6_EFFECT.instance()

		par.global_position = par_location
		Global.ViewPort.add_child(par)
		par_2.modulate = Color("c3ffc7")
		par_2.global_position = par_location
		par_2.rotation_degrees = (int(rand_range(0,2)) * 45) * Player.PlayerDirection
		Global.ViewPort.add_child(par_2)
		
	else:
		var par = Assets.PAR_SHIELD_HIT.instance()
		par.global_position = par_location
		Global.ViewPort.add_child(par)

	
	if saber_hitbox.linger_frames > 0:
		Global._freeze_frame(0.04)
		
	if new_hp < old_hp:
		self.meter += float(saber_hitbox.damage)/3

func fire_shot(shot_int : int):
	
	var shot : Projectile
	match shot_int:
		0:
			shot = Assets.PROJ_Z_BUSTER_1.instance()
			self.meter -= 5
		1:
			shot = Assets.PROJ_Z_BUSTER_2.instance()
			self.meter -= 10
	shot.global_position = self.global_position
	shot.BulletDire = Player.PlayerDirection
	$"../Buster_Shot_Holder".add_child(shot)
	

func can_fire_buster() -> bool:
	
	if !Player.isAttacking and $"../Buster_Shot_Holder".get_child_count() == 0 and Global.Player == Player:
		return true
	else:
		return false

func _on_Pause_Timer_timeout():
	if not Global.isPaused:
		get_tree().paused = false


func _on_EntityPlayer_Zero_Damage_taken(_i_frame,_damage_dealer):
	Can_Combo = true
	if charge_timer > 0:
		self.meter -= 20
	charge_timer = 0
	self.meter += 4
	Sound.SND_PL_ZERO_CHARGE.stop()


func _on_Saber_animator_animation_finished(anim_name):
	if Player.isAttacking:
		match anim_name:
			"Rolling_Slash":
				if not Input.is_action_pressed("fire") || not Player.HasControl:
					_do_attack("Dash_slash")
				else:
					saber_animator.play("Rolling_Slash")
			"Uppercut":

				
				Player.AttackSnap = false
				Player.velocity.y = -455
				Player.isAttacking = true
				saber_animator.play("Uppercut_intro")
				Player.isAttacking = true
				Player.x_momentum_velocity = 400 * Player.PlayerDirection
				Player.current_state = Player.state.JUMPING
				Player.CanVariableJumping = false
				
				
			"Raijinshou":
				Player.AttackSnap = false
				Player.velocity.y = -540
				Player.isAttacking = true
				saber_animator.play("Raijinshou_loop")
				Player.isAttacking = true
				#Player.x_momentum_velocity = 300 * Player.PlayerDirection
				Player.current_state = Player.state.JUMPING
				Player.CanVariableJumping = false
				
			"Raijinshou_loop":
				if Player.velocity.y < -200:
					saber_animator.play("Raijinshou_loop")
				else:
					saber_animator.play("Raijinshou_end")
			"Uppercut_intro":
				saber_animator.play("Uppercut_Loop")

				
			"Down_Thrust":
				saber_animator.play("Down_Thrust_Loop")
			_:
				saber_sprite.visible = false
				Player.isAttacking = false
				Player.ent_sprite.play("Holster")

				current_attack = attack_states.No_Attack
				
				match anim_name:
					"Dash_slash":
						Player._on_Dash_timer_timeout()
					"Uppercut_End":
						Player.current_state = Player.state.FALLING
					"Raijinshou_end":
						Player.current_state = Player.state.FALLING

func set_meter(value):
	if value != meter:
		meter = float(clamp(value,0,100))
	EventBus.emit_signal("UpdateWeaponInfo")
	
	
func get_meter():
	return meter
