extends "res://scripts/entity/Enemy/EntityEnemy.gd"


var velocity_multiplier = 0.0
var tw : SceneTreeTween

var space_state
var current_state = state.IDLE
enum state {IDLE, DIVING, BONK}

func _ready():
	space_state = get_world_2d().direct_space_state
	snap = false
	tw = create_tween()
	
	tw.tween_property(self,"velocity_multiplier",0.3,1)

func _physics_process(delta):

	match current_state:
		state.IDLE:
			velocity.x += (Global.GameCamera.get_camera_position().x + ((get_viewport().size.x/2.4) * -enemy_direction) - global_position.x) * velocity_multiplier
			if abs(Global.GameCamera.get_camera_position().x + ((get_viewport().size.x/2.4) * -enemy_direction) - global_position.x) < 50:
				velocity /= 1.085
			
			velocity.x = clamp(velocity.x, -110,110)
			global_position.y = lerp(global_position.y, Global.GameCamera.get_camera_screen_center().y - 40,delta)
			ent_sprite.offset.y = sin(Global.time * 4) * 8
		state.DIVING:
			velocity.x += 10 * velocity_multiplier * enemy_direction
			velocity_multiplier += delta * 2.1
			velocity = velocity.clamped(300)
			
			if is_on_wall():
				current_state = state.BONK
				gravityenabled = true
				velocity.y = -180
				velocity.x = 60 * -enemy_direction
				ent_sprite.play("Stun")
				receive_damage(4,false,null)
				var explosion = Assets.PAR_EXPLOSION_STANDARD.instance()
				explosion.global_position = global_position
				Global.ViewPort.add_child(explosion)
				Sound.play_standard_explosion_sound()
				
				var hitb = hitbox.new()
				hitb.temporary = true
				hitb.time = 0.1
				hitb.damage = 2
				hitb.set_collision_layer_bit(2,true)
				hitb.set_collision_mask_bit(1, true)
				hitb.size = Vector2(30,30)
				hitb.global_position = global_position
				Global.ViewPort.add_child(hitb)
				
				
				
				
				Global.GameCamera.camera_shake(1,2,0.2)
				$FireSpawner.stop()
				if tw:
					tw.stop()
			if enemy_direction < 0 and global_position.x + 100 < Global.Player.global_position.x || enemy_direction > 0 and global_position.x - 100 > Global.Player.global_position.x:
				if tw:
					tw.stop()
				current_state = state.IDLE
				$reaction_time.start(1.6)
				ent_sprite.play("default")
				$FireSpawner.stop()
				update_dir()
				
				var new_tw = create_tween()
				
				new_tw.tween_property(self,"velocity_multiplier",0.0,0.1)
				new_tw.tween_property(self,"velocity_multiplier",0.3,0.75)
				tw = create_tween()
				tw.tween_property(self,"velocity:y",-90.0,0.6)
				tw.tween_property(self,"velocity:y",0.0,0.6)
		state.BONK:
			if is_on_floor():
				update_dir()
				velocity.x = 40 * -enemy_direction
				$reaction_time.start(1.6)
				ent_sprite.play("default")
				current_state = state.IDLE
				gravityenabled = false
				var new_tw = create_tween()
				velocity_multiplier = 0.0
				new_tw.tween_property(self,"velocity_multiplier",0.3,1.5)
				tw = create_tween()
				tw.tween_property(self,"velocity:y",-130.0,0.6)
				tw.tween_property(self,"velocity:y",0.0,0.6)

	move()

func player_get_floor_position() -> Vector2:
	var space_state = get_world_2d().direct_space_state
	var pos = space_state.intersect_ray(Global.Player.global_position,Global.Player.global_position + Vector2(0, 240),[Global.Player],1)

	if pos:
		return pos.position
		
	else:
		return Vector2.ZERO


func _on_FireSpawner_timeout():
	var pos = space_state.intersect_ray(global_position, Vector2(global_position.x,global_position.y + 40),[self],1)
	if pos:
		var fire : ParticleSprite = Assets.PAR_DASHSMOKE_TRAIL.instance()
		fire.global_position = pos.position
		fire.speed_scale = 0.5
		fire.flip_h = true
		fire.modulate = Color(1,.6,.6)
		Global.ViewPort.add_child(fire)
		var hitb = hitbox.new()
		hitb.temporary = true
		hitb.time = 0.4
		hitb.damage = 2
		hitb.set_collision_layer_bit(2,true)
		hitb.set_collision_mask_bit(1, true)
		hitb.size = Vector2(20,20)
		hitb.global_position = pos.position
		Global.ViewPort.add_child(hitb)


func _on_reaction_time_timeout():
	current_state = state.DIVING
	$FireSpawner.start()
	velocity = Vector2.ZERO
	velocity_multiplier = 0
	velocity.x += 60 * -enemy_direction
	tw = create_tween()
	tw.set_ease(Tween.EASE_IN_OUT)
	tw.set_trans(Tween.TRANS_QUAD)
	#tw.parallel().tween_property(ent_sprite,"offset:x",0.0,0.3)
	tw.tween_property(self,"velocity:y",-60.0,0.3)
	tw.set_parallel(false)	
#	tw.set_ease(Tween.EASE_OUT)
	tw.set_trans(Tween.TRANS_LINEAR)
	tw.tween_property(self,"velocity:y",(player_get_floor_position().y - global_position.y) * 2.3,0.3)
	tw.tween_property(self,"velocity:y",0.0,0.2)
	ent_sprite.play("Diving")
