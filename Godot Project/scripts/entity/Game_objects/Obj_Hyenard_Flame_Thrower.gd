extends Node2D
tool

export (int) var fire_amount = 1 setget set_fireamount, get_fireamount
export (float) var fire_life = 0.2
export (float) var rotation_speed = 0.0
export (bool) var on : bool = true
export (float) var on_time : float = 0.0
export (float) var off_time : float = 0.0
export (Vector2) var offset_vec : Vector2 = Vector2.ZERO
export (float) var offset_time : float = 0.0
export (float) var start_offset : float = 0.0


var rot_array = []
onready var tw = $Tween

var start_pos
var destination

func _ready():
	if not Engine.is_editor_hint():
		calculate_rotations()
		if off_time != 0:
			if start_offset > 0:

				yield(get_tree().create_timer(start_offset,true),"timeout")
			$On_off_timer.start(on_time)
		if offset_vec != Vector2.ZERO:
			start_pos = global_position
			destination = global_position + offset_vec
			_on_Tween_tween_all_completed()

func _physics_process(delta):
	if Engine.is_editor_hint():
		if $Line2D.points.size() <= 2:
			$Line2D.points[1] = offset_vec
	else:
			
		rotate(delta * rotation_speed)
		
		if Engine.get_physics_frames()%5 == 0 and $VisibilityNotifier2D.is_on_screen() and on:
			
			
			for n in fire_amount:
				var rot = deg2rad((self.rotation_degrees + rot_array[n]) + 90)
				var fire : Projectile = Assets.PROJ_ENE_FLAMETHROWER.instance()
				fire.rotation = rot - 1.57
				fire.global_position = self.global_position - Vector2(0,16).rotated(rot)
				fire.lifetime = fire_life

				Global.ViewPort.add_child(fire)

func set_fireamount(value):
	fire_amount = value
	calculate_rotations()
	
func get_fireamount():
	return fire_amount

func calculate_rotations():
	rot_array.clear()
	for n in fire_amount:
		rot_array.append(float((((360/fire_amount) * n) - 90)))


func _on_On_off_timer_timeout():
	if on:
		on = false
		$On_off_timer.start(off_time)
	else:
		on = true
		$On_off_timer.start(on_time)


func _on_Tween_tween_all_completed():

	if destination == global_position:
		tw.interpolate_property(self,"global_position",destination,start_pos,offset_time)
		tw.start()
	else:
		tw.interpolate_property(self,"global_position",start_pos,destination,offset_time)
		tw.start()
