tool
extends Resource

var char_utils := preload("../Util/CharUtils.gd").new()

export var source_texture: Texture
export var scaled_texture: Texture

func set_texture(new_texture):
	source_texture = new_texture
	scaled_texture = get_scaled_texture()
func get_texture():
	return scaled_texture


export var rect_size: Vector2
export var rect_gap: Vector2
export var texture_offset: Vector2
export var scale := 1 setget set_scale, get_scale
func set_scale(new_scale):
	scale = new_scale
	scaled_texture = get_scaled_texture()
func get_scale():
	return scale
	
export var interpolation := Image.INTERPOLATE_NEAREST setget set_interpolation, get_interpolation
func set_interpolation(new_in):
	interpolation = new_in
	scaled_texture = get_scaled_texture()
func get_interpolation():
	return interpolation

export var chars: String setget set_chars, get_chars
func set_chars(new_chars):
	chars = new_chars
	char_codes = char_utils.chars_to_codes(new_chars)
func get_chars():
	return chars

# 2d Array containing int char codes
var char_codes: Array


func get_scaled_texture() -> Texture:
	if scale == 1:
		return source_texture
	
	var size := source_texture.get_size()
	var flags := source_texture.flags
	
	var scaled = size * scale
	
	if scaled.x > 16384 or scaled.y > 16384:
		push_error("Could not Upscale Texture! Texture too large")
		return source_texture
	
	var img := source_texture.get_data()
	img.resize(scaled.x, scaled.y, interpolation)
	var tex = ImageTexture.new()
	tex.create_from_image(img, flags)
	
	return tex


func get_char_width(char_code: int) -> int:
	if char_codes.find(char_code) == -1:
		return -1
	
	var rect = get_char_rect(char_code)
	return rect.size.x


func get_char_pos(char_code: int):
	for i in char_codes.size():
		var line = char_codes[i]
		var pos = line.find(char_code)
		if pos == -1:
			continue
		else:
			return Vector2(pos, i)
	
	return null


func _get_char_rect_unscaled(char_code: int):
	var pos: Vector2 = get_char_pos(char_code)
	if pos == null:
		return null
	
	var rect := Rect2(
		(rect_size + rect_gap) * pos + texture_offset,
		rect_size
	)
	
	var texture_size := source_texture.get_size()
	if rect.end.x > texture_size.x or rect.end.y > texture_size.y:
		return null
	
	return rect


func get_char_rect(char_code: int):
	var rect = _get_char_rect_unscaled(char_code)
	if rect == null:
		return null
	
	rect.position *= scale
	rect.size *= scale
	
	return rect


func get_cropped_char_rect(char_code: int):
	var rect = _get_char_rect_unscaled(char_code)
	if rect == null:
		return null
	
	var empty_left := _scan_empty_pixels(
		rect.position.x, rect.position.x + rect.size.x,
		rect.position.y, rect.position.y + rect.size.y)
	
	rect.position.x += empty_left
	rect.size.x -= empty_left
	
	if rect.size.x == 0:
		return rect
	
	var empty_right := _scan_empty_pixels(
		rect.position.x + rect.size.x - 1, rect.position.x - 1,
		rect.position.y, rect.position.y + rect.size.y)
	
	rect.size.x -= empty_right
	
	rect.position *= scale
	rect.size *= scale
	
	return rect


# returns number of empty collumns
func _scan_empty_pixels(from_x: int, to_x: int, from_y: int, to_y: int) -> int:
	var img_data := source_texture.get_data()
	img_data.lock()
	var c = 0
	
	var dir = 1
	if from_x > to_x:
		dir = -1
	
	for x in range(from_x, to_x, dir):
		for y in range(from_y, to_y):
			var pix := img_data.get_pixel(x, y)
			if pix.a != 0.0:
				return c
		c += 1
	img_data.unlock()
	
	return c


func get_local_position(position: Vector2) -> Vector2:
	var pos = ((position - texture_offset * scale) / ((rect_size + rect_gap) * scale)).floor()
	return pos


func get_char_at_position(position: Vector2) -> String:
	var tex_size = scaled_texture.get_size()
	if position.x < 0.0 or position.y < 0.0 or position.x > tex_size.x or position.y > tex_size.y:
		return ""
	
	var pos = get_local_position(position)
	
	if pos.y >= char_codes.size() or pos.y < 0:
		return ""
	
	var line: Array = char_codes[pos.y]
	
	if pos.x >= line.size() or pos.x < 0:
		return ""
	
	return char(line[pos.x])

func get_rect_for_position(position: Vector2):
	var tex_size = scaled_texture.get_size()
	if position.x < 0.0 or position.y < 0.0 or position.x > tex_size.x or position.y > tex_size.y:
		return null
	
	var pos = get_local_position(position)
	return Rect2(
		((rect_size + rect_gap) * pos + texture_offset) * scale,
		rect_size * scale
	)
