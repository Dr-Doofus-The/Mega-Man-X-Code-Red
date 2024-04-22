extends KinematicBody2D

var velocity := Vector2.ZERO
var BulletDire : int

func _ready():
	var DirY = Input.get_action_strength("down") - Input.get_action_strength("up")
	velocity.y = (-4.4 + (DirY)) * 90
	velocity.x = ((2.2 + (DirY)) * 80) * BulletDire

func _physics_process(delta):
	velocity.y += delta * Global.Gravity
	if is_on_floor():
		spawn()
	if is_on_ceiling():
		spawn(true)
	if is_on_wall():
		velocity.x *= -0.5
		Sound.play_sound(Sound.SND_HIT_SHIELD,0,1)
	$Sprite.rotation = velocity.angle()
	move_and_slide(velocity,Vector2.UP)

func spawn(up : bool = false):
	var space_state = get_world_2d().direct_space_state
	var pos_y = 12 if !up else -1
	var result_pos = space_state.intersect_ray(global_position, Vector2(global_position.x,global_position.y + pos_y),[self],collision_mask)

	if result_pos.has("position"):
		var proj = Assets.PROJ_ARTILLERY_EXPLOSION.instance()
		proj.global_position = result_pos.position
		proj.upside = up
		get_parent().add_child(proj)

	else:

		var proj = Assets.PROJ_ARTILLERY_EXPLOSION.instance()
		proj.global_position = self.global_position
		proj.upside = up
		get_parent().add_child(proj)

	queue_free()


func _on_Hitbox_damage_dealt(old_hp, new_hp, target):
	var HITBOX = hitbox.new()
	
	HITBOX.temporary = true
	HITBOX.time = 0.2
	HITBOX.size = Vector2.ONE * 20
	HITBOX.damage = 5
	HITBOX.set_collision_mask_bit(2, true)
	HITBOX.global_position = global_position
	Global.ViewPort.add_child(HITBOX)
	
	Sound.play_standard_explosion_sound()
	
	var exp_a = Assets.PAR_EXPLOSION_STANDARD.instance()
	exp_a.global_position = global_position
	Global.ViewPort.add_child(exp_a)
	
	queue_free()
