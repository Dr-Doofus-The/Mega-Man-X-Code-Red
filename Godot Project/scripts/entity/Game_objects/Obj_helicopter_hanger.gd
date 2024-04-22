extends KinematicBody2D

onready var zipline = $obj_zipline

onready var state = 0

var velocity : Vector2 = Vector2.ZERO
var og_pos : Vector2 = position

export (float) var y_force = 200.0

func _ready():
	og_pos = position
	EventBus.connect("PlayerSpawned",self,"reset_pos")

func _physics_process(delta):
	

	
	if zipline.is_player_grabbing():
		
		if Global.Player.dir == 0:
			decelerate()
		else:
			velocity.x += Global.Player.dir * 8
			velocity.x = clamp(velocity.x, -4600,4600)
		#velocity.x = clamp(velocity.x, -4600,4600)
		
		match state:
			0:
				state = 1
				var tw = create_tween()
				tw.set_ease(Tween.EASE_IN_OUT)
				tw.set_trans(Tween.TRANS_EXPO)
				tw.tween_property(self,"velocity:y",float(40),y_force/2000)
				tw.tween_property(self,"velocity:y",float(-y_force),0.5)
				yield(tw,"finished")
				state = 2
			2:
				if Global.Player.dirY != 0:
					var mult_power = Global.Player.dirY + 3.0 if velocity.y > 0 else Global.Player.dirY + 1.8
					velocity.y += (2 + (mult_power))
					velocity.y = clamp(velocity.y,-y_force,50 + (40*mult_power))
				else:
					velocity.y += 3
					velocity.y = clamp(velocity.y,-y_force,50)
	elif state != 0:
		velocity.y += 2
		velocity.y = clamp(velocity.y,-y_force,50)
	
	decelerate()
	if is_on_floor():
		_on_VisibilityNotifier2D_screen_exited()
	velocity = velocity * (delta*60)
	move_and_slide(velocity,Vector2.UP)
	


func decelerate():
	velocity.x *= 0.95


func _on_VisibilityNotifier2D_screen_exited():
	if state != 0 and !zipline.is_player_grabbing():
		state = 0
		velocity = Vector2.ZERO
		position = og_pos

func reset_pos():
	state = 0
	velocity = Vector2.ZERO
	position = og_pos
