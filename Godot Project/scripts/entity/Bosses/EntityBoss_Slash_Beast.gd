extends "res://scripts/entity/Bosses/EntityBoss.gd"

onready var par_twin_slasher = preload("res://nodes/entity/Projectile/Bosses/Slash_Beast/proj_boss_slash_beast_twin_slasher.tscn")

enum states {NONE,JUMP, FALLING, LANDING, STOMP, FLASH_KICK, KICK_AIR}
var current_state = states.NONE

var short_jump = false
var jump_slasher = false

var jump_count = 1


func _physics_process(delta):
	
	if current_common_state == common_states.ATTACKING:
		match current_state:
			states.JUMP:
				
				if velocity.y > 0:
					if jump_slasher:
						flash_kick_air(1)
					else:
						animplayer.play("Fall")
						current_state = states.FALLING
					
			states.FALLING:
				if is_on_floor():
					land()
			states.STOMP:
				if is_on_floor():
					land()


func _on_EntityBoss_Slash_Beast_start_fight():
	do_attack()
	pre_jump()


func land():
	current_state = states.LANDING
	velocity = Vector2.ZERO
	land_effect()
	snap = true
	animplayer.play("Land")

func land_effect():
	Sound.play_sound(Sound.SND_OBJ_BOX_FALL,0,1)
	Global.GameCamera.camera_shake(0,1,0.2)


func _on_AnimationPlayer_beast_animation_finished(anim_name):
	match anim_name:
		"Land":
			decide_attack()
			flip_to_match_player()
		"Flash_Kick":
			animplayer.play("Fall")
			current_state = states.JUMP
		"Flash_Kick_Air":
			animplayer.play("Fall")
			current_state = states.FALLING


func _on_EntityBoss_Slash_Beast_decide_attack():
	
	if randi()%2 == 0 and jump_count > 0:
		pre_jump()
		jump_count -=1
	else:
		flash_kick()
		
		jump_count = 1



func pre_jump():


	
	animplayer.play("Jump")
	flip_to_match_player()
	current_state = states.JUMP


	if abs(global_position.x - Global.Player.global_position.x) > 80 and randi()%2 == 0:
		jump_slasher = true
	else:
		jump_slasher = false
	
	
		if abs(global_position.x - Global.Player.global_position.x) < 50 or (randi() % 2 == 0 and abs(global_position.x - Global.Player.global_position.x) < 160):
			short_jump = true
		else:
			short_jump = false


func jump():
	snap = false
	flip_to_match_player()
	
	if jump_slasher:
		velocity.y = -400
		velocity.x = 10 * direction
		return
	
	
	if short_jump:
		velocity.y -= 200
		velocity.x = (Global.Player.global_position.x - global_position.x) * 2.1
	else:
		velocity.y -= 400
		velocity.x = (Global.Player.global_position.x - global_position.x) * 1.5



func flash_kick():
	
	animplayer.play("Flash_Kick")
	flip_to_match_player()
	current_state = states.FLASH_KICK
func pre_stomp():
	current_state = states.STOMP
	velocity.y = -10
	velocity.x *= 0.2
	animplayer.play("Stomp")
func stomp():
	velocity.y = 500

func flash_kick_standing():
	snap = false
	velocity.y -= 400
	velocity.x = ent_sprite.scale.x * -100
	
	for n in [0,0.785398]:
		
	
		var proj : Projectile = par_twin_slasher.instance()
		proj.global_position = global_position + Vector2(0,-14)
		proj.BulletDire = direction
		proj.rotation = n * -direction
		Global.ViewPort.add_child(proj)
	
#	twin_slasher_count = int(rand_range(-1,-2))
	jump_slasher = false
	current_state = states.JUMP



func flash_kick_air(variant : int):
	current_state = states.KICK_AIR
	velocity.y = -100
	#velocity.x *= 0.4
	animplayer.play("Flash_Kick_Air")
	
	var shot_array = [2.181661565,0.959931] if variant == 0 else [0.349066, 0.872665]
	
	for n in shot_array:
		var proj : Projectile = par_twin_slasher.instance()
		proj.global_position = global_position + Vector2(0,14)
		proj.rotation = n
		Global.ViewPort.call_deferred("add_child",proj)
#	twin_slasher_count = int(rand_range(-1,-2))

func _on_Area2D_body_entered(body):
	if current_state == states.JUMP and velocity.y > -180 and not short_jump:
		if abs(Global.Player.velocity.x) > 0 and randi()%2 == 0:
			flash_kick_air(0)
		else:
			pre_stomp()



func _on_EntityBoss_Slash_Beast_boss_died():
	velocity = Vector2.ZERO
	animplayer.play("Dying")
	current_state = states.NONE
