extends AnimatedSprite
class_name ParticleSprite

export (bool) var oneshot : bool = true
export (float) var y_movement : float = -0.5
export (float) var x_movement : float = 0.0
export (float) var life_time : float = 0.0
export (float) var deceleration_value : float = 0.0
export (float) var x_sine_movement : float = 0.0
export (float) var x_sine_time_multiplier : float = 0.0
export (float) var y_sine_movement : float = 0.0
export (float) var y_sine_time_multiplier : float = 0.0
export (bool) var random_start_frame : bool = false
export (float) var gravity : float = 0
export (bool) var flicker : bool = false

var play_animation = true
var start_on_frame_0 = true



func _ready():
	var _con = EventBus.connect("PlayerSpawned",self,"delete")
	
	if life_time > 0.0:
		var timer = Timer.new()
		timer.wait_time = life_time
		timer.pause_mode =Node.PAUSE_MODE_STOP
		timer.connect("timeout",self,"delete")
		add_child(timer)
		timer.start()
		
	
	if start_on_frame_0:
		frame = 0
	playing = play_animation
	
	var sprite_texture : Texture = self.get_sprite_frames().get_frame(animation,get_frame())

	if sprite_texture:
		$VisibilityNotifier2D.rect.size = Vector2(sprite_texture.get_size().x,sprite_texture.get_size().y)
		$VisibilityNotifier2D.rect.position = Vector2($VisibilityNotifier2D.rect.size.x / 2, $VisibilityNotifier2D.rect.size.y / 2)



	if random_start_frame:
		frame = int(rand_range(0, self.get_sprite_frames().get_frame_count(animation)))
	

func _physics_process(delta):

	
	if flicker and Engine.get_physics_frames() % 2 == 0:
		visible = true if visible == false else false
	
	
	if gravity != 0.0:
		y_movement += gravity * delta
	
	if deceleration_value != 0.0:
		x_movement = move_toward(x_movement,0,(delta * 60) * deceleration_value)
		y_movement = move_toward(y_movement,0,(delta * 60) * deceleration_value)
	
	global_position.y += y_movement * (delta * 66) + (sin(Global.time * y_sine_time_multiplier) * y_sine_movement)
	global_position.x += x_movement * (delta * 66) + (sin(Global.time * x_sine_time_multiplier) * x_sine_movement)

func _on_ParticleBase_animation_finished():
	if oneshot == true:
		queue_free()


func _on_VisibilityNotifier2D_screen_exited():
	call_deferred("queue_free")

func delete():
	queue_free()

func _on_ParticleBase_tree_exiting():

	queue_free()
