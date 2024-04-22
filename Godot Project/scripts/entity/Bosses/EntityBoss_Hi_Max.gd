extends "res://scripts/entity/Bosses/EntityBoss.gd"

enum boss_attack_states {DOUBLE_SHOT, BIG_SHOT, WALLPUNCH, WALLPUNCH_RECOVER, SEED_SHOT, WALLDROP}

onready var Medium_energy_ball = preload("res://nodes/entity/Projectile/Bosses/Hi_Max/Proj_Max_med_ball.tscn")
onready var Large_energy_ball = preload("res://nodes/entity/Projectile/Bosses/Hi_Max/Proj_Max_large_ball.tscn")
onready var Seed_Shot = preload("res://nodes/entity/Projectile/Bosses/Hi_Max/Proj_Max_small_ball.tscn")
onready var Wall_Drop = preload("res://nodes/entity/Projectile/Bosses/Hi_Max/Proj_Max_wall.tscn")

onready var M_Tween = $Movement_tween

func _ready():
	phase_01_attack_set = ["seed_shot", "double_shot", "wall_drop"]
	set_attack_set()

func _physics_process(_delta):
	ent_sprite.scale.x = direction * -1
	
	match current_common_state:
		common_states.IDLE:
			animplayer.play("Idle")

		common_states.ATTACKING:
			match current_move:
				boss_attack_states.WALLPUNCH:
					if is_on_wall():
						for angle in [1.5,-1.5]:
							var proj = Medium_energy_ball.instance()
							proj.position = Vector2(position.x + (20 * direction), position.y)
							proj.rotation = angle
							Global.ViewPort.add_child(proj)
						velocity.x = 0
						big_boi_punch_recover()
						current_move = boss_attack_states.WALLPUNCH_RECOVER

func double_shot():
	current_common_state = common_states.ATTACKING
	current_move = boss_attack_states.DOUBLE_SHOT
	emit_signal("state_changed")
	animplayer.play("Double_Shot")
	yield(animplayer, "animation_finished")
	if is_attack_active(boss_attack_states.DOUBLE_SHOT):
		return
	big_shot()
	
func big_shot():
	current_common_state = common_states.ATTACKING
	current_move = boss_attack_states.BIG_SHOT
	emit_signal("state_changed")
	M_Tween.interpolate_property(self,"position:y",position.y,$Arena/Ground_position.global_position.y,0.4,Tween.TRANS_LINEAR,Tween.EASE_IN_OUT)
	M_Tween.start()
	animplayer.play("Big_Shot")
	yield(animplayer, "animation_finished")
	if is_attack_active(boss_attack_states.BIG_SHOT):
		return
	big_boi_punch()

func big_boi_punch():
	current_common_state = common_states.ATTACKING
	current_move = boss_attack_states.WALLPUNCH
	emit_signal("state_changed")
	animplayer.play("WallPunch")
	yield(animplayer, "animation_finished")
	if is_attack_active(boss_attack_states.WALLPUNCH):
		return	
	velocity.x = 600 * direction
	collshape.disabled = false

func big_boi_punch_recover():
	current_common_state = common_states.ATTACKING
	current_move = boss_attack_states.WALLPUNCH_RECOVER
	emit_signal("state_changed")
	animplayer.play("WallPunch_Recover")
	Global.GameCamera.camera_shake(1, 2, 0.4)
	position.x +=2 * -direction
	AttackTimer.start(0.9);yield(AttackTimer,"timeout")
	if is_attack_active(boss_attack_states.WALLPUNCH_RECOVER):
		return
	direction = direction * -1
	M_Tween.interpolate_property(self,"position:y",position.y,Arena.global_position.y - 10,0.5,Tween.TRANS_LINEAR,Tween.EASE_IN_OUT)
	M_Tween.start()
	yield(M_Tween,"tween_completed")
	if is_attack_active(boss_attack_states.WALLPUNCH_RECOVER):
		return	
	current_common_state = common_states.IDLE
	emit_signal("state_changed")
	
func seed_shot():
	current_common_state = common_states.ATTACKING
	current_move = boss_attack_states.SEED_SHOT
	emit_signal("state_changed")
	animplayer.play("Seed_Shot")
	yield(animplayer, "animation_finished")
	if is_attack_active(boss_attack_states.SEED_SHOT):
		return	
	current_common_state = common_states.IDLE
	emit_signal("state_changed")

func wall_drop():
	current_common_state = common_states.ATTACKING
	current_move = boss_attack_states.WALLDROP
	emit_signal("state_changed")
	animplayer.play("Wall_Drop")
	yield(animplayer, "animation_finished")
	if is_attack_active(boss_attack_states.WALLDROP):
		return	
	current_common_state = common_states.IDLE
	emit_signal("state_changed")
	
func fire_projectile(projectile):
	
	match projectile:
		"med_ball":
			var proj = Medium_energy_ball.instance()
			proj.position = $Sprite/Projectile_Spawn_Point.global_position
			proj.rotation = (Global.Player.global_position - proj.position).angle()
			Global.ViewPort.add_child(proj)
		"big_ball":
			var proj = Large_energy_ball.instance()
			proj.position = $Sprite/Projectile_Spawn_Point.global_position
			proj.BulletDire = direction
			Global.ViewPort.add_child(proj)
		"seed_shot":
			var proj = Seed_Shot.instance()
			proj.position = $Sprite/Projectile_Spawn_Point.global_position
			proj.rotation = (Vector2((Arena.get_arena_edge(3) if direction < 0 else Arena.get_arena_edge(1)), $Arena/Projectile_Aim_Point.global_position.y) - proj.position).angle()

			Global.ViewPort.add_child(proj)
		"wall_drop":
			var proj = Wall_Drop.instance()
			proj.position.y = Arena.global_position.y - 50
			Global.ViewPort.add_child(proj)



func _on_EntityBoss_Hi_Max_boss_died():
	velocity = Vector2.ZERO
	animplayer.play("Dying")
	M_Tween.stop_all()
