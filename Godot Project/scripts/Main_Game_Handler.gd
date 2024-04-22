extends Control

onready var viewport_container = $ViewportContainer

var current_pixel_scale = 1.0

func _ready():
	var _screen_resize_signal = get_tree().connect("screen_resized",self,"update_viewport")
	var _settings_changed = EventBus.connect("SettingsChanged",self,"on_settings_change")

func update_viewport():
	var window_size = OS.get_window_size()
	
	var scale_x = window_size.x / viewport_container.rect_size.x
	var scale_y = window_size.y / viewport_container.rect_size.y

	var scale = min(scale_x,scale_y)
	
	viewport_container.rect_scale = Vector2.ONE * scale
	viewport_container.rect_pivot_offset = viewport_container.rect_size / 2.0

	_update_pixel_scale(_calculate_pixel_scale(Vector2(scale_x,scale_y)))

func _calculate_pixel_scale(scale):
	var pixel_scale = floor(min(scale.x, scale.y))
	if pixel_scale == 0.0:
		return 1.0

	return pixel_scale

func _update_pixel_scale(new_pixel_scale):
	if current_pixel_scale != new_pixel_scale:
		current_pixel_scale = new_pixel_scale
		viewport_container.material.set_shader_param("pixel_scale", new_pixel_scale)

func on_settings_change():
	$ViewportContainer/Filter.visible = Settings.options["video"]["Filter"]
	$Border.visible = Settings.options["video"]["Border"]
