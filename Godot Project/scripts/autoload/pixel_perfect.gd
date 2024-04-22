extends Node

"""
An autoload singleton for pixel perfect rendering of the game.
Set this script as an autoload.
`base_size` - Is the target size of the viewport. The viewport will scale up to fit the largest
possible integer multiple of this size within the window.
`expand` - If true the viewport will expand to the edges of the window after scaling up.
Otherwise the empty space outside of the viewport will be filled with black bars.
`pixel_perfect` - If false the viewport will still scale up, but not render pixel perfectly.
`pixel_aspect` - Used to stretch pixels to a non-square size.
Notes
----
The commented out code for black bar texture will let you set the texture of the black bars.
This is a work around until black bars can be easily edited in a project.
"""

onready var _root : Viewport = get_tree().root

# const black_bar_texture = preload("res://black_bars.png")

var base_size : = Vector2(640, 360) setget set_base_size
var expand : = false setget set_expand
var pixel_perfect : = true setget set_pixel_perfect
var pixel_aspect : = Vector2(1, 1) setget set_pixel_aspect


func _ready() -> void:
	get_tree().connect("screen_resized", self, "_on_screen_resized")
	
#	var t_id = black_bar_texture.get_rid()
#	VisualServer.black_bars_set_images(t_id, t_id, t_id, t_id)
	
	_on_screen_resized()


func set_base_size(value : Vector2) -> void:
	base_size = value.floor()
	_on_screen_resized()


func set_expand(value : bool) -> void:
	expand = value
	_on_screen_resized()


func set_pixel_perfect(value : bool) -> void:
	pixel_perfect = value
	_on_screen_resized()


func set_pixel_aspect(value : Vector2) -> void:
	pixel_aspect = value
	_on_screen_resized()


func _on_screen_resized() -> void:
	var new_window_size : = OS.window_size
	
	var total_base_size : Vector2 = base_size * pixel_aspect
	
	var scale_width : = max(1, new_window_size.x / total_base_size.x)
	var scale_height : = max(1, new_window_size.y / total_base_size.y)
	var scale : = min(scale_width, scale_height) as int
	
	var size : Vector2 = new_window_size / scale if expand else total_base_size
	size = size.floor()
	
	var offset : Vector2 = (new_window_size - size * scale) * 0.5
	offset = offset.floor()
	
	if pixel_perfect:
		_root.size = size / pixel_aspect
		_root.set_attach_to_screen_rect(Rect2(offset, size * scale))
		_root.set_size_override(false)
		_root.set_size_override_stretch(false)
		
	else:
		_root.size = (size * scale) / pixel_aspect
		_root.set_attach_to_screen_rect(Rect2(offset, size * scale))
		_root.set_size_override(true, size / pixel_aspect)
		_root.set_size_override_stretch(true)
	
	offset.x = max(0, offset.x)
	offset.y = max(0, offset.y)
	
	VisualServer.black_bars_set_margins(
			offset.x as int,
			offset.y as int,
			new_window_size.x as int - (offset.x + size.x * scale) as int,
			new_window_size.y as int - (offset.y + size.y * scale) as int
	)
