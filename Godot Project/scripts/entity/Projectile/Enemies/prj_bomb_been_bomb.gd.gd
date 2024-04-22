extends KinematicBody2D

var bomb_direction = 1
var Hspeed = 100

var landed = false

var velocity:Vector2 = Vector2.ZERO

onready var rotation_tween = $Tween


func _ready():
	var start_rotation = -bomb_direction * 90
	rotation_tween.interpolate_property($AnimatedSprite, "rotation_degrees", start_rotation, 0, 0.5,Tween.TRANS_QUAD,Tween.EASE_OUT)
	rotation_tween.start()
	velocity.x = Hspeed * bomb_direction

func _physics_process(delta):
	if not is_on_floor():
		velocity.y += 10 * (delta * 66)
		velocity.x = lerp(velocity.x, 0, 0.02)
	else:
		velocity.y = 0
		velocity.x = 0
	if not landed and is_on_floor():
		start_bomb()
		landed = true
		
	
	velocity = move_and_slide(velocity,Vector2.UP)

func start_bomb():
	$AnimatedSprite.playing = true
	yield($AnimatedSprite,"animation_finished")
	$AnimatedSprite.play("Blink")
	$Yield_timer.start(0.4);yield($Yield_timer,"timeout")
	if is_inside_tree():
		$AnimatedSprite.speed_scale = 2
	$Yield_timer.start(0.4);yield($Yield_timer,"timeout")
	if is_inside_tree():
		explode()


func explode():
	var explosion_effect = Assets.PAR_EXPLOSION_STANDARD.instance()
	explosion_effect.global_position = self.global_position
	Global.ViewPort.add_child(explosion_effect)
	$Hitbox.set_deferred("monitorable", true)
	Global.SoundBank.play_standard_explosion_sound()

	$Yield_timer.start(0.1);yield($Yield_timer,"timeout")
	if is_inside_tree():
		queue_free()
func _on_Area2D_body_entered(body):
	if body == Global.Player:
		explode()
