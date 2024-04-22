extends AnimatedSprite

onready var Player = get_parent()
var prev_state


func _process(_delta):
	
	if not Player.isAttacking:

		match Player.current_state:
			Player.state.SPAWNING:
				play("Spawn")
			Player.state.IDLE:
				if prev_state == Player.state.FALLING:
					play("Land")
				elif not ["Land", "Holster"].has(animation):
					play("idle")
			Player.state.RUN_IN:
				play("Run_in")
			Player.state.CROUCHING:
				play("Crouch")
			Player.state.RUNNING:
				play("Run")
			Player.state.DASH_START:
				play("Dash_in")
			Player.state.DASHING:
				play("Dash_Loop")
				
			Player.state.AIRDASH:
				if animation != "Dash_Loop":
					play("Dash_in")
				else:
					play("Dash_Loop")
				
			Player.state.DASH_SKID:
				play("Dash_skid")
			Player.state.JUMPING:
				if not ["Jump_Loop", "DoubleJump"].has(animation):
					if prev_state == Player.state.WALLJUMPING:
						play("Jump")
						frame = 2
					if prev_state == Player.state.FALLING:
						play("DoubleJump")
					else:
						play("Jump")
			Player.state.FALLING:
				if not ["Fall_Loop", "DoubleJump"].has(animation):
					play("Fall")
			Player.state.WALLCLING:
				play("Wallcling")
			Player.state.WALLSLIDING:
				play("Wallslide")
			Player.state.WALLJUMPING:
				play("Walljump")
			Player.state.DYING:
				play("Dying")
			Player.state.HITSTUNNED:
				play("Damage_light")
		prev_state = Player.current_state

func _on_Sprite_animation_finished():
	match animation:
		"Jump":
			play("Jump_Loop")
		"Fall":
			play("Fall_Loop")
		"Land":
			play("idle")
		"Dash_in":
			play("Dash_Loop")
			$"../Dash_jet_effect".frame = 0
			
		"Holster":
			play("idle")
		"DoubleJump":
			play("Fall")
			frame = 6


func _on_Sprite_frame_changed():
	match animation:
		"Spawn":
			
			match Player.current_state:
				Player.state.SPAWNING:
					if frame == 1:
						Sound.play_sound(Sound.SND_PL_TELEPORT_LAND,0,1)
			
		"Run":
			if [3,10].has(frame):
				Sound.play_footstep()
		"Victory":
			if frame == 10:
				$"../Sounds/snd_player_ching".play()
