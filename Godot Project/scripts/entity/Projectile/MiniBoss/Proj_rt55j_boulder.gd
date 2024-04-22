extends "res://scripts/entity/EntityBase.gd"

onready var direction
var holder
var x_move

onready var big_rock_exp = preload("res://nodes/particles/mini_boss/par_rt55j_big_rock_explosion.tscn")

func _ready():
	snap = false

func _physics_process(delta):
	if holder:
		global_position = holder.global_position
		gravityenabled = false
	else:
		if is_on_wall():
			direction = direction * -1
			x_move = x_move * -1
			Global.GameCamera.camera_shake(1,1,0.2)
		x_move = clamp(x_move, -170, 170)
		velocity.x = x_move
		if is_on_floor():
			velocity.y = -470 * (delta * 60)
			Global.GameCamera.camera_shake(0,1,0.2)
		ent_sprite.rotate(x_move/7000)



		
		move()
		
func throw():
	holder = null
	gravityenabled = true
	position.x += 60 * -direction
	velocity.y = -470
	x_move = 150 * -direction
	turn_off_collision_box(false)

func _on_EntityBase_Damage_taken(_ki_frame, damage_dealer):
	x_move += (global_position.x - damage_dealer.global_position.x) * (damage_dealer.knockback_power * 2.5)

	
	if hp == 0:
		queue_free()


func _on_EntityBase_Rock_tree_exiting():
	var fx = big_rock_exp.instance()
	fx.global_position = self.global_position
	Global.ViewPort.get_child(0).call_deferred("add_child",fx)
