extends KinematicBody2D

var falling = false

var velocity = Vector2.ZERO
var sound = SFX.new()

func _ready():
	sound.stream = $AudioStreamPlayer.stream

func _physics_process(delta):
	if falling:
		velocity.y = lerp(velocity.y, 2000, delta)
		if is_on_floor():
			Global.GameCamera.camera_shake(0, 2, 0.4)
			Global.ViewPort.add_child(sound)
			queue_free()
	elif !Global.Player == null:
		global_position.x = Global.Player.global_position.x
	velocity = move_and_slide(velocity,Vector2.UP)

func _on_AnimationPlayer_animation_finished(_anim_name):
	falling = true
