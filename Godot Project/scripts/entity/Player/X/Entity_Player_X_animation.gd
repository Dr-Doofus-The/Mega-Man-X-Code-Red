extends AnimatedSprite

onready var Player = get_parent()
onready var SND_CHING = get_node("../Sounds/snd_player_ching")
onready var SND_FOOTSTEP = get_node("../Sounds/snd_player_footstep")
onready var proj_spawn = get_parent().get_node("Projectile_Spawn_Point_Sync")
onready var weapon_manager = get_node("../X_Weapon_manager")

var charge_fire_anim = false

var prev_state



func _physics_process(_delta):

	if Player.current_state != Player.state.CLIMBING:
		speed_scale = 1

	if Player.current_state == Player.state.AIRDASH and Player.current_airdash == Player.airdash_mode.BLADE:
		rotation_degrees = Player.bladeDire.y * (90 * Player.PlayerDirection)
	else:
		rotation_degrees = 0

	if not Player.isAttacking:

		match Player.current_state:
			Player.state.IDLE:
				if prev_state == Player.state.FALLING:
					_shooting_or_not_animation("Land", "Land_shoot")
					proj_spawn.play("Idle")
				elif not ["Land", "Land_shoot"].has(animation):
					if not ["idle_charge_shot", "idle_shoot"].has(animation):
						_shooting_or_not_animation("idle", "idle_shoot")
					proj_spawn.play("Idle")
				prev_state = Player.state.IDLE
			Player.state.RUN_IN:
				_shooting_or_not_animation("Run_in", "Run_in_shoot")
				proj_spawn.play("Run_In")
				prev_state = Player.state.RUN_IN
			Player.state.RUNNING:
				_shooting_or_not_animation("Run", "Run_shoot")
				proj_spawn.play("Run")
				prev_state = Player.state.RUNNING
			Player.state.JUMPING:
				_shooting_or_not_animation("Jump", "Jump_shoot")
				if prev_state == Player.state.WALLJUMPING:
					frame = 3
				prev_state = Player.state.JUMPING
				proj_spawn.play("Jump")
			Player.state.CROUCHING:
				if not [Player.state.CROUCHING, Player.state.DASHING].has(prev_state):
					_shooting_or_not_animation("Crouch_in", "Crouch_in_shoot")
					proj_spawn.play("Crouch_in")
				else:
					if not ["Crouch_charge_shot"].has(animation):
						_shooting_or_not_animation("Crouch", "Crouch_shoot")
					proj_spawn.play("Crouch")
					prev_state = Player.state.CROUCHING
			Player.state.FALLING:
				_shooting_or_not_animation("Falling", "Falling_shoot")
				if prev_state == Player.state.RUNNING:
					frame = 10
				elif prev_state != Player.state.FALLING:
					frame = 0
				prev_state = Player.state.FALLING	
				proj_spawn.play("Falling")
			Player.state.DASHING:
				_shooting_or_not_animation("Dash", "Dash_shoot")
				proj_spawn.play("Dash")
				prev_state = Player.state.DASHING
			Player.state.DASH_START:
				_shooting_or_not_animation("Dash_start", "Dash_start_shoot")
				proj_spawn.play("Dash_Start")
				prev_state = Player.state.DASH_START
			Player.state.DASH_SKID:
				_shooting_or_not_animation("Dash_skid", "Dash_skid_shoot")
				proj_spawn.play("Dash_Skid")
				prev_state = Player.state.DASH_SKID
			Player.state.HITSTUNNED:
				animation = "Damage_light"
				prev_state = Player.state.HITSTUNNED
			Player.state.WALLSLIDING:
				_shooting_or_not_animation("Wallslide", "Wallslide_shoot")			
				prev_state = Player.state.WALLSLIDING
				proj_spawn.play("Wallslide")
			Player.state.WALLJUMPING:
				_shooting_or_not_animation("Walljump", "Walljump_shoot")			
				prev_state = Player.state.WALLJUMPING
				proj_spawn.play("Walljump")
			Player.state.WALLCLING:
				_shooting_or_not_animation("Wallcling", "Wallcling_shoot")
				prev_state = Player.state.WALLCLING
				proj_spawn.play("WallCling")
			Player.state.SPAWNING:
				animation = "Spawn"
			Player.state.AIRDASH:
				match Player.current_airdash:
					Player.airdash_mode.STANDARD:
						if !["Dash","Dash_shoot"].has(animation):
							_shooting_or_not_animation("Dash_start", "Dash_start_shoot")							
						else:
							_shooting_or_not_animation("Dash", "Dash_shoot")
					Player.airdash_mode.UPWARD:
						animation = "Up_dash"
					Player.airdash_mode.BLADE:
						animation = "Mach_Dash"
			Player.state.HOVER:
				match Player.current_hover_mode:
					Player.hover_mode.GLIDE:
						if animation != "Dash":
							play("Dash_start")
						else:
							animation = "Dash"
					Player.hover_mode.BLADE:
						animation = "Mach_Dash_Prep"
			Player.state.GRABBED:
				animation = "Damage_light"
				frame = 0
			Player.state.DYING:
				animation = "Dying"
				prev_state = Player.state.DYING
			Player.state.CLIMBING:
				if Player.IsShooting:
					play("Climbing_shoot")
					frame = 0
					speed_scale = 1
				else:
					
					if Player.velocity.y > 0:
						play("Climbing", true)
						speed_scale = 1
					elif Player.velocity.y < 0:
						play("Climbing")
						speed_scale = 1
					else:
						play("Climbing")
						speed_scale = 0
			Player.state.CLIMBING_END:
				play("Climbing_End")
				prev_state = Player.state.CLIMBING_END
			Player.state.CLIMBING_ENTER:
				play("Climbing_Enter_Top")
			Player.state.ZIPLINE:
				play("Zipline")
		
	#Shot Spawn Syncer
	
	proj_spawn.seek(int(frame))


			
func _process(_delta):
	#Armor Syncer
	
	$Armor.scale.x = Player.PlayerDirection
	
	if GameProgress.Leg_Part != GameProgress.Armor.NONE:
		if $Armor/Foot_sprite.frames.has_animation(animation):
			$Armor/Foot_sprite.visible = true
			$Armor/Foot_sprite.animation = animation
			$Armor/Foot_sprite.frame = frame
		else:
			$Armor/Foot_sprite.visible = false
func _shooting_or_not_animation(non_firing_anim, firing_anim):
	if Player.IsShooting:
		if animation == non_firing_anim:
			var old_frame = frame
			animation = firing_anim
			frame = old_frame + 1
		else:
			animation = firing_anim
	else:
		if animation == firing_anim:
			var old_frame = frame
			animation = non_firing_anim
			frame = old_frame + 1
			
		else:
			animation = non_firing_anim

func _on_X_Weapon_manager_fire_shot():
	if Player.current_state == Player.state.IDLE:
		frame = 0
		animation = "idle_shoot"

	if Player.current_state == Player.state.CLIMBING:
		frame = 0

func _on_X_Weapon_manager_fire_chargeshot():
	if Player.current_state == Player.state.IDLE:
		frame = 0
		animation = "idle_charge_shot"
	if Player.current_state == Player.state.CROUCHING:
		frame = 0
		animation = "Crouch_charge_shot"

func _on_Sprite_frame_changed():
	match animation:
		"idle_shoot":
			if prev_state != Player.state.IDLE:
				frame = 3
		"Spawn":
			match Player.current_state:
				Player.state.SPAWNING:
					if frame == 1:
						Sound.play_sound(Sound.SND_PL_TELEPORT_LAND,0,1)
					
					if frame == 17:
						SND_CHING.play()
						Player.spawn_teleport_spark_cluster()
		"Victory":
			if frame == 9:
				SND_CHING.play()
		"Run":
			if [0,7].has(frame):
				Sound.play_footstep()
		"Climbing_End":
			match frame:
				2:
					Player.position.y -= 20
		"Climbing_Enter_Top":
			match frame:
				2:
					Player.position.y += 16


func _on_Sprite_animation_finished():
	match animation:
		"idle_shoot":
#			weapon_manager.shoot_anim_cooldown = 0
			animation = "idle"
		"idle_charge_shot":
#			weapon_manager.shoot_anim_cooldown = 0
			animation = "idle"
		"Land":
			animation = "idle"
		"Land_shoot":
			animation = "idle"
		"Crouch_in":
			prev_state = Player.state.CROUCHING
		"Crouch_charge_shot":
#			weapon_manager.shoot_anim_cooldown = 0
			animation = "Crouch"
		"Stand_out":
			prev_state = Player.state.IDLE
			Player.current_state = Player.state.IDLE
		"Dash_start":
			animation = "Dash"
			Player.DashJetFX.frame = 0

func _on_X_Weapon_manager_special_weapon_fired():
	if Player.current_state == Player.state.IDLE:
		frame = 0
		animation = "idle_shoot"
