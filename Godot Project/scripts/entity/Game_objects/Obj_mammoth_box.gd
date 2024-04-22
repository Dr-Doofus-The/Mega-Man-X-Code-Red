extends "res://scripts/entity/EntityBase.gd"

onready var exp_fx = preload("res://nodes/particles/robot_part_explosion/par_mammoth_box_parts_exp.tscn")

export (bool) var respawnable = true
var landed = true

func _ready():
	snap = false
	round_position()


func _physics_process(_delta):
	
	if not is_on_floor():
		landed = false
	else:
		if not landed:
			landed = true
			if not Sound.SND_OBJ_BOX_FALL.is_playing():
				Sound.play_sound(Sound.SND_OBJ_BOX_FALL,-3,1)
				Global.GameCamera.camera_shake(0,1,0.02)
	
	velocity.x = 0
	#position += velocity

	move()



func _on_Entity_Mammoth_Box_Damage_taken(_i_frame, _damage_dealer):
	flash()
	if hp <= hp_max / 2:
		ent_sprite.frame = 1
	
	if hp == 0:
		queue_free()


func _on_Hitbox_damage_dealt(_old_hp, _new_hp, _target):
	queue_free()


func _on_Area2D_body_entered(body):
	queue_free()
func flash():
	var tween = create_tween().set_trans(Tween.TRANS_LINEAR)
	modulate = Color(4,4,4)
	tween.tween_property(self,"modulate",Color(1,1,1),0.05)

func _on_Entity_Mammoth_Box_tree_exiting():
	Sound.play_sound(Sound.SND_OBJ_BOX_FALL,-2,0.8)
	var fx = exp_fx.instance()
	fx.global_position = global_position
	Global.ViewPort.call_deferred("add_child",fx)
