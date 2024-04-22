extends Enemy_Class

var missle_count = 2


func _ready():
	Sound.play_sound(Sound.SND_OBJ_MACHINE_MOVE,0,1)

func fire_missle(pos : Vector2):
	
	var puff : ParticleSprite = Assets.PAR_SMOKE_PUFF_SMALL.instance()
	puff.x_movement = rand_range(-0.1,1) * enemy_direction
	puff.y_movement = rand_range(-1,0.5) * 0.5
	puff.global_position = Vector2(pos.x * enemy_direction,pos.y) + global_position
	Global.ViewPort.add_child(puff)
		
	var proj : Projectile = Assets.PROJ_ENE_GIGADEATH_MISSLE.instance()
	proj.global_position = Vector2(pos.x * enemy_direction,pos.y) + global_position
	proj.BulletDire = enemy_direction
	Global.ViewPort.add_child(proj)
	Sound.play_sound(Sound.SND_PRJ_LAUNCH,2,1)

func _on_AnimationPlayer_animation_finished(anim_name):
	
	match anim_name:
		"intro":
			animplayer.play("idle")
			
		"idle":
			animplayer.play("fire_left")
			
			
		"fire_right":
			self.missle_count -= 1
			if missle_count > 0:
				animplayer.play("fire_left")
			else:
				animplayer.play("laser")
		"laser":
			animplayer.play("idle")
			missle_count = 2
			


func _on_EntityEnemy_Giga_Death_stop_behavior():
	$Sprite/Position2D/Hitbox/CollisionShape2D.set_deferred("disabled",true)
	$Sprite/Position2D.visible = false
