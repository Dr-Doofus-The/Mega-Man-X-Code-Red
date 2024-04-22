extends "res://scripts/entity/Bosses/EntityBoss.gd"

enum boss_attack_states {FLYTOPOINT,YANMARK_RUSH,ACTIVATE_SHIELD,YANMARK_OPTION_RUSH}



onready var ground_position = global_position.y

onready var Movement_Tween = $Movement_Tween
#ATTACKS

#YANMARK RUSH
onready var Yanmark_Rush_Fly_Point = $Yanmark_Rush/Yanmark_rush_location
onready var Yanmark_Rush_Spawn_Point = $Yanmark_Rush/Yanmark_rush_spawnpoint
onready var Yanmark_Rush_Spawn_Mover = $Yanmark_Rush/Yanmark_rush_spawn_mover
onready var Yanmark_Rush_Spawn_Holder = $Yanmark_Rush/YR_Spawn_holder
onready var Yanmark_Rush_Projectile = preload("res://nodes/entity/Projectile/Bosses/Yanmark/Proj_Yanmark_Rush.tscn")

#YANMARK OPTION
onready var Yanmark_Option_Spawn_Holder = $Yanmark_Option
onready var Yanmark_Option_Shield = preload("res://nodes/entity/Enemies/Bosses/Yanmark/EntityEnemy_Yanmark_Option_Shield.tscn")

onready var Main_Sprite = $Sprite/Commander_Yanmark_main
onready var Wing_Sprite = $Sprite/Commander_Yanmark_main/Commander_Yanmark_Wing

func _ready():
	phase_01_attack_set = ["yanmark_rush", "yanmark_option"]
	set_attack_set()

func _physics_process(delta):
	match current_common_state:
		common_states.IDLE:
			animplayer.play("Idle")
		common_states.DYING:
			animplayer.play("Dying")
			Movement_Tween.stop_all()



	if current_common_state == common_states.ATTACKING:
		match current_move:
			boss_attack_states.YANMARK_OPTION_RUSH:
				velocity = position.direction_to(Global.Player.global_position) * 5000 * delta
				if Global.Player.global_position.x > global_position.x:
					Main_Sprite.flip_h = true
				else:
					Main_Sprite.flip_h = false
				if Yanmark_Option_Spawn_Holder.get_child_count() == 0:
					velocity = Vector2.ZERO
					current_common_state = common_states.IDLE
					AttackTimer.stop()
					emit_signal("state_changed")

	if current_common_state != common_states.INTRO:
		Wing_Sprite.flip_h = Main_Sprite.flip_h
	if Wing_Sprite.flip_h:
		Wing_Sprite.position.x = -6
	else:
		Wing_Sprite.position.x = 6


func yanmark_rush():
	
	current_common_state = common_states.ATTACKING
	current_move = boss_attack_states.YANMARK_RUSH
	emit_signal("state_changed")
	var position_moveto = Vector2(0,Yanmark_Rush_Fly_Point.global_position.y)
	if global_position.x > Global.GameCamera.get_camera_screen_center().x:
		position_moveto.x = Yanmark_Rush_Fly_Point.global_position.x
		direction = 1
		Main_Sprite.flip_h = false
	else:
		position_moveto.x = Global.GameCamera.get_camera_screen_center().x - (Yanmark_Rush_Fly_Point.global_position.x - Global.GameCamera.get_camera_screen_center().x)
		direction = -1
		Main_Sprite.flip_h = true
	
	
	Movement_Tween.interpolate_property(self, "position",global_position,position_moveto,1,Tween.TRANS_SINE,Tween.EASE_IN_OUT)
	Movement_Tween.start()
	animplayer.play("Flying")
	AttackTimer.start(0.9);yield(AttackTimer, "timeout")
	if is_attack_active(boss_attack_states.YANMARK_RUSH):
		return
	animplayer.play("Point")
	if direction == 1:
		Main_Sprite.flip_h = true
	else:
		Main_Sprite.flip_h = false
	AttackTimer.start(0.6);yield(AttackTimer, "timeout")
	if is_attack_active(boss_attack_states.YANMARK_RUSH):
		return
	yanmark_rush_projectile(direction)
	AttackTimer.start(0.3);yield(AttackTimer, "timeout")
	if is_attack_active(boss_attack_states.YANMARK_RUSH):
		return
	Movement_Tween.interpolate_property(self, "position:y",global_position.y,ground_position,0.7,Tween.TRANS_SINE,Tween.EASE_IN_OUT)
	Movement_Tween.start()	
	animplayer.play("Idle")
	AttackTimer.start(0.5);yield(AttackTimer, "timeout")
	if is_attack_active(boss_attack_states.YANMARK_RUSH):
		return
	if current_common_state == common_states.ATTACKING:
		current_common_state = common_states.IDLE
		emit_signal("state_changed")
		
func yanmark_rush_projectile(dire):
	var original_sm_location = Yanmark_Rush_Spawn_Point.global_position
	Yanmark_Rush_Spawn_Point.global_position.y = Global.GameCamera.get_camera_screen_center().y + get_viewport_rect().size.y/2
	Yanmark_Rush_Spawn_Mover.interpolate_property(Yanmark_Rush_Spawn_Point,"position:y",Global.GameCamera.get_camera_screen_center().y + get_viewport_rect().size.y/2,original_sm_location.y,0.6)
	Yanmark_Rush_Spawn_Mover.start()

	while Yanmark_Rush_Spawn_Mover.is_active():
		var projectile = Yanmark_Rush_Projectile.instance()
		match dire:
			1:
				projectile.position.x = Global.GameCamera.get_camera_screen_center().x -  get_viewport_rect().size.x/2
			-1:
				projectile.position.x = Global.GameCamera.get_camera_screen_center().x +  get_viewport_rect().size.x/2

		projectile.BulletDire = dire
		projectile.position.y = Yanmark_Rush_Spawn_Point.global_position.y
		Yanmark_Rush_Spawn_Holder.add_child(projectile)
		yield(get_tree().create_timer(0.05),"timeout")

func yanmark_option():
	if Yanmark_Option_Spawn_Holder.get_child_count() == 0:
		current_common_state = common_states.ATTACKING
		current_move = boss_attack_states.ACTIVATE_SHIELD
		emit_signal("state_changed")
		animplayer.play("Shield")
		AttackTimer.start(0.5);yield(AttackTimer, "timeout")
		if is_attack_active(boss_attack_states.ACTIVATE_SHIELD):
			return
		var shield = Yanmark_Option_Shield.instance()
		Yanmark_Option_Spawn_Holder.add_child(shield)
		AttackTimer.start(0.8);yield(AttackTimer, "timeout")
		if is_attack_active(boss_attack_states.ACTIVATE_SHIELD):
			return	
		yanmark_option_rush()
	else:
		yanmark_option_rush()
	
func yanmark_option_rush():
	current_common_state = common_states.ATTACKING
	current_move = boss_attack_states.YANMARK_OPTION_RUSH
	emit_signal("state_changed")
	animplayer.play("Flying")
	AttackTimer.start(6);yield(AttackTimer, "timeout")
	if is_attack_active(boss_attack_states.YANMARK_OPTION_RUSH):
		return
	current_common_state = common_states.IDLE
	velocity = Vector2.ZERO
	emit_signal("state_changed")

func _on_EntityBoss_C_Yanmark_state_changed():
	if current_common_state == common_states.ATTACKING:
		match current_move:
			boss_attack_states.FLYTOPOINT:
				if animplayer.current_animation != "Flying":
					animplayer.play("Flying")


func _on_EntityBoss_Commander_Yanmark_boss_died():
	for n in Yanmark_Option_Spawn_Holder.get_children():
		Yanmark_Option_Spawn_Holder.remove_child(n)
		n.queue_free()
