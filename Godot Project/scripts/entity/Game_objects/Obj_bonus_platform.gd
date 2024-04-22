extends StaticBody2D

var off_palette = preload("res://sprites/GameObjects/Universal/spr_gobj_checkpoint_palette_off.png")
var on_palette = preload("res://sprites/GameObjects/Universal/spr_gobj_checkpoint_palette_x.png")

export var bonus_room : NodePath
var active = true
onready var bonus = get_node(bonus_room)

export var self_camera_bounds : NodePath
onready var cam_bounds = get_node(self_camera_bounds)
func _ready():
	pass


func _on_Area2D_body_entered(body):
	if active:
		deactive_platform()
		Global.bonus_platform = self
		Global.Player.HasControl = false
		Global.Player.dir = 0
		Global.Player.DashTimer.stop()
		
		if Global.Player.global_position.x != global_position.x:
			Global.Player.walk_to_point(global_position.x)
			yield(EventBus,"PlayerWalkToDone")
		Global.Player.dir = 0
		Global.Player.current_state = player_character.state.ANIMATION
		Global.Player.animplayer.play("Teleport_Out")
		Sound.SND_PL_TELEPORT_OUT.play()
		MusicPlayer.fade_music(false,1)
		yield(Global.Player.animplayer,"animation_finished")
		Global.teleport_player(bonus.spawn_point.global_position,bonus.camera_bounds)
		yield(get_tree().create_timer(0.1),"timeout")
		bonus.start_bonus()

func deactive_platform():
	
	$AnimatedSprite.play("deactive")
	Global.bonus_platform = null
	active = false
	$AnimatedSprite.get_material().set_shader_param("palette",off_palette)


func _on_Timer_timeout():
	active = true
	$AnimatedSprite.get_material().set_shader_param("palette",on_palette)
	$AnimatedSprite.play("active")
