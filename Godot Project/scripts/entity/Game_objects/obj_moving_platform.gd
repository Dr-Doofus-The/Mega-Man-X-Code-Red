extends KinematicBody2D

export (String) var Platform_Name


onready var og_pos = position
onready var relative_pos : Vector2 = Vector2.ZERO

onready var visibility_notifier = $VisibilityNotifier2D

var parent

var vis_rect : Rect2 

var time_offset = rand_range(-2,2)
var paused = false

func _ready():
	visible = true
	parent = get_parent()
	if !parent.is_class("ParallaxLayer"):
		visibility_notifier.connect("screen_entered",self,"vis_on")

		visibility_notifier.connect("screen_exited",self,"vis_off")
	else:
		$CollisionShape2D.queue_free()
		#match Platform_Name:
		#	"Airforce_Plane_1":
				#$AudioStreamPlayer2D.queue_free()
	
	vis_rect = visibility_notifier.rect


func vis_on():
	visible = true
	
func vis_off():
	visible = false

func _unhandled_input(event):
	if Input.is_key_pressed(KEY_KP_2):
		paused = false if paused else true

func _notification(what):
	if what == NOTIFICATION_TRANSFORM_CHANGED and paused:
		og_pos = position

func _physics_process(delta):
	
	if !paused:
		
		match Platform_Name:
			"Airforce_Plane_1":
				relative_pos.x = sin((Global.time + time_offset) * 4) * 4
				relative_pos.y = cos((Global.time + time_offset) * 2) * 3
				
				
		position = og_pos + (relative_pos * scale).round()

