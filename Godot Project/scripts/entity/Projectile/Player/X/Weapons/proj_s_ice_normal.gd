extends "res://scripts/entity/ProjectileBase.gd"

var scatter_shot = preload("res://nodes/entity/Projectile/Player/X/Weapons/proj_X_s_ice_scatter_shot.tscn")
var scatter_fx = preload("res://nodes/particles/projectiles/player/X/par_shotgun_ice_small_exp.tscn")

onready var snd_fx = preload("res://sound_assests/objects/snd_glass_destroy_small.wav")

func shatter():
	for angle in [-0.8, -0.4, 0, 0.4, 0.8]:
		var shot = scatter_shot.instance()
		shot.BulletDire = BulletDire * -1
		shot.position.x = self.global_position.x - (20 * BulletDire)
		shot.position.y = self.global_position.y
		shot.rotation = angle
		get_parent().call_deferred("add_child", shot)
	var fx = scatter_fx.instance()
	fx.global_position = global_position
	Global.ViewPort.get_child(0).add_child(fx)
	
	var snd = SFX.new()
	snd.stream = snd_fx
	snd.bus = "Projectiles"
	snd.volume_db = 2
	Global.ViewPort.add_child(snd)
	queue_free()

func _on_Hitbox_damage_dealt(_old_hp, _new_hp, _target):
	shatter()

func _on_PROJ_S_ICE_NOR_body_entered(body):
	if body != Global.Player:
		shatter()
