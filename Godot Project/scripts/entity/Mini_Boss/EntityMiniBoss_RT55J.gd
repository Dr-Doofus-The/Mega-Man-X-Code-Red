extends "res://scripts/entity/Mini_Boss/EntityMiniBoss.gd"

enum boss_states {NOTHING,JUMPING,LANDING,FALLING,DRILLING,CLAW_ATTACK, CLAW_RETRACTING,CLAW_GRABED,CLAW_THROW,CLAW_WALL,ROCK_THROW}
var current_state = boss_states.NOTHING

onready var land_sfx = preload("res://sound_assests/bosses/himax/snd_boss_max_crash.wav")
onready var smoke_puff = preload("res://nodes/particles/other/Par_smoke_puff_small.tscn")
onready var dash_smoke = preload("res://nodes/particles/player/par_player_dashsmoke_trail.tscn")

onready var rock_projectile = preload("res://nodes/entity/Projectile/MiniBoss/RT55J/Proj_rt55j_wall_rock.tscn")
onready var rock_shatter_particle = preload("res://nodes/particles/mini_boss/par_rt55j_rock_explosion.tscn")
onready var boulder_projectile = preload("res://nodes/entity/Projectile/MiniBoss/RT55J/Proj_rt55j_beeg_rock.tscn")

var boulder


signal landed()
signal retract_claw()

var throwing_player
var fakeout_drill = false

func _ready():
	var _con = connect("state_changed",self,"state_changed")
	attack_set = ["Pre_Jump","Pre_Drill","Throw_claw"]
	first_attack = "Pre_Jump"


func _physics_process(delta):
	
	
	if current_common_state == common_states.ATTACKING:
		if throwing_player:
			if direction > 0:
				$Sprite/Claw_Thrower.position.x -= (delta * 600)
				$Sprite/Claw_Thrower/Hitbox.position.x = -20
			else:
				$Sprite/Claw_Thrower.position.x -= (delta * 600)
				$Sprite/Claw_Thrower/Hitbox.position.x = 20
			$Hitbox/CollisionShape2D.set_deferred("disabled", true)
			Global.Player.invulnerable = false
			if $Sprite/Claw_Thrower.get_overlapping_bodies().size() > 0:

				Global.Player.receive_damage($Sprite/Claw_Thrower/Hitbox.damage,$Sprite/Claw_Thrower/Hitbox.activate_iframes,$Sprite/Claw_Thrower/Hitbox)
				$Hitbox/CollisionShape2D.set_deferred("disabled", false)
				throwing_player = false
				Global.Player.GrabHolder = null



		match current_state:
			boss_states.JUMPING:
				if velocity.y > 0:
					ent_sprite.play("Falling")
					current_state = boss_states.FALLING
			boss_states.FALLING:
				if is_on_floor():
					land()
			boss_states.DRILLING:
				velocity.x = (25000 * (delta)) * direction
				
				if is_on_wall():
					if Engine.get_physics_frames() % 14 == 0:
						spawn_wall_rock()
						Global.GameCamera.camera_shake(1,1,0.5)
					if Engine.get_physics_frames() % 4 == 0:
						spawn_drill_smoke()
				else: 
					if fakeout_drill and is_player_behind() and not $Sprite/Wall_checker.is_colliding():
						Pre_Drill()
						fakeout_drill = false
					if Engine.get_physics_frames() % 2 == 0:
						spawn_dash_smoke()
		
		
func _process(_delta):
	if [boss_states.CLAW_ATTACK, boss_states.CLAW_WALL, boss_states.CLAW_RETRACTING, boss_states.CLAW_GRABED].has(current_state) and current_common_state == common_states.ATTACKING:
		$Sprite/Chain_Link.points[0] = Vector2($Sprite/Claw.position.x + 49,$Sprite/Claw.position.y - 16)

	
func Pre_Jump():
	current_common_state = common_states.ATTACKING
	emit_signal("state_changed")
	update_direction()
	ent_sprite.play("Jump")

func Jump():
	current_common_state = common_states.ATTACKING
	current_state = boss_states.JUMPING
	emit_signal("state_changed")
	
	snap = false
	velocity.y = -450
	velocity.x = (Global.Player.global_position.x - global_position.x) * 1.1

	yield(self,"landed")
	yield(ent_sprite,"animation_finished")
	current_common_state = common_states.IDLE

	decide_attack()
	


func land():
	velocity.x = 0
	ent_sprite.play("Land")
	current_state = boss_states.LANDING
	land_effect()
	emit_signal("landed")

func land_effect():
	Global.GameCamera.camera_shake(0,1,0.4)
	var sound_fx = SFX.new()
	sound_fx.stream = land_sfx
	Global.ViewPort.add_child(sound_fx)
	
	for n in [-2,-1,0,1,2]:
		var smk_fx = smoke_puff.instance()
		smk_fx.x_movement = n
		smk_fx.global_position = Vector2(global_position.x + (n * 5), global_position.y + 5)
		smk_fx.y_movement = rand_range(-0.2,-1)
		Global.ViewPort.get_child(0).add_child(smk_fx)

func Pre_Drill():

	current_common_state = common_states.ATTACKING
	current_state = boss_states.NOTHING
	emit_signal("state_changed")
	update_direction()
	ent_sprite.play("Pre_Drill")
	velocity.x = 50 * -direction if not fakeout_drill else 230 * -direction
	fakeout_drill = true if randi()%2 == 0 else false


func Drill():
	current_common_state = common_states.ATTACKING
	current_state = boss_states.DRILLING
	emit_signal("state_changed")
	ent_sprite.play("Drill")
	fakeout_drill = false
	$Sprite/Wall_checker.enabled = true
	yield_timer.start(3.5); yield(yield_timer,"timeout")
	current_state = boss_states.NOTHING
	$Sprite/Wall_checker.enabled = false
	velocity.x = 0
	ent_sprite.play("Drill_Recover")

func Throw_claw():
	if abs(Global.Player.global_position.x - global_position.x) > 200:
		Throw_Boulder()
		last_attack = "Throw_Boulder"
	else:
	
		update_direction()
		current_common_state = common_states.ATTACKING
		current_state = boss_states.CLAW_ATTACK
		$Sprite/Claw.position.x = -50
		emit_signal("state_changed")
		ent_sprite.play("Throw_Claw")

func Throw_Player():
	Global.Player.GrabHolder = $Sprite/Claw_Thrower
	$Sprite/Claw/CollisionShape2D.set_deferred("disabled", true)
	throwing_player = true
	yield_timer.start(1);yield(yield_timer,"timeout")
	$Sprite/Claw.visible = false
	current_common_state = common_states.IDLE
	update_direction()
	emit_signal("state_changed")


func Claw_Launch():
	$Sprite/Claw/Move_Tween.interpolate_property($Sprite/Claw,"position:x",-50,-250,0.7,Tween.TRANS_QUAD,Tween.EASE_OUT)
	$Sprite/Claw/Move_Tween.start()
	$Sprite/Claw/AnimatedSprite.play("default")
	$Sprite/Claw.visible = true
	$Sprite/Claw/CollisionShape2D.set_deferred("disabled", false)
	$Sprite/Chain_Link.visible = true
	
	yield_timer.start(1); yield(yield_timer,"timeout")
	if current_state == boss_states.CLAW_ATTACK and current_common_state == common_states.ATTACKING:
		$Sprite/Claw/Move_Tween.interpolate_property($Sprite/Claw,"position:x",-250,-50,0.7,Tween.TRANS_EXPO,Tween.EASE_IN)
		$Sprite/Claw/Move_Tween.start()
		current_state = boss_states.CLAW_RETRACTING
	
func Claw_Retract():
	$Sprite/Claw.visible = false
	$Sprite/Chain_Link.visible = false
	$Sprite/Claw/CollisionShape2D.set_deferred("disabled", true)
	ent_sprite.play("Claw_Recover")

func Claw_Grabbed_Player():
	current_state = boss_states.CLAW_GRABED
	$Sprite/Claw_Thrower.global_position.x = self.global_position.x
	$Sprite/Claw/Move_Tween.remove_all()
	$Sprite/Claw/Move_Tween.interpolate_property($Sprite/Claw,"position:x",$Sprite/Claw.position.x,-50,0.5,Tween.TRANS_CIRC,Tween.EASE_IN)
	$Sprite/Claw/AnimatedSprite.play("grabbed")
	$Sprite/Claw/Move_Tween.start()

func Claw_Wall_Collide():
	current_state = boss_states.CLAW_WALL
	$Sprite/Claw_Thrower.global_position.x = self.global_position.x
	$Sprite/Claw/Move_Tween.remove_all()
	$Sprite/Claw/AnimatedSprite.play("grab_wall")
	if randi()%2 == 0:
	
		$Sprite/Claw/Move_Tween.interpolate_property($Sprite/Claw,"position:x",$Sprite/Claw.position.x,-50,0.5,Tween.TRANS_CIRC,Tween.EASE_IN,0.8)
		$Sprite/Claw/Move_Tween.start()
	else:
		var time_to_destination = abs($Sprite/Claw.global_position.x - global_position.x)/250

		$Sprite/Claw/Move_Tween.interpolate_property(self,"global_position:x",global_position.x,$Sprite/Claw.global_position.x + (40 * -direction),time_to_destination,Tween.TRANS_LINEAR,Tween.EASE_IN,0.8)
		$Sprite/Claw/Move_Tween.interpolate_property($Sprite/Claw,"position:x",$Sprite/Claw.position.x,-50,time_to_destination,Tween.TRANS_LINEAR,Tween.TRANS_LINEAR,0.8)
		$Sprite/Claw/Move_Tween.start()
		yield_timer.start(0.8); yield(yield_timer,"timeout")
		Global.GameCamera.camera_shake(1,1,time_to_destination)
		
func Throw_Boulder():
	if not boulder:
		update_direction()
		current_common_state = common_states.ATTACKING
		current_state = boss_states.ROCK_THROW
		animplayer.play("Boulder_Throw")
		emit_signal("state_changed")
		yield(animplayer,"animation_finished")
		current_common_state = common_states.IDLE
		update_direction()
		emit_signal("state_changed")
		
	else:
		Pre_Jump()

func state_changed():
	match current_common_state:
		common_states.IDLE:
			ent_sprite.animation = "Idle"
			current_state = boss_states.NOTHING

func spawn_boulder():
	var rock = boulder_projectile.instance()
	rock.global_position = $Sprite/Claw.global_position
	rock.holder = $Sprite/Claw
	rock.direction = -direction
	boulder = rock
	Global.ViewPort.get_child(0).add_child(rock)
	var _con = rock.connect("tree_exiting",self,"boulder_destoyed")

func throw_rock():
	if boulder:
		boulder.throw()

func boulder_destoyed():
	boulder = null

func spawn_wall_rock():
	var rock = rock_projectile.instance()
	rock.global_position = global_position + Vector2(0,-60)
	rock.start_Y_speed = rand_range(7,10)
	rock.projectile_speed = -direction * rand_range(0.7,8)
	rock.projectile_destroy_fx = rock_shatter_particle
	Global.ViewPort.get_child(0).add_child(rock)

func spawn_dash_smoke():
	var fx = dash_smoke.instance()
	fx.global_position = Vector2(global_position.x, global_position.y - 1)
	Global.ViewPort.get_child(0).add_child(fx)

func spawn_drill_smoke():
	var fx = smoke_puff.instance()
	var rand_vector = Vector2(rand_range(-10,10),rand_range(-15,15))
	fx.global_position = Vector2(global_position.x + (direction * 40),global_position.y - 30) + rand_vector
	fx.x_movement = rand_range(0.1,3) *-direction
	Global.ViewPort.get_child(0).add_child(fx)
func is_player_behind():
	if Global.Player.global_position < global_position and direction == 1:
		return true
	elif Global.Player.global_position > global_position and direction == -1:
		return true
func _on_Sprite_frame_changed():
	match ent_sprite.animation:
		
		"Jump":
			if ent_sprite.frame == 5:
				Jump()
		"Pre_Drill":
			if ent_sprite.frame == 6:
				Drill()
		"Throw_Claw":
			if ent_sprite.frame == 6 and current_common_state == common_states.ATTACKING:
				match current_state:
					boss_states.CLAW_ATTACK:
						Claw_Launch()
					boss_states.CLAW_THROW:
						Throw_Player()


func _on_Sprite_animation_finished():
	match ent_sprite.animation:
		"Drill_Recover":
			current_common_state = common_states.IDLE
			update_direction()
			emit_signal("state_changed")
		"Claw_Recover":
			current_common_state = common_states.IDLE
			update_direction()
			emit_signal("state_changed")


func _on_EntityMiniBossRT55J_boss_reset():
	current_state = boss_states.NOTHING
	update_direction()


func _on_Move_Tween_tween_all_completed():
	if current_common_state == common_states.ATTACKING:
		match current_state:
			boss_states.CLAW_RETRACTING:
				Claw_Retract()
			boss_states.CLAW_GRABED:
				animplayer.play("Throw")
				$Sprite/Chain_Link.visible = false
				Global.Player.invulnerable = true
				current_state = boss_states.CLAW_THROW
			boss_states.CLAW_WALL:
				ent_sprite.play("Claw_Recover")
				$Sprite/Claw.visible = false
				$Sprite/Chain_Link.visible = false

func _on_Claw_body_entered(body):
	if current_state == boss_states.CLAW_ATTACK:
		if body == Global.Player:
			Global.Player.get_grabbed($Sprite/Claw)
			Claw_Grabbed_Player()
		else:
			Claw_Wall_Collide()


func _on_Hitbox_damage_dealt(_old_hp, _new_hp, _target):
	match current_state:
		boss_states.DRILLING:
			fakeout_drill = false


func _on_EntityMiniBossRT55J_boss_dying():
	current_common_state = common_states.DYING
	gravityenabled = false
	velocity = Vector2.ZERO
	ent_sprite.play("Dying")
	$Sprite/Chain_Link.visible = false
	$Sprite/Claw.visible = false
	$Sprite/Claw/Move_Tween.remove_all()



func _on_EntityMiniBossRT55J_fight_started():
	$Sprite/Claw.visible = false
