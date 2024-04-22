extends "res://scripts/entity/EntityBase.gd"

onready var boss_health_bar_ui = preload("res://nodes/UI/HUD/Elements/Health_Bar_Enemy.tscn")


export (String) var boss_music



export (bool) var grounded
export (Vector2) var spawn_offset : Vector2

var direction = -1
onready var Arena = get_parent().get_parent()

signal state_changed()
signal fight_started()
signal boss_reset()
signal boss_dying()

export(String) var Damage_Chart_Path

export (Texture) var palette
export (Vector2) var standard_palette
export (Vector2) var ex_palette
export (Vector2) var hurt_palette

export (Rect2) var explosion_rect : Rect2


onready var yield_timer : Timer = $Yield_Timer
onready var idle_timer : Timer = $Idle_Timer

enum common_states{INTRO,IDLE,ATTACKING,DYING}
var current_common_state = common_states.INTRO


var attack_set : Array
var first_attack
var last_attack = ""


func _ready():
	reset_boss()
	if UseDamageTable:
		damage_table = _get_damage_table()
	var _con = EventBus.connect("PlayerSpawned",self,"reset_boss")
	ent_sprite.get_material().set_shader_param("palette", palette)
	
func _enter():

	animplayer.play("Intro_1")
	animplayer.playback_speed = 1
	MusicPlayer.change_music(boss_music)	
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
	
	
	if i_frame_timer.time_left > 0:
		$Flash_anim.play("damage")
	
	move()

func return_to_palette():

	if GameProgress.GameDificulty == 2:
		ent_sprite.material.set_shader_param("frame_coordinate",ex_palette)
	else:
		ent_sprite.material.set_shader_param("frame_coordinate",standard_palette)

func intro_2_anim():
	var health_bar = boss_health_bar_ui.instance()
	health_bar.enemy = self
	Global.Current_Hud.boss_health_bar_container.add_child(health_bar)
	
	Global.Current_Hud.hud_anim_player.play("ShowHud")	
	animplayer.play("Intro_2")
	yield(animplayer,"animation_finished")
	
	health_bar.raise_hp()
	yield(health_bar,"raise_finished")
	_start_fighting()

func _start_fighting():
	Global.Player.HasControl = true
	Global.canPause = true
	call(first_attack)
	last_attack = first_attack
	emit_signal("state_changed")
	emit_signal("fight_started")
	
func decide_attack():

	if current_common_state == common_states.IDLE:
		if attack_set.size() == 1:
			call(attack_set[0])
			last_attack = attack_set[0]
		else:
			var rand_value = attack_set[randi() % attack_set.size()]
			if rand_value == last_attack:
				decide_attack()
			else:
				call(rand_value)
				last_attack = rand_value

		
func update_direction():
	if Global.Player:
		if Global.Player.global_position.x > global_position.x:
			direction = 1
			ent_sprite.scale.x = -1
		else:
			direction = -1
			ent_sprite.scale.x = 1
	
func reset_boss():
	velocity = Vector2.ZERO
	return_to_palette()
	hp = hp_max
	direction = -1
	reset_position()
	current_common_state = common_states.INTRO
	animplayer.play("Intro_1")
	animplayer.playback_speed = 0
	emit_signal("boss_reset")

func reset_position():
	global_position = Arena.global_position + spawn_offset

func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "Intro_1":
		intro_2_anim()


func _on_EntityMiniBossBase_state_changed():
	match current_common_state:
		common_states.IDLE:
			idle_timer.start()



func _on_Idle_Timer_timeout():
	match current_common_state:
		common_states.IDLE:
			decide_attack()

func boss_explode():


	hurtbox.set_deferred("monitoring", false)
	$Hitbox/CollisionShape2D.set_deferred("disabled", true)
	var die_timer = Timer.new()
	die_timer.pause_mode =Node.PAUSE_MODE_STOP
	add_child(die_timer)

		
	for n in 20:

		spawn_explosion_death_effect()
		die_timer.start(0.13); yield(die_timer,"timeout")

	call_deferred("queue_free")

func spawn_explosion_death_effect():
	var explosion_effect = Global.ResourceBank.FX_Explosion_Standard.instance()
	explosion_effect.position = self.global_position + Vector2(rand_range(explosion_rect.position.x,explosion_rect.position.x + explosion_rect.size.x),rand_range(explosion_rect.position.y,explosion_rect.position.y + explosion_rect.size.y))
	

	Global.ViewPort.call_deferred("add_child",explosion_effect)	
	Global.SoundBank.play_standard_explosion_sound()

func switch_to_hurt_palette():
	ent_sprite.get_material().set_shader_param("frame_coordinate", hurt_palette)

func _on_EntityMiniBossBase_Damage_taken(_i_frame, _damage_dealer):
	if hp == 0:
		emit_signal("boss_dying")
		current_common_state = common_states.DYING
		$Idle_Timer.stop()
		$Yield_Timer.stop()
		boss_explode()
		MusicPlayer.fade_music(false,2)

