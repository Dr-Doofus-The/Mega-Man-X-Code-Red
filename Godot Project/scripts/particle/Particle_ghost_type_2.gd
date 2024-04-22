extends AnimatedSprite

var color_array = []
var color_index = 0
var tracking : AnimatedSprite

func _ready():
	_on_Timer_timeout()
	
	if tracking:
		frames = tracking.frames

func _process(_delta):
	if tracking:
		animation = tracking.animation
		frame = tracking.frame
		rotation_degrees = tracking.rotation_degrees

func _on_Timer_timeout():
	if color_index == color_array.size():
	
		queue_free()
	else:
		modulate = color_array[color_index]
		modulate.a -= (0.1 * color_index) + 0.5
		#scale += Vector2(0.04,0.04)
		#get_material().set_shader_param("brightness", get_material().get_shader_param("brightness") - 1)
		color_index += 1
