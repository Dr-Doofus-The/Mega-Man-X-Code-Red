extends Area2D

#export (int) var new_top_limit
#export (int) var new_bottom_limit
#export (int) var new_left_limit
#export (int) var new_right_limit
export (float) var update_speed : int = 5
#export var offset : Vector2

onready var ref_rect : ReferenceRect = $ReferenceRect 

var can_update = true

func _ready():
	EventBus.connect("CharactersSwitched",self,"pause_can_update")

func _update_camera_limits(instant):

	if !instant:
		Global.GameCamera.limit_bottom = int(Global.GameCamera.get_camera_screen_center().y - Global.GameCamera.offset.y) + 120
		Global.GameCamera.limit_top = int(Global.GameCamera.get_camera_screen_center().y - Global.GameCamera.offset.y) - 120
		Global.GameCamera.limit_left = int(Global.GameCamera.get_camera_screen_center().x) - 160
		Global.GameCamera.limit_right = int(Global.GameCamera.get_camera_screen_center().x) + 160
		#pass
	else:
		Global.GameCamera.limit_bottom = ref_rect.margin_bottom
		Global.GameCamera.limit_top = ref_rect.margin_top
		Global.GameCamera.limit_left = ref_rect.margin_left
		Global.GameCamera.limit_right = ref_rect.margin_right
		
	Global.GameCamera.limit_speed = update_speed
		
	Global.GameCamera.target_bottom_limit = ref_rect.margin_bottom
	Global.GameCamera.target_top_limit = ref_rect.margin_top
	Global.GameCamera.target_left_limit = ref_rect.margin_left
	Global.GameCamera.target_right_limit = ref_rect.margin_right
	
	
#	Global.GameCamera.Offset_Vec = offset
	Global.GameCamera.current_bound = self
	
func pause_can_update():
	can_update = false
	yield(get_tree().create_timer(0.05,false),"timeout")
	can_update = true

func _on_Camera_Bounds_body_entered(body):
	if can_update and body == Global.Player and Global.GameCamera.current_bound != self and not [Global.Player.state.DYING,Global.Player.state.SPAWNING].has(Global.Player.current_state):
		_update_camera_limits(false)
