extends "res://scripts/entity/ProjectileBase.gd"

onready var split_shot = preload("res://nodes/entity/Projectile/Player/X/Weapons/proj_X_c_sting_split.tscn")

func _ready():
	var _con = $AnimatedSprite.connect("frame_changed",self,"check_for_split")

func _on_Timer_timeout():
	projectile_speed = 0
	sprite.play("Split")
	

	yield(sprite, "animation_finished")
	queue_free()


func check_for_split():
	if sprite.animation == "Split" and sprite.frame == 2:
		for angle in [0.5, 0, -0.5]:
			var shot = split_shot.instance()
			shot.BulletDire = BulletDire
			shot.get_node("AnimatedSprite").flip_h = false
			shot.position.y = self.position.y
			shot.position.x = self.position.x + (BulletDire * 7)
			shot.rotation = angle
			if shot.rotation != 0:
				shot.get_node("AnimatedSprite").play("tilt")
				if angle > 0:
					shot.get_node("AnimatedSprite").flip_v = true

			get_parent().add_child(shot)
