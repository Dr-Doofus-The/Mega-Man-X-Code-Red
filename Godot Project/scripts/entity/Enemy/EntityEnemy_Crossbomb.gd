extends "res://scripts/entity/Enemy/EntityEnemy.gd"


func _ready():
	ent_sprite.frame = varient

func play_beep():
	Sound.play_sound(Sound.SND_OBJ_EXPBOX_BEEP,-8,1)

func cross_explosion(lvl):
	if lvl == 0:
		turn_off_hurtbox(true)
		Global.GameCamera.camera_shake(0,2,0.3)
		visible = false
		emit_signal("enemy_dying")
		Sound.play_standard_explosion_sound()
		spawn_cross_explosion(global_position)
		$Timer.start(0.11) ; yield($Timer,"timeout")
		cross_explosion(1)
	
	elif lvl == 4:
		queue_free()
	else:
		Sound.play_standard_explosion_sound()
		for n in 4:
			var extra_rotation = 0.785 if varient == 1 else 0
			var exp_pos = Vector2(0, - lvl * 32).rotated((1.57 * n) + extra_rotation)
			spawn_cross_explosion(global_position + exp_pos)
		$Timer.start(0.11) ; yield($Timer,"timeout")
		cross_explosion(lvl + 1)
func spawn_cross_explosion(pos : Vector2):
	var explosion : ParticleSprite = Assets.PAR_EXPLOSION_STANDARD.instance()
	explosion.global_position = pos
	Global.ViewPort.add_child(explosion)
	var Explosion_HitBox = hitbox.new()
	Explosion_HitBox.temporary = true
	Explosion_HitBox.time = 0.15

	Explosion_HitBox.damage = 4

	Explosion_HitBox.set_collision_layer_bit(7,true)
	Explosion_HitBox.set_collision_mask_bit(1,true)
	Explosion_HitBox.set_collision_mask_bit(2,true)
	Explosion_HitBox.size = Vector2(22,22)
	Explosion_HitBox.global_position = pos 

	Global.ViewPort.add_child(Explosion_HitBox)


func _on_EntityEnemy_CrossBomb_Damage_taken(i_frame, damage_dealer):
	if hp == 0:
		cross_explosion(0)


func _on_Area2D_body_entered(body):
	animplayer.play("beep")


func _on_Hitbox_damage_dealt(_old_hp, _new_hp, _target):
	animplayer.stop()
	cross_explosion(0)
