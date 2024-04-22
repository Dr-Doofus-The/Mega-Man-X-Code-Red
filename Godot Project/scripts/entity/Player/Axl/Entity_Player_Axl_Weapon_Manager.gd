extends Node2D


enum COPY_BOOST {
	CHASERSHOT,
	BOUNCESHOT,
	PIERCESHOT,
	SPREADSHOT
}

enum PROJECTILE {
	AXL_BULLET, COPY_SHOT,
	SPREAD_SHOT, CHASER, 
	SPEED_SHOT
}

var current_copy_boost = -1
onready var Player : player_character = get_parent()


func _physics_process(delta):
	
	if Player.current_state == Player.state.CROUCHING:
		Player.ent_sprite.scale.y = 0.6
		Player.ent_sprite.scale.x = 1.8
		Player.ent_sprite.position.y = 8
		
	else:
		Player.ent_sprite.scale.y = 1
		Player.ent_sprite.scale.x = 1

		Player.ent_sprite.position.y = -3
		
	
	#Fire Weapon
	
	if Player.HasControl:
		if Input.is_action_pressed("fire") or Input.is_action_pressed("special_weapon"):
			if Input.is_action_pressed("fire"):
				
				var aim_direction = get_aim_dir()
				Player.x_velocity = 0
				Player.IsShooting = true
				if !Player.is_on_floor() and Player.hover_juice > 1:
					Player.hover_juice = 1

				
				if $Timer.time_left == 0:
				
					if current_copy_boost >= 0:
						
						match current_copy_boost:
							COPY_BOOST.CHASERSHOT:
								fire_projectile(aim_direction,PROJECTILE.CHASER)
							COPY_BOOST.SPREADSHOT:
								fire_projectile(aim_direction,PROJECTILE.SPREAD_SHOT)
					else:
						fire_projectile(aim_direction,PROJECTILE.AXL_BULLET)

			if Input.is_action_pressed("special_weapon"):
				
				var aim_direction = get_aim_dir()
				Player.x_velocity = 0
				Player.IsShooting = true
				if !Player.is_on_floor() and Player.hover_juice > 1:
					Player.hover_juice = 1

				
				if $Timer.time_left == 0 and $Projectile_holder.get_child_count() == 0:
					fire_projectile(aim_direction,PROJECTILE.COPY_SHOT)
		elif Player.IsShooting:
			Player.gravity_affected = true
			Player.IsShooting = false
			
			
			if Player.hover_juice > 0:
				Player.hover_juice = 0

func _unhandled_input(event):
	if event.is_action_pressed("special_weapon"):
		if current_copy_boost >= 0:
			current_copy_boost = -1

func fire_projectile(aim_direction : Vector2, proj :int):
	
	flash_fire()

	var shot : Projectile
	var shot_offset = 10 if Player.current_state == Player.state.CROUCHING else 0
	$Timer.wait_time = 0.1

	match proj:
		PROJECTILE.AXL_BULLET:
			shot = Assets.PROJ_X_BUSTER_1.instance()
			var Hitbox : hitbox = shot.get_node("Hitbox")
			Hitbox.damage = 2
			Hitbox.hitbox_name = "AXL_BULLET"
			shot.projectile_speed = 10
			Sound.play_sound(Sound.SND_PRJ_X_BUSTER_FIRE,0,1)
		PROJECTILE.COPY_SHOT:
			shot = Assets.PROJ_AXL_COPY_SHOT.instance()
			shot.projectile_speed = 7
			Sound.play_sound(Sound.SND_PRJ_X_BUSTER_FIRE,0,1)
		PROJECTILE.CHASER:
			shot = Assets.PROJ_X_BUSTER_1.instance()
			shot.get_node("Hitbox").damage = 1
			shot.projectile_speed = 7
			shot.homing = true
			shot.homing_strength = 10
			Sound.play_sound(Sound.SND_PRJ_X_BUSTER_FIRE,0,1)
		PROJECTILE.SPREAD_SHOT:
			shot = Assets.PROJ_X_BUSTER_1.instance()
			Sound.play_sound(Sound.SND_PRJ_X_BUSTER_FIRE,0,1)
			shot.get_node("Hitbox").damage = 1
			shot.projectile_speed = 10
			for n in 2:
				var spread_shot = Assets.PROJ_X_BUSTER_1.instance()
				spread_shot.global_position = global_position + (aim_direction * 26) + Vector2(0,shot_offset)
				spread_shot.rotation = aim_direction.angle() + ((n - 0.5)* 0.65)
				spread_shot.auto_rotate_sprite = false
				spread_shot.destroy_on_contact = true
				$Timer.wait_time = 0.15
				spread_shot.get_node("Hitbox").damage = 1
				spread_shot.projectile_speed = 10
				Global.ViewPort.add_child(spread_shot)
		PROJECTILE.SPEED_SHOT:
			shot = Assets.PROJ_X_BUSTER_1.instance()
			shot.get_node("Hitbox").damage = 1
			shot.projectile_speed = 11
			Sound.play_sound(Sound.SND_PRJ_X_BUSTER_FIRE,0,1)
			$Timer.wait_time = 0.05
	
	shot.global_position = global_position + (aim_direction * 26) + Vector2(0,shot_offset)
	shot.rotation = aim_direction.angle()
	shot.auto_rotate_sprite = false
	shot.destroy_on_contact = true
	
	$Timer.start()
	$Projectile_holder.add_child(shot)
func flash_fire():

	Player.ent_sprite.get_material().set_shader_param("frame_coordinate", Vector2(0.514,0.003))
	$"../Flash_timer".start(0.05);yield($"../Flash_timer","timeout")
	Player.ent_sprite.get_material().set_shader_param("frame_coordinate", Vector2(-0.01,0.003))

func get_aim_dir() -> Vector2:
	var aim_direction = Vector2(Player.dir,Player.dirY).normalized() 

	if aim_direction == Vector2.ZERO || Player.current_state == Player.state.CROUCHING:
		aim_direction = Vector2(Player.PlayerDirection,0)
	return aim_direction

func set_copy_boost(id):
	Player.pause_mode = Node.PAUSE_MODE_PROCESS
	Player.HasControl = false
	Player.dir = 0
	Player.velocity.y = 0
	Player.gravity_affected = false
	Player.current_state = Player.state.ANIMATION
	current_copy_boost = id
	Global.Current_Hud.box_notify(COPY_BOOST.keys()[id])
	get_tree().paused = true
	Player.animplayer.play("Copy")
	


func _on_AnimationPlayer_animation_finished(anim_name):
	match anim_name:
		"Copy":
			Player.pause_mode = Node.PAUSE_MODE_STOP
			Player.HasControl = true
			Player.current_state = Player.state.IDLE
			Player.gravity_affected = true
			get_tree().paused = false


func _on_EntityPlayer_Axl_Damage_taken(_i_frame, _damage_dealer):
	current_copy_boost = -1
