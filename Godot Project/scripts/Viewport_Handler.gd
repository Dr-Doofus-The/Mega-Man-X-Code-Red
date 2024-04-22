extends ViewportContainer


onready var RESOLUTION = $Viewport.size
onready var ASPECT_RATIO = RESOLUTION.x / RESOLUTION.y

var current_pixel_scale = 1.0

func _ready():
	
	
	_update_view()
	var _con = get_tree().get_root().connect("size_changed", self, "_on_window_resized")

func _on_window_resized():
	_update_view()

func _update_view():

	var window_size = OS.window_size
	var window_aspect_radio = window_size.x / window_size.y

	var target_position
	var width
	var height
	if window_aspect_radio < ASPECT_RATIO:
		width = window_size.x
		height = width / ASPECT_RATIO
		target_position = Vector2(0, (window_size.y - height)/2)
	else:
		height = window_size.y
		width = height * ASPECT_RATIO
		target_position = Vector2((window_size.x - width)/2, 0)

	var target_size = Vector2(width, height)
	var target_scale = target_size / RESOLUTION

	rect_position = target_position
	#rect_size = target_size
	#rect_scale = target_scale
	_update_pixel_scale(_calculate_pixel_scale(target_scale))

	#visible = false
	#visible = true

func _calculate_pixel_scale(scale):
	var pixel_scale = floor(min(scale.x, scale.y))
	if pixel_scale == 0.0:
		return 1.0

	return pixel_scale

func _update_pixel_scale(new_pixel_scale):
	if current_pixel_scale != new_pixel_scale:
		current_pixel_scale = new_pixel_scale
		material.set_shader_param("pixel_scale", new_pixel_scale)

