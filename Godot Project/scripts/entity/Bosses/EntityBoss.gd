extends "res://scripts/entity/EntityBase.gd"

onready var boss_health_bar_ui = preload("res://nodes/UI/HUD/Elements/Health_Bar_Enemy.tscn")



export (String) var boss_apperance_music
export (String) var boss_music

export (bool) var grounded
export (Vector2) var spawn_offset : Vector2

var direction = -1

signal state_changed()
signal decide_attack()
signal start_fight()
signal boss_died()
signal reset()

export(String) var Damage_Chart_Path


onready var IdleTimer = $Idle_Timer
onready var AttackTimer = $Attack_Timer
onready var Invulnerable_timer = $Invulnerable_timer
onready var Arena = get_parent().get_parent()


enum common_states{INTRO,IDLE,ATTACKING,HITSTUN,DYING}
var current_common_state = common_states.INTRO

var current_attack_set = []
var current_move = null
var last_attack = "nothing"


func _ready():
	$Explosion_timer.one_shot = false
	if UseDamageTable:
		damage_table = _get_damage_table()
	
	reset_position()
	animplayer.play("Intro_1")
	animplayer.playback_speed = 0
	var _con = Global.connect("PlayerSpawned", self, "reset_boss")
func _enter():

	flip_to_match_player()
	animplayer.play("Intro_1")
	animplayer.playback_speed = 1
	MusicPlayer.change_music(boss_apperance_music)	
	MusicPlayer.fade_music(true, .01)	
	MusicPlayer.start_music(true)
	

func _get_damage_table():
	var f = File.new()
	f.open(Damage_Chart_Path,File.READ)
	var json = f.get_as_text()
	
	var output = parse_json(json)
	
	
	if typeof(output) == TYPE_DICTIONARY:
		return output
	else:
		return []



func _physics_process(_delta):


	match current_common_state:

		common_states.DYING:
			velocity = Vector2.ZERO
	
	move()

func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "Intro_1":
		#Write Logic for dialog
		intro_2_anim()
func intro_2_anim():
	var health_bar = boss_health_bar_ui.instance()
	health_bar.enemy = self
	Global.Current_Hud.boss_health_bar_container.add_child(health_bar)
	
	Global.Current_Hud.hud_anim_player.play("ShowHud")	
	animplayer.play("Intro_2")
	yield(animplayer,"animation_finished")
	Arena.return_to_game_camera()
	health_bar.raise_hp()
	yield(health_bar,"raise_finished")
	_start_fighting()

func _start_fighting():
	MusicPlayer.change_music(boss_music)
	MusicPlayer.start_music(true)
	Global.Player.HasControl = true
	Global.canPause = true
	current_common_state = common_states.IDLE
	emit_signal("state_changed")
	emit_signal("start_fight")

func decide_attack():
	IdleTimer.start()
	current_common_state = common_states.IDLE

func do_attack():
	current_common_state = common_states.ATTACKING

func _on_EntityBoss_Damage_taken(i_frame,_Damage_Dealer):
	if hp == 0:
		boss_death()
	else:
		if i_frame:
			Invulnerable_timer.start(0.4 if _Damage_Dealer.hitbox_name == "AXL_BULLET" else 1.0)
			invulnerable = true
		$Flash_anim.play("Flash")


func _on_EntityBoss_state_changed():
	if current_common_state == common_states.IDLE:
		pass

func flip_to_match_player():
	if Global.Player:
		if Global.Player.global_position.x > global_position.x:
			direction = 1
			ent_sprite.scale.x = -1
		else:
			direction = -1
			ent_sprite.scale.x = 1

func _on_Idle_Timer_timeout():
	emit_signal("decide_attack")
	current_common_state = common_states.ATTACKING

func placeholder_attack():
	current_common_state = common_states.IDLE
	emit_signal("state_changed")

func boss_death():
	current_common_state = common_states.DYING
	$Final_hit.play()
	AttackTimer.stop()
	emit_signal("boss_died")
	hurtbox_collision.set_deferred("disabled", true)
	emit_signal("state_changed")
	MusicPlayer.fade_music(false, 0.1)

	if Global.Player.current_state == Global.Player.state.HITSTUNNED:
		Global.Player.Hitstun_Timer.stop()
		Global.Player.current_state = Global.Player.state.IDLE
	Global.Player.HasControl = false
	Global.canPause = false
	Global.Player.turn_off_hurtbox(true)
	Global.Player.dir = 0
	yield(get_tree().create_timer(0.1),"timeout")
	$Flash_anim.play("Death_Explosion")
	$Explosion_timer.start()

func reset_boss():
	velocity = Vector2.ZERO
	hp = hp_max
	direction = -1
	AttackTimer.stop()
	reset_position()
	current_common_state = common_states.INTRO
	animplayer.play("Intro_1")
	animplayer.playback_speed = 0	
	emit_signal("reset")

func reset_position():
	global_position = Arena.global_position + spawn_offset

func _on_Invulnerable_timer_timeout():
	invulnerable = false

func is_attack_active(attack):
	if not current_common_state == common_states.ATTACKING:
		return true
	elif current_move != attack:
		return true



func _on_Flash_anim_animation_finished(anim_name):
	if invulnerable:
		$Flash_anim.play("Flash")
	else:
		$Flash_anim.stop(true)
		
	if anim_name == "Death_Explosion":
		queue_free()


func _on_Explosion_timer_timeout():
	
	var explosion_effect = Assets.PAR_EXPLOSION_STANDARD.instance()
	explosion_effect.position.x = self.global_position.x + rand_range(-50, 50)
	explosion_effect.position.y = self.global_position.y + rand_range(-50, 50)

	Global.ViewPort.call_deferred("add_child",explosion_effect)	

	Global.SoundBank.play_standard_explosion_sound()
	if $Explosion_timer.wait_time > 0.12:
		$Explosion_timer.wait_time = $Explosion_timer.wait_time -0.011
