extends Enemy_Class

var state = 0
var time_to_flies = int(rand_range(0,2))

func _ready():
	pass

func _physics_process(delta):
	match state:
		1:
			if velocity.y > 0:
				ent_sprite.play("Fall")
				state = 2
		2:
			if is_on_floor():
				state = 0
				velocity.x = 0
				ent_sprite.play("Land")

func pre_jump():
	update_dir()
	ent_sprite.play("Jump")

func jump():
	state = 1
	snap = false
	if global_position.y > Global.Player.global_position.y + 20:
		velocity.x = 130 * enemy_direction
		velocity.y = -370
	elif global_position.y < Global.Player.global_position.y - 20:
		velocity.x = 130 * enemy_direction
		velocity.y = -200
	else:
		velocity.x = 260 * enemy_direction
		velocity.y = -200

func pre_flies():
	update_dir()
	ent_sprite.play("Flies")
	
func spawn_flies():
	for n in 2:
		var par = Assets.PROJ_ENE_FLY.instance()
		par.global_position = global_position
		var rotation_offset = PI if enemy_direction == -1 else 0
		var rotation_base = 0.523599 if n == 0 else -0.523599
		par.rotation = rotation_base + rotation_offset
		Global.ViewPort.add_child(par)

func _on_reaction_time_timeout():
	pre_jump()


func _on_Sprite_animation_finished():
	match ent_sprite.animation:
		"Jump":
			jump()
		"Land":
			state = 0
			update_dir()
			if time_to_flies <= 0:
				pre_flies()
				time_to_flies = int(rand_range(1,2))
			else:
				if global_position.y < Global.Player.global_position.y - 20:
					$reaction_time.start(0.12)
				else:
					$reaction_time.start(0.3)
				time_to_flies -= 1
		"Flies":
			ent_sprite.play("!idle")
			$reaction_time.start(0.4)

func _on_Sprite_frame_changed():
	match ent_sprite.animation:
		"Flies":
			if ent_sprite.frame == 5:
				spawn_flies()
