extends "res://scripts/entity/EntityBase.gd"
class_name player_character

onready var FX_DASH_SMOKE = preload("res://nodes/particles/player/par_player_dashsmoke.tscn")
onready var FX_WALLKICK = preload("res://nodes/particles/player/par_player_wallkick.tscn")
onready var FX_DASH_SMOKE_TRAIL = preload("res://nodes/particles/player/par_player_dashsmoke_trail.tscn")
onready var FX_WATER_SPLASH_SIDE = preload("res://nodes/particles/water/par_water_splash_side.tscn")
onready var FX_WATER_SPLASH_CENTER = preload("res://nodes/particles/water/par_water_splash_center.tscn")
onready var FX_WATER_BUBBLE = preload("res://nodes/particles/water/par_water_bubble.tscn")
onready var FX_DEATH_EFFECT = preload("res://nodes/particles/player/par_player_death.tscn")
onready var FX_GHOST = preload("res://nodes/particles/other/Par_Ghost_Type_2.tscn")


onready var SFX_WATER_SPLASH = preload("res://sound_assests/objects/snd_water_splash.wav")

signal regained_controls()
signal landed()

export(int) var speed: int = 100
export(float) var jump_height: float = 100
export(float) var time_to_peak: float = 0.25
export(float) var time_to_fall: float = 0.2
export(float) var wall_slide_speed: float = 0.2
export(float) var walljump_x_speed: float = 20
export(int,"X", "Zero", "Axl") var character_name

onready var additive_velocity = Vector2.ZERO

onready var gravity_affected : bool = true

onready var jump_speed : float = ((2.0 * jump_height) / time_to_peak) * -1.0
onready var jump_gravity : float = ((-2.0 * jump_height) / (time_to_peak * time_to_peak)) * -1.0 
onready var fall_gravity : float = ((-2.0 * jump_height) / (time_to_fall * time_to_fall))  * -1.0

onready var RayCast_Left = $RC_wall_left
onready var RayCast_Right = $RC_wall_right

onready var Ghosting = false

onready var giga_attack_holder = $Giga_Attack_Holder
onready var WallJumpTimer = $Walljump_timer
onready var DashTimer = $Dash_timer
onready var State_Label = $State_Label
onready var Hitstun_Timer = $Hitstun_timer
onready var CommandDashTimer = $Command_Dash_Timer
onready var PlayerVoice = $Player_voice
onready var JumpBuffer_Timer = $JumpBuffer_Timer
onready var DashBuffer_Timer = $DashBuffer_Timer
onready var DashSpeed = speed * 2.0
onready var DashJetFX = $Dash_jet_effect

onready var SND_PLAYER_DASH = $Sounds/snd_player_dash


var current_climbable = null
var current_zipline
var current_giga_attack : giga_attack setget set_giga_attack, get_giga_attack

#States
var HasControl = true
#var CanAirDash = false
var GrabHolder
var WalkingToPoint = 0 #0 is false and everything else is direction
var WalkPoint
var Active = false
var play_low_health = false

var CanVariableJumping = true
var IsJumping = false
var HasDoubleJumped = true
var IsJustWallJumping = false
var IsDashJumping = false
var IsShooting = false
var IsDamageStunned = false
var AirDashCount = 0

#Attack Properties

var isAttacking = false
var canAttackMoveInAir = true
var AttackSnap = true
var AttackCrouch = true

var AttackCancelable = true


var UnderWater = false

var bladeDire : Vector2 = Vector2.ZERO


#Command Dash
var CDR = false
var CDL = false


#State Machine

enum state {
IDLE, RUN_IN, RUNNING, JUMPING, CROUCHING,
DYING, FALLING, WALLCLING,
WALLSLIDING, WALLJUMPING, JUSTWALLJUMPING, 
DASH_START, DASHING, DASH_SKID, HITSTUNNED, AIRDASH, HOVER, ZIPLINE,
CLIMBING_ENTER, CLIMBING, CLIMBING_END, SPAWNING, GRABBED, GIGA, ANIMATION}

enum airdash_mode {STANDARD, UPWARD, FALCON, BLADE}
var current_airdash

enum hover_mode {AXL, GLIDE, FORCE, FALCON, BLADE}
var current_hover_mode

var dir = null
var dirY = null
var PlayerDirection = 1
var current_state = state.IDLE

var x_velocity = 0
var x_momentum_velocity = 0
var wind_force_x = 0

var y_up_force = 0
var dash_boost = 0


var hover_juice = 0
var hover_toggleable = true

onready var voice_lines



func _ready():
	visible = false
	turn_off_hurtbox(true)
	turn_off_collision_box(true)
	moving_platform_apply_velocity_on_leave = 2
	Global.Player = self
	i_frame_timer.wait_time += Hitstun_Timer.wait_time
	current_state = state.DYING
	HasControl = false
	hp_max = 16 + (GameProgress.heart_tank_array.size() * 2)
	hp = hp_max
	dir = 0
	ent_sprite.position = Vector2(-1000000,-10000000)

	match character_name:
		0:
			voice_lines = Sound.X_VOICE
		1:
			voice_lines = Sound.Zero_Voice
		2:
			voice_lines = Sound.AXL_VOICE
			$Player_voice/SND_VOICE.volume_db = 0
	
func spawn(respawn : bool):
	
	Active = true
	Global.emit_signal("PlayerSpawned")
	Global.Player = self
	EventBus.emit_signal("UpdateWeaponInfo")
	MusicPlayer.back_to_stage_music()
	MusicPlayer.fade_music(true, .01)	
	MusicPlayer.start_music(false)
	for n in Global.Character_Slots:
		n.hp = n.hp_max
	EventBus.emit_signal("PlayerSpawned")
	EventBus.emit_signal("PlayerHealthUpdated",false)
	ent_sprite.flip_h = false
	if Global.checkpoint != null:
		self.global_position.x = Global.checkpoint.global_position.x
	self.global_position.y = Global.checkpoint.global_position.y - 100 - get_viewport_rect().size.y/2
	_reset_var()
	visible = false
	current_state = state.DYING
	CanVariableJumping = true
	HasControl = false
	animplayer.play("RESET")
	
	if respawn or Settings.skip_ready:
		Transition.get_node("AnimationPlayer").play("Transition_out")
		if Settings.skip_ready:
			yield(get_tree().create_timer(0.1),"timeout")
		else:
			yield(get_tree().create_timer(0.9),"timeout")
	else:
		yield(Global,"SpawnPlayer")
	visible = true
	ent_sprite.visible = true
	current_state = state.SPAWNING
	Sound.play_sound(Sound.SND_PL_TELEPORT_IN,0,1)
	ent_sprite.frame = 0
	gravity_affected = true
	dir = 0

func switch_in():
	pause_mode = Node.PAUSE_MODE_PROCESS

	visible = true
	turn_off_hurtbox(true)
	stop_movement()
	animplayer.play("Switch_In")
	#snap_to_ground(50)
	current_state = state.ANIMATION
	Global.Player_Character = character_name
	Global.Player = self
	gravity_affected = false
	hurtbox.set_deferred("monitoring", true)
	EventBus.emit_signal("PlayerHealthUpdated",false)
	EventBus.emit_signal("UpdateWeaponInfo")
	#$Sounds/snd_player_ching.play()
	Sound.play_sound(Sound.SND_PL_TELEPORT_IN,0,1)
	#snap_to_ground(50)
	#current_state = state.IDLE
	


func _physics_process(delta):

	if is_on_floor():
		dash_boost *= 0.9
	else:
		dash_boost *= 0.93
#Snap
	if not current_state == state.ANIMATION:
		if not [state.HITSTUNNED, state.GIGA, state.ZIPLINE,state.CLIMBING,state.CLIMBING_ENTER,state.CLIMBING_END, state.JUMPING, state.WALLJUMPING].has(current_state) and not y_up_force < -1100:
			snap = true if not (isAttacking and not AttackSnap) else false
		else:
			snap = false

#Direction Handeling
	if HasControl:
		if not [state.ANIMATION, state.GIGA,state.GRABBED].has(current_state):
			dir = Input.get_action_strength("right") - Input.get_action_strength("left")
			dirY = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")

		if not [state.AIRDASH, state.DASH_START, state.DASHING, state.WALLJUMPING, state.HITSTUNNED].has(current_state) and !(current_state == state.HOVER and current_hover_mode != hover_mode.BLADE):
			if not (isAttacking and is_on_floor()):
				if not (isAttacking and not canAttackMoveInAir):
					if dir < 0:
						PlayerDirection = -1
						CDR = false
					elif dir > 0:
						PlayerDirection = 1
						CDL = false
#State Machine
	
	match current_state:
		
		state.IDLE:
			State_Label.text = str("IDLE")
			IsDashJumping = false
			
			if not is_on_floor() and not (isAttacking and not AttackSnap) || animplayer.current_animation == "Switch_In":
				current_state = state.FALLING
				AirDashCount = 1
				hover_juice = 2
				isAttacking = false
				DashTimer.stop()	

		state.RUN_IN:
			State_Label.text = str("RUN_IN")
			IsDashJumping = false	
			if not is_on_floor():
				current_state = state.FALLING	
				AirDashCount = 1
				hover_juice = 2
				DashTimer.stop()	


		state.RUNNING:
			State_Label.text = str("RUNNING")
			IsDashJumping = false	
			if not is_on_floor():
				current_state = state.FALLING	
				AirDashCount = 1
				hover_juice = 2
				DashTimer.stop()	

		state.JUMPING:
			State_Label.text = str("JUMPING")

			if velocity.y >=0:
				current_state = state.FALLING	
	
	
		state.FALLING:
			State_Label.text = str("FALLING")	
			if is_on_floor():
				$Sounds/snd_player_land.play()
				CanVariableJumping = true

				if isAttacking and dir != 0:
					dir = 0
					x_velocity = 0
				emit_signal("landed")

		state.CROUCHING:
			State_Label.text = str("CROUCHING")
			if not Input.is_action_pressed("down") and not (isAttacking and not AttackCrouch):
				current_state = state.IDLE
			if not is_on_floor():
				current_state = state.FALLING
				isAttacking = false
				AirDashCount = 1
				hover_juice = 2
			
			x_velocity = (lerp(x_velocity, 0 ,0.9))

		state.HOVER:
			hover_juice -= delta * 1.5
			
			match current_hover_mode:
				hover_mode.GLIDE:
					if dir != 0:
						PlayerDirection = dir
					x_velocity = lerp(x_velocity,PlayerDirection * (speed*2),0.04)
					velocity.y = clamp(velocity.y + 0.33, 0, 120)
					
					ent_sprite.flip_h = true if x_velocity < 0 else false
					if get_hover_release_button():
						current_state = state.FALLING
				hover_mode.BLADE:

					
					if !Input.is_action_pressed("jump"):
						if dir != 0 or dirY != 0:
							DashTimer.start(0.3)
							$Sounds/snd_player_dash.play()
							current_airdash = airdash_mode.BLADE
							current_state = state.AIRDASH
							if dir != 0:
								bladeDire = Vector2(dir,0)
							else:
								bladeDire = Vector2(0,dirY)
							AirDashCount -=1
						else:
							current_state = state.FALLING
				hover_mode.AXL:
					if !IsShooting:
						x_velocity = dir * speed
					else:
						x_velocity = 0
					
					var y_move = clamp(hover_juice,-1.2,0)
					velocity.y = -y_move*130
					
					position.y += sin(Global.time * 13) * 0.3
					
					if get_hover_release_button():
						current_state = state.FALLING
					

		state.WALLCLING:
			State_Label.text = str("WALLCLING")	
			velocity.y = 0

	
		state.WALLSLIDING:
			State_Label.text = str("WALLSLIDING")	
			
			var lerp_speed = 0.075 if velocity.y < 0 else 0.3
			
			velocity.y = lerp(velocity.y, wall_slide_speed, lerp_speed)
			
			if Engine.get_physics_frames() % 7 == 0:
				spawn_wall_smoke(0)
			
			
		state.AIRDASH:
			State_Label.text = str("AIRDASHING")	
			IsDashJumping = true
			match current_airdash:
				airdash_mode.STANDARD:
					velocity.y = 0
					if PlayerDirection > 0:
						x_velocity = DashSpeed * (delta * 66)
					else:
						x_velocity = -DashSpeed * (delta * 66)
				airdash_mode.UPWARD:
					x_velocity = 0
					if ent_sprite.frame > 2:
						velocity.y = -DashSpeed
					else:
						velocity.y = 40
				airdash_mode.BLADE:

					velocity.y = bladeDire.y * DashSpeed * 1.5
					x_velocity = bladeDire.x * DashSpeed * 1.5
			if is_on_floor():
				current_state = state.IDLE

		state.DASH_START:
			State_Label.text = str("DASH_START")

			x_velocity = DashSpeed * PlayerDirection

			if not is_on_floor():
				IsDashJumping = true
				current_state = state.FALLING
				isAttacking = false
				AirDashCount = 1
				hover_juice = 2
			#if is_on_wall():
			#	current_state = state.FALLING		
			#	DashTimer.stop()


		state.DASH_SKID:
			State_Label.text = str("DASH_SKID")

			x_velocity = lerp(x_velocity, 0, 0.3)

			if not is_on_floor():
				IsDashJumping = true
				isAttacking = false
				current_state = state.FALLING
				AirDashCount = 1
				hover_juice = 2	
			if is_on_wall():
				current_state = state.FALLING		
				DashTimer.stop()

		state.DASHING:
			
			
			if PlayerDirection > 0:
				x_velocity = (DashSpeed + max(dash_boost,0)) * (delta * 66)
			else:
				x_velocity = -(DashSpeed + max(dash_boost,0)) * (delta * 66)

			if not is_on_floor():
				IsDashJumping = true
				current_state = state.FALLING
				AirDashCount -= 1
				hover_juice = 2
				isAttacking = false
			if is_on_wall() and not isAttacking:
				current_state = state.FALLING		
				DashTimer.stop()
				
			if $DashTrail_Timer.time_left == 0:
				$DashTrail_Timer.start(0.0333)



		state.WALLJUMPING:
			State_Label.text = str("WALLJUMPING")	
			AirDashCount = 1
			hover_juice = 2

			if IsDashJumping:
				x_velocity = -DashSpeed * PlayerDirection
			else:
				x_velocity = -walljump_x_speed * PlayerDirection
				
		
		state.HITSTUNNED:
			State_Label.text = str("HITSTUNNED")
			HasControl = false
			x_velocity = lerp(x_velocity,0,0.05)
			
		state.CLIMBING:
			State_Label.text = str("CLIMBING")
			x_velocity = 0
			
			if IsShooting:
				velocity.y = 0
			else:
				velocity.y = speed * (dirY * delta * 66)
			if current_climbable != null:
				global_position.x = current_climbable.coll_shape.global_position.x
				if global_position.y < current_climbable.coll_shape.global_position.y - current_climbable.coll_shape.shape.extents.y + 26:
					global_position.y = current_climbable.coll_shape.global_position.y - current_climbable.coll_shape.shape.extents.y + 26
					current_state = state.CLIMBING_END
					global_position.y = current_climbable.coll_shape.global_position.y - current_climbable.coll_shape.shape.extents.y + 26
					
			else:
				current_state = state.IDLE

		state.DYING:
			State_Label.text = str("DYING")
			velocity.x = 0
			velocity.y = 0
		state.SPAWNING:
			State_Label.text = str("SPAWNING")
			PlayerDirection = 1
			velocity.x = 0
			
			if global_position.y < Global.checkpoint.global_position.y:
				collshape.set_deferred("disabled", true)
			else:
				collshape.set_deferred("disabled", false)
			
			if not is_on_floor():
				velocity.y = 800
				ent_sprite.playing = false
			else:
				velocity.y = 0
				ent_sprite.playing = true
			
		state.CLIMBING_END:
			velocity = Vector2.ZERO
			x_velocity = 0
			snap = true
		state.CLIMBING_ENTER:
			if current_climbable != null:
				global_position.x = current_climbable.coll_shape.global_position.x
				x_velocity = 0
		state.GIGA:
			if get_giga_attack().stop_on_wall and is_on_wall() and get_giga_attack().active:
				end_giga()
			match get_giga_attack().name:
				"Nova_Strike":
					if get_giga_attack().active:
						velocity.y = 0
		state.ZIPLINE:
			x_velocity = 0
			wind_force_x = 0
			x_momentum_velocity = 0
			velocity = Vector2.ZERO
			if is_on_floor():
				current_state = state.FALLING
		
		state.GRABBED:
			if GrabHolder:
				global_position = GrabHolder.global_position


#Run Animation

	if is_on_floor() and not [state.ANIMATION, state.ZIPLINE,state.GIGA,state.CROUCHING, state.HITSTUNNED,state.DYING, state.SPAWNING, state.AIRDASH, state.DASH_START, state.DASHING, state.WALLJUMPING, state.CLIMBING, state.CLIMBING_END, state.CLIMBING_ENTER, state.GRABBED].has(current_state) and not isAttacking:
		if dir == 0:
			if not [state.DASH_SKID].has(current_state):
				current_state = state.IDLE
		if dir != 0:
			if current_state == state.IDLE:
				current_state = state.RUN_IN
			elif current_state != state.RUN_IN:
				current_state = state.RUNNING

#Gravity

	if not [state.GRABBED, state.WALLSLIDING, state.ZIPLINE,state.WALLCLING,state.AIRDASH,state.CLIMBING, state.CLIMBING_END, state.CLIMBING_ENTER,state.DYING, state.HOVER].has(current_state) and gravity_affected:
		if UnderWater:
			velocity.y += (get_gravity()/1.8) * delta
		else:
			
			velocity.y += get_gravity() * delta
#Flip
	
	if !(current_hover_mode != hover_mode.BLADE and current_state == state.HOVER):
		if PlayerDirection > 0:
			ent_sprite.flip_h = false
	
		else:
			ent_sprite.flip_h = true



#Input


	#Zipline
		if Input.is_action_pressed("ui_up") and current_zipline != null and current_state == state.FALLING and $Climbable_detector.get_overlapping_bodies().size() >0:
			current_zipline.update_follower()
			enter_zipline()
	#Movement
		
	if not [state.AIRDASH, state.CROUCHING, state.DASH_SKID, state.ZIPLINE,state.DASH_START, state.DASHING, state.WALLJUMPING, state.HITSTUNNED, state.SPAWNING, state.CLIMBING, state.CLIMBING_END, state.CLIMBING_ENTER, state.DYING, state.GRABBED, state.HOVER].has(current_state) and not (IsShooting and is_on_floor() and character_name == 2):
		if not (isAttacking and is_on_floor()):
			if not (isAttacking and not canAttackMoveInAir):
				if IsDashJumping == true and not is_on_floor():
					x_velocity = (DashSpeed + max(dash_boost,0)) * (delta * 66) * dir
				else:
					if current_state == state.RUN_IN:
						x_velocity = speed * (delta * 33) * dir
					else:
						x_velocity = speed * (delta * 66) * dir					

	if HasControl and not current_state == state.GRABBED:
		
	# WallSliding
		if [state.FALLING, state.AIRDASH, state.HOVER].has(current_state) and is_on_wall():
			
			if dir != 0:	
				if dir > 0 and RayCast_Left.is_colliding():
					pass
				elif dir < 0 and RayCast_Right.is_colliding():
					pass
				else:
					$Sounds/snd_player_enter_wallslide.play()	
					if character_name == 1:
						HasDoubleJumped = false
					current_state = state.WALLCLING
					isAttacking = false
					IsDashJumping = false

					
		if [state.WALLCLING, state.WALLSLIDING].has(current_state) and dir == 0:
			spawn_wall_smoke(1)
			if velocity.y > 0:
				velocity.y = 0
			x_momentum_velocity = 50 * -PlayerDirection
			PlayerDirection = PlayerDirection*-1
			current_state = state.FALLING
			

		if current_state == state.WALLSLIDING and is_on_floor():
			current_state = state.IDLE

		if [state.WALLCLING, state.WALLSLIDING].has(current_state) and not is_on_wall():
			velocity.y = 0
			current_state = state.FALLING
#			spawn_wall_smoke(1)
			
	#Jumping
		if ([state.IDLE, state.RUNNING, state.RUN_IN, state.DASHING, state.DASH_START, state.DASH_SKID, state.CROUCHING, state.ZIPLINE].has(current_state) || [state.FALLING].has(current_state) and HasDoubleJumped == false and not isAttacking):
			if !JumpBuffer_Timer.is_stopped():
				if not is_on_floor() and character_name == 1:
					HasDoubleJumped = true
					AirDashCount -= 1


				
				match current_state:
					state.DASHING:
						jump_function(true)
					state.CROUCHING:
						jump_function(false)
						x_momentum_velocity = x_velocity + x_momentum_velocity
					_:
						jump_function(false)
			

			
	#DashCancel - Update method
		if [state.DASH_START, state.DASHING, state.AIRDASH].has(current_state):
			if !(current_airdash == airdash_mode.BLADE and current_state == state.AIRDASH):
				if not Input.is_action_pressed("dash"):
					_on_Dash_timer_timeout()

	#Variable Jumping
		if not Input.is_action_pressed("jump") and [state.JUMPING].has(current_state) and CanVariableJumping and velocity.y < velocity.y * 0.05 * (delta * 66):

			IsJumping = false
			current_state = state.FALLING
			velocity.y = velocity.y * 0.05 * (delta * 66)

		if not is_on_floor() and y_up_force < -1100:
			CanVariableJumping = false

	#Crouching + Hurtbox shrink
		if Input.is_action_pressed("down") and [state.IDLE, state.RUNNING].has(current_state) || Input.is_action_just_pressed("down") and [state.DASHING,state.DASH_SKID].has(current_state):
			if not (isAttacking and not AttackCrouch):
				if current_state != state.CROUCHING:
					isAttacking = false
				current_state = state.CROUCHING
			
			
		if [state.DASHING, state.AIRDASH, state.CROUCHING].has(current_state):
			hurtbox_collision.shape.extents.y = 8
			hurtbox_collision.position.y = 5
		else:
			hurtbox_collision.shape.extents.y = 13
			hurtbox_collision.position.y = 0
	#Falling
	if IsJumping == true and velocity.y >=0 and not [state.HOVER, state.WALLCLING, state.WALLSLIDING, state.ZIPLINE, state.DYING, state.AIRDASH, state.CLIMBING, state.CLIMBING_END,state.HITSTUNNED, state.ANIMATION,state.GIGA, state.GRABBED].has(current_state):
		IsJumping = false		
		current_state = state.FALLING

	
	#GhostEffect
	if IsDashJumping or [state.DASH_START,state.DASHING,state.DASH_SKID].has(current_state):
		if Engine.get_physics_frames()%4 == 0:
			spawn_ghost()
	

	
	#FX Syncer
	dash_jet_fx_syncer()
	
	get_inertia()
	
	
	#Bubble effects
	
	if Engine.get_physics_frames()%120 == 0 and UnderWater:
		spawn_bubble_fx(0)
	
	if $bubble_timer.time_left !=0 and not is_on_floor():
		spawn_bubble_fx(1)
	
	if (ent_sprite.animation == "Spawn" and ent_sprite.frame == 0 || ent_sprite.animation == "Leave" and ent_sprite.frame == ent_sprite.frames.get_frame_count("Leave") - 1) and (animplayer.is_playing() || current_state == state.SPAWNING):
		if Engine.get_physics_frames()%2 == 0:
			var par : ParticleSprite = Assets.PAR_TELEPORT_TRAIL.instance()
			par.pause_mode = Node.PAUSE_MODE_PROCESS
			par.gravity = 10 if ent_sprite.animation == "Leave" else -10

			par.global_position = Vector2(ent_sprite.global_position.x  + rand_range(-2,2),ent_sprite.global_position.y)
			par.modulate = self_modulate * 2.4
			$Ghost_holder.add_child(par)
	
	
	#WalkToPoint
	if WalkingToPoint != 0:
		match WalkingToPoint:
			1:
				if WalkPoint < global_position.x:
					dir = 0
					WalkingToPoint = 0
					EventBus.emit_signal("PlayerWalkToDone")
			-1:
				if WalkPoint > global_position.x:
					dir = 0
					WalkingToPoint = 0
					EventBus.emit_signal("PlayerWalkToDone")
#Move n Slide
	move()

	
#MOVEMENT CLAMP
	velocity.x = x_velocity + wind_force_x + x_momentum_velocity
	velocity.y = clamp(velocity.y, -600, 400)


	
func _input(event):

	#if event.is_action_pressed("fire"):
	#	spawn_teleport_spark_cluster()


	if HasControl:

		if event.is_action_pressed("switch_player") and Global.Player == self:
			#set_deferred("pause_mode", Node.PAUSE_MODE_PROCESS)
			var inactive_char = 0 if Global.get_active_player() == 1 else 1
			
			if Global.Character_Slots[inactive_char].hp > 0:
				switch_character()

	#Jump-Buffer
		if (event.is_action_pressed("jump") and not [state.CLIMBING].has(current_state)):
			JumpBuffer_Timer.start()
	#Dash-Buffer
		if event.is_action_pressed("dash"):
			DashBuffer_Timer.start()
	
	#Walljump			
		if [state.FALLING, state.WALLSLIDING, state.WALLCLING].has(current_state):
			if !JumpBuffer_Timer.is_stopped() and RayCast_Left.is_colliding():
				walljump_function(1)
			elif !JumpBuffer_Timer.is_stopped() and RayCast_Right.is_colliding():
				walljump_function(-1)

			
	#Dash
		if [state.IDLE, state.RUNNING, state.RUN_IN].has(current_state):
			if !DashBuffer_Timer.is_stopped() and is_on_floor() || event.is_action_pressed("left") and CDL and is_on_floor() and Settings.command_dash || event.is_action_pressed("right") and CDR and is_on_floor() and Settings.command_dash:
				$Sounds/snd_player_dash.play()
				ent_sprite.frame = 0
				if dir != 0:
					PlayerDirection = dir
	
				else:
					PlayerDirection = PlayerDirection

				spawn_dash_start()
				current_state = state.DASH_START
				AttackCancelable = true
				dash_boost = 110
				isAttacking = false
				DashBuffer_Timer.stop()
		elif current_state == state.CROUCHING:
			if !DashBuffer_Timer.is_stopped() and is_on_floor() || event.is_action_pressed("left") and CDL and is_on_floor() and Settings.command_dash || event.is_action_pressed("right") and CDR and is_on_floor() and Settings.command_dash:	
				if dir != 0:
					PlayerDirection = dir
				else:
					PlayerDirection = PlayerDirection
				AttackCancelable = true
				isAttacking = false
				$Sounds/snd_player_dash.play()
				DashBuffer_Timer.stop()
				_dash_start()
				

	#Air-Dash
#		if is_on_floor():
#			AirDashCount = 1
#			hover_juice = 2
		
		if [state.JUMPING, state.FALLING].has(current_state) and AirDashCount > 0:
			if ((event.is_action_pressed("dash") || (event.is_action_pressed("left") and CDL || event.is_action_pressed("right") and CDR))) and not is_on_floor():

				var dash_time = 0.5
				DashTimer.start(dash_time)
				$Sounds/snd_player_dash.play()

				
				if GameProgress.Leg_Part == GameProgress.Armor.BLADE and character_name == 0:
					
					DashTimer.start(0.3)
					current_airdash = airdash_mode.BLADE

					if !Vector2(dir,dirY) == Vector2.ZERO:
						if dir != 0:
							bladeDire = Vector2(dir,0)
						else:
							bladeDire = Vector2(0,dirY)
					else:
						bladeDire = Vector2(PlayerDirection,0)
					#current_airdash = airdash_mode.BLADE
				elif Input.is_action_pressed("up") and not(GameProgress.Leg_Part == GameProgress.Armor.BLADE and character_name == 0):
					current_airdash = airdash_mode.UPWARD
				else:
					current_airdash = airdash_mode.STANDARD
				current_state = state.AIRDASH
				AirDashCount -=1
				HasDoubleJumped = true
				isAttacking = false

	#Dash Cancel
		if [state.DASH_START, state.DASHING, state.AIRDASH].has(current_state):
			if !(current_state == state.AIRDASH and [airdash_mode.UPWARD, airdash_mode.BLADE].has(current_airdash)):
				if PlayerDirection > 0 and event.is_action_pressed("left") || PlayerDirection < 0 and event.is_action_pressed("right"):
					if current_state != state.AIRDASH:
						current_state = state.RUNNING
					else:
						current_state = state.FALLING
					DashTimer.stop()
			
	#Enter Ladder
		if event.is_action_pressed("up") and current_climbable != null and not $Climbable_detector.overlaps_area(current_climbable.top_point):
			enter_ladder()
	#Enter Ladder Top
		if event.is_action_pressed("down") and current_climbable != null and $Climbable_detector.overlaps_area(current_climbable.top_point) and current_state != state.CLIMBING and is_on_floor():
			current_state = state.CLIMBING_ENTER
			global_position.x = current_climbable.coll_shape.global_position.x
	#Jump-off-Ladder
		if event.is_action_pressed("jump") and current_state == state.CLIMBING:
			current_state = state.FALLING
	
	
	#Command Dash			
		if event.is_action_pressed("right"):
			CDR = true
			CommandDashTimer.start()
		if Input.is_action_just_pressed("left"):
			CDL = true
			CommandDashTimer.start()
	#Hover
		if event.is_action_pressed("jump") and current_state == state.FALLING and AirDashCount > 0 and character_name != 1:
			hover_toggleable = false
			match character_name:
				0:
					match GameProgress.Leg_Part:
						GameProgress.Armor.GLIDE:
							current_hover_mode = hover_mode.GLIDE
							x_velocity = PlayerDirection * 130
							velocity.y = 0
							current_state = state.HOVER
							IsDashJumping = false
							AirDashCount -=1
						GameProgress.Armor.BLADE:
							current_hover_mode = hover_mode.BLADE
							stop_movement()
							current_state = state.HOVER
							AirDashCount -= 1
				2:
					current_hover_mode = hover_mode.AXL
					stop_movement()
					current_state = state.HOVER
					AirDashCount -= 1



func jump_function(dashjump):
	JumpBuffer_Timer.stop()
	snap = false
	hover_juice = 2
	if dashjump == true:
		IsDashJumping = true
		AirDashCount -= 1
		HasDoubleJumped = true

	else:
		if Input.is_action_pressed("dash"):
			IsDashJumping = true
			AirDashCount -= 1
			HasDoubleJumped = true

		elif is_on_floor():
			IsDashJumping = false
			AirDashCount = 1

		else:
			HasDoubleJumped = true
	$Sounds/snd_player_jump.play()
	velocity.y = jump_speed
	isAttacking = false
	IsJumping = true
	current_state = state.JUMPING
	var rng_value = randi()
	if rng_value % 2:
		play_voice("jump")
	
func walljump_function(direction):
	JumpBuffer_Timer.stop()
	snap = false
	var rng_value = randi()

	if rng_value % 3:
		pass
	elif rng_value % 2:
		play_voice("jump")

	if Input.is_action_pressed("dash"):
		IsDashJumping = true
	else:
		IsDashJumping = false	

	$Sounds/snd_player_jump.play()
	current_state = state.WALLJUMPING
	PlayerDirection = direction * -1
	velocity.y = jump_speed
	IsJumping = true
	isAttacking = false
	WallJumpTimer.start()
	var fx = FX_WALLKICK.instance()
	fx.position = Vector2(position.x + (15 * PlayerDirection),position.y + 15)

	Global.ViewPort.add_child(fx)
	

func get_gravity() -> float:
	return fall_gravity + y_up_force

func player_death():
	Global.canPause = false
	current_state = state.DYING
	isAttacking = false
	hp = 0
	HasControl = false
	IsDashJumping = false
	$Sounds/snd_player_damage.play()
	Global._freeze_frame(0.5)
	yield(get_tree().create_timer(0.5), "timeout")
	play_voice("death")
	var death_fx = FX_DEATH_EFFECT.instance()
	death_fx.global_position = global_position
	Global.ViewPort.get_child(0).add_child(death_fx)
	$Sounds/snd_player_death.play()
	visible = false	
	yield(get_tree().create_timer(1), "timeout")
	MusicPlayer.fade_music(false, 3)
	Transition.get_node("AnimationPlayer").play("Death_Transition")
	yield(Transition.get_node("AnimationPlayer"), "animation_finished")
	Global.Character_Slots[0].spawn(true)

	
func switch_character():
	EventBus.emit_signal("CharactersSwitched")
	isAttacking = false
	var inactive_char = 0 if Global.get_active_player() == 1 else 1
	for n in $Player_ghost.get_children():
		n.queue_free()
	yield(get_tree(),"physics_frame")
	Global.Character_Slots[inactive_char].global_position = self.global_position
	Global.Character_Slots[inactive_char].PlayerDirection = PlayerDirection

	self.pause_mode = PAUSE_MODE_PROCESS

	hurtbox.set_deferred("monitoring", false)
	get_tree().paused = true
	Global.canPause = false
	Global.isPaused = true
	current_state = state.ANIMATION
	animplayer.play("Switch_Out")
	HasControl = false
	gravity_affected = false
	stop_movement()
	turn_off_collision_box(true)
	turn_off_hurtbox(true)
	Global.Character_Slots[inactive_char].switch_in()
	#Sound.play_sound(Sound.SND_PL_TELEPORT_LAND,0,1)

func _on_Walljump_timer_timeout():
	if current_state == state.WALLJUMPING:
		current_state = state.JUMPING


func _on_Command_Dash_Timer_timeout():
	CDL = false
	CDR = false


func _on_Dash_timer_timeout():
	
	match current_state:
		state.DASHING:
			if dir != 0:
				current_state = state.RUNNING
			else:
				current_state = state.DASH_SKID	
		state.AIRDASH:
			current_state = state.FALLING
			match current_airdash:
				airdash_mode.UPWARD:
					velocity.y = -120
				airdash_mode.BLADE:
					velocity.y = velocity.y * 0.3


func _on_EntityPlayer_Damage_taken(_i_frame,damage_dealer):
	
	if hp == 0:
		var inactive = 0 if Global.get_active_player() == 1 else 1
		if Global.Character_Slots[inactive].hp > 0 and damage_dealer.damage < 100:
			switch_character()
			
			Global.Character_Slots[inactive].invulnerable = true
			Global.Character_Slots[inactive].i_frame_timer.start()
			
		else:
			player_death()
		hurtbox.set_deferred("monitoring", false)
	else:
		if (hp + damage_dealer.damage) > (hp_max * 0.3) and hp < (hp_max * 0.3):
			play_low_health = true
		$Sounds/snd_player_damage.play()
		play_voice("damage")
		current_state = state.HITSTUNNED
		IsDashJumping = false
		isAttacking = false
		HasControl = false	
		
		if damage_dealer.global_position.x > global_position.x:
			PlayerDirection = 1 
		else:
			PlayerDirection = -1
		gravity_affected = true
		velocity.y = -150
		x_velocity = (200 * damage_dealer.knockback_power) * -PlayerDirection
		Hitstun_Timer.start()
	EventBus.emit_signal("PlayerHealthUpdated", false)

func _on_Hitstun_timer_timeout():
	if ![state.DYING].has(current_state):
		if is_on_floor():
			current_state = state.IDLE
		else:
			current_state = state.FALLING
		HasControl = true
		if play_low_health:
			play_voice("low_health")
			play_low_health = false

func _reset_var():
	hurtbox.set_deferred("monitoring", true)
	HasControl = true
	AirDashCount = 0
	pause_mode = Node.PAUSE_MODE_STOP
	IsJumping = false
	IsJustWallJumping = false
	IsDashJumping = false
	IsShooting = false
	IsDamageStunned = false
	if character_name == 1:
		HasDoubleJumped = false	
	#Command Dash
	CDR = false
	CDL = false
	
	PlayerDirection = 1
	current_state = state.IDLE	

	for child in get_children():
		if child is Timer:
			child.stop()

func _update_max_health():
	hp_max = 16 + (GameProgress.heart_tank_array.size() * 2)
	EventBus.emit_signal("PlayerHealthUpdated",false)

func _dash_start():
	var dash_time = 0.5
	DashTimer.start(dash_time)
	current_state = state.DASHING
	dash_boost = 110
	DashJetFX.frame = 0

func _on_Sprite_animation_finished():
	match current_state:
		state.SPAWNING:
			current_state = state.IDLE
			Global.canPause = true
			HasControl = true
			turn_off_collision_box(false)
			turn_off_hurtbox(false)
		state.RUN_IN:
			current_state = state.RUNNING
		state.WALLCLING:
			current_state = state.WALLSLIDING
		state.DASH_START:
			_dash_start()
			$Dash_jet_effect.rotation_degrees = 0
			
	
		state.DASH_SKID:
			DashTimer.stop()
			current_state = state.IDLE
		state.CLIMBING_END:
			global_position.y = current_climbable.top_collision.global_position.y - 29
			#snap_to_ground(30)
			IsJumping = false
			snap = true
			current_state = state.IDLE
			

		state.CLIMBING_ENTER:
			enter_ladder()

func walk_to_point(x_coordinate):
	HasControl = false
	WalkPoint = x_coordinate
	current_state = state.RUNNING
	if x_coordinate > global_position.x:
		dir = 1
	elif x_coordinate < global_position.x:
		dir = -1
		
	WalkingToPoint = dir

func enter_ladder():
	DashTimer.stop()
	current_state = state.CLIMBING
	IsDashJumping = false

func enter_zipline():
	DashTimer.stop()
	current_state = state.ZIPLINE
	IsDashJumping = false
	

func _on_Climbable_detector_area_entered(area):
	if area.is_in_group("Climbable"):
		current_climbable = area


func _on_Climbable_detector_area_exited(area):
	if area.is_in_group("Climbable"):
		current_climbable = null


func _on_Zipline_detector_body_entered(body):
	if body.get_parent().is_in_group("Zipline") and current_zipline == null:
		current_zipline = body.get_parent()
		

func _on_Zipline_detector_body_exited(body):
	if body.get_parent().is_in_group("Zipline") and current_zipline == body.get_parent() and current_state != state.ZIPLINE:
		current_zipline = null



func dash_jet_fx_syncer():
	DashJetFX.offset.x = abs(DashJetFX.offset.x) * -PlayerDirection
	DashJetFX.flip_h = true if PlayerDirection < 0 else false
	
	if not [state.DASHING,state.AIRDASH].has(current_state) and DashJetFX.frames:
		DashJetFX.frame = DashJetFX.frames.get_frame_count("default")

func spawn_dash_trail():
	var par = FX_DASH_SMOKE_TRAIL.instance()
	par.x_movement = 0.9 * -PlayerDirection
	par.y_movement = rand_range(-0.4, -0.8)
	par.position = Vector2(position.x + (16*-PlayerDirection), position.y + 12)
	par.flip_h = true if PlayerDirection < 0 else false
	par.speed_scale = rand_range(0.8, 1.5)
	Global.ViewPort.add_child(par)

func spawn_ghost():
	var fx = FX_GHOST.instance()
	#fx.texture = ent_sprite.frames.get_frame(ent_sprite.animation,ent_sprite.frame)
	fx.tracking = ent_sprite
	fx.global_position = ent_sprite.global_position
	match character_name:
		0:	
			fx.color_array = [Color("#1840a0"),Color("#002878"),Color("#001060")]
		1:
			if GameProgress.current_zero_armor == 1:
				fx.color_array = [Color("#5000a0"),Color("#300070"),Color("#180038")]
			else:
			
				fx.color_array = [Color("#900800"),Color("#700000"),Color("#480000")]
		2:
			fx.color_array = [Color("#111961"),Color("#181c44"),Color("#12154e")]
	
	fx.flip_h = ent_sprite.flip_h
	$Player_ghost.add_child(fx)
	fx.global_position = ent_sprite.global_position

func spawn_dash_start():
	var smoke = FX_DASH_SMOKE.instance()
	smoke.position.x = global_position.x + (30 * -PlayerDirection)
	smoke.position.y = global_position.y + 10
	if PlayerDirection > 0:
		smoke.flip_h = false
	else:
		smoke.flip_h = true
	Global.ViewPort.add_child(smoke)

func _on_DashTrail_Timer_timeout():
	if current_state == state.DASHING:
		spawn_dash_trail()

func get_grabbed(grabber):
	current_state = state.GRABBED
	x_velocity = 0
	x_momentum_velocity = 0
	velocity = Vector2.ZERO
	GrabHolder = grabber

func get_inertia():
	
	if is_on_floor():
		x_momentum_velocity = lerp(x_momentum_velocity,0,0.3)
		
	else:
		if dir != 0 and not isAttacking:
			x_momentum_velocity = lerp(x_momentum_velocity,0,0.3)
		else:
			x_momentum_velocity = lerp(x_momentum_velocity,0,0.05)

	#if is_on_wall():
	#	x_momentum_velocity = 0

func spawn_water_splash_fx():

	for n in [-13, 13]:
		
		var fx = FX_WATER_SPLASH_SIDE.instance()
		fx.global_position = Vector2(global_position.x + n, global_position.y)
		fx.flip_h = true if n < 0 else false
		Global.ViewPort.call_deferred("add_child",fx)
	var center_fx = FX_WATER_SPLASH_CENTER.instance()
	center_fx.global_position = Vector2(global_position.x, global_position.y +3)
	Global.ViewPort.get_child(0).call_deferred("add_child",center_fx)
	var snd = SFX.new()
	snd.stream = SFX_WATER_SPLASH
	Global.ViewPort.get_child(0).call_deferred("add_child",snd)
	
func _on_Climbable_detector_body_entered(body):
	if body.is_in_group("Water"):
		UnderWater = true
		call_deferred("spawn_water_splash_fx")
		$bubble_timer.start()

func _on_Climbable_detector_body_exited(body):
	if body.is_in_group("Water"):
		UnderWater = false
		call_deferred("spawn_water_splash_fx")
		$bubble_timer.stop()

func play_stand_animation(mode : int):
	current_state = state.ANIMATION
	match mode:
		0:
			stop_movement()
			current_state = state.ANIMATION
			ent_sprite.play("Stand_in")
		1:
			ent_sprite.play("Stand_out")

func stop_movement():
	x_velocity = 0
	wind_force_x = 0
	x_momentum_velocity = 0
	dir = 0
	IsDashJumping = false
	velocity = Vector2.ZERO

func do_giga_attack():
	current_state = state.GIGA
	gravity_affected = false
	IsDashJumping = false
	isAttacking = false
	velocity = Vector2.ZERO
	x_momentum_velocity = 0
	dir = 0
	
	
func end_giga():
	gravity_affected = true
	current_state = state.FALLING
	turn_off_hurtbox(false)

func get_giga_attack() -> giga_attack:
	if giga_attack_holder.get_children().size() > 0:
		return giga_attack_holder.get_child(0)
	else:
		return null
	
func set_giga_attack(giga_attack : giga_attack):
	if giga_attack_holder.get_children().size() > 0:
		for n in giga_attack_holder.get_children():
			n.queue_free()
		giga_attack_holder.add_child(giga_attack)

func spawn_bubble_fx(spawn_point : int):
	var fx = FX_WATER_BUBBLE.instance()
	if spawn_point != 1:
		fx.global_position = Vector2(ent_sprite.global_position.x  + 2 + (PlayerDirection * 10),global_position.y - 20)
	else:
		fx.global_position = Vector2(Vector2(ent_sprite.global_position.x + rand_range(-13,13),global_position.y +rand_range(-18,18)))
	Global.ViewPort.get_child(0).call_deferred("add_child",fx)


func spawn_wall_smoke(varient : int):
	match varient:

		0:
			var smk : ParticleSprite = Assets.PAR_SMOKE_PL_WALL.instance()
			smk.flip_h = true if PlayerDirection > 0 else false
			smk.y_movement = 0.8
			smk.speed_scale = 1.5
			smk.gravity = -3
			smk.global_position = global_position + Vector2(10 * PlayerDirection,15)
			Global.ViewPort.add_child(smk)

		1:
			var smk : ParticleSprite = Assets.PAR_SMOKE_PL_WALL.instance()
			smk.flip_h = true if PlayerDirection > 0 else false
			smk.y_movement = 0.8
			smk.speed_scale = 1
			smk.gravity = -3
			smk.global_position = global_position + Vector2(10 * PlayerDirection,15)
			smk.animation = "wall_off"
			Global.ViewPort.add_child(smk)


func _on_EntityPlayer_landed():
	if character_name == 1:
		HasDoubleJumped = false

func spawn_teleport_spark_cluster():
	for n in 18:
		var par : ParticleSprite = Assets.PAR_TELEPORT_SPARK.instance()
		par.global_position = global_position
		par.x_movement = rand_range(-4,4)
		par.y_movement = rand_range(-1	,2.1)
		par.deceleration_value = 0.078
		par.speed_scale = rand_range(0.8,1.3)
		if n > 9:
			par.z_index = 1
		else:
			par.z_index = -1
		
		par.gravity = -4
		Global.ViewPort.call_deferred("add_child",par)
func _on_AnimationPlayer_animation_finished(anim_name):
	match anim_name:
		"Switch_In":

			Global.canPause = true
			Global.isPaused = false
			get_tree().paused = false
			pause_mode =Node.PAUSE_MODE_STOP
			gravity_affected = true
			snap = true
			#snap_to_ground(50)
			
			#This is a stupid fix======================================
			yield(get_tree(),"physics_frame")
			yield(get_tree(),"physics_frame")
			#==========================================================
			
			turn_off_collision_box(false)
			turn_off_hurtbox(false)
			HasControl = true
			ent_sprite.playing = true
				
#			if ent_sprite.get("prev_state"):
#				ent_sprite.prev_state = state.IDLE
			current_state = state.IDLE

			#ent_sprite.prev_state = state.IDLE
			#current_state = state.IDLE

func get_hover_release_button() -> bool:
	if Settings.options["input"]["hover_mode"] == true:
		if !Input.is_action_pressed("jump"):
			return true
	else:
		if Input.is_action_just_pressed("jump"):
			if hover_toggleable:
				return true
			else:
				hover_toggleable = true
	return false

func play_voice(voice : String, index : int = -1):
	$Player_voice/SND_VOICE.stop()
	if index != -1:
		$Player_voice/SND_VOICE.stream = voice_lines[voice][index]
	else:
		var audio = voice_lines[voice] if typeof(voice_lines[voice]) != TYPE_ARRAY else voice_lines[voice][rand_range(0,voice_lines[voice].size())] 
		
		
		$Player_voice/SND_VOICE.stream = audio
	$Player_voice/SND_VOICE.play()
	
