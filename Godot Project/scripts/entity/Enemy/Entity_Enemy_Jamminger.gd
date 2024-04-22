extends "res://scripts/entity/Enemy/EntityEnemy.gd"

var HasHit = false

onready var movement_tween = $Tween
enum state{Idle, Attacking, Following, Laughing}

var current_state = state.Idle
var actual_speed = 0
var laugh_count = 0

func _ready():
	attack_player(false)
	var _con = connect("Damage_taken",self,"damage_taken")

func _physics_process(delta):
	$Sprite.position.y = sin(10 * lifetime)*4
	
	if current_state != state.Following || current_state == state.Following and not $Knockback_timer.is_stopped():
		actual_speed -= delta*200
		velocity.x = lerp(velocity.x, 0, 0.1)
		velocity.y = lerp(velocity.y, 0, 0.1)
	else:
		actual_speed += delta*200
	if current_state == state.Following and $Knockback_timer.is_stopped():
		velocity = global_position.direction_to(Global.Player.global_position) * actual_speed * (delta* 70)
	actual_speed = clamp(actual_speed,0,Movement_Speed)


func attack_player(ease_in : bool):
	current_state = state.Attacking
	var distance_multiplier = abs(global_position.distance_to(Global.Player.global_position)/360)
	
	var ease_type = Tween.EASE_IN_OUT if ease_in == true else Tween.EASE_OUT
	movement_tween.interpolate_property(self, "global_position:x",global_position.x, Global.Player.global_position.x + (Global.Player.PlayerDirection * -15),1.3*distance_multiplier,Tween.TRANS_SINE,ease_type)
	movement_tween.interpolate_property(self, "global_position:y",global_position.y, Global.Player.global_position.y,0.8*distance_multiplier,Tween.TRANS_QUAD,ease_type)
	movement_tween.interpolate_property(self, "global_position:y",Global.Player.global_position.y, Global.Player.global_position.y - 50 ,0.5,Tween.TRANS_SINE,Tween.EASE_IN_OUT,0.8*distance_multiplier)
	movement_tween.start()
	


func _on_Hitbox_damage_dealt(_old_hp, _new_hp, _target):
	HasHit = true
	if current_state == state.Following:
		retaliate()

func _on_Tween_tween_all_completed():
	if HasHit:
		laugh()
	else:
		goto_idle()
func laugh():
	laugh_count = 4
	$Sprite.play("laugh")

func goto_idle():
	current_state = state.Idle
	$Idle_timer.start()

func _on_Sprite_animation_finished():
	if $Sprite.animation == "laugh":
		if laugh_count > 0:
			laugh_count -= 1
		else:
			$Sprite.play("default")
			goto_idle()


func _on_Idle_timer_timeout():
	current_state = state.Following


func retaliate():
	current_state = state.Idle
	movement_tween.interpolate_property(self, "position:y",position.y, position.y - 80 ,0.6,Tween.TRANS_SINE,Tween.EASE_IN_OUT)
	movement_tween.start()
	$Idle_timer.stop()

func damage_taken(_i_frames,damage_dealer):
	velocity = damage_dealer.global_position.direction_to(global_position) * 200 * damage_dealer.knockback_power
	$Knockback_timer.start(0.2 * damage_dealer.knockback_power)
	actual_speed = 0
