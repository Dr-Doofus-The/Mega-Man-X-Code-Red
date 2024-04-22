extends X_Weapon

var shot = preload("res://nodes/entity/Projectile/Player/X/Weapons/proj_X_sniper_missle.tscn")

var enemy_list :=[]
var icon_list :=[]

var targeting

func _ready():
	var con = get_parent().connect("weapon_changed",self,"weapon_change")

func _process(_delta):
	for n in icon_list.size():
		icon_list[n].global_position = enemy_list[n].centerpoint.global_position

func _on_Area2D_body_entered(body):
	if body is Enemy_Class and enemy_list.size() < 5:
		enemy_list.append(body)
		var new_reticle = $AnimatedSprite.duplicate()
		new_reticle.modulate.a = 1
		$Reticle_Holder.add_child(new_reticle)
		icon_list.append(new_reticle)
		Sound.play_sound(Sound.SND_UI_LOCK_ON,-6.5,1)


func _on_Area2D_body_exited(body):
	if body is Enemy_Class and targeting:
		var enemy_index = enemy_list.find(body)
		enemy_list.remove(enemy_index)
		
		icon_list[enemy_index].queue_free()
		icon_list.remove(enemy_index)


func _on_X_weapon_sniper_missle_fire_shot(_lvl):
	for n in enemy_list.size():
		var proj = shot.instance()
		proj.BulletDire = W_manager.Player.PlayerDirection
		proj.position.y = W_manager.projectile_spawn_point.global_position.y
		proj.position.x = global_position.x + (W_manager.projectile_spawn_point.position.x * W_manager.Player.PlayerDirection)
		proj.target = enemy_list[n]
		
		proj.rotation = (n - float(enemy_list.size() - 1) * 0.5)
		
		if proj.BulletDire < 0:
			proj.rotation += PI
		
		proj.homing_strength = 0.1
		proj.projectile_speed = 3
		var tw = create_tween()
		#tw.set_ease(Tween.EASE_IN)
		#tw.set_trans(Tween.TRANS_SINE)
		tw.tween_property(proj,"homing_strength",0.4,0.4)
		
		tw.parallel().tween_property(proj,"projectile_speed",8,0.3)
		
		projectile_spawner.add_child(proj)
	ammo -= int(normal_shot_cost)
	Sound.play_sound(Sound.SND_PRJ_LAUNCH,0,1)

func weapon_change(wp_name):
	if wp_name == self.name:
		targeting = true
		$Area2D/CollisionShape2D.disabled = false
	else:
		targeting = false
		icon_list.clear()
		enemy_list.clear()
		$Area2D/CollisionShape2D.disabled = true
		for n in $Reticle_Holder.get_children():
			n.queue_free()
