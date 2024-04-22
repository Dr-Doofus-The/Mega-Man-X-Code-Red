extends Node2D

var exp_range : int = 2
var upside := false

var stopped = [false,false]

func _ready():
	spawn_explosion(0)

func spawn_explosion(direction : int):
	var space_state = get_world_2d().direct_space_state
	
	var pos = direction * 16
	
	var pos_y = -10 if upside else 2
	
	var result = space_state.intersect_ray(global_position + Vector2(pos,0), global_position + Vector2(pos,pos_y),[self],1)
	
	if direction > 0:
		$Checker_left.position.x -= pos * direction
	else:
		$Checker_right.position.x += pos * direction
	if result :

		var proj = Assets.PROJ_EXP_TOWER.instance()
		proj.global_position = result.position
		Sound.play_standard_explosion_sound()
		if upside:
			proj.scale.y = -1
		Global.ViewPort.add_child(proj)
		$Timer.start(0.1);yield($Timer,"timeout")
		wait_and_spawn_anodda(direction)
	
	elif direction == 0:
		var proj = Assets.PROJ_EXP_TOWER.instance()
		proj.global_position = global_position
		Sound.play_standard_explosion_sound()
		if upside:
			proj.scale.y = -1
		Global.ViewPort.add_child(proj)
		$Timer.start(0.1);yield($Timer,"timeout")
		wait_and_spawn_anodda(direction)
	
	else:
		if direction < 0:
			stopped[0] = true
		else:
			stopped[1] = true
		
func wait_and_spawn_anodda(direction):


	if direction == 0:
			
		if !($Checker_left.get_overlapping_bodies().size() + $Checker_right.get_overlapping_bodies().size()) > 1:
			
			if !$Checker_left.get_overlapping_bodies().size() > 0:
				spawn_explosion(-1)

			if !$Checker_right.get_overlapping_bodies().size() > 0:
				spawn_explosion(1)
		else:

			queue_free()
	else:
		if abs(direction) >= exp_range:
			queue_free()
		
		if direction < 0:
			if !$Checker_left.get_overlapping_bodies().size() > 0:
				spawn_explosion(direction + sign(direction))
			else:
				stopped[0] = true
		elif direction > 0:
			if !$Checker_right.get_overlapping_bodies().size() > 0:
				spawn_explosion(direction + sign(direction))
			else:
				stopped[1] = true

		if not false in stopped:

			queue_free()
