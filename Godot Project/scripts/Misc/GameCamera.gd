extends Camera2D
class_name game_cam

onready var tween = $Tween
onready var shake_timer = Timer.new()
onready var shake_duration = Timer.new()


var Shake_Vec = Vector2.ZERO
var Offset_Vec = Vector2.ZERO

onready var target_right_limit : int = 0
onready var target_top_limit : int = 0
onready var target_left_limit : int = 0
onready var target_bottom_limit : int = 0

onready var limit_speed = 100

var current_bound = null

var velocity_offset_x : float = 0


func _ready():

	Global.GameCamera = self
	shake_timer.wait_time = 0.04
	shake_timer.one_shot = true
	shake_duration.one_shot = true
	add_child(shake_timer)
	add_child(shake_duration)
	shake_timer.connect("timeout",self,"_on_shake_timer_finish")
	Global.connect("Paused",self,"change_pause_mode")
	update_offset()


func _physics_process(delta):
	
	limit_speed += delta * 3.0

	
	if not tween.is_active():
		limit_bottom = int(move_toward(limit_bottom,target_bottom_limit,limit_speed))
		limit_left = int(move_toward(limit_left,target_left_limit,limit_speed))
		limit_top = int(move_toward(limit_top,target_top_limit,limit_speed))
		limit_right = int(move_toward(limit_right,target_right_limit,limit_speed))

func _process(_delta):
	if Global.Player != null:
		global_position = Global.Player.global_position + Offset_Vec


func camera_shake(Direction : int, amp : int, duration : float):
	match Direction:
		0:
			Shake_Vec.x = 0
			Shake_Vec.y = amp
			update_offset()
			shake_timer.start()
			shake_duration.start(duration)
		1:
			Shake_Vec.x = amp
			Shake_Vec.y = 0
			update_offset()
			shake_timer.start()
			shake_duration.start(duration)


func update_offset():
	offset = Shake_Vec

func slow_update(time, direction):
	pause_mode = Node.PAUSE_MODE_PROCESS
	

	limit_bottom = int(get_camera_screen_center().y + 120)
	limit_left = int(get_camera_screen_center().x - 160)
	limit_top = int(get_camera_screen_center().y - 120)
	limit_right = int(get_camera_screen_center().x + 160)
	
	
	
	match direction:
		1:
			tween.interpolate_property(self,"limit_bottom",limit_bottom,target_bottom_limit,time,Tween.TRANS_LINEAR)
			tween.interpolate_property(self,"limit_left",limit_left,target_left_limit,time,Tween.TRANS_LINEAR)
			tween.interpolate_property(self,"limit_top",limit_top,target_top_limit,time,Tween.TRANS_LINEAR)
			tween.interpolate_property(self,"limit_right",limit_right,target_left_limit + 320,time,Tween.TRANS_LINEAR)

		3:
			tween.interpolate_property(self,"limit_bottom",limit_bottom,target_bottom_limit,time,Tween.TRANS_LINEAR)
			tween.interpolate_property(self,"limit_left",limit_left,target_right_limit - 320,time,Tween.TRANS_LINEAR)
			tween.interpolate_property(self,"limit_top",limit_top,target_top_limit,time,Tween.TRANS_LINEAR)
			tween.interpolate_property(self,"limit_right",limit_right,target_right_limit,time,Tween.TRANS_LINEAR)

	tween.start()
	
	yield(tween,"tween_all_completed")
	
	pause_mode = Node.PAUSE_MODE_INHERIT
	limit_bottom = target_bottom_limit
	limit_left = target_left_limit
	limit_top = target_top_limit
	limit_right = target_right_limit
	
func _on_shake_timer_finish():
	if shake_duration.is_stopped():
		if Shake_Vec.y > 0:
			Shake_Vec.y -= 1
		elif Shake_Vec.y < 0:
			Shake_Vec.y += 1
		
		if Shake_Vec.x > 0:
			Shake_Vec.x -= 1
		elif Shake_Vec.x < 0:
			Shake_Vec.x += 1
	Shake_Vec = Shake_Vec * -1
	update_offset()
	if Shake_Vec != Vector2.ZERO:
		shake_timer.start()

func change_pause_mode():
	if not Global.isPaused:
		pause_mode = Node.PAUSE_MODE_STOP
	else:
		pause_mode =Node.PAUSE_MODE_PROCESS
