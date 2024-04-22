extends "res://scripts/entity/EntityBase.gd"

var ticking = false
var respawnable = true
var landed = true

var exploded = false

onready var exp_fx = preload("res://nodes/particles/robot_part_explosion/par_mammoth_explosivebox_parts_exp.tscn")

func _ready():
	$Timer.wait_time = 0.5
	var _con = EventBus.connect("PlayerSpawned",self,"respawn")

func _physics_process(_delta):
	if gravityenabled:

		move()
		if not is_on_floor():
			landed = false
		else:
			if not landed:
				landed = true
				if not Sound.SND_OBJ_BOX_FALL.is_playing():
					Sound.play_sound(Sound.SND_OBJ_BOX_FALL,-2,1)



func _on_Obj_Explosive_Box_Damage_taken(_i_frame, damage_dealer):
	if !exploded:
		if hp != 0:
			start_countdown()
		elif (hp_max - damage_dealer.damage) < 0:
			$Timer.stop()
			$Timer.wait_time = 0.05
			_on_Timer_timeout()
		
		else:
			$Timer.stop()
			$Timer.wait_time = 0.1
			start_countdown()



func _on_Area2D_body_entered(body):
	if body == Global.Player and !exploded:
		start_countdown()

func start_countdown():
	flash()
	ent_sprite.playing = true
	if $Timer.is_stopped():
		$Timer.start()
		$Yield_timer.start($Timer.wait_time - 0.05); yield($Yield_timer,"timeout")
		flash()

func flash():

	ent_sprite.modulate = Color(20,20,20)
	yield(get_tree().create_timer(0.05),"timeout")
	ent_sprite.modulate = Color(1,1,1)

func _on_Timer_timeout():
	if exploded == false:
		exploded = true
		var fx = Assets.PAR_EXPLOSION_STANDARD.instance()
		spawn_part_effect()
		fx.global_position = Vector2(global_position.x, global_position.y + 2)
		Global.ViewPort.call_deferred("add_child",fx)
		$Hitbox/CollisionShape2D.set_deferred("disabled", false)
		$Hurtbox/CollisionShape2D.set_deferred("disabled", true)
		$KinematicBody2D/CollisionShape2D.set_deferred("disabled", true)
		ent_sprite.visible = false
		collshape.set_deferred("disabled", true)
		$Hitbox_timer.start()
		Global.GameCamera.camera_shake(0,2,0.3)
		Sound.play_standard_explosion_sound()
		ent_sprite.playing = false
		gravityenabled = false


func _on_Hitbox_timer_timeout():
	$Hitbox/CollisionShape2D.set_deferred("disabled", true)
	if respawnable == false:
		queue_free()

func respawn():
	$Hitbox/CollisionShape2D.set_deferred("disabled", true)
	$Hurtbox/CollisionShape2D.set_deferred("disabled", false)
	$KinematicBody2D/CollisionShape2D.set_deferred("disabled", false)
	exploded = false
	ent_sprite.visible = true
	collshape.set_deferred("disabled", false)
	ent_sprite.playing = false
	ent_sprite.frame = 0
	$Timer.stop()
	$Hitbox_timer.stop()
	$Timer.wait_time = 0.5
	hp = hp_max

func _on_Sprite_frame_changed():
	match ent_sprite.frame:
		1:
			Global.SoundBank.SND_OBJ_EXPBOX_BEEP.play()


func spawn_part_effect():
	var fx = exp_fx.instance()
	fx.global_position = global_position
	Global.ViewPort.call_deferred("add_child",fx)
