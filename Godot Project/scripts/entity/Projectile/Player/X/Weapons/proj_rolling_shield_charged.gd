extends "res://scripts/entity/ProjectileBase.gd"

onready var sound = preload("res://sound_assests/projectiles/snd_shield_activate.wav")


var shield_activating = true

func _ready():
	var _con_1 = $Hitbox.connect("damage_dealt",self,"on_damage_dealt")
	var _con_2 = Global.Player.connect("Damage_taken",self,"destroy_shield")
	
	var snd = SFX.new()
	snd.stream = sound
	snd.volume_db = 1
	Global.ViewPort.add_child(snd)
	
	Global.Player.current_state = Global.Player.state.ANIMATION
	Global.Player.ent_sprite.play("Special_attack_1")
	Global.Player.gravity_affected = false
	Global.Player.velocity = Vector2.ZERO
	Global.Player.dir = 0
	Global.Player.x_velocity = 0
	Global.Player.x_momentum_velocity = 0
	Global.Player.invulnerable = true
	$Timer.start();yield($Timer,"timeout")
	shield_activating = false
	Global.Player.gravity_affected = true
	Global.Player.current_state = Global.Player.state.IDLE if Global.Player.is_on_floor() else Global.Player.state.FALLING
	
	
func _physics_process(delta):
	global_position = Global.Player.global_position
	#Global.Player.invulnerable = true
	

	var color_val = sin(Global.time * 60) / 3 + 1.2
	sprite.self_modulate = Color(color_val,color_val,color_val)

func on_damage_dealt(_old,_new,target):
	if target.hp_max >= 12:
		destroy_shield(1,2)
	
func destroy_shield(_1,_2):
	Global.Player.invulnerable = false
	if shield_activating:
		Global.Player.gravity_affected = true
		Global.Player.current_state = Global.Player.state.IDLE if Global.Player.is_on_floor() else Global.Player.state.FALLING

	queue_free()
	
func _on_Area2D_tree_exiting():
	destroy_shield(1,2)


func _on_Area2D_area_entered(area):
	if not area.is_in_group("Hitbox"):

		area.queue_free()


func _on_Area2D_body_entered(body):
	if not body.is_in_group("Hitbox"):

		body.queue_free()
