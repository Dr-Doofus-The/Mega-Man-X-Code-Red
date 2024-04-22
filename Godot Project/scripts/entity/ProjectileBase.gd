extends Area2D
class_name Projectile

signal projectile_exiting()

export(String) var Projectile_Name
export(int) var projectile_speed: int = 10
export(int) var start_Y_speed: int = 0
export(float) var lifetime: float = 0
export(float) var start_up_time: float = 0
export(bool) var affected_by_gravity: bool = false
export(bool) var piercing: bool = false
export(bool) var stay: bool = false
export(int) var max_hit_count : int = 0
export(bool) var destroy_on_contact: bool = false
export(bool) var flip_to_match_dire: bool = true
export(bool) var auto_rotate_sprite: bool = true
export(bool) var random_sprite_v_flip: bool = false
export(bool) var flip_every_frame: bool = false
export(bool) var homing: bool = false
export(float) var homing_power: float = 0
export(bool) var invulnerable = false
export(PackedScene) var projectile_trail
export(PackedScene) var projectile_impact_fx
export(PackedScene) var projectile_destroy_fx
export(AudioStreamSample) var projectile_impact_sound
export(AudioStreamSample) var projectile_destroy_sound
export(int, "none", "player", "enemy") var hitbox_layer

var target = null
var homing_strength : float = 0.0

export(String, "Proj_Null", "Proj_Bullet", "Proj_Missle") var ProjClass

var BulletDire = 1
var sprite_rotation = 0
var projtime = 0
var onscreen
var y_velocity
var hitcount = 0

onready var sprite : AnimatedSprite = $AnimatedSprite
onready var visanotifier = $VisibilityNotifier2D
onready var collshape = $CollisionShape2D
onready var Hitbox : hitbox = $Hitbox





func _ready():
	if hitbox_layer != 0:
		match hitbox_layer:
			1:
				Hitbox.set_collision_layer_bit(4,true)
				Hitbox.set_collision_mask_bit(2,true)
			2:
				Hitbox.set_collision_layer_bit(7,true)
				Hitbox.set_collision_mask_bit(1,true)
	
	if homing:
		var detector = Area2D.new()
		var detect_shape = RectangleShape2D.new()
		var detect_col = CollisionShape2D.new()
		detect_shape.extents = Vector2(180,180)
		detect_col.shape = detect_shape
		detector.monitorable = false
		detector.set_collision_layer_bit(0,false)
		detector.set_collision_mask($Hitbox.get_collision_mask())
		add_child(detector)
		detector.add_child(detect_col)
		var _con2 = detector.connect("body_entered",self,"target_detection")
	
	if start_up_time > 0:
		var timer = Timer.new()
		var pro_speed = projectile_speed
		projectile_speed = 0
		add_child(timer)
		timer.start(start_up_time); yield(timer,"timeout")
		projectile_speed = pro_speed
		
	
	var _con = Global.connect("PlayerSpawned", self, "_delete_projectile")
	


	if random_sprite_v_flip:
		sprite.flip_v = true if randi() % 2 == 0 else false
	if auto_rotate_sprite:
		sprite.rotation = (sprite_rotation + self.rotation) * -1
	
	if projectile_trail != null:
		var trail = projectile_trail.instance()
		
		trail.follower = self
		trail.position = self.position
		trail.scale.x = BulletDire
		
		Global.ViewPort.add_child(trail)
	
	if flip_to_match_dire:
		if BulletDire > 0:
			sprite.flip_h = false
		else:
			sprite.flip_h = true

	match Projectile_Name:
#		"Glide_Buster":
#			if BulletDire == -1:
#				$Hitbox.scale.x = -1
#				$TextureRect.scale.x = -1 
		"x_wind_cutter":
			scale.x = BulletDire
		"x_volt_tornado_ball":
			var tw = create_tween()
			tw.set_ease(Tween.EASE_OUT)
			tw.set_trans(Tween.TRANS_SINE)

			tw.tween_property(self,"projectile_speed",0,1.0)
		"x_blaze_burst":
			if !Global.Player.is_on_floor() and Input.is_action_pressed("down"):
				
				start_Y_speed = -projectile_speed
				sprite.flip_v = true
				#Global.Player.x_momentum_velocity = -BulletDire * 100
			else:
				start_Y_speed = projectile_speed
			position.y -= start_Y_speed * 2
	

	
	y_velocity = - start_Y_speed
	sprite.frame = 0
	sprite.playing = true

func _physics_process(delta):
	if homing and is_instance_valid(target):
		
		#var rotate_degree = clamp(get_angle_to(target.global_position),-delta*homing_strength,delta*homing_strength)
		
		#var difference = min(1.0,(abs(Vector2(projectile_speed * BulletDire,0).rotated(rotation).angle_to(target.global_position)) * 4.0))
		
		#var dif = ((global_position - target.global_position).normalized() * projectile_speed) - Vector2(projectile_speed,0).rotated(self.rotation)

		
		var direction = global_position.direction_to(target.global_position)
		
		var desired_velocity = direction * projectile_speed
		var change = (desired_velocity - Vector2((projectile_speed * (delta * 66)),0).rotated(self.rotation)) * homing_strength
		
		var new_velocity = Vector2(projectile_speed * (delta * 66),0).rotated(self.rotation) + change
		
		look_at(global_position + new_velocity)
		
		if auto_rotate_sprite:
			sprite.rotation = (sprite_rotation + self.rotation) * -1
	

		
	elif homing and !is_instance_valid(target):
		target = null
		#rotation = 0
		
	if lifetime != 0:
		projtime += delta
		if projtime >= lifetime:
			_delete_projectile()


	match ProjClass:
		"Proj_Bullet":
			self.position += Vector2((projectile_speed * (delta * 66) * BulletDire),0).rotated(self.rotation)
			position.y += y_velocity
		"Proj_Missle":
			self.position += Vector2((projectile_speed * (delta * 66)),0).rotated(self.rotation)

	
	if !$VisibilityNotifier2D.is_on_screen() and onscreen:
		call_deferred("queue_free")
	if affected_by_gravity:
		y_velocity += delta * 20
		position.y += y_velocity
		
	match Projectile_Name:
		"x_wind_cutter":
			global_position.y = Global.Player.WeaponManager.projectile_spawn_point.global_position.y
			global_position.x = Global.Player.global_position.x + (BulletDire * 16)
			Hitbox.global_position = sprite.global_position + Vector2(BulletDire * 16,0)
		"sniper_missle":
			if projectile_speed > 4:
				if Engine.get_physics_frames()%5 == 0:
					var par = Assets.PAR_SMOKE_PUFF_SMALL.instance()
					#global_position
					par.global_position = global_position
					Global.ViewPort.add_child(par)
				$AnimatedSprite/jet.visible = true
			
func _on_VisibilityNotifier2D_screen_exited():
	call_deferred("queue_free")



func target_detection(entity):

	if homing_strength == 0:
		var tw = create_tween()
		tw.tween_property(self,"homing_strength",homing_power,homing_power/5.0)
	if target == null:

		target = entity
		if hitbox_layer != 2:
			entity.connect("enemy_dying",self,"clear_target")
			entity.connect("tree_exiting",self,"clear_target")

func clear_target():
	if target != null:
		target.disconnect("tree_exiting",self,"clear_target")
	
	target = null

func _delete_projectile():

	emit_signal("projectile_exiting")


	
	if projectile_destroy_fx != null:
		var particle = projectile_destroy_fx.instance()
		particle.global_position = self.global_position
		
		get_parent().call_deferred("add_child",particle)
		
		match Projectile_Name:
			"x_blaze_burst":
				Global.GameCamera.camera_shake(0,1,0.2)
				Sound.play_standard_explosion_sound()
		
	if projectile_destroy_sound:
		var sfx = SFX.new()
		sfx.stream = projectile_destroy_sound
		Global.ViewPort.add_child(sfx)
	
	call_deferred("queue_free")


func _on_Hitbox_body_entered(_body):
	#if destroy_on_contact:
	#	queue_free()
	pass



func _on_Hitbox_damage_dealt(old_hp, new_hp, target):
	
	if target.invulnerable and target != Global.Player and old_hp == new_hp:
		var par = Assets.PAR_SHIELD_HIT.instance()
		par.global_position = global_position
		par.scale.x = BulletDire
		Global.ViewPort.add_child(par)
	else:
		if projectile_impact_fx != null:
			var particle = projectile_impact_fx.instance()
			particle.global_position = self.global_position
			if BulletDire == -1:
				particle.flip_h = true
			Global.ViewPort.call_deferred("add_child",particle)
		if projectile_impact_sound:
			var sound = SFX.new()
			sound.stream = projectile_impact_sound
			sound.bus = "Projectiles"
			Global.ViewPort.add_child(sound)
	#Projectile Specific stuff
	
	match Projectile_Name:
		"Plasma_Shot_Ult":
			var balls = Assets.PROJ_BUSTER_PLASMA_BALL.instance()
			balls.global_position = Vector2(global_position.x + (BulletDire * 20),global_position.y)
			Global.ViewPort.get_child(0).call_deferred("add_child",balls)
	
	
	

	
	if max_hit_count > 0:
		hitcount += 1
		if hitcount >= max_hit_count:
			_delete_projectile()
	
	if not stay:
		if not destroy_on_contact:
			
			if piercing == true:
				if new_hp <= 0:
					pass
				else:
					_delete_projectile()
			else:
				_delete_projectile()
		else:
			_delete_projectile()


func _on_AnimatedSprite_frame_changed():
	match Projectile_Name:
		"Glide_Buster_1":
			if sprite:
				if sprite.frame == 4:
					queue_free()
				$TextureRect.region_rect.position.y += 4
		"blaze_burst_explosion":
			if sprite.frame == 10:
				Hitbox.set_deferred("monitorable",false)
			

	if flip_every_frame and sprite:
		sprite.flip_h = true if randi() % 2 == 0 else false
		sprite.flip_v = true if randi() % 2 == 0 else false	


func _on_AnimatedSprite_animation_finished():
	if sprite.animation == "start":
		sprite.play("default")


func _on_VisibilityNotifier2D_screen_entered():
	onscreen = true


func _on_Area2D_body_entered(_body):
	
	if destroy_on_contact:
		_delete_projectile()



func _on_Area2D_area_entered(area):
	if area is hitbox:
		if invulnerable:
			Sound.play_sound(Sound.SND_HIT_SHIELD,0,1)
			area.emit_signal("damage_dealt", 100, 100, self)
		else:
			area.emit_signal("damage_dealt", 0, -1, self)
			if destroy_on_contact:
				_delete_projectile()
